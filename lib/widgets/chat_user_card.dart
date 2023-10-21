
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

import 'package:we_chat/controller/home_page_controller.dart';
import 'package:we_chat/core/const/colors.dart';
import 'package:we_chat/core/helper/my_date_utile.dart';
import 'package:we_chat/main.dart'; 

import '../models/chat_user.dart';
import '../models/message.dart';
import '../screens/chat_screen.dart';
import '../screens/view_profile_screen.dart';
import 'custom_text.dart';

class ChatUserCard extends StatelessWidget {
  final ChatUser user;
  ChatUserCard({super.key, required this.user});
  HomeScreenController controller = Get.find();
  Message? message;
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Get.to(ChatScreen(
            user: user,
          ));
        },
        child: StreamBuilder(
          stream: controller.getLastMessage(user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;

            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) {
              message = list[0];
            }
            return ListTile(
                leading: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Container(
                          padding: EdgeInsets.all(20),
                          color: AppColors.white.withOpacity(0),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 0),
                            child: Stack(
                              children: [
                                Positioned(
                                    bottom: mq.height * .444,
                                    left: 0,
                                    right: mq.width * .096,
                                    child: Container(
                                        width: mq.width * .1,
                                        height: mq.height * .077,
                                        color: AppColors.white,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: mq.height * .01),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // SizedBox(width: 20),
                                              Material(
                                                color: AppColors.white,
                                                // Set the Material's color to transparent
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.message,
                                                    color: AppColors.teal,
                                                  ), // Replace 'first_icon' with your first icon
                                                  onPressed: () {
                                                    Get.back();
                                                    Get.to(
                                                        ChatScreen(user: user));
                                                  },
                                                ),
                                              ),
                                              StreamBuilder(
                                                  stream: controller
                                                      .getUserInfo(user),
                                                  builder: (context, snapshot) {
                                                    final data =
                                                        snapshot.data?.docs;
                                                    final list = data
                                                            ?.map((e) => ChatUser
                                                                .fromJson(
                                                                    e.data()))
                                                            .toList() ??
                                                        [];
                                                    return CustomText(
                                                      color: AppColors.grey,
                                                      text: list.isNotEmpty
                                                          ? list[0].isOnline
                                                              ? 'online'
                                                              : MyDateUtil.getLastActiveTime(
                                                                  context:
                                                                      context,
                                                                  lastActive: list[
                                                                          0]
                                                                      .lastActive)
                                                          : MyDateUtil
                                                              .getLastActiveTime(
                                                                  context:
                                                                      context,
                                                                  lastActive: user
                                                                      .lastActive),
                                                      size: mq.width * .04,
                                                      //color: AppColors.black54,
                                                    );
                                                  }),
                                              Material(
                                                color: AppColors.white,
                                                // Set the Material's color to transparent
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.info_outline,
                                                    color: AppColors.teal,
                                                  ), // Replace 'second_icon' with your second icon
                                                  onPressed: () {
                                                    Get.back();
                                                    Get.to(ViewProfileScreen(
                                                        user: user));
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))),
                                Container(
                                  height: mq.height * .4,
                                  width: mq.width * .78,
                                  child: CachedNetworkImage(
                                    width: mq.height * .055,
                                    height: mq.height * .055,
                                    imageUrl: user.image,
                                    placeholder: (context, url) {
                                      return Image.asset('assets/images.jpeg');
                                    },
                                    errorWidget: (context, url, error) =>
                                        Image.asset('assets/images.jpeg'),
                                  ),
                                ),
                                Positioned(
                                  top: mq.height * .01,
                                  child: Container(
                                      width: mq.width * .78,
                                      height: mq.height * .04,
                                      color: AppColors.black.withOpacity(0.3),
                                      child: Padding(
                                        padding:
                                            EdgeInsets.only(left: 10, top: 2),
                                        child: CustomText(
                                          text: user.name,
                                          color: AppColors.white,
                                          size: 20,
                                        ),
                                      )),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .03),
                    child: CachedNetworkImage(
                      width: mq.height * .055,
                      height: mq.height * .055,
                      imageUrl: user.image,
                      placeholder: (context, url) {
                        return Image.asset('assets/images.jpeg');
                      },
                      errorWidget: (context, url, error) =>
                          Image.asset('assets/images.jpeg'),
                    ),
                  ),
                ),
                title: CustomText(text: '${user.name}'),
                       subtitle: message != null
                    ?  message!.type == Type.image
                        ? Row(
                            children: [
                              Icon(
                                Icons.image,
                                color: AppColors.grey,
                                size: 20,
                              ),
                              CustomText(
                                text: 'Photo',
                              ),
                            ],
                          )
                        : CustomText(
                            text: message!.msg,
                          )
                    : CustomText(
                        text: user.about,
                      ),
                trailing: message == null
                    ? null
                    : message!.read.isEmpty &&
                            message!.fromId != HomeScreenController.user.uid
                        ? Icon(
                            Icons.mark_email_unread_outlined,
                            size: 15,
                            color: Colors.teal,
                          )
                        : CustomText(
                            text:
                                '${MyDateUtil.getMessageTime(context: context, time: message!.sent)}',
                            color: AppColors.black54,
                          ));
          },
        ));
  }
}
