import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_page.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _cpassController = TextEditingController();
  bool obsText = true;
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
          colorBack(),
          Column(
            children: [
              SizedBox(
                height: 500.h,
              ),
              SizedBox(
                height: 300.h,
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
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        style:
                        GoogleFonts.merriweather(color: Colors.white),
                        decoration: InputDecoration(
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
                        controller: _cpassController,
                        obscureText: obsText == true ? true : false,
                        keyboardType: TextInputType.visiblePassword,
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
                          hintText: 'Confirm Password',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 150.h,
                    ),
                    GestureDetector(
                      onTap: () {
                        _emailController.text.isEmpty ||
                            _passController.text.isEmpty
                            ? Fluttertoast.showToast(
                          msg: 'Invalid email or password.',
                        )
                            : EmailValidator.validate(
                          _emailController.text,
                        ) ==
                            false
                            ? Fluttertoast.showToast(
                          msg: 'Enter a valid email',
                        )
                            : _passController.text ==
                            _cpassController.text
                            ? signUp(
                          _emailController.text,
                          _passController.text,
                        )
                            : Fluttertoast.showToast(
                          msg: 'Passwords do not match',
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.circular((20)),
                        ),
                        height: 100.h,
                        width: 350.w,
                        child: Center(
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.ubuntu(
                              fontSize: 60.sp,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    GestureDetector(
                      onTap: () => Get.off(const LoginPage()),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme == 'light'
                              ? Colors.black26
                              : Colors.orange,
                          borderRadius: BorderRadius.circular((20)),
                        ),
                        height: 100.h,
                        width: 350.w,
                        child: Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: theme == 'light'
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          if (theme == 'light')
            Container()
          else
            Positioned(
              height: 500.w,
              left: Get.width / 2 - 250.w,
              child: Image.asset(
                'assets/gold_logo.png',
              ),
            ),
        ],
      ),
    ),
  );
}

Future signUp(var email, var pass) async {
  try {
    await EasyLoading.show();
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: pass,
    )
        .whenComplete(() => EasyLoading.dismiss());

    await Fluttertoast.showToast(msg: 'You have successfully signed up.');
    await Get.off(() => const LoginPage());
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      await Fluttertoast.showToast(msg: 'The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      await Fluttertoast.showToast(
          msg: 'The account already exists for that email.');
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
}
