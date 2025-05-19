// // ignore_for_file: file_names, prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:image_card/image_card.dart';
// import 'package:user/screens/product-model.dart';
//
// import '../utils/app-constant.dart';
// import '../utils/utils.dart';
// import 'club_details/club_details.dart';
// import 'home/view/discover_view.dart';
//
// class FeaturedView extends StatelessWidget {
//   const FeaturedView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     DateTime timeNow = DateTime.now();
//     DateTime today = DateTime(timeNow.year, timeNow.month, timeNow.day);
//     return FutureBuilder(
//       future: FirebaseFirestore.instance
//           .collection('Events')
//           .where('isActive', isEqualTo: true)
//           .where('date', isGreaterThanOrEqualTo: today)
//       // .where('city', isEqualTo: homeController.city)
//           .limit(10)
//           .get(),
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasError) {
//           return Center(
//             child: Text("Error"),
//           );
//         }
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Container(
//             height: Get.height / 5,
//             child: Center(
//               child: CupertinoActivityIndicator(),
//             ),
//           );
//         }
//
//         if (snapshot.data!.docs.isEmpty) {
//           return Center(
//             child: Text("No products found!"),
//           );
//         }
//
//         if (snapshot.data != null) {
//           return Container(
//             height: 310.0,
//             child: ListView.builder(
//               itemCount: snapshot.data!.docs.length,
//               shrinkWrap: true,
//               padding: EdgeInsets.zero,
//               scrollDirection: Axis.horizontal,
//               itemBuilder: (context, index) {
//                 final productData = snapshot.data!.docs[index];
//                 ProductModel productModel = ProductModel(
//                   productId: productData['clubUID'],
//                   categoryId: productData['title'],
//                   productName: productData['title'],
//                   categoryName: productData['venueName'],
//                   salePrice: productData['startTime'].toDate(),
//                   fullPrice: productData['title'],
//                   productImages: productData['coverImages'],
//                 );
//                 // CategoriesModel categoriesModel = CategoriesModel(
//                 //   categoryId: snapshot.data!.docs[index]['categoryId'],
//                 //   categoryImg: snapshot.data!.docs[index]['categoryImg'],
//                 //   categoryName: snapshot.data!.docs[index]['categoryName'],
//                 //   createdAt: snapshot.data!.docs[index]['createdAt'],
//                 //   updatedAt: snapshot.data!.docs[index]['updatedAt'],
//                 // );
//                 return Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => ClubDetails(
//                               productModel.productName,
//                               clubName: productModel.productName,
//                               description: productModel.categoryName,
//                               clubUID: productModel.productId,
//                             ),
//                           ),
//                         );
//                       },
//                       child: Padding(
//                         padding: EdgeInsets.all(8.0),
//                         child: Container(
//                             decoration: BoxDecoration(
//                               boxShadow: [
//                                 BoxShadow(
//                                   offset: Offset(0, 1.h),
//                                   spreadRadius: 5.h,
//                                   blurRadius: 20.h,
//                                   color: Colors.deepPurple,
//                                 )
//                               ],
//                               borderRadius: BorderRadius.circular(22),
//                               color: Color(0x42DCDCDC),
//                             ),
//                             width: Get.width / 2,
//                             child: Column(children: [
//                               Container(
//                                 width: Get.width,
//                                 height: 250,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   color: Colors.white,
//                                 ),
//                                 child: ClipRRect(
//                                     borderRadius:
//                                     BorderRadius.circular(10),
//                                     child: CachedNetworkImage(
//                                         fit: BoxFit.fill,
//                                         fadeInDuration: const Duration(
//                                             milliseconds: 100),
//                                         fadeOutDuration: const Duration(
//                                             milliseconds: 100),
//                                         useOldImageOnUrlChange: true,
//                                         filterQuality: FilterQuality.low,
//                                         imageUrl: productModel
//                                             .productImages[0],
//                                         placeholder: (_, __) => const Center(
//                                             child:
//                                             CircularProgressIndicator(
//                                                 color:
//                                                 Colors.orange)))),
//                               ),
//                               Text(
//                                 productModel.productName,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: TextStyle(
//                                     fontSize: 16.0, color: Colors.white),
//                               ).paddingOnly(top: 10.0).marginOnly(left: 10.0,right: 10.0),
//
//                             ])),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           );
//         }
//
//         return Container();
//       },
//     );
//   }
// }









import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:user/screens/product-model.dart';

import '../utils/app-constant.dart';
import '../utils/utils.dart';
import 'club_details/club_details.dart';
import 'home/view/discover_view.dart';

class FeaturedView extends StatelessWidget {
  const FeaturedView({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime timeNow = DateTime.now();
    DateTime today = DateTime(timeNow.year, timeNow.month, timeNow.day);

    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('Events')
          .where('isActive', isEqualTo: true)
          .where('date', isGreaterThanOrEqualTo: today)
          .limit(10)
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

        return Container(
          height: 310.0,
          child: ListView.builder(
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final productData = snapshot.data!.docs[index];

              // Convert document data to a Map for safer access
              final productDataMap = productData.data() as Map<String, dynamic>;

              // Check if coverImages exists and is a valid, non-empty list
              if (productDataMap.containsKey('coverImages') &&
                  productDataMap['coverImages'] != null &&
                  productDataMap['coverImages'].isNotEmpty) {

                ProductModel productModel = ProductModel(
                  productId: productDataMap['clubUID'] ?? '',
                  categoryId: productDataMap['title'] ?? '',
                  productName: productDataMap['title'] ?? '',
                  categoryName: productDataMap['venueName'] ?? '',
                  salePrice: (productDataMap['startTime'] != null)
                      ? productDataMap['startTime'].toDate()
                      : DateTime.now(),
                  fullPrice: productDataMap['title'] ?? '',
                  productImages: productDataMap['coverImages'] is List
                      ? productDataMap['coverImages']
                      : [],
                );

                return Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClubDetails(
                              productModel.productName,
                              clubName: productModel.productName,
                              description: productModel.categoryName,
                              clubUID: productModel.productId,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 1.h),
                                spreadRadius: 5.h,
                                blurRadius: 20.h,
                                color: Colors.deepPurple,
                              )
                            ],
                            borderRadius: BorderRadius.circular(22),
                            color: Color(0x42DCDCDC),
                          ),
                          width: Get.width / 2,
                          child: Column(
                            children: [
                              Container(
                                width: Get.width,
                                height: 250,
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
                                    imageUrl: productModel.productImages.isNotEmpty
                                        ? productModel.productImages[0]
                                        : 'https://via.placeholder.com/200', // Use fallback image if empty
                                    placeholder: (_, __) => const Center(
                                      child: CircularProgressIndicator(color: Colors.orange),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                                child: Text(
                                  productModel.productName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // If no valid cover images found, return an empty container or handle as needed
                return Container();
              }
            },
          ),
        );
      },
    );
  }
}
