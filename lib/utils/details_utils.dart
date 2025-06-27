import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/utils/utils.dart';

PreferredSizeWidget eventAppBar(String title, bool isFolded) => AppBar(
      automaticallyImplyLeading: false,
      title: Stack(
        children: [
          Positioned(
            top: 30.h,
            left: -30.h,
            child: Row(
              children: [
                IconButton(
                    onPressed: Get.back,
                    icon: Icon(
                      Icons.arrow_back,
                      size: 60.h,
                    )),
                SizedBox(
                  height: 100.h,
                  width: 250.w,
                  child: Center(
                    child: Text(
                      title.capitalizeFirst!,
                      style: GoogleFonts.montserrat(fontSize: isFolded ? 24.sp : 42.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: Get.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150.w,
                ),
                SizedBox(
                    height: 200.h,
                    width: 300.w,
                    child: Center(
                        child: Text(
                      "PartyOn",
                      style: GoogleFonts.dancingScript(color: Colors.white, fontSize: isFolded ? 40.sp : 80.sp),
                    ))
                    //Image.asset("assets/logo.png"),
                    ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          width: 100.w,
        )
      ],
      backgroundColor: themeRed(),
    );

Widget aboutDetails(String assets, String title, String content, bool isFolded) => Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(height: 70.h, width: 70.h, child: Image.asset(assets, fit: BoxFit.contain)),
      SizedBox(width: 50.w),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          title,
          style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.bold),
        ).marginAll(10.w),
        SizedBox(
            width: 800.h,
            child: Text(
              content,
              style: GoogleFonts.ubuntu(color: Colors.white),
            ).marginAll(10.w))
      ])
    ]).marginOnly(bottom: isFolded ? 10.w : 30.w, top: isFolded ? 0.w : 30.w, left: 10.w);
