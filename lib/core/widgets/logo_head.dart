import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LogoHead extends StatelessWidget {
  final bool isWeb;

  const LogoHead({super.key, this.isWeb = false});

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 100.h,
        height: isWeb == false ? 750.w : 500.h,
        left: isWeb == false ? Get.width / 2 - 500.w : Get.width / 2 - 250.h,
        child: SizedBox(
            height: 1200.h,
            width: 1000.h,
            child: Image.asset('assets/logo.png', fit: BoxFit.contain)));
  }
}
