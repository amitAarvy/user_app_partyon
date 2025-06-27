import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:user/screens/events/book_events.dart';
import 'package:user/utils/details_utils.dart';
import 'package:user/utils/terms_n_conditions.dart';
import 'package:user/utils/utils.dart';

class EventDetails extends StatefulWidget {
  final String tag, title, location, genre, artistName, eventID, aboutEvent, clubUID;
  final DateTime startTime, endTime;
  final bool isPast;
  final DateTime date;
  final List coverLink;

  const EventDetails(
    this.coverLink,
    this.tag,
    this.title,
    this.date,
    this.location,
    this.genre,
    this.artistName, {
    required this.clubUID,
    required this.eventID,
    required this.startTime,
    required this.endTime,
    required this.aboutEvent,
    this.isPast = false,
    super.key,
  });

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  bool isTnC = false;
  bool isFolded = false;

  Widget eventBox(
    String img,
    String title,
    String content, {
    bool isIconImg = false,
    bool isAboutEvent = false,
    bool isDateCalender = false,
    DateTime? startTime,
    DateTime? endTime,
  }) =>
      GestureDetector(
          onTap: () {
            if (isAboutEvent) {
              Get.defaultDialog(
                  title: 'About Event',
                  content: Text(
                    content,
                    style: GoogleFonts.ubuntu(fontSize: 50.sp),
                  ).paddingSymmetric(horizontal: 30.w));
            }
          },
          child: Container(
            height: 350.h,
            width: Get.width - 100.w,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 1.h),
                  spreadRadius: 5.h,
                  blurRadius: 20.h,
                  color: Colors.deepPurple,
                )
              ],
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
            ),
            child: isDateCalender == true
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$title : $content',
                            style: GoogleFonts.montserrat(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ).marginAll(10.w),
                          if (startTime != null)
                            Text(
                              'Start Time: ${DateFormat('hh : mm a').format(startTime)}',
                              style: GoogleFonts.ubuntu(color: Colors.white),
                            ),
                          SizedBox(
                            height: 20.h,
                          ),
                          if (endTime != null)
                            Text(
                              'Upto: ${DateFormat('hh : mm a').format(endTime)}',
                              style: GoogleFonts.ubuntu(color: Colors.white),
                            )
                        ],
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 100.h,
                        width: 100.h,
                        child: isIconImg
                            ? Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 90.h,
                              )
                            : Image.asset(
                                img,
                                fit: BoxFit.contain,
                              ),
                      ),
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ).marginAll(10.w),
                      Text(
                        content,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.ubuntu(
                          color: Colors.white70,
                        ),
                      ).marginAll(10.w),
                    ],
                  ).paddingSymmetric(horizontal: 30.w),
          )).marginOnly(top: 30.h, bottom: 30.h);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Detect fold (hinge) using displayFeatures
    final displayFeatures = MediaQuery.of(context).displayFeatures;

    // Hinge is considered if there's a display feature of type 'hinge'
    final isFoldedPhone = displayFeatures.any((feature) => feature.type == DisplayFeatureType.fold && feature.bounds != Rect.zero);

    setState(() {
      isFolded = isFoldedPhone;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: eventAppBar('Event Details', isFolded),
      backgroundColor: matte(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            eventCarousel(widget.coverLink, isNetworkImage: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("${TimeOfDay(hour: widget.startTime.hour, minute: widget.startTime.minute).hourOfPeriod.toString()}:${TimeOfDay(hour: widget.startTime.hour, minute: widget.startTime.minute).minute.toString().padLeft(2, '0')} ${TimeOfDay(hour: widget.startTime.hour, minute: widget.startTime.minute).period.name} Onwards",
                      style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                  const SizedBox(height: 5),
                  Text(DateFormat.yMMMd().format(widget.date), style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                  const SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.black),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(widget.title.capitalize!, style: GoogleFonts.adamina(fontSize: 25, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 10),
                        Text("About event : ", style: GoogleFonts.adamina(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white, decoration: TextDecoration.underline, decorationColor: Colors.white, decorationThickness: 1)),
                        const SizedBox(height: 5),
                        Text(widget.aboutEvent, style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                        const SizedBox(height: 15),
                        Text("Date: ${DateFormat.yMMMMEEEEd().format(widget.date)}", style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                        const SizedBox(height: 15),
                        Text("Time: ${TimeOfDay(hour: widget.startTime.hour, minute: widget.startTime.minute).hourOfPeriod.toString()}:${TimeOfDay(hour: widget.startTime.hour, minute: widget.startTime.minute).minute.toString().padLeft(2, '0')} ${TimeOfDay(hour: widget.startTime.hour, minute: widget.startTime.minute).period.name} Onwards",
                            style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                        const SizedBox(height: 15),
                        Text("Duration: ${widget.endTime.difference(widget.startTime).inHours} hours", style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                        const SizedBox(height: 15),
                        Text("Artist: ${widget.artistName}", style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                        const SizedBox(height: 15),
                        Text("Genre: ${widget.genre}", style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                        const SizedBox(height: 15),
                        // Text("Band Type: ${bandType}", style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            // Text(
            //   widget.title,
            //   style: GoogleFonts.adamina(
            //     fontWeight: FontWeight.bold,
            //     fontSize: 60.sp,
            //     color: Colors.white,
            //   ),
            // ).marginAll(30.w),
            // SizedBox(height: 25.h),
            // SizedBox(
            //  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            // width: Get.width,
            // child: Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            // eventBox(
            //   'assets/calender.png',
            //   'Date',
            //   '${widget.date.day} ${getMonthName(widget.date.month)}, ${widget.date.year}',
            //   isDateCalender: true,
            //   startTime: widget.startTime,
            //   endTime: widget.endTime,
            // ),
            // eventBox(
            //   '',
            //   'About Event',
            //   widget.aboutEvent,
            //   isAboutEvent: true,
            //   isIconImg: true,
            // ),
            // GestureDetector(
            //   onTap: () async {
            //     await FirebaseFirestore.instance
            //         .collection('Club')
            //         .doc(widget.clubUID)
            //         .get()
            //         .then((data) {
            //       if (data.exists) {
            //         openMap(data.data()?['latitude'],
            //             data.data()?['longitude']);
            //       }
            //     });
            //   },
            //   child: eventBox(
            //     'assets/location.png',
            //     'Location',
            //     widget.location,
            //   ),
            // ),
            // eventBox(
            //   'assets/artist.png',
            //   'Artist',
            //   widget.artistName,
            // ),
            // eventBox('assets/genre.png', 'Genre', widget.genre),
            //     ],
            //   ).marginAll(50.w),
            // ),
            SizedBox(
              height: 30.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  fillColor: MaterialStateProperty.resolveWith(
                    (states) => Colors.orange,
                  ),
                  value: isTnC,
                  onChanged: (val) {
                    setState(() {
                      isTnC = val!;
                    });
                  },
                ),
                Text(
                  'I agree to the ',
                  style: GoogleFonts.ubuntu(color: Colors.white),
                ),
                GestureDetector(
                  onTap: () => Get.bottomSheet(
                    Container(
                      color: Colors.white,
                      width: Get.width,
                      height: Get.height,
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                Text(
                                  'Terms & Conditions',
                                  style: GoogleFonts.ubuntu(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 50.h,
                                ),
                                Text(
                                  tnc,
                                  style: GoogleFonts.ubuntu(fontSize: 40.sp),
                                ),
                              ],
                            ),
                          ).paddingAll(40.w),
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: Get.back,
                              icon: const Icon(Icons.close),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  child: Text(
                    'Terms & Conditions',
                    style: GoogleFonts.ubuntu(color: Colors.orange),
                  ),
                ),
                SizedBox(
                  width: 30.w,
                )
              ],
            ),
            SizedBox(
              height: 30.h,
            ),
            if (widget.endTime.millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch)
              ElevatedButton(
                onPressed: () {
                  if (isTnC == true) {
                    Get.to(
                      BookEvents(
                        clubUID: widget.clubUID,
                        eventID: widget.eventID,
                      ),
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: 'Please agree to Terms & Conditions to continue',
                    );
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                    (states) => themeRed(),
                  ),
                ),
                child: const Text('Book Event'),
              )
            else
              Text(
                'Event Over',
                style: GoogleFonts.ubuntu(
                  color: Colors.white,
                  fontSize: 60.sp,
                ),
              ).paddingAll(50.h)
          ],
        ).marginAll(20.w).paddingSymmetric(vertical: 50.h),
      ),
    );
  }
}
