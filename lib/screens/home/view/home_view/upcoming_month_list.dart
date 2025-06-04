import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:user/screens/events/event_details.dart';
import 'package:user/screens/home/home_utils.dart';
import 'package:user/screens/product-model.dart';
import 'package:user/utils/details_utils.dart';

import '../../../../utils/networkImage.dart';
import '../../../events/book_events.dart';
import '../../controller/home_controller.dart';

class UpcomingMonthList extends StatefulWidget {
  const UpcomingMonthList({super.key});

  @override
  State<UpcomingMonthList> createState() => _UpcomingMonthListState();
}

class _UpcomingMonthListState extends State<UpcomingMonthList> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(const Duration(days: 30));
  DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  List? upcomingMonthData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUpcomingMonthEventData();
  }

  final HomeController hc = Get.put(HomeController());

  void fetchUpcomingMonthEventData() async {
    QuerySnapshot data = await FirebaseFirestore.instance.collection('Events').where('isActive', isEqualTo: true).get();
    QuerySnapshot clubData = await FirebaseFirestore.instance.collection("Club").where("businessCategory", isEqualTo: 1).get();
    upcomingMonthData = data.docs;
    if (hc.city == 'All City') {
      upcomingMonthData = data.docs.where((element) {
        return clubData.docs.map((ele) => ele['clubUID']).contains(element['clubUID']);
      }).toList();
    } else {
      upcomingMonthData = data.docs.where((element) {
        return clubData.docs.where((e) => e['city'] == hc.city || e['locality'] == hc.city || hc.showFav == true).map((ele) => ele['clubUID']).contains(element['clubUID']);
      }).toList();
    }

    upcomingMonthData = upcomingMonthData!.where((element) => element['date'].toDate().isAfter(today)).toList();
    upcomingMonthData!.sort((a, b) => a['date'].toDate().compareTo(b['date'].toDate()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Upcoming Month Events", style: TextStyle(fontSize: 19)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: upcomingMonthData == null
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : upcomingMonthData!.isEmpty
                ? const Center(child: Text("No events found", style: TextStyle(color: Colors.white)))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 450.0),
                    itemCount: upcomingMonthData!.length,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final productData = upcomingMonthData![index];
                      final productDataMap = productData.data() as Map<String, dynamic>;

                      // Check if 'coverImages' exists and is a non-empty list
                      List<dynamic> coverImages = [];
                      if (productDataMap.containsKey('coverImages') && productDataMap['coverImages'] != null && productDataMap['coverImages'] is List && productDataMap['coverImages'].isNotEmpty) {
                        coverImages = productDataMap['coverImages'];
                      } else {
                        coverImages = ['https://via.placeholder.com/200']; // Default image URL if coverImages is missing
                      }

                      // Initialize ProductModel with appropriate values
                      ProductModel productModel = ProductModel(
                        productId: productDataMap['clubUID'] ?? '',
                        categoryId: productDataMap['title'] ?? '',
                        productName: productDataMap['title'] ?? '',
                        categoryName: productDataMap['venueName'] ?? '',
                        salePrice: productDataMap['startTime'] != null ? productDataMap['startTime'].toDate() : DateTime.now(), // Use current date if missing
                        fullPrice: productDataMap['title'] ?? '',
                        productImages: coverImages, // Use validated coverImages list
                      );

                      return GestureDetector(
                        onTap: () async {
                          Get.to(BookEvents(
                            clubUID: productDataMap['clubUID'] ?? '',
                            eventID: productData.id,
                          )

                              // EventDetails(
                              //   coverImages,
                              //   'tag', // Modify this if needed
                              //   productDataMap['title'] ?? '',
                              //   productDataMap['date'].toDate(),
                              //   productDataMap['venueName'] ?? '',
                              //   productDataMap['genre'] ?? '',
                              //   productDataMap['artistName'] ?? '',
                              //   eventID: productData.id,
                              //   startTime: productDataMap['startTime'].toDate(),
                              //   endTime: productDataMap['endTime'].toDate(),
                              //   aboutEvent: productDataMap['briefEvent'] ?? '',
                              //   clubUID: productDataMap['clubUID'] ?? '',
                              // ),
                              );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                // BoxShadow(
                                //   offset: Offset(0, 1.h),
                                //   spreadRadius: 5.h,
                                //   blurRadius: 20.h,
                                //   color: Colors.deepPurple,
                                // ),
                              ],
                              borderRadius: BorderRadius.circular(22),
                              // color: Color(0x42C3C3C3),
                              color: Colors.black,
                            ),
                            // width: Get.width / 2.8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 9 / 16,
                                  child: Container(
                                    // width: Get.width,
                                    // height: 180,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: kIsWeb
                                          ? netWorkImage(url: coverImages[0])
                                          : CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              fadeInDuration: const Duration(milliseconds: 100),
                                              fadeOutDuration: const Duration(milliseconds: 100),
                                              useOldImageOnUrlChange: true,
                                              filterQuality: FilterQuality.low,
                                              imageUrl: coverImages[0], // Use the first image in the list
                                              placeholder: (_, __) => const Center(
                                                child: CircularProgressIndicator(color: Colors.orange),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                Text(
                                  DateFormat.yMMMd().format(productModel.salePrice),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.white,
                                  ),
                                ).paddingOnly(top: 10.0).marginOnly(left: 10.0, right: 10.0),
                                Text(
                                  productModel.productName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 19.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ).paddingOnly(top: 5.0).marginOnly(left: 10.0, right: 10.0),
                                const SizedBox(height: 2),
                                FutureBuilder(
                                  future: FirebaseFirestore.instance.collection('Club').doc(productModel.productId).get(),
                                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) return Offstage();
                                    if (snapshot.hasError) return Offstage();
                                    if (snapshot.hasData) {
                                      return Text(
                                        maxLines: 2,
                                        "${snapshot.data!.data() == null ? '' : (snapshot.data!.data() as Map<String, dynamic>)['address'] ?? ''}",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12.0, color: Colors.white, overflow: TextOverflow.ellipsis),
                                      ).marginOnly(left: 10.0, right: 10.0);
                                    }
                                    return Offstage();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
