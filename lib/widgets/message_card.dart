import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';


import 'package:get/get.dart';

import 'package:we_chat/controller/chat_controller.dart';

import 'package:we_chat/controller/home_page_controller.dart';
import 'package:we_chat/core/const/colors.dart';
import 'package:we_chat/core/helper/my_date_utile.dart';


import '../../main.dart';
import '../models/message.dart';
import 'custom_text.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  ChatController controller = Get.put(ChatController());
  HomeScreenController controller2 = Get.find();

  @override
  Widget build(BuildContext context) {
    bool isMe = HomeScreenController.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        showBottomSheett(isMe);
      },
      child: isMe ? greenMessage() : orangeMessage(),
    );
  }

  //our message
  Widget greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: mq.width * .04),
          child: Row(
            children: [
              widget.message.read.isNotEmpty
                  ? Icon(
                      Icons.done_all_rounded,
                      color: AppColors.green,
                      size: 16,
                    )
                  : Icon(
                      Icons.done_rounded,
                      color: AppColors.grey,
                      size: 16,
                    ),
              SizedBox(
                width: mq.width * .01,
              ),
              CustomText(
                text: MyDateUtil.getFormattedTime(
                    context: context, time: widget.message.sent),
                color: Colors.black54,
                size: 13,
              ),
            ],
          ),
        ),
        Flexible(
          child: Container(
              padding: EdgeInsets.all(
                widget.message.type == Type.image
                    ? mq.width * .01
                    : mq.width * .04,
              ),
              margin: EdgeInsets.symmetric(
                  horizontal: mq.width * .04, vertical: mq.height * .01),
              decoration: BoxDecoration(
                  color: Colors.teal.shade200,
                  borderRadius: widget.message.type == Type.image
                      ? BorderRadius.only(
                          topLeft: Radius.circular(mq.height * .04),
                          topRight: Radius.circular(mq.height * .04),
                          bottomLeft: Radius.circular(mq.height * .04),
                          bottomRight: Radius.circular(mq.height * .04))
                      : BorderRadius.only(
                          topLeft: Radius.circular(mq.height * .04),
                          topRight: Radius.circular(mq.height * .04),
                          bottomLeft: Radius.circular(mq.height * .04),
                        )),
              child: widget.message.type == Type.image
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .04),
                      child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(
                                color: AppColors.teal,
                              ),
                          errorWidget: (context, url, error) => Icon(
                                Icons.image,
                                size: 70,
                              )),
                    )
                  : CustomText(
                      text: '${widget.message.msg}',
                      color: Colors.black87,
                      size: 15,
                    )),
        ),
      ],
    );
  }

  //sender message
  Widget orangeMessage() {
    if (widget.message.read.isEmpty) {
      controller.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            child: Container(
                padding: EdgeInsets.all(
                  widget.message.type == Type.image
                      ? mq.width * .01
                      : mq.width * .04,
                ),
                margin: EdgeInsets.symmetric(
                    horizontal: mq.width * .04, vertical: mq.height * .01),
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 249, 230, 196),
                    borderRadius: widget.message.type == Type.image
                        ? BorderRadius.only(
                            topLeft: Radius.circular(mq.height * .04),
                            topRight: Radius.circular(mq.height * .04),
                            bottomRight: Radius.circular(mq.height * .04),
                            bottomLeft: Radius.circular(mq.height * .04))
                        : BorderRadius.only(
                            topLeft: Radius.circular(mq.height * .04),
                            topRight: Radius.circular(mq.height * .04),
                            bottomRight: Radius.circular(mq.height * .04))),
                child: widget.message.type == Type.image
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .04),
                        child: CachedNetworkImage(
                            imageUrl: widget.message.msg,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(
                                  color: AppColors.teal,
                                ),
                            errorWidget: (context, url, error) => Icon(
                                  Icons.image,
                                  size: 70,
                                )),
                      )
                    : CustomText(
                        text: '${widget.message.msg}',
                        color: Colors.black87,
                        size: 15,
                      ))),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: CustomText(
            text: MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            color: Colors.black54,
            size: 13,
          ),
        ),
      ],
    );
  }

  void showBottomSheett(bool isMe) {
    Get.bottomSheet(Container(
      height: isMe
          ? (widget.message.type == Type.image
              ? mq.height * .3
              : mq.height * .47)
          : (widget.message.type == Type.image
              ? mq.height * .2
              : mq.height * .28),
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
            height: mq.height * .005,
            width: mq.width * .2,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: AppColors.black54),
          ),
          widget.message.type == Type.image
              ? SizedBox()
              : InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.message.msg))
                        .then((value) {
                      Get.back();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: AppColors.green,
                        content: CustomText(
                          text: 'Message copied',
                        ),
                      ));
                    });
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.copy,
                      color: AppColors.blue,
                    ),
                    title: CustomText(
                      text: 'Copy Text',
                      color: AppColors.black54,
                    ),
                  ),
                ),
          if (widget.message.type == Type.text && isMe)
            InkWell(
              onTap: () {
                String updateMg = widget.message.msg;
                Get.back();
                Get.defaultDialog(
                    title: 'Edit Message',
                    content: TextFormField(
                      //hint: 'Edit',
                      onChanged: (val) => updateMg = val,
                      initialValue: updateMg,
                    ),
                    cancel: TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: CustomText(text: 'Cancel')),
                    confirm: TextButton(
                        onPressed: () {
                          controller.updateMessage(
                              widget.message, updateMg);
                          Get.back();
                        },
                        child: CustomText(text: 'Edit')));
              },
              child: ListTile(
                leading: Icon(
                  Icons.edit,
                  color: AppColors.blue,
                ),
                title: CustomText(
                  text: 'Edit Message',
                  color: AppColors.black54,
                ),
              ),
            ),
          if (isMe)
            InkWell(
              onTap: () {
                controller.deleteMessage(widget.message);
                Get.back();
              },
              child: ListTile(
                leading: Icon(
                  Icons.delete_forever_outlined,
                  color: AppColors.red,
                ),
                title: CustomText(
                  text: 'Delete Message',
                  color: AppColors.black54,
                ),
              ),
            ),
          if (isMe)
            Divider(
              color: AppColors.black54,
              indent: mq.height * .04,
              endIndent: mq.width * .04,
            ),
          ListTile(
            leading: Icon(
              Icons.remove_red_eye_outlined,
              color: AppColors.blue,
            ),
            title: CustomText(
              text:
                  'Sent At ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
              color: AppColors.black54,
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.remove_red_eye_outlined,
              color: AppColors.green,
            ),
            title: CustomText(
              text: widget.message.read.isNotEmpty
                  ? 'Read At ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}'
                  : 'Not seen yet',
              color: AppColors.black54,
            ),
          ),
        ],
      ),
    ));
  }
}
