import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:we_chat/controller/home_page_controller.dart';

import '../models/chat_user.dart';
import '../models/message.dart';

class ChatController extends GetxController {
  HomeScreenController controller = Get.find();
  Rx<File?> selectedImage = Rx<File?>(null);
  final textController = TextEditingController();
  void selectImage(File image) {
    selectedImage.value = image;
  }

  //HomeController controller = Get.put(HomeController());
  List<Message> list = [];
  RxBool isUploading = false.obs;
  RxBool showEmoji = false.obs;

   Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = controller.storage.ref().child(
        'images/${controller.getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

    //update read status of message
 Future<void> updateMessageReadStatus(Message message) async {
    controller.firestore
        .collection('chats/${controller.getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // for sending message
   Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: HomeScreenController.user.uid,
        sent: time);

    final ref = controller.firestore
        .collection('chats/${controller.getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }
  // for update message 
    Future<void> updateMessage(Message message, String updatedMsg) async {
    await controller.firestore
        .collection('chats/${controller.getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
  // for delete message
   Future<void> deleteMessage(Message message) async {
    await controller.firestore
        .collection('chats/${controller.getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await controller.storage.refFromURL(message.msg).delete();
    }
  }
  // for sending push notification
    Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": controller.me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        // "data": {
        //   "some_data": "User ID: ${me.id}",
        // },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAQ0Bf7ZA:APA91bGd5IN5v43yedFDo86WiSuyTERjmlr4tyekbw_YW6JrdLFblZcbHdgjDmogWLJ7VD65KGgVbETS0Px7LnKk8NdAz4Z-AsHRp9WoVfArA5cNpfMKcjh_MQI-z96XQk5oIDUwx8D1'
          },
          body: jsonEncode(body));
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
    } catch (e) {
      print('\nsendPushNotificationE: $e');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return controller.firestore
        .collection('chats/${controller.getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }
}
