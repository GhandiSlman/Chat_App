import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_chat/controller/home_page_controller.dart';
import '../core/const/colors.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';
import '../widgets/custom_text.dart';
import 'profile_screen.dart';

//home screen -- where all available contacts are shown
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  HomeScreenController controller = Get.put(HomeScreenController());

  @override
  Widget build(BuildContext context) {
    return
        WillPopScope(
            //if search is on & back button is pressed then close search
            //or else simple close current screen on back button click
            onWillPop: () {
              if (controller.isSearching.value) {
                controller.isSearching.value = !controller.isSearching.value;
                return Future.value(false);
              } else {
                return Future.value(true);
              }
            },
            child: Scaffold(
                //app bar

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
                            user: controller.me,
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
                                controller.searchList.clear();
                                for (var i in controller.list) {
                                  if (i.name
                                          .toLowerCase()
                                          .contains(value.toLowerCase()) ||
                                      i.email
                                          .toLowerCase()
                                          .contains(value.toLowerCase())) {
                                    controller.searchList.add(i);
                                  }
                                }
                              },
                              decoration:
                                  InputDecoration(hintText: 'Name,email'),
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
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FloatingActionButton(
                      onPressed: () {
                        String email = '';
                        Get.defaultDialog(
                          title: 'Add User',
                          content: TextFormField(
                            maxLines: null,
                            onChanged: (value) => email = value,
                            decoration: InputDecoration(
                                hintText: 'Email Id',
                                prefixIcon:
                                    const Icon(Icons.email, color: Colors.blue),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15))),
                          ),
                          cancel: TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: CustomText(text: 'Cancel'),
                          ),
                          confirm: TextButton(
                            onPressed: () async {
                              if (email.isNotEmpty) {
                                await controller.addChatUser(email).then((value) {
                                  if (!value) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text("The email that you entered not found"),
                                            backgroundColor: AppColors.red,
                                            ));
                                  }
                                });
                              }
                              Get.back();
                            },
                            child: CustomText(text: 'Finish'),
                          ),
                        );
                      },
                      child: Icon(CupertinoIcons.equal_square)),
                ),

                //body
                body: StreamBuilder(
                  stream: controller.getMyUsersId(),

                  //get id of only known users
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      //if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(child: CircularProgressIndicator());

                      //if some or all data is loaded then show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                        return StreamBuilder(
                          stream: controller.getAllUsers(
                              snapshot.data?.docs.map((e) => e.id).toList() ??
                                  []),

                          //get only those user, who's ids are provided
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              //if data is loading
                              case ConnectionState.waiting:
                              case ConnectionState.none:
                           

                              //if some or all data is loaded then show it
                              case ConnectionState.active:
                              case ConnectionState.done:
                                final data = snapshot.data?.docs;
                                controller.list.value = data
                                        ?.map(
                                            (e) => ChatUser.fromJson(e.data()))
                                        .toList() ??
                                    [];

                                if (controller.list.isNotEmpty) {
                                  return Obx(() {
                                    return ListView.builder(
                                      itemCount: controller.isSearching.value
                                          ? controller.searchList.length
                                          : controller.list.length,
                                      physics: BouncingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return ChatUserCard(
                                          user: controller.isSearching.value
                                              ? controller.searchList[index]
                                              : controller.list[index],
                                        );
                                      },
                                    );
                                  });
                                } else {
                                  return const Center(
                                    child: Text('No Users Found!',
                                        style: TextStyle(fontSize: 15)),
                                  );
                                }
                            }
                          },
                        );
                    }
                  },
                )));
  }
}
