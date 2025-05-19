import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/utils/utils.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: matte(),
    appBar: AppBar(
      backgroundColor: themeRed(),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 200.h,
            width: 300.h,
            child: Center(
              child: Text(
                'PartyOn',
                style: GoogleFonts.dancingScript(
                  fontSize: 80.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 100.h,
            height: 100.h,
          )
        ],
      ),
    ),
    body: SizedBox(
      height: Get.height,
      width: Get.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Help',
            style: TextStyle(color: Colors.white, fontSize: 60.sp),
          ),
          SizedBox(
            height: 100.h,
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Contact us at : ',
                  style: TextStyle(color: Colors.white, fontSize: 50.sp),
                ),
                TextSpan(
                  text: ' partyonuser@gmail.com',
                  style: TextStyle(color: Colors.orange, fontSize: 50.sp),
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}
