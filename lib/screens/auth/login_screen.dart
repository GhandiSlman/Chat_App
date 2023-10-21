// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_chat/controller/login_controller.dart';
import 'package:we_chat/core/const/colors.dart';


import '../../../main.dart';
import '../../widgets/custom_text.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  LoginController controller = Get.put(LoginController(),);

  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      //appBar
      appBar: AppBar(
          elevation: 1,
          centerTitle: true,
          backgroundColor: AppColors.white,
          title: CustomText(
            text: 'Welcome to We Chat',
            size: 19,
            color: AppColors.black,
            weight: FontWeight.normal,
          )),
      body: Stack(
        children: [
         Obx(() {
            final isAnimate = controller.isAnimate.value;
            return AnimatedPositioned(
              duration: Duration(seconds: 1),
              top: mq.height * .15,
              left: isAnimate ? mq.width * .25 : mq.width * .5,
              width: mq.width * .5,
              child: Image.asset('assets/rating.png'),
            );
          }),
          Positioned(
              bottom: mq.height * .15,
              left: mq.width * .05,
              width: mq.width * .9,
              height: mq.height * .06,
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  onTap: () {
                    controller.handleGoogleBtnClick();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: AppColors.green1),
                    child: Row(children: [
                      SizedBox(
                        width: mq.width * .2,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset('assets/search.png'),
                      ),
                      SizedBox(
                        width: mq.width * .02,
                      ),
                      CustomText(text: 'Sign in with Google'),
                    ]),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
