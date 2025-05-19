import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget netWorkImage({String? url}){
  return Image.network('$url',

    errorBuilder: (_, __, ___) => Center(
        child: Icon(
          Icons.image,
          color: Colors.white,
          size: 300.h,
        )),
    fit: BoxFit.fill,
  );
}