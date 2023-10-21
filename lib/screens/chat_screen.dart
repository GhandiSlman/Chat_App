import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
//import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/controller/chat_controller.dart';
import 'package:we_chat/controller/home_page_controller.dart';
import 'package:we_chat/core/const/colors.dart';
import 'package:we_chat/core/helper/my_date_utile.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/models/message.dart';
import 'package:we_chat/screens/view_profile_screen.dart';

import '../models/chat_user.dart';
import '../widgets/custom_text.dart';
import '../widgets/message_card.dart';

class ChatScreen extends StatelessWidget {
  ChatUser user;
  ChatScreen({super.key, required this.user});
  
  ChatController controller = Get.put(ChatController());
  HomeScreenController controller2 = Get.find();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 1,
            automaticallyImplyLeading: false,
            flexibleSpace: appBar()),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: controller.getAllMessages(user),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return SizedBox();
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;

                      controller.list = data
                              ?.map((e) => Message.fromJson(e.data()))
                              .toList() ??
                          [];

                      if (controller.list.isNotEmpty) {
                        return ListView.builder(
                          reverse: true,
                          itemCount: controller.list.length,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return MessageCard(
                              message: controller.list[index],
                            );
                          },
                        );
                      } else {
                        return Center(
                          child: CustomText(text: 'No connection found'),
                        );
                      }
                  }
                },
              ),
            ),
            Obx(() => controller.isUploading.value
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: mq.height * .01,
                          bottom: mq.height * .01,
                          right: mq.height * .02),
                      child: CustomText(
                        text: 'Sending Photo',
                        color: AppColors.grey,
                      ),
                    ))
                : Padding(padding: EdgeInsets.all(0))),
            Padding(
              padding: EdgeInsets.all(mq.height * .01),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      child: Row(
                        children: [
                          Obx(() => IconButton(
                              onPressed: () {
                                controller.showEmoji.value =
                                    !controller.showEmoji.value;
                              },
                              icon: Icon(
                                controller.showEmoji.value
                                    ? Icons.keyboard_alt_outlined
                                    : Icons.emoji_emotions_outlined,
                                color: AppColors.grey,
                              ))),
                          Expanded(
                              child: TextFormField(
                            controller: controller.textController,
                            keyboardType: TextInputType.multiline,
                            //maxLines: null,
                            decoration: InputDecoration(
                                hintText: 'Message',
                                hintStyle:
                                    TextStyle(fontWeight: FontWeight.w300),
                                border: InputBorder.none),
                          )),
                          Obx(() => IconButton(
                              onPressed: () async {
                                final List<XFile> pickedImages =
                                    await ImagePicker()
                                        .pickMultiImage(imageQuality: 70);
                                for (var i in pickedImages) {
                                  controller.isUploading.value = true;
                                  await controller.sendChatImage(
                                      user, File(i.path));
                                  controller.isUploading.value = false;
                                }
                              },
                              icon: Icon(Icons.image,
                                  color: controller.isUploading.value
                                      ? AppColors.grey
                                      : AppColors.grey))),
                          Obx(
                            () => IconButton(
                                onPressed: () async {
                                  final pickedFile = await ImagePicker()
                                      .pickImage(
                                          source: ImageSource.camera,
                                          imageQuality: 70);
                                  if (pickedFile != null) {
                                    final image = File(pickedFile.path);
                                    controller.selectImage(image);
                                    controller.isUploading.value = true;
                                    await controller.sendChatImage(
                                        user,
                                        File(controller
                                            .selectedImage.value!.path));
                                    controller.isUploading.value = false;
                                  }
                                },
                                icon: Icon(Icons.camera_alt_outlined,
                                    color: controller.isUploading.value
                                        ? AppColors.grey
                                        : AppColors.grey)),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (controller.textController.text.isNotEmpty) {
                        controller.sendMessage(user, controller.textController.text,Type.text);
                        controller.textController.text = '';
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Center(
                          child: Icon(
                        Icons.send,
                        size: 20,
                        color: AppColors.white,
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    return InkWell(
      onTap: () {
        Get.to(ViewProfileScreen(user: user));
      },
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder(
            stream: controller2.getUserInfo(user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
              return Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(Icons.arrow_back)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .03),
                    child: CachedNetworkImage(
                      width: mq.height * .055,
                      height: mq.height * .055,
                      imageUrl: list.isNotEmpty ? list[0].image : user.image,
                      placeholder: (context, url) {
                        return Image.asset('assets/images.jpeg');
                      },
                      errorWidget: (context, url, error) =>
                          Image.asset('assets/images.jpeg'),
                    ),
                  ),
                  SizedBox(
                    width: mq.width * .03,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: list.isNotEmpty ? list[0].name : user.name,
                        size: 16,
                        color: Colors.black87,
                      ),
                      SizedBox(
                        height: mq.height * .003,
                      ),
                      CustomText(
                        text: list.isNotEmpty
                            ? list[0].isOnline
                                ? 'online'
                                : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive)
                            : MyDateUtil.getLastActiveTime(
                                context: context, lastActive: user.lastActive),
                        size: mq.width * .03,
                        color: AppColors.black54,
                      )
                    ],
                  )
                ],
              );
            },
          )),
    );
  }
}
