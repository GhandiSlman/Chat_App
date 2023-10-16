import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/controller/chat_controller.dart';
import 'package:we_chat/controller/home_controller.dart';
import 'package:we_chat/controller/login_controller.dart';
import 'package:we_chat/model/chat_user.dart';
import '../../core/const/colors.dart';
import '../../main.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_text_form.dart';

class ProfileScreen extends StatelessWidget {
  ChatUser user;
  TextEditingController ?textEditingController;
  ProfileScreen({super.key,required this.user});

  LoginController controller = Get.put(LoginController());

  HomeController controller2 = Get.put(HomeController());
  ChatController controller3 = Get.put(ChatController());
  @override
  Widget build(BuildContext context) {
    final formkey = GlobalKey<FormState>();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.black,
            ),
          ),
          elevation: 1,
          centerTitle: true,
          backgroundColor: AppColors.white,
          title: CustomText(
            text: 'Profile Screen',
            color: AppColors.black,
            size: 19,
            weight: FontWeight.normal,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: mq.height * .05, vertical: mq.width * .05),
          child: ListView(
            children: [
              Form(
                key: formkey,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Obx(
                          () => controller2.selectedImage.value != null
                              ? ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(mq.height * .1),
                                  child: Image.file(
                                    controller2.selectedImage.value!,
                                    width: mq.height * .2,
                                    height: mq.height * .2,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(mq.height * .1),
                                  child: CachedNetworkImage(
                                    width: mq.height * .2,
                                    height: mq.height * .2,
                                    imageUrl: user.image,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Image.asset('assets/images.jpeg'),
                                    errorWidget: (context, url, error) =>
                                        Image.asset('assets/images.jpeg'),
                                  ),
                                ),
                        ),
                        Positioned(
                            right: 0,
                            bottom: 0,
                            child: InkWell(
                              onTap: () {
                                Get.bottomSheet(Container(
                                  height: mq.height * 0.2,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(25),
                                      topRight: Radius.circular(25),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: mq.height * .01,
                                      ),
                                      Container(
                                        height: mq.height * .01,
                                        width: mq.width * .2,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: AppColors.grey),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          final pickedFile = await ImagePicker()
                                              .pickImage(
                                                  source: ImageSource.camera,
                                                  imageQuality: 80);
                                          if (pickedFile != null) {
                                            final image = File(pickedFile.path);
                                            controller2.selectImage(image);
                                            controller2.updateProfilePicture(
                                                File(controller2.selectedImage
                                                    .value!.path));
                                          }
                                        },
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: AppColors.black54,
                                            child: Icon(CupertinoIcons.camera),
                                          ),
                                          title: CustomText(
                                            text: 'Take photo',
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          final pickedFile = await ImagePicker()
                                              .pickImage(
                                                  source: ImageSource.gallery,
                                                  imageQuality: 80);
                                          if (pickedFile != null) {
                                            final image = File(pickedFile.path);
                                            controller2.selectImage(image);
                                            controller2.updateProfilePicture(
                                                File(controller2.selectedImage
                                                    .value!.path));
                                          }
                                        },
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: AppColors.black54,
                                            child: Icon(Icons.image),
                                          ),
                                          title: CustomText(
                                            text: 'Upload photo',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                              },
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(20),
                                child: CircleAvatar(
                                  backgroundColor: AppColors.white,
                                  child: Icon(Icons.edit),
                                ),
                              ),
                            ))
                      ],
                    ),
                    SizedBox(
                      height: mq.height * .05,
                    ),
                    CustomText(
                        text: '${user.email}',
                        color: AppColors.black54,
                        size: 16),
                    SizedBox(
                      height: mq.height * .05,
                    ),
                    CustomTextForm(
                      mycontroller: textEditingController,
                      onSaved: (val) => controller2.me!.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Field required',
                      initialValue: user.name,
                      label: CustomText(text: 'Name'),
                      icon: Icon(CupertinoIcons.person),
                    ),
                    SizedBox(
                      height: mq.height * .02,
                    ),
                    CustomTextForm(
                      mycontroller: textEditingController,
                      onSaved: (val) => controller2.me!.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Field required',
                      initialValue: user.about,
                      label: CustomText(text: 'About'),
                      icon: Icon(CupertinoIcons.info_circle),
                    ),
                    SizedBox(
                      height: mq.height * .2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            controller2.udateUserInfo().then(
                                (value) => Get.snackbar('title', ' message'));
                          },
                          child: CircleAvatar(
                              maxRadius: 25,
                              backgroundColor: AppColors.blue,
                              child: Icon(
                                Icons.edit,
                                color: AppColors.white,
                              )),
                        ),
                        FloatingActionButton.extended(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: CustomText(
                                      text: 'Log out of your account?',
                                      weight: FontWeight.normal),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: CustomText(
                                        text: 'Cancel',
                                        color: AppColors.black54,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await controller3
                                            .updateActiveStatus(false);
                                        controller.signOut();
                                        Get.back();
                                        controller.auth = FirebaseAuth.instance;
                                      },
                                      child: CustomText(
                                        text: 'LOG OUT',
                                        color: AppColors.red,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                            // controller.signOut();
                          },
                          backgroundColor: AppColors.redAccent,
                          icon: Icon(Icons.logout_outlined),
                          label: CustomText(text: 'Log Out'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
