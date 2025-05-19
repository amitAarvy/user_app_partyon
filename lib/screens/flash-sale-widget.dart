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
// class FlashSaleWidget extends StatelessWidget {
//   const FlashSaleWidget({super.key});
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
//           // .where('city', isEqualTo: homeController.city)
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
//             height: 240.0,
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
//                               color: Color(0x42C3C3C3),
//                             ),
//                             width: Get.width / 2.8,
//                             child: Column(children: [
//                               Container(
//                                 width: Get.width,
//                                 height: 180,
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
//                              Text(
//                                   productModel.productName,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: TextStyle(
//                                       fontSize: 16.0, color: Colors.white),
//                                 ).paddingOnly(top: 10.0).marginOnly(left: 10.0,right: 10.0),
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










// ignore_for_file: file_names, prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import 'package:user/screens/home/view/home_view/category_on_event.dart';
import 'package:user/screens/product-model.dart';

import '../utils/app-constant.dart';
import '../utils/utils.dart';
import 'club_details/club_details.dart';
import 'home/view/discover_view.dart';

class FlashSaleWidget extends StatelessWidget {
  FlashSaleWidget({super.key});

  final List<Map<String, dynamic>> categoryData = [
    {
      "title": "Club",
      "icon": "assets/category/club.jpg",
      "route": Container(),
    },
    {
      "title": "Lounge",
      "icon": "assets/category/lounge.jpeg",
      "route": Container(),
    },
    {
      "title": "Roof Top",
      "icon": "assets/category/roof_top.jpg",
      "route": Container(),
    },
    {
      "title": "Bar",
      "icon": "assets/category/bar.jpg",
      "route": Container(),
    },
    {
      "title": "Concert Venue",
      "icon": "assets/category/concert_stadium.jpg",
      "route": Container(),
    },
    // {
    //   "title": "Day Club",
    //   "icon": Icons.cloud_upload,
    //   "route": Container(),
    // },
    // {
    //   "title": "Night Club",
    //   "icon": Icons.cloud_upload,
    //   "route": Container(),
    // },
    {
      "title": "Sports Bar",
      "icon": "assets/category/sports_bar.jpg",
      "route": Container(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: categoryData.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryOnEvent(catName: categoryData[index]['title']),));
              },
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.purple),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 1.h),
                            spreadRadius: 5.h,
                            blurRadius: 20.h,
                            color: Colors.black,
                          )
                        ]
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10000),
                      child: Image.asset(categoryData[index]['icon'], width: 130, height: 130, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    categoryData[index]['title'],
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          );
        },),
    );
    // return FutureBuilder(
    //   future: FirebaseFirestore.instance
    //       .collection('Events')
    //       .where('isActive', isEqualTo: true)
    //       .where('date', isGreaterThanOrEqualTo: today)
    //   // .where('city', isEqualTo: homeController.city)
    //       .limit(10)
    //       .get(),
    //   builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    //     if (snapshot.hasError) {
    //       return Center(
    //         child: Text("Error"),
    //       );
    //     }
    //
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return Container(
    //         height: Get.height / 5,
    //         child: Center(
    //           child: CupertinoActivityIndicator(),
    //         ),
    //       );
    //     }
    //
    //     if (snapshot.data!.docs.isEmpty) {
    //       return Center(
    //         child: Text("No products found!"),
    //       );
    //     }
    //
    //     if (snapshot.data != null) {
    //       return Container(
    //         height: 240.0,
    //         child: ListView.builder(
    //           itemCount: snapshot.data!.docs.length,
    //           shrinkWrap: true,
    //           padding: EdgeInsets.zero,
    //           scrollDirection: Axis.horizontal,
    //           itemBuilder: (context, index) {
    //             final productData = snapshot.data!.docs[index];
    //
    //             // Convert Firestore document to a Map
    //             final productDataMap = productData.data() as Map<String, dynamic>;
    //
    //             // Check if coverImages exists and is a valid, non-empty list
    //             List<dynamic> coverImages = [];
    //             if (productDataMap.containsKey('coverImages') &&
    //                 productDataMap['coverImages'] != null &&
    //                 productDataMap['coverImages'] is List &&
    //                 productDataMap['coverImages'].isNotEmpty) {
    //               coverImages = productDataMap['coverImages'];
    //             } else {
    //               coverImages = ['https://via.placeholder.com/200']; // Fallback image if not valid
    //             }
    //
    //             ProductModel productModel = ProductModel(
    //               productId: productDataMap['clubUID'] ?? '',
    //               categoryId: productDataMap['title'] ?? '',
    //               productName: productDataMap['title'] ?? '',
    //               categoryName: productDataMap['venueName'] ?? '',
    //               salePrice: productDataMap['startTime'] != null
    //                   ? productDataMap['startTime'].toDate()
    //                   : DateTime.now(),
    //               fullPrice: productDataMap['title'] ?? '',
    //               productImages: coverImages,
    //             );
    //
    //             return Row(
    //               children: [
    //                 GestureDetector(
    //                   onTap: () {
    //                     Navigator.push(
    //                       context,
    //                       MaterialPageRoute(
    //                         builder: (_) => ClubDetails(
    //                           productModel.productName,
    //                           clubName: productModel.productName,
    //                           description: productModel.categoryName,
    //                           clubUID: productModel.productId,
    //                         ),
    //                       ),
    //                     );
    //                   },
    //                   child: Padding(
    //                     padding: EdgeInsets.all(8.0),
    //                     child: Container(
    //                         decoration: BoxDecoration(
    //                           boxShadow: [
    //                             BoxShadow(
    //                               offset: Offset(0, 1.h),
    //                               spreadRadius: 5.h,
    //                               blurRadius: 20.h,
    //                               color: Colors.deepPurple,
    //                             )
    //                           ],
    //                           borderRadius: BorderRadius.circular(22),
    //                           color: Color(0x42C3C3C3),
    //                         ),
    //                         width: Get.width / 2.8,
    //                         child: Column(children: [
    //                           Container(
    //                             width: Get.width,
    //                             height: 180,
    //                             decoration: BoxDecoration(
    //                               borderRadius: BorderRadius.circular(10),
    //                               color: Colors.white,
    //                             ),
    //                             child: ClipRRect(
    //                               borderRadius: BorderRadius.circular(10),
    //                               child: CachedNetworkImage(
    //                                 fit: BoxFit.fill,
    //                                 fadeInDuration: const Duration(milliseconds: 100),
    //                                 fadeOutDuration: const Duration(milliseconds: 100),
    //                                 useOldImageOnUrlChange: true,
    //                                 filterQuality: FilterQuality.low,
    //                                 imageUrl: coverImages[0], // Use the first image in the list
    //                                 placeholder: (_, __) => const Center(
    //                                   child: CircularProgressIndicator(color: Colors.orange),
    //                                 ),
    //                               ),
    //                             ),
    //                           ),
    //                           Text(
    //                             productModel.productName,
    //                             overflow: TextOverflow.ellipsis,
    //                             style: TextStyle(
    //                               fontSize: 16.0,
    //                               color: Colors.white,
    //                             ),
    //                           ).paddingOnly(top: 10.0).marginOnly(left: 10.0, right: 10.0),
    //                         ])),
    //                   ),
    //                 ),
    //               ],
    //             );
    //           },
    //         ),
    //       );
    //     }
    //
    //     return Container(); // If data is empty or error occurs
    //   },
    // );
  }
}
