import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/controller/home_page_controller.dart';
import 'package:we_chat/screens/auth/login_screen.dart';

class ProfileController extends GetxController {
  //late final TextEditingController name;
  //late final TextEditingController about;
  TextEditingController? name;
  TextEditingController? about;
  HomeScreenController controller = Get.find();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  Rx<File?> selectedImage = Rx<File?>(null);

  void selectImage(File image) {
    selectedImage.value = image;
  }

  GlobalKey<FormState> formState = GlobalKey<FormState>();
  // for updating user information
  Future<bool> updateUserInfo() async {
    if (formState.currentState!.validate()) {
      formState.currentState!.save();
      await controller.firestore
          .collection('users')
          .doc(HomeScreenController.user.uid)
          .update({
        'name': controller.me.name,
        'about': controller.me.about,
      });
    }
    return true;
  }

  // update profile picture of user
  Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    print('Extension: $ext');

    //storage file ref with path
    final ref = storage
        .ref()
        .child('profile_pictures/${HomeScreenController.user.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    controller.me.image = await ref.getDownloadURL();
    await controller.firestore
        .collection('users')
        .doc(HomeScreenController.user.uid)
        .update({'image': controller.me.image});
  }

  

  signOut() {
    auth.signOut().then((value) async {
      await GoogleSignIn().signOut().then((value) {
        //for hiding progress dialog
        Get.back();

        //for moving to home screen
        Get.back();

        auth = FirebaseAuth.instance;

        //replacing home screen with login screen
        Get.off(LoginScreen());
      });
    });
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // name = TextEditingController();
    // about = TextEditingController();
  }
}
