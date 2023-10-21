import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/controller/home_page_controller.dart';
import '../core/const/colors.dart';
import '../models/chat_user.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home_screen.dart';

class LoginController extends GetxController {
  RxBool isAnimate = false.obs;
  User get user => FirebaseAuth.instance.currentUser!;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  handleGoogleBtnClick() {
    //for showing progress bar
    //Dialogs.showProgressBar(context);

    _signInWithGoogle().then((user) async {
      //for hiding progress bar
      Get.back();

      if (user != null) {
        print('\nUser: ${user.user}');
        print('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if ((await userExists())) {
          Get.to(HomeScreen());
        } else {
          await createUser().then((value) {
            Get.to(HomeScreen());
          });
        }
      }
    });
  }

   Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, I'm using We Chat!",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  Future<UserCredential?> _signInWithGoogle() async {
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
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('\n_signInWithGoogle: $e');
      //Dialogs.showSnackbar(context, 'Something Went Wrong (Check Internet!)');
      return null;
    }
  }
  Future<void> checkCurrentUser() async {
    await Future.delayed(Duration(milliseconds: 500));
    if (HomeScreenController.auth.currentUser != null) {
      print('\nUser: ${HomeScreenController.auth.currentUser}');
      Get.off(HomeScreen());
    } else {
      Get.off(LoginScreen());
    }
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
