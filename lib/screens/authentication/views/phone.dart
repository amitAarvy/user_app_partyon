import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
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
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'package:msg91/msg91.dart';

class PhoneLogin extends StatefulWidget {
  final String? eventID;

  const PhoneLogin({super.key, this.eventID});

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  bool isFolded = false;
  final templateId = "685cec7ad6fc05713b4079e2";
  dynamic theme;
  late Msg91 msg91;
  late dynamic msgOtp;
  final OtpController otpController = Get.put(OtpController());

  @override
  void initState() {
    super.initState();
    msg91 = Msg91().initialize(authKey: "456047A13TTYLdn684c3039P1");
    msgOtp = msg91.getOtp();

    print('yes login page  is ');
  }

  String generateOtp() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString(); // Ensures 4-digit OTP
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
  String? generatedOtp;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> _phoneSignIn(var phone) async {
    TextEditingController otpTextController = TextEditingController();

    try {
      EasyLoading.dismiss();
      await EasyLoading.show();

      // Error handling.
      try {
        generatedOtp = generateOtp();
        Map<String, String> variables = {"OTP": generatedOtp!};
        final response = await msg91.getSMS().send(flowId: templateId, recipient: SmsRecipient(mobile: "+91$phone", key: variables));

        final message = response["message"];
        if (message != null && message.toString().trim().isNotEmpty) {
          print('OTP sent successfully!');
          await EasyLoading.dismiss();
          startTimer();

          await Get.defaultDialog(
            title: 'Enter OTP',
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                PinCodeTextField(
                  length: 4,
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
                    print(generatedOtp);
                    print(code);
                    if (generatedOtp == code) {
                      print('check is ${phone}');

                      final url = Uri.parse('https://generatetoken-774845460870.asia-south1.run.app');
                      final response = await http.post(
                        url,
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({'phone': phone}),
                      );

                      print(response.body);
                      print(response.statusCode);

                      if (response.statusCode == 200) {
                        final Map<String, dynamic> data = jsonDecode(response.body);
                        final token = data["token"];
                        print(data);

                        // Get user credentials.
                        UserCredential userCredential = await FirebaseAuth.instance.signInWithCustomToken(token);

                        // If user exists, then only proceed with user check in Firestore.
                        if (userCredential.user != null) {
                          // Proceed with user check in Firestore
                          final userDoc = await FirebaseFirestore.instance.collection('User').doc(userCredential.user!.uid).get();

                          if (userDoc.exists) {
                            await Get.off(() => const BottomNavigationBarExample());
                          } else {
                            Get.off(UserInfoData(
                              email: userCredential.user?.email ?? '',
                              isPhone: true,
                            ));
                          }
                        } else {
                          // Style guide.
                          Fluttertoast.showToast(msg: 'Failed to sign in with custom token');
                        }
                      } else {
                        Fluttertoast.showToast(msg: 'Failed to get token. Status: $response');
                        return null;
                      }
                    } else {
                      print('OTP verification failed: $response');
                      await Fluttertoast.showToast(msg: 'OTP verification failed');
                    }
                  } catch (e) {
                    print('check error is ${e.toString()}');
                    otpTextController.clear();
                    await Fluttertoast.showToast(msg: e.toString());
                  }
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (otpController.count.value != 0) {
                    await Fluttertoast.showToast(msg: 'Please wait for few seconds before resending.');
                  } else {
                    try {
                      startTimer();
                      generatedOtp = generateOtp();
                      print("reseent otp");
                      print(generatedOtp);
                      Map<String, String> variables = {"OTP": generatedOtp!};
                      final response = await msg91.getSMS().send(flowId: templateId, recipient: SmsRecipient(mobile: "+91$phone", key: variables));

                      final message = response["message"];
                      if (message != null && message.toString().trim().isNotEmpty) {
                        await Fluttertoast.showToast(msg: 'OTP resent successfully');
                      } else {
                        await Fluttertoast.showToast(msg: 'Failed to resend OTP');
                      }
                    } catch (e) {
                      await Fluttertoast.showToast(msg: e.toString());
                    }
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                        (Set<MaterialState> states) => Colors.green,
                  ),
                ),
                child: Obx(
                      () => Text(
                    otpController.count.value == 0 ? 'Resend' : 'Resend in ${otpController.count.value}',
                    style: GoogleFonts.ubuntu(color: Colors.white),
                  ),
                ),
              )
            ],
          );
        } else {
          print('Failed to send OTP: $response');
        }
      } on TimeoutException {
        // Style guide.
        Fluttertoast.showToast(msg: 'Otp verification timeout. Please try again.');

        // Dismiss the loading indicator.
        await EasyLoading.dismiss();

        // Report failure.
        return;
      } catch (e) {
        // Style guide.
        print('Error while waiting for otp verification: $e');
        Fluttertoast.showToast(msg: 'Something went wrong. Please try again.');

        // Dismiss the loading indicator.
        await EasyLoading.dismiss();

        // Report failure.
        return;
      }
    } catch (e) {
      EasyLoading.dismiss();
      await Fluttertoast.showToast(msg: 'Something went wrong');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Detect fold (hinge) using displayFeatures
    final displayFeatures = MediaQuery.of(context).displayFeatures;

    // Hinge is considered if there's a display feature of type 'hinge'
    final isFoldedPhone = displayFeatures.any((feature) => feature.type == DisplayFeatureType.fold && feature.bounds != Rect.zero);

    setState(() {
      isFolded = isFoldedPhone;
    });
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
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) => Colors.orange),
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
                        fontSize: isFolded ? 24.sp : 45.sp,
                      )
                          : _phoneSignIn(_phoneController.text);
                    },
                    child: const Text('Send OTP'),
                  )
                ]),
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