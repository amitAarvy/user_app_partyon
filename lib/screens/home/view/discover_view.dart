import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:user/screens/club_details/club_details_provider.dart';
import 'package:user/screens/events/event_details.dart';
import 'package:user/screens/search/seach_club_view.dart';
import 'package:user/utils/dynamic_provider.dart';
import 'package:user/utils/utils.dart';

import '../../events/book_events.dart';

class Discover extends StatefulWidget {
  const Discover({super.key});

  @override
  State<Discover> createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  bool isFolded = false;
  final DynamicProvider dynamicProvider = Get.put(DynamicProvider());
  final EventController eventController = Get.put(EventController());
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  void loadInitialData() async {
    try {
      final eventController = Get.put(EventController());
      DateTime timeNow = DateTime.now();
      DateTime today = DateTime(timeNow.year, timeNow.month, timeNow.day);
      final getData = await FirebaseFirestore.instance.collection('Events').where('isActive', isEqualTo: true).where('date', isGreaterThanOrEqualTo: today).get();
      List dataList = getData.docs;
      for (DocumentSnapshot eventData in dataList) {
        try {
          if (eventData['isActive'] ?? false) {
            DateTime evenDate = eventData.get('date').toDate();
            DateTime tomorrow = today.add(const Duration(days: 1));
            DateTime week = today.add(const Duration(days: 7));
            DateTime month = today.add(const Duration(days: 30));
            Map eventMap = {'eventData': eventData.data(), 'uid': eventData.get('clubUID'), 'eventID': eventData.id};

            if (evenDate.millisecondsSinceEpoch >= today.millisecondsSinceEpoch && evenDate.millisecondsSinceEpoch < tomorrow.millisecondsSinceEpoch) {
              eventController.addToday(eventMap);
            } else if (evenDate.millisecondsSinceEpoch >= tomorrow.millisecondsSinceEpoch && evenDate.millisecondsSinceEpoch < week.millisecondsSinceEpoch) {
              eventController.addTomorrow(eventMap);
            } else if (evenDate.millisecondsSinceEpoch >= week.millisecondsSinceEpoch && evenDate.millisecondsSinceEpoch < month.millisecondsSinceEpoch) {
              eventController.addWeek(eventMap);
            } else if (evenDate.millisecondsSinceEpoch >= month.millisecondsSinceEpoch) {
              eventController.addMonth(eventMap);
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
      loading = false;
    } catch (e) {
      loading = false;
      Fluttertoast.showToast(msg: 'Something went wrong.Please try again');
    }
    setState(() {});
  }

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
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: matte(),
        appBar: AppBar(
          backgroundColor: themeRed(),
          title: GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Discover',
                  style: GoogleFonts.ubuntu(fontSize: isFolded ? 24.sp : 50.sp, color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Get.to(const SearchClub());
              },
              icon: const Icon(Icons.search),
            )
          ],
        ),
        body: loading
            ? Center(
                child: CircularProgressIndicator(
                  color: themeRed(),
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50.h,
                    ),
                    heading('Today'),
                    eventListWidget(eventController.todayList),
                    heading('This Week'),
                    eventListWidget(eventController.tomorrowList),
                    heading('Next Week'),
                    eventListWidget(eventController.nextWeekList),
                    heading('Next Month'),
                    eventListWidget(eventController.nextMonthList),
                  ],
                ),
              ),
      );

  Widget eventListWidget(List list) => SizedBox(
        height: 550.h,
        width: Get.width,
        child: list.isNotEmpty
            ? ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: list.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  try {
                    final DateFormat formatter = DateFormat('dd/MM');
                    Map eventData = list[index]['eventData'];
                    return SizedBox(
                      width: 600.w,
                      height: 600.h * 9 / (isFolded ? 8 : 16),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              final IndexProvider c = Get.put(IndexProvider());
                              c.changeIndex(1);
                              Get.to(BookEvents(
                                clubUID: eventData['clubUID'],
                                eventID: list[index]['eventID'],
                              )

                                  // EventDetails(
                                  //   eventData['coverImages'] as List,
                                  //   'tag',
                                  //   eventData['title'],
                                  //   eventData['date'].toDate(),
                                  //   eventData['venueName'],
                                  //   eventData['genre'],
                                  //   eventData['artistName'],
                                  //   eventID: list[index]['eventID'],
                                  //   startTime: eventData['startTime'].toDate(),
                                  //   endTime: eventData['endTime'].toDate(),
                                  //   aboutEvent: eventData['briefEvent'],
                                  //   clubUID: eventData['clubUID'],
                                  // ),
                                  );
                            },
                            child: SizedBox(
                              height: 500.h * 9 / (isFolded ? 8 : 16),
                              width: 500.w,
                              child: CachedNetworkImage(
                                imageUrl: eventData['coverImages'][0],
                                placeholder: (_, __) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Text(
                            formatter.format(eventData['date'].toDate()),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.ubuntu(
                              color: Colors.white,
                              fontSize: isFolded ? 24.sp : 50.sp,
                            ),
                          ).paddingSymmetric(vertical: 30.h),
                          Text(
                            eventData['title'] ?? '',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.ubuntu(
                              color: Colors.white,
                              fontSize: isFolded ? 24.sp : 50.sp,
                            ),
                          )
                        ],
                      ).marginAll(20.w),
                    );
                  } catch (e) {
                    if (kDebugMode) print(e);
                  }
                  return null;
                },
              )
            : Center(
                child: Text(
                  'No Events found',
                  style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 60.sp),
                ),
              ),
      );

  Widget heading(String heading) => Row(
        children: [
          Text(
            heading,
            style: GoogleFonts.ubuntu(
              color: Colors.white,
              fontSize: 60.sp,
              fontWeight: FontWeight.bold,
            ),
          ).marginAll(20.w),
        ],
      );
}

class EventController extends GetxController {
  RxList todayList = [].obs, tomorrowList = [].obs, nextWeekList = [].obs, nextMonthList = [].obs;

  void addToday(var val) {
    todayList.add(val);
    todayList.refresh();
  }

  void addTomorrow(var val) {
    tomorrowList.add(val);
    todayList.refresh();
  }

  void addWeek(var val) {
    nextWeekList.add(val);
    nextWeekList.refresh();
  }

  void addMonth(var val) {
    nextMonthList.add(val);
    nextMonthList.refresh();
  }
}
