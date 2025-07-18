import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:user/screens/events/event_details.dart';
import 'package:user/screens/home/home_utils.dart';
import 'package:user/screens/product-model.dart';
import 'package:user/utils/details_utils.dart';

import '../../../../utils/networkImage.dart';
import '../../../events/book_events.dart';
import '../../controller/home_controller.dart';

class ThisWeekList extends StatefulWidget {
  const ThisWeekList({super.key});

  @override
  State<ThisWeekList> createState() => _ThisWeekListState();
}

class _ThisWeekListState extends State<ThisWeekList> {


  List? thisWeekEventData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchNextWeekEventData();
  }


  final HomeController hc = Get.put(HomeController());

  void fetchNextWeekEventData() async{
    DateTime now = DateTime.now();
    int weekday = now.weekday;
    DateTime weekStart = now.subtract(Duration(days: weekday - 1));
    DateTime weekEnd = weekStart.add(Duration(days: 6));  // 6 days after weekStart





    QuerySnapshot data = await FirebaseFirestore.instance
        .collection('Events')
        .where('isActive', isEqualTo: true)
    // .where('date', isGreaterThanOrEqualTo: week)
    // .limit(4)
        .get();
    QuerySnapshot clubData =await FirebaseFirestore.instance
        .collection("Club")
        .where("businessCategory", isEqualTo: 1)
        .get();
    thisWeekEventData = data.docs;
    if(hc.city =='All City'){
      thisWeekEventData = data.docs.where((element) {
        return clubData.docs
            .map((ele) => ele['clubUID'])
            .contains(element['clubUID']);
      }).toList();
    }else{
      thisWeekEventData = data.docs.where((element) {
        return clubData.docs.where((e)=>e['city'] == hc.city ||
            e['locality'] == hc.city ||
            hc.showFav == true)
            .map((ele) => ele['clubUID'])
            .contains(element['clubUID']);
      }).toList();

    }

    thisWeekEventData = thisWeekEventData!.where((element) {
      DateTime eventDate = element['date'].toDate(); // Converting to DateTime if it's a Timestamp
      return eventDate.isAfter(weekStart) && eventDate.isBefore(weekEnd);
    }).toList();
    thisWeekEventData!.sort((a, b) => a['date'].toDate().compareTo(b['date'].toDate()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("This Week Events", style: TextStyle(fontSize: 19)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: thisWeekEventData == null
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : thisWeekEventData!.isEmpty
            ? const Center(child: Text("No events found", style: TextStyle(color: Colors.white)))
            : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 450.0),
          itemCount: thisWeekEventData!.length,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final productData = thisWeekEventData![index];

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

            return Center(
              child: GestureDetector(
                onTap: () async {
                  Get.to(BookEvents(clubUID: productDataMap['clubUID'] ?? '', eventID: productData.id,));

                      // Get.to(

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
                  // );
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
              ),
            );
          },
        ),
      ),
    );
  }
}
