import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/screens/bottom-screens.dart';
import 'package:user/screens/home/view/home_view.dart';
import 'package:user/utils/qr_generator.dart';
import 'package:user/utils/utils.dart';

class BookingInfo extends StatefulWidget {
  final String bookingID, clubID, clubUID, userID,eventId;
  final bool isRedirected;

  const BookingInfo({
    required this.clubUID,
    required this.clubID,
    required this.userID,
    required this.eventId,
    required this.bookingID,
    this.isRedirected = false,
    super.key,
  });

  @override
  State<BookingInfo> createState() => _BookingInfoState();
}

class _BookingInfoState extends State<BookingInfo> {
  TableRow tableRow({
    required String first,
    required String second,
    required String third,
    required String fourth,
  }) =>
      TableRow(
        children: [
          Center(
            child: Text(
              first,
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(
                color: Colors.orange,
                fontSize: 42.sp,
              ),
            ).paddingAll(20.w),
          ),
          Center(
            child: Text(
              second,
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(
                color: Colors.white,
                fontSize: 42.sp,
              ),
            ).paddingAll(20.w),
          ),
          Center(
            child: Text(
              third,
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(
                color: Colors.white,
                fontSize: 42.sp,
              ),
            ).paddingAll(20.w),
          ),
          Center(
            child: Text(
              fourth,
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(
                color: Colors.white,
                fontSize: 42.sp,
              ),
            ).paddingAll(10.w),
          ),
        ],
      );

