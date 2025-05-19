import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:user/screens/events/event_details.dart';
import 'package:user/screens/product-model.dart';

import '../../../events/book_events.dart';
import '../../controller/home_controller.dart';

class CategoryOnEvent extends StatefulWidget {
  final String catName;
  const CategoryOnEvent({super.key, required this.catName});

  @override
  State<CategoryOnEvent> createState() => _CategoryOnEventState();
}

class _CategoryOnEventState extends State<CategoryOnEvent> {
  List? eventList;

  DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTechnoListEventData();
  }

  final HomeController hc = Get.put(HomeController());

  void fetchTechnoListEventData() async{
    QuerySnapshot clubsData = await FirebaseFirestore.instance
        .collection('Club')
        .where('activeStatus', isEqualTo: true)
        .get();


    List clubIds = clubsData.docs.where((e) => e['category'][0] == widget.catName).toList().map((e) => e.id).toList();
    print("the clubs are : ${clubIds}");
    QuerySnapshot data = await FirebaseFirestore.instance
        .collection('Events')
    // .where('clubUID', arrayContains: clubIds)
        .where('isActive', isEqualTo: true)
        .get();
    QuerySnapshot clubData =await FirebaseFirestore.instance
        .collection("Club")
        .where("businessCategory", isEqualTo: 1)
        .get();
    eventList = data.docs;
    eventList = data.docs.where((element) {
      return clubData.docs.where((e)=>e['city'] == hc.city ||
          e['locality'] == hc.city ||
          hc.showFav == true)
          .map((ele) => ele['clubUID'])
          .contains(element['clubUID']);
    }).toList();

    eventList = data.docs.where((element) => clubIds.contains(element['clubUID']) && element['date'].toDate().isAfter(today)).toList();
    eventList!.sort((a, b) => a['date'].toDate().compareTo(b['date'].toDate()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("${widget.catName} Events", style: const TextStyle(fontSize: 19)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: eventList == null
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : eventList!.isEmpty
            ? const Center(child: Text("No events found", style: TextStyle(color: Colors.white)))
            : GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 450.0),
          itemCount: eventList!.length,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final productData = eventList![index];

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
                  Get.to(
                      BookEvents(clubUID: productDataMap['clubUID'] ?? '', eventID: productData.id,));

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
                            // width: Get.width,
                            // height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
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
                              print('clubId is ${(snapshot.data!.data() as Map<String, dynamic>)['clubUID'] ?? ''}');
                              return Column(
                                children: [
                                  Text(
                                    maxLines: 2,
                                    "${snapshot.data!.data() == null ? '' : (snapshot.data!.data() as Map<String, dynamic>)['address'] ?? ''}",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.white,
                                        overflow: TextOverflow.ellipsis
                                    ),
                                  ).marginOnly(left: 10.0, right: 10.0),
                                ],
                              );
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
