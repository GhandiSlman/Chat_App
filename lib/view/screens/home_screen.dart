import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_chat/api.dart';
import 'package:we_chat/controller/chat_controller.dart';
import 'package:we_chat/controller/home_controller.dart';
import 'package:we_chat/controller/login_controller.dart';
import 'package:we_chat/core/const/colors.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/model/chat_user.dart';
import 'package:we_chat/model/message.dart';
import 'package:we_chat/view/screens/profile_screen.dart';
import 'package:we_chat/view/widgets/chat_user_card.dart';
import 'package:we_chat/view/widgets/custom_text_form.dart';
import '../widgets/custom_text.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  static FirebaseAuth auth = FirebaseAuth.instance;

  static User get user => auth.currentUser!;

  Message? message;

  HomeController controller = Get.put(HomeController());

  //LoginController controller2 = Get.find();
  ChatController controller2 = Get.put(ChatController());

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (controller.isSearching.value) {
          controller.isSearching.value = !controller.isSearching.value;
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
          //appBar
          appBar: AppBar(
            elevation: 1,
            centerTitle: true,
            leading: Padding(
                padding: EdgeInsets.all(mq.height * .02),
                child: Icon(
                  CupertinoIcons.home,
                  color: AppColors.black,
                )),
            actions: [
              //search user button
              Obx(() {
                return IconButton(
                  onPressed: () {
                    // Toggle the value of isSearching
                    controller.isSearching.value =
                        !controller.isSearching.value;
                  },
                  icon: Icon(
                      controller.isSearching.value
                          ? CupertinoIcons.clear_circled_solid
                          : CupertinoIcons.search,
                      color: controller.isSearching.value
                          ? AppColors.red
                          : AppColors.black),
                );
              }),
              //more features button
              IconButton(
                  onPressed: () {
                    Get.to(ProfileScreen(
                      user: controller.me!,
                    ));
                  },
                  icon: Icon(
                    CupertinoIcons.person,
                    color: AppColors.black,
                  ))
            ],
            backgroundColor: AppColors.white,
            title: Obx(
              () => controller.isSearching.value
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: TextFormField(
                        onChanged: (value) {
                          controller.saerchList.clear();
                          for (var i in controller.list) {
                            if (i.name
                                    .toLowerCase()
                                    .contains(value.toLowerCase()) ||
                                i.email
                                    .toLowerCase()
                                    .contains(value.toLowerCase())) {
                              controller.saerchList.add(i);
                            }
                          }
                        },
                        decoration: InputDecoration(hintText: 'Name,email'),
                      ),
                    )
                  : CustomText(
                      text: 'We Chat',
                      color: AppColors.black,
                      size: 19,
                      weight: FontWeight.normal,
                    ),
            ),
          ),
          //floating button to add new user
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child:FloatingActionButton(
  onPressed: () async {
    String email = '';
    await Get.defaultDialog(
      title: 'Add User',
      content: CustomTextForm(
        onChanged: (value) {
          
                email = value;
          
        
        } ,
        hint: 'email',
       
      ),
      cancel: TextButton(
        onPressed: () {
          Get.back();
        },
        child: CustomText(text: 'Cancel'),
      ),
      confirm: TextButton(
        onPressed: () async {
          // Ensure that controller.addUser is asynchronous and returns a Future<bool>.
           controller.addUser(email);
          // if (userAdded) {
          //   print('User added successfully.');
          //   print('Email to be queried: $email');
          // } else {
          //   print('User could not be added.');
          //   print('Email to be queried: $email');
          // }
          Get.back();
        },
        child: CustomText(text: 'Finish'),
      ),
    );
  },
  child: Icon(CupertinoIcons.equal_square),
),

          ),
          body: StreamBuilder(
            stream: controller.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Center(child: CircularProgressIndicator());
                case ConnectionState.active:
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    final data = snapshot.data?.docs;
                    controller.list = data
                            ?.map((e) => ChatUser.fromJson(e.data()))
                            .toList() ??
                        [];
                  }

                  // Check if the search list is empty
                  final isSearchListEmpty = controller.isSearching.value &&
                      controller.saerchList.isEmpty;

                  if (isSearchListEmpty) {
                    return Center(
                      child: CustomText(text: 'No results found'),
                    );
                  } else if (controller.list.isNotEmpty) {
                    return Obx(() {
                      return ListView.builder(
                        itemCount: controller.isSearching.value
                            ? controller.saerchList.length
                            : controller.list.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ChatUserCard(
                            user: controller.isSearching.value
                                ? controller.saerchList[index]
                                : controller.list[index],
                          );
                        },
                      );
                    });
                  } else {
                    return Center(
                      child: CustomText(text: 'No connection found'),
                    );
                  }
              }
            },
          )),
    );
  }
}
