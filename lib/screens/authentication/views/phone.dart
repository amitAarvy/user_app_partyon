import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:user/core/widgets/logo_head.dart';
import 'package:user/screens/authentication/views/user_info.dart';
import 'package:user/screens/bottom-screens.dart';
import 'package:user/screens/home/view/home_view.dart';
import 'package:user/screens/venue_view.dart';

import 'login_page.dart';

class PhoneLogin extends StatefulWidget {
  final String? eventID;

  const PhoneLogin({super.key, this.eventID});

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  dynamic theme;
  final OtpController otpController = Get.put(OtpController());

  @override
  void initState() {
    super.initState();
    print('yes login page  is ');
  }

  Future<void> startTimer() async {
    otpController.updateCount();
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (otpController.count > 0) {
        otpController.decCount();
      } else {
        timer.cancel();
      }
    });
  }

  bool sendOtp = false;
  final TextEditingController _phoneController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> _phoneSignIn(var phone) async {
    TextEditingController otpTextController = TextEditingController();
    int? resendToken;
    try {
      EasyLoading.dismiss();
      await EasyLoading.show();
      await auth.verifyPhoneNumber(
        phoneNumber: ('+91$phone').toString(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // ANDROID ONLY!
          print('user crediential is ${credential}');
          // Sign the user in (or link) with the auto-generated credential
          await auth
              .signInWithCredential(credential)
              .then((UserCredential result) {
            if (result.user != null) {
              FirebaseFirestore.instance
                  .collection('User')
                  .doc(result.user?.uid)
                  .get()
                  .then((DocumentSnapshot<Map<String, dynamic>> value) {
                if (value.exists) {
                  // Get.off(() => const HomeView());
                  Get.off(() => const VenueView());
                  // Get.off(() => const BottomNavigationBarExampleApp());
                } else {
                  Get.off(
                    UserInfoData(
                      email: (result.user?.email ?? '').toString(),
                      isPhone: true,
                    ),
                  );
                }
              });
            } else {
              print("object hu me 2");
              Fluttertoast.showToast(msg: 'User does not exist');
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {}
        },
        codeSent: (String verificationId, int? resendToken) async {
          startTimer();
          resendToken = resendToken;
          await EasyLoading.dismiss();
          if (!mounted) return;
          await Get.defaultDialog(
            title: 'Enter OTP',
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                PinCodeTextField(
                  length: 6,
                  appContext: context,
                  autoFocus: true,
                  controller: otpTextController,
                  onChanged: (String val) {},
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                        (Set<MaterialState> states) => Colors.black,
                  ),
                ),
                child: const Text('Confirm'),
                onPressed: () async {
                  final String code = otpTextController.text.trim();

                  try {
                    AuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: verificationId,
                      smsCode: code,
                    );

                    UserCredential result =
                    await auth.signInWithCredential(credential);

                    if (result.user != null) {
                      await FirebaseFirestore.instance
                          .collection('User')
                          .doc(result.user?.uid)
                          .get()
                          .then((DocumentSnapshot<Map<String, dynamic>> value) {
                        if (value.exists) {
                          if (widget.eventID != null) {
                            Get.back();
                            Get.back();
                          } else {
                            // Get.off(() => const HomeView());
                            // Get.off(() => const VenueView());
                            Get.off(() => const BottomNavigationBarExampleApp());
                          }
                        } else {
                          Get.off(
                            UserInfoData(
                              email: (result.user?.email ?? '').toString(),
                              isPhone: true,
                            ),
                          );
                        }
                      });
                    } else {
                      await Fluttertoast.showToast(msg: 'User does not exist');
                    }
                  } catch (e) {
                    print('check error is ${ e.toString()}');
                    otpTextController.clear();
                    await Fluttertoast.showToast(msg: e.toString());
                  }
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (otpController.count.value == 0) {
                    Get.back();
                    _phoneSignIn(phone);
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                        (Set<MaterialState> states) => Colors.green,
                  ),
                ),
                child: Obx(
                      () => Text(
                    otpController.count.value == 0
                        ? 'Resend'
                        : 'Resend in ${otpController.count.value}',
                    style: GoogleFonts.ubuntu(color: Colors.white),
                  ),
                ),
              )
            ],
          );
        },
        forceResendingToken: resendToken,
        timeout: const Duration(seconds: 30),
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-resolution timed out...
        },
      );
    } catch (e) {
      EasyLoading.dismiss();
      await Fluttertoast.showToast(msg: 'Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: Stack(
      children: [
        SizedBox(
          height: Get.height,
          width: Get.width,
          child: Image.asset(
            'assets/loginBack.png',
            fit: BoxFit.fill,
          ),
        ),
        //Center(child: Text("PARTY ON",style: GoogleFonts.ubuntu(color: Colors.white,fontSize: 140.sp,fontWeight: FontWeight.bold),),),
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 75.w, right: 75.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: Get.height / 1.3),
                // Text(
                //   "Login through Moblie",
                //   style: TextStyle(color: Colors.white, fontSize: 70.sp),
                // ),

                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.black87,
                  ),
                  child: TextField(
                    autofocus: false,
                    inputFormatters: [LengthLimitingTextInputFormatter(10)],
                    style: GoogleFonts.ubuntu(color: Colors.white),
                    keyboardType: TextInputType.number,
                    controller: _phoneController,
                    decoration: InputDecoration(
                      prefixText: '+91 ',
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.ubuntu(color: Colors.white),
                      icon: const Icon(
                        Icons.call,
                        color: Colors.white,
                      ),
                      hintText: 'Enter mobile number',
                    ),
                  ).marginSymmetric(horizontal: 50.w),
                ),
                SizedBox(
                  height: 30.h,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith(
                            (Set<MaterialState> states) => Colors.orange),
                  ),
                  onPressed: () {
                    _phoneController.value.text.length < 10
                        ? Fluttertoast.showToast(
                      msg: 'Enter a valid number',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 45.sp,
                    )
                        : _phoneSignIn(_phoneController.text);
                  },
                  child: const Text('Send OTP'),
                ),
                SizedBox(
                  height: 30.h,
                ),
                // ElevatedButton(
                //   style: ButtonStyle(backgroundColor:
                //       MaterialStateProperty.resolveWith((states) {
                //     return theme == "light"
                //         ? Colors.black45
                //         : Colors.white38;
                //   })),
                //   onPressed: () {
                //     Get.back();
                //   },
                //   child: Text("Back to Login"),
                // ),
                SizedBox(
                  height: 50.h,
                ),
              ],
            ),
          ),
        ),
        if (theme != 'light') const LogoHead()
      ],
    ),
  );
}

class OtpController extends GetxController {
  RxInt count = 30.obs;

  updateCount() => count.value = 30;

  decCount() => --count.value;
}
