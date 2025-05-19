import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/utils/utils.dart';

PreferredSizeWidget eventAppBar(String title) => AppBar(
  automaticallyImplyLeading: false,
  title: Stack(
    children: [
      Positioned(
        top: 30.h,
        left: -50.h,
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
                  style: GoogleFonts.montserrat(
                      fontSize: 42.sp, fontWeight: FontWeight.w600),
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
                      style: GoogleFonts.dancingScript(
                          color: Colors.white, fontSize: 80.sp),
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

Widget aboutDetails(String assets, String title, String content) =>
    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(
          height: 100.h,
          width: 100.h,
          child: Image.asset(assets, fit: BoxFit.contain)),
      SizedBox(width: 50.w),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          title,
          style: GoogleFonts.ubuntu(
              color: Colors.white, fontWeight: FontWeight.bold),
        ).marginAll(10.w),
        SizedBox(
            width: 800.h,
            child: Text(
              content,
              style: GoogleFonts.ubuntu(color: Colors.white),
            ).marginAll(10.w))
      ])
    ]).marginOnly(bottom: 30.w, top: 30.w, left: 10.w);
