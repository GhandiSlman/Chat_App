import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/controller/chat_controller.dart';
import 'package:we_chat/core/const/colors.dart';
import 'package:we_chat/view/screens/auth/login_screen.dart';

import '../model/chat_user.dart';
import '../view/screens/home_screen.dart';

class LoginController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  //ChatController controller = Get.put(ChatController());
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  User get user => auth.currentUser!;

  final RxBool isAnimate = false.obs;

  Future<bool> userExists() async {
    return (await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  

  Future<void> creatUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using We Chat",
      image: user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  handleGoogleBtnClick() {
    Get.dialog(Center(
      child: CircularProgressIndicator(),
    ));
    signInWithGoogle().then((user) async => {
          if (user != null)
            {
              print('\nUser: ${user.user}'),
              print('\nUserAdditionalInfo: ${user.additionalUserInfo}'),
              if (await userExists())
                {
                  Get.off(HomeScreen()),
                }
              else
                {
                  creatUser().then((value) => Get.off(HomeScreen())),
                }
            }
        });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await auth.signInWithCredential(credential);
    } catch (e) {
      print('\nSignInWithGoogle: $e');
      Get.snackbar(
        'Error',
        'Check your internet connection',
        backgroundColor: Colors.red.withOpacity(0.3),
        icon: Icon(Icons.disabled_by_default_outlined),
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.all(15),
      );
    }
    return null;
  }

  Future<void> checkCurrentUser() async {
    await Future.delayed(Duration(milliseconds: 500));
    if (auth.currentUser != null) {
      print('\nUser: ${auth.currentUser}');
      Get.off(HomeScreen());
    } else {
      Get.off(LoginScreen());
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
    await GoogleSignIn().signOut().then((value) {
      Get.back();
      Get.back();
      Get.off(LoginScreen());
    });
  }

  void onInit() {
    super.onInit();
    Future.delayed(Duration(milliseconds: 500), () {
      isAnimate.value = true;
      checkCurrentUser();
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: AppColors.white));
    });
  }
}
