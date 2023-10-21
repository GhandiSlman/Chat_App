import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/controller/chat_controller.dart';

import 'package:we_chat/controller/home_page_controller.dart';
import 'package:we_chat/controller/profile_controller.dart';

import '../../core/const/colors.dart';
import '../../core/helper/my_date_utile.dart';
import '../../main.dart';
import '../models/chat_user.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_text_form.dart';

class ViewProfileScreen extends StatelessWidget {
  ChatUser user;

  ViewProfileScreen({super.key, required this.user});

  ProfileController controller = Get.put(ProfileController());

  HomeScreenController controller2 =  Get.find();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: mq.height * .05, vertical: mq.width * .05),
          child: ListView(
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      Obx(
                        () => controller.selectedImage.value != null
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: Image.file(
                                  controller.selectedImage.value!,
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
                    ],
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  CustomText(
                    text: '${user.name}',
                    color: AppColors.black,
                    size: 20,
                    weight: FontWeight.normal,
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  CustomText(
                      text: '${user.email}',
                      color: AppColors.black54,
                      size: 16),
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  StreamBuilder(
                      stream: controller2.getUserInfo(user),
                      builder: (context, snapshot) {
                        final data = snapshot.data?.docs;
                        final list = data
                                ?.map((e) => ChatUser.fromJson(e.data()))
                                .toList() ??
                            [];
                        return Container(
                          width: mq.width * 1,
                          height: mq.height * .05,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromRGBO(210, 209, 209, 1)),
                          child: Center(
                            child: CustomText(
                              text: list.isNotEmpty
                                  ? list[0].isOnline
                                      ? 'online'
                                      : MyDateUtil.getLastActiveTime(
                                          context: context,
                                          lastActive: list[0].lastActive)
                                  : MyDateUtil.getLastActiveTime(
                                      context: context,
                                      lastActive: user.lastActive),
                              size: mq.width * .04,
                              //color: AppColors.black54,
                            ),
                          ),
                        );
                      }),
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  Divider(
                    thickness: mq.height * .001,
                    color: AppColors.teal,
                  ),
                  ListTile(
                    title: CustomText(
                      text: user.about,
                    ),
                  ),
                  Divider(
                    thickness: mq.height * .001,
                    color: AppColors.teal,
                  ),
                  SizedBox(
                    height: mq.height * .3,
                  ),
                  CustomText(
                    text:
                        'Joined at: ${MyDateUtil.getLastMessageTime(context: context, time: user.createdAt, showYear: true)}',
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