  TableRow tableRowWidget({required String title, required String value}) =>
      TableRow(
        children: [
          Text(
            title,
            style: GoogleFonts.ubuntu(
              color: Colors.orange,
              fontSize: 45.sp,
            ),
          ).paddingAll(40.w),
          Text(
            value,
            style: GoogleFonts.ubuntu(
              color: Colors.white,
              fontSize: 45.sp,
            ),
          ).paddingAll(40.w),
        ],
      );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  TableBorder customisedTableBorder(
      {double borderRadius = 0, Color? borderColor}) =>
      TableBorder.all(
        borderRadius: BorderRadius.circular(borderRadius),
        color: borderColor ?? Colors.amber,
        style: BorderStyle.solid,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: matte(),
    appBar: AppBar(
      backgroundColor: themeRed(),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () =>
        widget.isRedirected ? Get.to(const BottomNavigationBarExample()) : Get.back(),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Booking ID- ${widget.bookingID}',
            style: GoogleFonts.ubuntu(
              color: Colors.white,
              fontSize: 50.sp,
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
          FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Bookings')
                  .doc(widget.bookingID)
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: Get.height,
                    width: Get.width,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.orange,
                      ),
                    ),
                  );
                } else if (!snapshot.hasData) {
                  return SizedBox(
                    height: Get.height,
                    width: Get.width,
                    child: Center(
                      child: Text(
                        'No Data Found',
                        style: GoogleFonts.ubuntu(
                          color: Colors.white,
                          fontSize: 45.sp,
                        ),
                      ),
                    ),
                  );
                } else {
                  return Column(children: [
                    Text(
                      'Booking Details',
                      style: GoogleFonts.ubuntu(
                        color: Colors.amber,
                        fontSize: 60.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ).paddingAll(40.sp),
                    qrGenerator(
                        bookingId: widget.bookingID,
                        clubID: widget.clubID,
                        clubUID: widget.clubUID,
                      eventId: widget.eventId

                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('Club')
                            .doc(widget.clubUID)
                            .get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox(
                              height: Get.height,
                              width: Get.width,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.orange,
                                ),
                              ),
                            );
                          } else if (!snapshot.hasData) {
                            return SizedBox(
                              height: Get.height,
                              width: Get.width,
                              child: Center(
                                child: Text(
                                  'No Data Found',
                                  style: GoogleFonts.ubuntu(
                                    color: Colors.white,
                                    fontSize: 45.sp,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return
                              FutureBuilder(
                                        future: FirebaseFirestore.instance
                        .collection('Events')
                        .doc(widget.eventId)
                        .get(),
                                        builder: (BuildContext context,
                                        AsyncSnapshot<DocumentSnapshot> snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: Get.height,
                          width: Get.width,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.orange,
                            ),
                          ),
                        );
                      }
                      DateTime startTime = snap.data?.get('startTime').toDate();

                      return  SizedBox(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Venue",
                                  style: GoogleFonts.adamina(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      decorationColor: Colors.white)),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(snapshot.data?.get("clubName"),
                                  style: GoogleFonts.adamina(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      decorationColor: Colors.white)),
                            ),


                            Row(
                              children: [
                                Icon(Icons.door_back_door_outlined, color: Colors.white, size: 70.h),
                                const SizedBox(width: 5),
                                Text("Doors open at ${TimeOfDay(hour: startTime.hour, minute: startTime.minute).hourOfPeriod.toString()}:${TimeOfDay(hour: startTime.hour, minute: startTime.minute).minute.toString().padLeft(2, '0')} ${TimeOfDay(hour: startTime.hour, minute: startTime.minute).period.name}", style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                              ],
                            ),

                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.white, size: 70.h),
                                const SizedBox(width: 5),
                                Text( "${snapshot.data?.get("address")}, ${snapshot.data?.get("area")}, ${snapshot.data?.get("city")}, ${snapshot.data?.get("state")}", style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                              ],
                            ),
                            SizedBox(height: 10,),

                            GestureDetector(
                              onTap:() async{
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('Club')
                                      .doc(widget.clubUID)
                                      .get()
                                      .then((data) {
                                    if (data.exists) {
                                      openMap(data.data()?['latitude'], data.data()?['longitude']);
                                    }
                                  });
                                } catch (e) {
                                  Fluttertoast.showToast(msg: 'Something went wrong');
                                }
                              },
                              child: Container(
                                height:200,
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Text(
                                        "${snapshot.data?.get("address")}, ${snapshot.data?.get("area")}, ${snapshot.data?.get("city")}, ${snapshot.data?.get("state")}",
                                        style: TextStyle(color: Colors.white70, fontSize: 16),
                                      ),
                                    ),
                                    const Align(
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.location_on,
                                        color: Colors.yellow,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          // children: [
                          //   Text(
                          //     'Club Details',
                          //     style: GoogleFonts.ubuntu(
                          //       color: Colors.amber,
                          //       fontSize: 60.sp,
                          //       fontWeight: FontWeight.bold,
                          //     ),
                          //   ).paddingAll(40.sp),
                          //   Table(
                          //     border: TableBorder.all(
                          //       borderRadius: BorderRadius.circular(20),
                          //       color: Colors.amber,
                          //       style: BorderStyle.solid,
                          //     ),
                          //     children: [
                          //       TableRow(
                          //         children: [
                          //           Text(
                          //             'Club Name',
                          //             style: GoogleFonts.ubuntu(
                          //               color: Colors.orange,
                          //               fontSize: 45.sp,
                          //             ),
                          //           ).paddingAll(40.w),
                          //           Text(
                          //             "${snapshot.data?.get("clubName")}",
                          //             style: GoogleFonts.ubuntu(
                          //               color: Colors.white,
                          //               fontSize: 45.sp,
                          //             ),
                          //           ).paddingAll(40.w),
                          //         ],
                          //       ),
                          //       TableRow(
                          //         children: [
                          //           Text(
                          //             'Club Venue',
                          //             style: GoogleFonts.ubuntu(
                          //               color: Colors.orange,
                          //               fontSize: 45.sp,
                          //             ),
                          //           ).paddingAll(40.w),
                          //           Text(
                          //             "${snapshot.data?.get("address")}, ${snapshot.data?.get("area")}, ${snapshot.data?.get("city")}, ${snapshot.data?.get("state")}",
                          //             style: GoogleFonts.ubuntu(
                          //               color: Colors.white,
                          //               fontSize: 45.sp,
                          //             ),
                          //           ).paddingAll(40.w),
                          //         ],
                          //       ),
                          //     ],
                          //   ).paddingAll(40.w),
                          // ],
                        ),
                      );
                                        }


                              );
                          }
                        },
                      ),
                    ),
                    Table(
                      border: TableBorder.all(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.amber,
                      ),
                      children: [
                        tableRowWidget(
                          title: 'Booking ID',
                          value: "${snapshot.data?.get("bookingID")}",
                        ),
                        tableRowWidget(
                          title: 'Category',
                          value:
                          "${snapshot.data?.get("entryList")[0]['categoryName']}",
                        ),
                        tableRowWidget(
                          title: 'Total Entry',
                          value:
                          "${snapshot.data?.get("totalEntranceCount")}",
                        ),
                        tableRowWidget(
                          title: 'Total Table',
                          value:
                          "${getKeyValueFirestore(snapshot.data!, "totalTableCount") ?? 0}",
                        ),
                        tableRowWidget(
                          title: 'Total Amount',
                          value: "₹ ${snapshot.data?.get("amount")}",
                        ),
                        tableRowWidget(
                          title: 'Booking Code',
                          value: "${snapshot.data?.get("bookingCode")}",
                        ),
                      ],
                    ).paddingAll(40.w)
                  ]);
                }
              }),
          FutureBuilder<DatabaseEvent>(
              future: FirebaseDatabase.instance
                  .ref('Bookings')
                  .child(widget.bookingID)
                  .child('entranceList')
                  .once(),
              builder: (context, snapshot) {
                if (kDebugMode) {
                  print(snapshot.data?.snapshot.value);
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(
                    color: Colors.orange,
                  );
                } else if (!snapshot.hasData) {
                  return const SizedBox();
                } else {
                  List entranceList = snapshot.data?.snapshot.value != null
                      ? snapshot.data?.snapshot.value as List
                      : [];
                  if (entranceList.isNotEmpty) {
                    return Column(
                      children: [
                        if (entranceList.isNotEmpty)
                          Text(
                            'Entrance List',
                            style: GoogleFonts.ubuntu(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 60.sp),
                          ),
                        Column(
                          children: [
                            if (entranceList.isNotEmpty)
                              Table(
                                border:
                                customisedTableBorder(borderRadius: 5),
                                children: [
                                  tableRow(
                                      first: 'Name',
                                      second: 'Amount',
                                      third: 'Bookings',
                                      fourth: 'Remaining')
                                ],
                              ),
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount:
                                (snapshot.data?.snapshot.value as List)
                                    .length,
                                itemBuilder: (context, index) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator(
                                      color: Colors.orange,
                                    );
                                  } else {
                                    Map data = entranceList[index] ?? {};
                                    return Table(
                                      border: customisedTableBorder(
                                          borderRadius: 5),
                                      children: [
                                        tableRow(
                                            first:
                                            '${data['categoryName']} ${data['subCategoryName']}',
                                            second:
                                            '₹ ${data['bookingAmount'].toString()}',
                                            third: data['bookingCount']
                                                .toString(),
                                            fourth: data['bookingCountLeft']
                                                .toString())
                                      ],
                                    );
                                  }
                                })
                          ],
                        ).paddingAll(40.w),
                      ],
                    );
                  } else {
                    return const SizedBox();
                  }
                }
              }),
          FutureBuilder<DatabaseEvent>(
              future: FirebaseDatabase.instance
                  .ref('Bookings')
                  .child(widget.bookingID)
                  .child('tableList')
                  .once(),
              builder: (context, snapshot) {
                if (kDebugMode) {
                  print(snapshot.data?.snapshot.value);
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(
                    color: Colors.orange,
                  );
                } else if (!snapshot.hasData) {
                  return const SizedBox();
                } else {
                  List entranceList = snapshot.data?.snapshot.value != null
                      ? snapshot.data?.snapshot.value as List
                      : [];
                  if (entranceList.isNotEmpty) {
                    return Column(
                      children: [
                        if (entranceList.isNotEmpty)
                          Text(
                            'Table List',
                            style: GoogleFonts.ubuntu(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 60.sp),
                          ),
                        Column(
                          children: [
                            if (entranceList.isNotEmpty)
                              Table(
                                border:
                                customisedTableBorder(borderRadius: 5),
                                children: [
                                  tableRow(
                                      first: 'Name',
                                      second: 'Amount',
                                      third: 'Entered',
                                      fourth: 'Remaining')
                                ],
                              ),
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount:
                                (snapshot.data?.snapshot.value as List)
                                    .length,
                                itemBuilder: (context, index) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator(
                                      color: Colors.orange,
                                    );
                                  } else {
                                    Map data = entranceList[index] ?? {};
                                    return Table(
                                      border: customisedTableBorder(
                                          borderRadius: 5),
                                      children: [
                                        tableRow(
                                            first: data['tableName']
                                                .toString(),
                                            second:
                                            '₹ ${data['tablePrice'].toString()}',
                                            third: data['bookingCount']
                                                .toString(),
                                            fourth: data['bookingCountLeft']
                                                .toString())
                                      ],
                                    );
                                  }
                                })
                          ],
                        ).paddingAll(40.w),
                      ],
                    );
                  } else {
                    return const SizedBox();
                  }
                }
              }),
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('User')
                .doc(widget.userID)
                .get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                    ),
                  ),
                );
              } else if (!snapshot.hasData) {
                return SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: Center(
                    child: Text(
                      'No Data Found',
                      style: GoogleFonts.ubuntu(
                        color: Colors.white,
                        fontSize: 45.sp,
                      ),
                    ),
                  ),
                );
              } else {
                return Offstage();
                //   Column(
                //   children: [
                //     Text(
                //       'User Details',
                //       style: GoogleFonts.ubuntu(
                //         color: Colors.amber,
                //         fontSize: 60.sp,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ).paddingAll(40.sp),
                //     Table(
                //       border: TableBorder.all(
                //         borderRadius: BorderRadius.circular(20),
                //         color: Colors.amber,
                //         style: BorderStyle.solid,
                //       ),
                //       children: [
                //         TableRow(
                //           children: [
                //             Text(
                //               'User Name',
                //               style: GoogleFonts.ubuntu(
                //                 color: Colors.orange,
                //                 fontSize: 45.sp,
                //               ),
                //             ).paddingAll(40.w),
                //             Text(
                //               "${snapshot.data?.get("userName").toString().capitalizeFirstOfEach}",
                //               style: GoogleFonts.ubuntu(
                //                 color: Colors.white,
                //                 fontSize: 45.sp,
                //               ),
                //             ).paddingAll(40.w),
                //           ],
                //         ),
                //       ],
                //     ).paddingAll(40.w),
                //   ],
                // );
              }
            },
          ),

        ],
      ),
    ),
  );
}
