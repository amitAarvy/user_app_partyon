import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/utils/utils.dart';

import 'booking_info.dart';

class BookingList extends StatefulWidget {
  final bool isRedirected;

  const BookingList({super.key, this.isRedirected = false});

  @override
  State<BookingList> createState() => _BookingListState();
}

class _BookingListState extends State<BookingList> {
  Widget titleWidget(String title) => Expanded(
      child: SizedBox(
          child: Center(
              child: Text(title,
                  style: GoogleFonts.ubuntu(
                    color: Colors.orange,
                    fontSize: 50.sp,
                  )))));

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () => onWillPop(context),
        child: Scaffold(
          backgroundColor: matte(),
          appBar: AppBar(
            backgroundColor: themeRed(),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'My Bookings',
                  style: GoogleFonts.ubuntu(
                    color: Colors.white,
                    fontSize: 60.sp,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                width: 200.w,
              )
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  width: Get.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [titleWidget('Date'), titleWidget('Amount'), titleWidget('BookingID'), titleWidget('Status')],
                  ).paddingAll(20.h),
                ),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('Bookings').where('userID', isEqualTo: uid()).orderBy('date', descending: true).get(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.orange,
                        ),
                      );
                    }
                    if (snapshot.data?.docs.isEmpty == true) {
                      return SizedBox(
                        height: Get.height / 2,
                        width: Get.width,
                        child: Center(
                          child: Text(
                            'No Bookings found',
                            style: GoogleFonts.ubuntu(
                              color: Colors.white,
                              fontSize: 60.sp,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        QueryDocumentSnapshot<Object?>? data = snapshot.data?.docs[index];
                        DateTime date = data?['date'].toDate();
                        return GestureDetector(
                          onTap: () {
                            Get.to(
                              BookingInfo(
                                bookingID: data?['bookingID'],
                                clubUID: data?['clubUID'],
                                clubID: data?['clubID'],
                                userID: data?['userID'],
                                eventId: data?['eventID'],
                              ),
                            );
                          },
                          child: Container(
                            height: 300.h,
                            width: Get.width,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${date.day}-${date.month}-${date.year}',
                                            style: GoogleFonts.ubuntu(
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            "${date.hour}:${date.minute} ${date.hour < 12 ? 'A.M' : 'P.M'}",
                                            style: GoogleFonts.ubuntu(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    child: Center(
                                      child: Text(
                                        "₹ ${data?["amount"]}",
                                        style: GoogleFonts.ubuntu(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    child: Center(
                                      child: Text(
                                        "${data?["bookingID"]}",
                                        style: GoogleFonts.ubuntu(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    child: Center(
                                      child: data?['status'] == 'F'
                                          ? Text(
                                              'Failed',
                                              style: GoogleFonts.ubuntu(
                                                color: Colors.red,
                                              ),
                                            )
                                          : Text(
                                              'Success',
                                              style: GoogleFonts.ubuntu(
                                                color: Colors.green,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).paddingAll(20.h),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
}
