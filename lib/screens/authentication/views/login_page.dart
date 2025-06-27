import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';
import 'package:user/core/widgets/logo_head.dart';
import 'package:user/screens/authentication/controller/auth_controller.dart';
import 'package:user/screens/authentication/views/phone.dart';
import 'package:user/screens/authentication/views/sign_up.dart';

class LoginPage extends StatefulWidget {
  final String? eventID;
  final String? clubUID;

  const LoginPage({super.key, this.eventID, this.clubUID});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  var obsText = true;
  dynamic theme;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Stack(
        children: [
          SizedBox(
            height: Get.height,
            width: Get.width,
            child: Image.asset(
              'assets/splash.png',
              fit: BoxFit.fill,
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 500.h,
              ),
              SizedBox(
                height: 200.h,
              ),
              // Container(
              //   height: 120.h,
              //   width: 700.w,
              //   child: Center(
              //     child: Image.asset("assets/gold_heading.png"),
              //   ),
              // ),
              SizedBox(
                height: 100.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 75.w, right: 75.w),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme == 'light'
                            ? Colors.black26
                            : Colors.white38,
                        borderRadius:
                        const BorderRadius.all(Radius.circular(20)),
                      ),
                      padding: EdgeInsets.only(left: 20.w, right: 20.w),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style:
                        GoogleFonts.merriweather(color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintStyle:
                          GoogleFonts.ubuntu(color: Colors.white),
                          icon: const Icon(
                            Icons.email_outlined,
                            color: Colors.white,
                          ),
                          hintText: 'Enter Email',
                        ),
                      ),
                    ),
                    SizedBox(height: 50.h),
                    Container(
                      decoration: BoxDecoration(
                        color: theme == 'light'
                            ? Colors.black26
                            : Colors.white38,
                        borderRadius:
                        const BorderRadius.all(Radius.circular(20)),
                      ),
                      padding: EdgeInsets.only(left: 20.w, right: 20.w),
                      child: TextField(
                        controller: _passController,
                        obscureText: obsText,
                        style:
                        GoogleFonts.merriweather(color: Colors.white),
                        decoration: InputDecoration(
                          suffixIcon: obsText == true
                              ? IconButton(
                            onPressed: () {
                              setState(() {
                                obsText = false;
                              });
                            },
                            icon: const Icon(
                              Icons.visibility_outlined,
                              color: Colors.white,
                            ),
                          )
                              : IconButton(
                            onPressed: () {
                              setState(() {
                                obsText = true;
                              });
                            },
                            icon: const Icon(
                              Icons.visibility_off_outlined,
                              color: Colors.white,
                            ),
                          ),
                          border: InputBorder.none,
                          hintStyle:
                          GoogleFonts.ubuntu(color: Colors.white),
                          icon: const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white,
                          ),
                          hintText: 'Enter Password',
                        ),
                      ),
                    ).paddingOnly(
                      bottom: 50.h,
                    ),
                    GestureDetector(
                      onTap: () {
                        TextEditingController forgotPass =
                        TextEditingController();
                        Get.defaultDialog(
                          title: 'Forgot Password?',
                          titleStyle: GoogleFonts.ubuntu(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 50.sp,
                          ),
                          content: Column(
                            children: [
                              TextField(
                                controller: forgotPass,
                                decoration: const InputDecoration(
                                  hintText: 'Enter Email',
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  FirebaseAuth auth = FirebaseAuth.instance;
                                  try {
                                    await auth.sendPasswordResetEmail(
                                      email: forgotPass.text,
                                    );
                                    await Fluttertoast.showToast(
                                      msg:
                                      'Check your email to reset the password',
                                    );
                                    Get.back();
                                  } on FirebaseAuthException catch (e) {
                                    await Fluttertoast.showToast(
                                      msg: e.code == 'user-not-found'
                                          ? 'User does not exist'
                                          : e.code,
                                    );
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                          (states) => Colors.black),
                                ),
                                child: Text(
                                  'Reset Password',
                                  style: GoogleFonts.ubuntu(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 50.sp,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      child: Container(
                        alignment: Alignment.topRight,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 150.h,
                    ),
                    GestureDetector(
                      onTap: () => _emailController.text == '' ||
                          _passController.text == ''
                          ? Fluttertoast.showToast(
                        msg: 'Invalid email or password',
                      )
                          : EmailValidator.validate(
                        _emailController.text,
                      ) ==
                          false
                          ? Fluttertoast.showToast(
                        msg: 'Enter a valid email',
                      )
                          : AuthController.signInUser(context, _emailController.text,
                          _passController.text,
                          clubUID: widget.clubUID,
                          eventID: widget.eventID),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 65.sp,
                          color: theme == 'light'
                              ? Colors.black
                              : Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.off(const SignUp());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme == 'light'
                              ? Colors.black26
                              : Colors.orange,
                          borderRadius: BorderRadius.circular((20)),
                        ),
                        height: 100.h,
                        width: 500.h,
                        child: Center(
                          child: Text(
                            'Create an account',
                            style: TextStyle(
                              fontSize: 42.sp,
                              fontWeight: FontWeight.bold,
                              color: theme == 'light'
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50.h,
                    ),
                    Center(
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 50.sp,
                          color: theme == 'light'
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.to(const PhoneLogin());
                          },
                          icon: Icon(
                            Icons.call,
                            size: 75.h,
                            color: theme == 'light'
                                ? Colors.black87
                                : Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        // const IconButton(
                        //   onPressed: AuthController.signInWithGoogle,
                        //   icon: Icon(
                        //     FontAwesomeIcons.google,
                        //     color: Colors.redAccent,
                        //   ),
                        // ),
                      ],
                    )
                  ],
                ).marginAll(40.w),
              )
            ],
          ),
          if (theme == 'light')
            Container()
          else
            LogoHead(isWeb: kIsWeb == true ? true : false)
        ],
      ),
    ),
  );
}

Widget colorBack() => Container(
  height: Get.height,
  width: Get.width,
  color: const Color(0XFF0F0F0F),
  child: ClipPath(
      clipper: ProsteBezierCurve(position: ClipPosition.bottom, list: [
        BezierCurveSection(
            start: const Offset(0, 150),
            top: Offset(Get.width / 2, 200),
            end: Offset(Get.width, 150))
      ]),
      child: Container(
          height: 200.h, color: const Color.fromRGBO(247, 0, 67, 1))),
);
