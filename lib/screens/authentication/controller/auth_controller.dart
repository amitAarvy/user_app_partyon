import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:user/screens/authentication/views/user_info.dart';
import 'package:user/screens/home/view/home_view.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:user/screens/events/book_events.dart';
class AuthController {
  static Future loginPin(String pin, BuildContext context) {
    //text controller for login pin
    TextEditingController loginPinController = TextEditingController();
    return Get.defaultDialog(
      title: 'Enter Login Pin',
      content: Column(
        children: [
          Center(
            child: PinCodeTextField(
              controller: loginPinController,
              appContext: context,
              autoFocus: true,
              keyboardType: TextInputType.number,
              length: 4,
              onChanged: (String val) {},
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                selectedColor: Colors.black,
                inactiveColor: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) => Colors.black,
              ),
            ),
            onPressed: () {
              if (loginPinController.text.isNotEmpty &&
                  loginPinController.text == pin) {
                Get.off(const HomeView());
              } else {
                Fluttertoast.showToast(msg: 'Invalid Pin');
                loginPinController.clear();
              }
            },
            child: const Text('Login'),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> states) => Colors.black,
              ),
            ),
            onPressed: Get.back,
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }

  static  Future signInUser(BuildContext buildContext, var email, var pass,
      {String? eventID, String? clubUID}) async {
    try {
      await EasyLoading.show(dismissOnTap: false);
      final UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass)
          .whenComplete(EasyLoading.dismiss);
      try {
        await FirebaseFirestore.instance
            .collection('User')
            .doc(credential.user?.uid)
            .get()
            .then((DocumentSnapshot<Map<String, dynamic>> value) {
          if (value.exists) {
            //if eventID and clubID exists go to Book Events else go home
            if (eventID != null && clubUID != null) {
              Get.to(BookEvents(clubUID: clubUID, eventID: eventID));
            } else {
              Get.off(() => const HomeView());
            }
          } else {
            Get.offAll(
              UserInfoData(
                email: (credential.user?.email).toString(),
              ),
            );
          }
        });
      } catch (e) {
        await Get.offAll(
            UserInfoData(email: (credential.user?.email).toString()));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        await Fluttertoast.showToast(msg: 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        await Fluttertoast.showToast(
            msg: 'Wrong password provided for that user.');
      }
    }
  }
  // static Future<UserCredential?> signInWithGoogle() async {
  //   UserCredential? userCred;
  //
  //   try {
  //     await EasyLoading.show();
  //     FirebaseAuth auth = FirebaseAuth.instance;
  //
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //
  //     // Obtain the auth details from the request
  //     final GoogleSignInAuthentication? googleAuth =
  //     await googleUser?.authentication;
  //
  //     // Create a new credential
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth?.accessToken,
  //       idToken: googleAuth?.idToken,
  //     );
  //     UserCredential userCredential =
  //     await auth.signInWithCredential(credential);
  //     await FirebaseFirestore.instance
  //         .collection('User')
  //         .doc(userCredential.user?.uid)
  //         .get()
  //         .then((value) {
  //       if (value.exists) {
  //         EasyLoading.dismiss();
  //         Get.off(() => const HomeView());
  //       } else {
  //         EasyLoading.dismiss();
  //         Get.off(
  //           UserInfoData(
  //             email: (userCredential.user?.email).toString(),
  //           ),
  //         );
  //       }
  //     });
  //     // Once signed in, return the UserCredential
  //     userCred = await FirebaseAuth.instance.signInWithCredential(credential);
  //   } catch (e) {
  //     await EasyLoading.dismiss();
  //     await Fluttertoast.showToast(msg: 'Something went wrong');
  //   }
  //
  //   return userCred;
  // }
}
