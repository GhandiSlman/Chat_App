import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:we_chat/controller/chat_controller.dart';
import 'package:we_chat/controller/login_controller.dart';
import '../model/chat_user.dart';

class HomeController extends GetxController {
  LoginController controller = Get.put(LoginController());
  ChatController controller2 = Get.put(ChatController());
  RxString email = ''.obs;
  Rx<File?> selectedImage = Rx<File?>(null);

  void selectImage(File image) {
    selectedImage.value = image;
  }

  List<ChatUser> list = [];
  final RxList<ChatUser> saerchList = <ChatUser>[].obs;
  RxBool isSearching = false.obs;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  ChatUser? me;
  User get user => auth.currentUser!;

  FirebaseMessaging fMessaging = FirebaseMessaging.instance;
  Future<void> getFirebseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((token) {
      if (token != null) {
        me!.pushToken = token;
        print('=============================$token');
      }
    });
  }

    Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me!.name,
      'about': me!.about,
    });
  }

  Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebseMessagingToken();
        controller2.updateActiveStatus(true);
      } else {
        await controller.creatUser().then((value) => getSelfInfo());
      }
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  Future<void> udateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me!.name,
      'about': me!.about,
    });
  }

  Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_pictures/${user.uid}.$ext');

    //uploading image
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    me!.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me!.image});
  }

  Future<bool> addUser(String email) async {
    print('=================================================');
    print('Email to be queried: $email');
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    print('==================================================');
    print('---------------+++++${data.docs}');
    print('---------------${controller2.user.uid}');
    // print('---------------${data.docs.first.data()}');
    print(user.uid);
    if (data.docs.isNotEmpty && data.docs.first.id != controller2.user.uid) {
    print('+++++++++++++++++++++++++++++++++++++++++++++++++');
     print('======================= ${data.docs.first.data()}');
    FirebaseFirestore.instance
        .collection('users')
        .doc(controller2.user.uid)
        .collection('my_users')
     .doc(data.docs.first.id)
     .set({});
    return true;
    }
    else {
    return false;
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    // me = ChatUser();
    super.onInit();
    getSelfInfo();
    //controller2.updateActiveStatus(true);
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          controller2.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          controller2.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }
}
