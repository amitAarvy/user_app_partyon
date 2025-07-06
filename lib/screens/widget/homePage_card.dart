import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../utils/networkImage.dart';
import '../product-model.dart';

class HomePageCard extends StatelessWidget {
  final ProductModel productModel;
  final List coverImages;
  final VoidCallback callback;
  const HomePageCard({super.key, required this.productModel, required this.coverImages, required this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
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
                      "${snapshot.data!.data() == null ? '' : (snapshot.data!.data() as Map<String, dynamic>)['address'] ?? ''}",
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
  }
}
