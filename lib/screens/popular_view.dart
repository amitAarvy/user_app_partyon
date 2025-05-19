// ignore_for_file: file_names, prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_card/image_card.dart';
import 'package:intl/intl.dart';
import 'package:user/screens/product-model.dart';

import '../utils/app-constant.dart';
import '../utils/utils.dart';
import 'club_details/club_details.dart';
import 'events/book_events.dart';
import 'events/event_details.dart';
import 'home/view/discover_view.dart';

class PopularView extends StatelessWidget {
  const PopularView({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime timeNow = DateTime.now();
    DateTime today = DateTime(timeNow.year, timeNow.month, timeNow.day);
    return FutureBuilder(

      future: FirebaseFirestore.instance
          .collection('Events')
          .where('isActive', isEqualTo: true)
          .where('date', isGreaterThanOrEqualTo: today)
          .limit(4)
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Error"),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: Get.height / 5,
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text("No products found!"),
          );
        }

        if (snapshot.data != null) {
          return Container(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final productData = snapshot.data!.docs[index];
                ProductModel productModel = ProductModel(
                  productId: productData['clubUID'],
                  categoryId: productData['title'],
                  productName: productData['title'],
                  categoryName: productData['venueName'],
                  salePrice: productData['startTime'].toDate(),
                  fullPrice: productData['title'],
                  productImages: productData['coverImages'] ,

                );
                // CategoriesModel categoriesModel = CategoriesModel(
                //   categoryId: snapshot.data!.docs[index]['categoryId'],
                //   categoryImg: snapshot.data!.docs[index]['categoryImg'],
                //   categoryName: snapshot.data!.docs[index]['categoryName'],
                //   createdAt: snapshot.data!.docs[index]['createdAt'],
                //   updatedAt: snapshot.data!.docs[index]['updatedAt'],
                // );
                return  GestureDetector(
                  onTap: () async {
                    Get.to(
                        Get.to(
                            BookEvents(clubUID: productData['clubUID'] ?? '', eventID: snapshot.data!.docs[index].id,)
                        ));
                    // EventDetails(
                    //   productData['coverImages'] as List,
                    //   'tag',
                    //   productData['title'],
                    //   productData['date'].toDate(),
                    //   productData['venueName'],
                    //   productData['genre'],
                    //   productData['artistName'],
                    //   eventID: snapshot.data!.docs[index].id,
                    //   startTime: productData['startTime'].toDate(),
                    //   endTime: productData['endTime'].toDate(),
                    //   aboutEvent: productData['briefEvent'],
                    //   clubUID: productData['clubUID'],
                    // ),
                    // );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                        width: Get.width,
                        child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            children: [
                              Container(
                                height: 200.h,
                                width: 200.h,
                                decoration: BoxDecoration(

                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        fadeInDuration: const Duration(
                                            milliseconds: 100),
                                        fadeOutDuration: const Duration(
                                            milliseconds: 100),
                                        useOldImageOnUrlChange: true,
                                        filterQuality: FilterQuality.low,
                                        imageUrl: productModel
                                            .productImages[0],
                                        placeholder: (_, __) => const Center(
                                            child:
                                            CircularProgressIndicator(
                                                color:
                                                Colors.orange)))),
                              ),
                              Container(
                                child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productModel.productName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white),
                                      ).paddingOnly(left: 10),
                                      Text(
                                        productModel.categoryName,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.ubuntu(color: Colors.white),
                                      ).paddingOnly(left: 10),
                                      Text(
                                        '${DateFormat('dd-MM-yyyy hh:mm a').format(productModel.salePrice)} onwards',
                                        style: GoogleFonts.ubuntu(color: Colors.white),
                                      ).paddingOnly(left: 10),
                                    ]),
                              ),
                            ])),
                  ),
                );
              },
            ),
          );
        }

        return Container();
      },
    );
  }
}
