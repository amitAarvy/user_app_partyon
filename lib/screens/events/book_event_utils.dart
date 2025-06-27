import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:user/utils/utils.dart';
import 'book_events_controller.dart';
import 'package:firebase_database/firebase_database.dart' as transaction;

class EntranceDataWidget extends StatefulWidget {
  final String eventID;

  const EntranceDataWidget({required this.eventID, super.key});

  @override
  State<EntranceDataWidget> createState() => _EntranceDataWidgetState();
}

class _EntranceDataWidgetState extends State<EntranceDataWidget> {
  bool isFolded = false;
  late Stream<List<dynamic>> entranceListStream;
  final BookingProvider bookingProvider = Get.put(BookingProvider());

  @override
  void initState() {
    super.initState();
    entranceListStream = getEntranceListStream(widget.eventID);
    // entranceListStream = FirebaseFirestore.instance.collection("Events").doc(widget.eventID).snapshots();
  }

  @override
  void dispose() {
    super.dispose();
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

  Map<dynamic, dynamic>? _nextAvailableSubCategory(List<dynamic> subCategories) => subCategories.firstWhere(
        (subCategory) => int.parse(subCategory['entryCategoryCountLeft'].toString()) > 0,
        orElse: () => null,
      );

  Widget entranceCategoryDataRow(String categoryName, String entryCategoryName, int categoryEntryLeft, double entryCategoryPrice, List subCategories, int index) => Column(
        children: [
          Row(
            children: [
              Text(
                categoryName.toString().capitalizeFirstOfEach,
                style: const TextStyle(color: Colors.orange),
              ),
            ],
          ).paddingOnly(top: 30.h, left: 30.w),
          SizedBox(
            height: kIsWeb ? 500.h : 200.h,
            width: Get.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SizedBox(
                    child: Center(
                      child: Text(
                        entryCategoryName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(
                          color: Colors.white,
                          fontSize: isFolded ? 24.sp : 45.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                // Text('${categoryEntryLeft}',style: TextStyle(color: Colors.white),),
                Expanded(
                  child: SizedBox(
                    child: Center(
                      child: Obx(() => Text(
                            categoryEntryLeft < 0 ? 'Sold Out' : '${categoryEntryLeft - bookingProvider.getBookingCount(index)} left',
                            style: GoogleFonts.ubuntu(
                              color: categoryEntryLeft < 0 ? Colors.red : Colors.orange,
                              fontSize: isFolded ? 24.sp : 45.sp,
                            ),
                          )),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (entryCategoryPrice == 0)
                            Text(
                              'Free',
                              style: GoogleFonts.ubuntu(
                                color: Colors.green,
                                fontSize: isFolded ? 24.sp : 45.sp,
                              ),
                            )
                          else
                            Text(
                              '₹ $entryCategoryPrice',
                              style: GoogleFonts.ubuntu(
                                color: Colors.white,
                                fontSize: isFolded ? 24.sp : 45.sp,
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (bookingProvider.getBookingCount(index) > 0) {
                                    bookingProvider.decBookingCount(index);
                                  }

                                  updateBookingList(index, subCategories, entryCategoryPrice.toDouble(), bookingProvider, categoryName: categoryName);

                                  Provider.of<EntryController>(context, listen: false).updatePriceEntryList(bookingProvider.getBookingList);
                                  if (kDebugMode) {
                                    print(Provider.of<EntryController>(context, listen: false).entryList);
                                  }
                                },
                                child: Icon(
                                  Icons.remove,
                                  size: isFolded ? 34.sp : 70.sp,
                                  color: Colors.orange,
                                ),
                              ).paddingOnly(
                                left: 20.w,
                                right: 10.w,
                              ),
                              Obx(
                                () => Text(
                                  '${bookingProvider.getBookingCount(index)}',
                                  style: GoogleFonts.ubuntu(color: Colors.white, fontSize: isFolded ? 24.sp : 45.sp),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (categoryEntryLeft != 0 && bookingProvider.getBookingCount(index) < categoryEntryLeft) {
                                    bookingProvider.incBookingCount(index);

                                    updateBookingList(index, subCategories, entryCategoryPrice.toDouble(), bookingProvider, categoryName: categoryName);
                                    Provider.of<EntryController>(context, listen: false).updatePriceEntryList(bookingProvider.getBookingList);
                                  }
                                },
                                child: Icon(
                                  Icons.add,
                                  size: isFolded ? 35.sp : 70.sp,
                                  color: Colors.orange,
                                ),
                              ).paddingOnly(
                                left: 20.w,
                                right: 10.w,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ).paddingAll(30.w),
          )
        ],
      );

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Events').doc(widget.eventID).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          } else {
            final entranceList = snapshot.data!['entranceList'];

            return ListView.builder(
              itemCount: entranceList.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final entrance = entranceList[index];
                final categoryName = entrance['categoryName'];
                List subCategories = entrance['subCategory'];

                // Find the next available subcategory
                final availableSubCategory = _nextAvailableSubCategory(subCategories);

                if (availableSubCategory != null) {
                  final entryCategoryName = availableSubCategory['entryCategoryName'];
                  final entryCategoryPrice = int.parse(availableSubCategory['entryCategoryPrice'].toString());
                  final categoryEntryLeft = int.parse(availableSubCategory['entryCategoryCountLeft'].toString());

                  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                    if (bookingProvider.getBookingCount(index) > categoryEntryLeft) {
                      bookingProvider.changeBookingCount(index, categoryEntryLeft);
                    }
                    updateBookingList(index, subCategories, entryCategoryPrice.toDouble(), bookingProvider, categoryName: categoryName);
                    Provider.of<EntryController>(context, listen: false).updatePriceEntryList(bookingProvider.getBookingList);
                  });

                  return entranceCategoryDataRow(categoryName, entryCategoryName, categoryEntryLeft, entryCategoryPrice.toDouble(), subCategories, index);
                } else {
                  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                    bookingProvider.changeBookingCount(index, 0);
                    updateBookingList(index, subCategories, 0, bookingProvider, categoryName: categoryName);
                    Provider.of<EntryController>(context, listen: false).updatePriceEntryList(bookingProvider.getBookingList);
                  });
                  final emptySubCategory = subCategories[0];
                  final entryCategoryName = emptySubCategory['entryCategoryName'];
                  final entryCategoryPrice = int.parse(emptySubCategory['entryCategoryPrice'].toString());
                  final categoryEntryLeft = int.parse(0.toString());
                  return entranceCategoryDataRow(categoryName, entryCategoryName, categoryEntryLeft, entryCategoryPrice.toDouble(), subCategories, index);
                }
              },
            );
          }
        },
      );
}

