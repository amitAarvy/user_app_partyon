// ignore_for_file: file_names, prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import 'package:intl/intl.dart';
import 'package:user/screens/events/book_events.dart';
import 'package:user/screens/product-model.dart';
import '../utils/networkImage.dart';
import 'home/controller/home_controller.dart';
import 'home/view/discover_view.dart';

class UpcomingMonthView extends StatefulWidget {
  final upcomingMonthEventData;
  const UpcomingMonthView({super.key, this.upcomingMonthEventData});

  @override
  State<UpcomingMonthView> createState() => _UpcomingMonthViewState();
}

class _UpcomingMonthViewState extends State<UpcomingMonthView> {

  DateTime month = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(const Duration(days: 30));

  DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  // List? upcomingMonthEventData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // fetchUpcomingMonthEventData();
  }
  final HomeController hc = Get.put(HomeController());

  // void fetchUpcomingMonthEventData() async{
  //   QuerySnapshot data = await FirebaseFirestore.instance
  //       .collection('Events')
  //       .where('isActive', isEqualTo: true)
  //       .get();
  //   QuerySnapshot clubData =await FirebaseFirestore.instance
  //       .collection("Club")
  //       .where("businessCategory", isEqualTo: 1)
  //       .get();
  //   upcomingMonthEventData = data.docs;
  //   if(hc.city =='All City'){
  //     upcomingMonthEventData = data.docs.where((element) {
  //       return clubData.docs
  //           .map((ele) => ele['clubUID'])
  //           .contains(element['clubUID']);
  //     }).toList();
  //   }else{
  //     upcomingMonthEventData = data.docs.where((element) {
  //       return clubData.docs.where((e)=>e['city'] == hc.city ||
  //           e['locality'] == hc.city ||
  //           hc.showFav == true)
  //           .map((ele) => ele['clubUID'])
  //           .contains(element['clubUID']);
  //     }).toList();
  //   }
  //
  //   upcomingMonthEventData = upcomingMonthEventData!.where((element) => element['date'].toDate().isAfter(today)).toList();
  //   upcomingMonthEventData!.sort((a, b) => a['date'].toDate().compareTo(b['date'].toDate()));
  //   upcomingMonthEventData = upcomingMonthEventData!.sublist(0, upcomingMonthEventData!.length >=10 ? 10 : upcomingMonthEventData!.length);
  //   setState(() {});
  // }
  @override
  Widget build(BuildContext context) {
    return
      // upcomingMonthEventData == null
      //   ? const Center(child: CircularProgressIndicator(color: Colors.white))
      //   : upcomingMonthEventData!.isEmpty
      //   ? const Center(child: Text("No events found", style: TextStyle(color: Colors.white)))
      //   :
      Container(
      height: 370.0,
      child: ListView.builder(
        itemCount: widget.upcomingMonthEventData!.length,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final productData =widget.upcomingMonthEventData![index];

          // Convert Firestore data to a Map
          final productDataMap = productData.data() as Map<String, dynamic>;

          // Check if coverImages exists and is a valid, non-empty list
          List<dynamic> coverImages = [];
          if (productDataMap.containsKey('coverImages') &&
              productDataMap['coverImages'] != null &&
              productDataMap['coverImages'] is List &&
              productDataMap['coverImages'].isNotEmpty) {
            coverImages = productDataMap['coverImages'];
          } else {
            coverImages = ['https://via.placeholder.com/200']; // Fallback image if not valid
          }

          ProductModel productModel = ProductModel(
            productId: productDataMap['clubUID'] ?? '',
            categoryId: productDataMap['title'] ?? '',
            productName: productDataMap['title'] ?? '',
            categoryName: productDataMap['venueName'] ?? '',
            salePrice: productDataMap['startTime'] != null
                ? productDataMap['startTime'].toDate()
                : DateTime.now(),
            fullPrice: productDataMap['title'] ?? '',
            productImages: coverImages,
          );

          return GestureDetector(
            onTap: () async {
              Get.to(BookEvents(clubUID: productDataMap['clubUID'] ?? '', eventID: productData.id,

              ),
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
                width: Get.width / 2.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 9/16,
                      child: Container(
                        width: Get.width,
                        // height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child:
                          kIsWeb?
                          netWorkImage(url:coverImages[0] ):
                          CachedNetworkImage(
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
                        if(snapshot.connectionState == ConnectionState.waiting) return Offstage();
                        if(snapshot.hasError) return Offstage();
                        if(snapshot.hasData){
                          return Text(
                            maxLines: 2,
                            "${snapshot.data!.data() == null ? '' : (snapshot.data!.data() as Map<String, dynamic>)['clubName'] ?? ''}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis
                            ),
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
    );
  }
}
