import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:im_animations/im_animations.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:page_transition/page_transition.dart';
import 'package:user/main.dart';

import 'home/controller/home_controller.dart';
import 'home/home_utils.dart';

class Welcome extends StatefulWidget {
  final InitPage initPage;
  const Welcome({required this.initPage, super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  bool show = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('yes it check value ');
    checkForUpdate();


    Future.delayed(Duration(seconds: 3),()async{
      if(kIsWeb){
        await Firebase.initializeApp(
            name: 'MyApp',
            options: FirebaseOptions(
                apiKey: "AIzaSyBdJcZdueFYJLEs26fqSLhjn14ns9CvV1Y",
                authDomain: "partyon-artist.firebaseapp.com",
                databaseURL: "https://partyon-artist-default-rtdb.asia-southeast1.firebasedatabase.app",
                projectId: "partyon-artist",
                storageBucket: "partyon-artist.appspot.com",
                messagingSenderId: "774845460870",
                appId: "1:774845460870:ios:d836926a2ff0600c56bc07",
                measurementId: "G-043F41BTBS"
            )
        );
      }
      Navigator.pushReplacement(
          context,
          PageTransition(
              duration:
              const Duration(milliseconds: 750),
              type: PageTransitionType
                  .rightToLeftWithFade,
              child: widget.initPage));
    });
  }
  final HomeController homeController = Get.put(HomeController());

  void checkForUpdate() async {

    InAppUpdate.checkForUpdate().then((updateInfo) {
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          // Perform an immediate update
          InAppUpdate.performImmediateUpdate().catchError((e) {
            print("Immediate update failed: $e");
          });
        } else if (updateInfo.flexibleUpdateAllowed) {
          // Start a flexible update
          InAppUpdate.startFlexibleUpdate().then((_) { print('yes 3');
            InAppUpdate.completeFlexibleUpdate();
          }).catchError((e) {
            print("Flexible update failed: $e");
          });
        }

      }

    }).catchError((e) {
      print("Error checking for updates: $e");
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        SizedBox(
          width: Get.width,
          height: Get.height,
          child: Image.asset(
            'assets/welcome/welcome.png',
            fit: BoxFit.fill,
          ),
        ),
        Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DelayedDisplay(
                    slidingBeginOffset: const Offset(0, 0.05),
                    delay: const Duration(milliseconds: 750),
                    child: HeartBeat(
                        beatsPerMinute: 60,
                        //curve: Curves.bounceIn,
                        child: GestureDetector(
                          onTap: ()async {
                            if(kIsWeb){
                              await Firebase.initializeApp(
                                  name: 'MyApp',
                                  options: FirebaseOptions(
                                      apiKey: "AIzaSyBdJcZdueFYJLEs26fqSLhjn14ns9CvV1Y",
                                      authDomain: "partyon-artist.firebaseapp.com",
                                      databaseURL: "https://partyon-artist-default-rtdb.asia-southeast1.firebasedatabase.app",
                                      projectId: "partyon-artist",
                                      storageBucket: "partyon-artist.appspot.com",
                                      messagingSenderId: "774845460870",
                                      appId: "1:774845460870:ios:d836926a2ff0600c56bc07",
                                      measurementId: "G-043F41BTBS"
                                  )
                              );
                            }
                            Navigator.pushReplacement(
                                context,
                                PageTransition(
                                    duration:
                                    const Duration(milliseconds: 750),
                                    type: PageTransitionType
                                        .rightToLeftWithFade,
                                    child: widget.initPage));

                          },
                          child: Container(
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black54,
                                    spreadRadius: 1,
                                    blurRadius: 20,
                                  ),
                                  BoxShadow(
                                    color: Color.fromRGBO(24, 58, 95, 1),
                                    spreadRadius: -1,
                                    blurRadius: 10,
                                  )
                                ]),
                            width: 600.h,
                            height: 600.h,
                            child: Image.asset(
                              'assets/welcome/cic_logo.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ))),
                SizedBox(
                  height: 50.h,
                ),
                DelayedDisplay(
                    slidingBeginOffset: const Offset(0, 0.05),
                    delay: const Duration(milliseconds: 750),
                    child: HeartBeat(
                        beatsPerMinute: 35,
                        child: Text(
                          'Enter the world of ultimate party destination',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.kaushanScript(
                              fontSize: 80.sp, color: Colors.white),
                        )))
              ],
            ))
      ],
    ),
  );
}