class TableList extends StatefulWidget {
  final QueryDocumentSnapshot tableData;
  final int index;

  const TableList({required this.index, required this.tableData, super.key});

  @override
  State<TableList> createState() => _TableListState();
}

class _TableListState extends State<TableList> {
  bool isFolded = false;
  BookingProvider bookingProvider = Get.put(BookingProvider());

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
  Widget build(BuildContext context) => Consumer<EntryTableController>(
        builder: (BuildContext context, EntryTableController data, Widget? child) => widget.tableData['tableAvail'] != 0
            ? SizedBox(
                height: kIsWeb ? 300.h : 200.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.defaultDialog(
                          title: 'Includes',
                          content: Text(
                            '${widget.tableData["tableInclusion"] != '' ? widget.tableData["tableInclusion"] : 'Only Entry'}',
                            style: GoogleFonts.ubuntu(color: Colors.black),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: Get.width / 4.5,
                        child: Center(
                          child: Text(
                            widget.tableData['tableName'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ubuntu(
                              color: Colors.white,
                              fontSize: isFolded ? 24.sp : 45.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: Get.width / 4.5,
                      child: widget.tableData['tableLeft'] != 0
                          ? Center(
                              child: Text(
                                "${widget.tableData["tableLeft"] - data.numTable[widget.index]} left",
                                style: GoogleFonts.ubuntu(
                                  color: Colors.red,
                                  fontSize: isFolded ? 24.sp : 45.sp,
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                'Sold Out',
                                style: GoogleFonts.ubuntu(
                                  color: Colors.red,
                                  fontSize: isFolded ? 24.sp : 45.sp,
                                ),
                              ),
                            ),
                    ),
                    SizedBox(
                      width: Get.width / 4.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Seats: ${widget.tableData["seatsAvail"]}",
                            style: GoogleFonts.ubuntu(
                              color: Colors.white,
                              fontSize: isFolded ? 24.sp : 45.sp,
                            ),
                          ),
                          if (widget.tableData['tablePrice'] != 0)
                            Text(
                              "₹ ${widget.tableData["tablePrice"]}",
                              style: GoogleFonts.ubuntu(
                                color: Colors.white,
                                fontSize: isFolded ? 24.sp : 45.sp,
                              ),
                            )
                          else
                            Text(
                              'Free',
                              style: GoogleFonts.ubuntu(
                                color: Colors.green,
                                fontSize: isFolded ? 24.sp : 45.sp,
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: Get.width / 4.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (data.numTable[widget.index] > 0) {
                                    data.updateNumTable(
                                      widget.index,
                                      data.numTable[widget.index] - 1,
                                    );
                                    bookingProvider.modifyTableBookingList(
                                      tableIndex: widget.index,
                                      tableName: widget.tableData["tableName"],
                                      bookingCount: data.numTable[widget.index],
                                      bookingAmount: double.parse(widget.tableData["tablePrice"].toString()),
                                      seatsAvailable: widget.tableData["seatsAvail"],
                                    );
                                  }
                                },
                                child: Center(
                                  child: Icon(
                                    Icons.remove,
                                    size: isFolded ? 35.sp : 70.sp,
                                    color: Colors.orange,
                                  ),
                                ).paddingOnly(left: 20.w, right: 15.w),
                              ),
                              Text(
                                '${data.numTable[widget.index]}',
                                style: GoogleFonts.ubuntu(
                                  color: Colors.white,
                                  fontSize: isFolded ? 24.sp : 45.sp,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (widget.tableData['tableLeft'] != 0 && data.numTable[widget.index] < widget.tableData['tableLeft']) {
                                    data.updateNumTable(
                                      widget.index,
                                      data.numTable[widget.index] + 1,
                                    );
                                    bookingProvider.modifyTableBookingList(
                                      tableIndex: widget.index,
                                      tableName: widget.tableData["tableName"],
                                      bookingCount: data.numTable[widget.index],
                                      bookingAmount: double.parse(widget.tableData["tablePrice"].toString()),
                                      seatsAvailable: widget.tableData["seatsAvail"],
                                    );
                                  }
                                  if (kDebugMode) {
                                    print(data.tableName);
                                  }
                                },
                                child: Center(
                                  child: Icon(
                                    Icons.add,
                                    size: isFolded ? 35.sp : 70.sp,
                                    color: Colors.orange,
                                  ),
                                ),
                              ).paddingOnly(left: 20.w, right: 15.w)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).paddingOnly(left: 30.w, right: 30.w)
            : Container(),
      );
}

Stream<List<dynamic>> getEntranceListStream(String eventID) {
  final rtdb = FirebaseDatabase.instance.ref();
  final entranceListRef = rtdb.child('Events/$eventID/entranceList');

  return entranceListRef.onValue.map((event) {
    final data = event.snapshot.value as List<dynamic>;
    return data;
  });
}

Future<void> updateAsTransaction(String eventID, String categoryId, String subcategoryId, int increment) async {
  try {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('Events/$eventID/entranceList/$categoryId/subCategory/$subcategoryId/entryCategoryCountLeft');
    await ref.runTransaction((mutableData) {
      return transaction.Transaction.success(((mutableData) as int? ?? 0) + increment);
      // else return Transaction.abort();
    });
  } on FirebaseException catch (e) {
    if (kDebugMode) {
      print(e.message);
    }
  }
}

void updateBookingList(int index, List subCategories, double bookingAmount, BookingProvider bookingProvider, {required String categoryName}) {
  int subIndex = 0;
  for (int i = 0; i < subCategories.length; i++) {
    if (int.parse(subCategories[i]['entryCategoryCountLeft'].toString()) > 0) {
      subIndex = i;
      break;
    }
  }
  bookingProvider.modifyBookingList(index, subIndex, bookingProvider.getBookingCount(index), bookingAmount, subCategoryName: subCategories[subIndex]['entryCategoryName'], categoryName: categoryName);
}
