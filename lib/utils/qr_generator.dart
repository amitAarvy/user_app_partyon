import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

Widget qrGenerator({
  required String bookingId,
  required String clubUID,
  required String clubID,
  required String eventId,
}) =>
    SizedBox(
      width: 600.h,
      height: 600.h,
      child: PrettyQr(
        elementColor: Colors.white,
        typeNumber: 5,
        size: 200,
        data: '$bookingId|$clubUID|$clubID|$eventId',
        roundEdges: true,
        image: const AssetImage('assets/logo.png'),
      ),
    );
