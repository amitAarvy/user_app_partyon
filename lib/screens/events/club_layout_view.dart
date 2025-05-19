import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';

import '../../utils/utils.dart';

class ClubLayout extends StatefulWidget {
  const ClubLayout({super.key, required this.imageURL});
  final String imageURL;

  @override
  State<ClubLayout> createState() => _ClubLayoutState();
}

class _ClubLayoutState extends State<ClubLayout> {
  @override
  void initState() {
    // TODO: implement initState
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: themeRed(),
      title: GestureDetector(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Club Layout',
              style:
              GoogleFonts.ubuntu(fontSize: 50.sp, color: Colors.white),
            ).paddingOnly(right: 100.h),
          ],
        ),
      ),
    ),
    body: Container(
      color: Colors.transparent,
      height: Get.height,
      width: Get.width,
      child: widget.imageURL.isNotEmpty
          ? PhotoView(
        imageProvider: CachedNetworkImageProvider(
          widget.imageURL,
        ),
        loadingBuilder: (_, __) => const Center(
          child: CircularProgressIndicator(
            color: Colors.orange,
          ),
        ),
      )
          : Center(
        child: Text(
          'No Layout Images found',
          style: GoogleFonts.ubuntu(fontSize: 60.sp),
        ),
      ),
    ),
  );
}
