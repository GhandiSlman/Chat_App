import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:we_chat/controller/home_controller.dart';
import 'package:we_chat/model/chat_user.dart';
import 'package:we_chat/model/message.dart';

class ChatController extends GetxController {
  // final textController = TextEditingController();
  Rx<File?> selectedImage = Rx<File?>(null);

  void selectImage(File image) {
    selectedImage.value = image;
  }

  //HomeController controller = Get.put(HomeController());
  List<Message> list = [];
  FirebaseAuth auth = FirebaseAuth.instance;
  User get user => auth.currentUser!;
  ChatUser? me;
  RxBool showEmoji = false.obs;
  RxBool isUploading = false.obs;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMeassages(ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  Future<void> sendMessage(ChatUser chatUser, String msg) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message = Message(
      toId: chatUser.id,
      msg: msg,
      read: '',
      type: '',
      fromId: user.uid,
      sent: time,
    );
    final ref = firestore
        .collection('chats/${getConversationId(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(
            chatUser, message.msg!.contains('http') ? 'image' : msg));
  }

  Future<void> sendPushNotification(ChatUser chatUser, String msg) async {
    try {
      final body = {
        'to': chatUser.pushToken,
        "notification": {"title": chatUser.name, "body": msg}
      };
      var response =
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAAX_fIoXo:APA91bGg8Z2DIu5C6wDPjmDo3U0SZJex1d8toQB-9Do5WSDbmcxJVoKwHDdUD3DLmPb7SMBjYUHiVI_LoMDentNZS35fPe7G_gfJO172TFyOJhwv7CyJ5O2s5TZGehu7LgLjbS-EZVot'
              },
              body: jsonEncode(body));
    } catch (e) {}
  }

  Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationId(message.fromId!)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMeassages(ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = FirebaseStorage.instance.ref().child(
        'images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me?.pushToken
    });
  }

  Future<void> deleteMessage(Message message) async {
    firestore
        .collection('chats/${getConversationId(message.toId!)}/messages/')
        .doc(message.sent)
        .delete();
    if (message.msg!.startsWith('http')) {
      await FirebaseStorage.instance.refFromURL(message.msg!).delete();
    }
  }
  
  Future<void> updateMessage(Message message,String updateMessage) async {
    firestore
        .collection('chats/${getConversationId(message.toId!)}/messages/')
        .doc(message.sent)
        .update({'msg' : updateMessage});
    
    }
}
