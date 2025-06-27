// ignore_for_file: file_names, prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_card/image_card.dart';
import 'package:intl/intl.dart';
import 'package:user/screens/events/book_events.dart';
import 'package:user/screens/product-model.dart';

import '../utils/app-constant.dart';
import '../utils/networkImage.dart';
import '../utils/utils.dart';
import 'club_details/club_details.dart';
import 'events/event_details.dart';
import 'home/controller/home_controller.dart';
import 'home/view/discover_view.dart';

class PoputerBollywoodView extends StatefulWidget {
  final popularCommercialData;
  const PoputerBollywoodView({super.key, this.popularCommercialData});

  @override
  State<PoputerBollywoodView> createState() => _PoputerBollywoodViewState();
}

class _PoputerBollywoodViewState extends State<PoputerBollywoodView> {
  DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  bool isFolded = false;
  // List? popularCommercialData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // fetchCommercialEventData();
  }

  final HomeController hc = Get.put(HomeController());

  // void fetchCommercialEventData() async{
  //   QuerySnapshot data = await FirebaseFirestore.instance
  //       .collection('Events')
  //       .where('isActive', isEqualTo: true)
  //       .where('genre', isEqualTo: "Bollywood Commercial")
  //   // .where('date', isGreaterThanOrEqualTo: today)
  //       .get();
  //   QuerySnapshot clubData =await FirebaseFirestore.instance
  //       .collection("Club")
  //       .where("businessCategory", isEqualTo: 1)
  //       .get();
  //   popularCommercialData = data.docs;
  //   if(hc.city =='All City'){
  //     popularCommercialData = data.docs.where((element) {
  //       return clubData.docs
  //           .map((ele) => ele['clubUID'])
  //           .contains(element['clubUID']);
  //     }).toList();
  //   }else{
  //     popularCommercialData = data.docs.where((element) {
  //       return clubData.docs.where((e)=>e['city'] == hc.city ||
  //           e['locality'] == hc.city ||
  //           hc.showFav == true)
  //           .map((ele) => ele['clubUID'])
  //           .contains(element['clubUID']);
  //     }).toList();
  //   }
  //
  //   popularCommercialData = data.docs.where((element) => element['date'].toDate().isAfter(today)).toList();
  //   popularCommercialData!.sort((a, b) => a['date'].toDate().compareTo(b['date'].toDate()));
  //   popularCommercialData = popularCommercialData!.sublist(0, popularCommercialData!.length >=10 ? 10 : popularCommercialData!.length);
  //   setState(() {});
  // }
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
    return
        // popularCommercialData == null
        //   ? const Center(child: CircularProgressIndicator(color: Colors.white))
        //   : popularCommercialData!.isEmpty
        //   ? const Center(child: Text("No events found", style: TextStyle(color: Colors.white)))
        //   :
        Container(
      height: 370.0,
      child: ListView.builder(
        itemCount: widget.popularCommercialData!.length,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final productData = widget.popularCommercialData![index];

          // Convert Firestore data to a Map
          final productDataMap = productData.data() as Map<String, dynamic>;

          // Check if coverImages exists and is a valid, non-empty list
          List<dynamic> coverImages = [];
          if (productDataMap.containsKey('coverImages') && productDataMap['coverImages'] != null && productDataMap['coverImages'] is List && productDataMap['coverImages'].isNotEmpty) {
            coverImages = productDataMap['coverImages'];
          } else {
            coverImages = ['https://via.placeholder.com/200']; // Fallback image if not valid
          }

          ProductModel productModel = ProductModel(
            productId: productDataMap['clubUID'] ?? '',
            categoryId: productDataMap['title'] ?? '',
            productName: productDataMap['title'] ?? '',
            categoryName: productDataMap['venueName'] ?? '',
            salePrice: productDataMap['startTime'] != null ? productDataMap['startTime'].toDate() : DateTime.now(),
            fullPrice: productDataMap['title'] ?? '',
            productImages: coverImages,
          );

          return GestureDetector(
            onTap: () async {
              Get.to(
                BookEvents(
                  clubUID: productDataMap['clubUID'] ?? '',
                  eventID: productData.id,
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
                      aspectRatio: 9 / (isFolded ? 8 : 16),
                      child: Container(
                        width: Get.width,
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
                    ).paddingOnly(top: 4.0).marginOnly(left: 10.0, right: 10.0),
                    Text(
                      productModel.productName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 19.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ).paddingOnly(top: 4.0).marginOnly(left: 10.0, right: 10.0),
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
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.white,
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
