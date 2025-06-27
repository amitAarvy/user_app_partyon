import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../utils/networkImage.dart';
import '../../utils/utils.dart';
import 'book_events.dart';

class OrganiserEvent extends StatefulWidget {
  final String? clubName;
  final String clubUid;
  final organiserData;
  const OrganiserEvent({super.key, this.clubName, required this.clubUid, this.organiserData});

  @override
  State<OrganiserEvent> createState() => _OrganiserEventState();
}

class _OrganiserEventState extends State<OrganiserEvent> {
  bool isFolded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUpcomingMonthEventData();
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

  List upcomingMonthData = [];
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  ValueNotifier<bool> isLoadingEvent = ValueNotifier(false);

  ValueNotifier<bool> checkFollow = ValueNotifier(false);
  String followId = '';

  void fetchUpcomingMonthEventData() async {
    isLoadingEvent.value = true;
    QuerySnapshot data = await FirebaseFirestore.instance.collection('Events').where('isActive', isEqualTo: true).get();
    QuerySnapshot clubData = await FirebaseFirestore.instance.collection("Club").where("businessCategory", isEqualTo: 1).get();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Follow').where('uid', isEqualTo: widget.clubUid).get();
    if (querySnapshot.docs.isNotEmpty) {
      Map<String, dynamic> data = querySnapshot.docs[0].data() as Map<String, dynamic>;
      checkFollow.value = data['follow'].toString() == 'true' ? true : false;
      followId = querySnapshot.docs[0].id; // Use this if you need the document ID
    }
    upcomingMonthData = data.docs;
    upcomingMonthData = data.docs.where((element) {
      return clubData.docs.map((ele) => ele['clubUID']).contains(element['clubUID']);
    }).toList();

    upcomingMonthData = upcomingMonthData.where((element) => element['organiserID'] == widget.clubUid.toString()).toList();
    upcomingMonthData = upcomingMonthData.where((element) => element['date'].toDate().isAfter(month)).toList();
    upcomingMonthData.sort((a, b) => a['date'].toDate().compareTo(b['date'].toDate()));
    setState(() {});
    isLoadingEvent.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: themeRed(),
        title: Text(
          widget.clubName.toString(),
          style: GoogleFonts.ubuntu(fontSize: 50.sp, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ValueListenableBuilder(
          valueListenable: isLoadingEvent,
          builder: (context, bool isLoading, child) {
            if (isLoading) {
              return Column(
                children: [
                  SizedBox(
                    height: 0.5.sh,
                  ),
                  Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () async {
                      // print('${productDataMap['clubUID'] ?? ''}');
                      // if(kIsWeb){
                      //   print('web is on ');
                      //   Get.to(()=>BookEvents(clubUID: productDataMap['clubUID'] ?? '', eventID: productData.id,
                      //   ));
                      // }else{
                      //   Get.to(BookEvents(clubUID: productDataMap['clubUID'] ?? '', eventID: productData.id,
                      //   ));
                      // }

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
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          // color: Color(0x42C3C3C3),
                          color: Colors.black,
                        ),
                        width: Get.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: Get.width,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: widget.organiserData['profile_image'] != null
                                      ? kIsWeb
                                          ? netWorkImage(url: widget.organiserData['profile_image'])
                                          : CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              fadeInDuration: const Duration(milliseconds: 100),
                                              fadeOutDuration: const Duration(milliseconds: 100),
                                              useOldImageOnUrlChange: true,
                                              filterQuality: FilterQuality.low,
                                              imageUrl: widget.organiserData['profile_image'], // Use the first image in the list
                                              placeholder: (_, __) => const Center(
                                                child: CircularProgressIndicator(color: Colors.orange),
                                              ),
                                            )
                                      : Image.asset(
                                          'assets/artist.png',
                                          fit: BoxFit.fill,
                                        )
                                  // kIsWeb?
                                  // netWorkImage(url: coverImages[0]):
                                  // CachedNetworkImage(
                                  //   fit: BoxFit.fill,
                                  //   fadeInDuration: const Duration(milliseconds: 100),
                                  //   fadeOutDuration: const Duration(milliseconds: 100),
                                  //   useOldImageOnUrlChange: true,
                                  //   filterQuality: FilterQuality.low,
                                  //   imageUrl: coverImages[0], // Use the first image in the list
                                  //   placeholder: (_, __) => const Center(
                                  //     child: CircularProgressIndicator(color: Colors.orange),
                                  //   ),
                                  // ),
                                  ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${widget.clubName}',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: checkFollow,
                                  builder: (context, bool isCheck, child) => GestureDetector(
                                    onTap: () {
                                      if (followId == '') {
                                        FirebaseFirestore.instance.collection('Follow').add({
                                          'uid': widget.clubUid,
                                          'follow': true,
                                        }).then((value) {
                                          checkFollow.value = true;
                                          print("User Added");
                                        }).catchError((error) {
                                          print("Failed to add user: $error");
                                        });
                                      } else {
                                        FirebaseFirestore.instance.collection('Follow').doc(followId).update({
                                          'uid': widget.clubUid,
                                          'follow': isCheck == true ? false : true,
                                        }).then((_) {
                                          checkFollow.value = isCheck == true ? false : true;
                                          print("User updated successfully!");
                                        }).catchError((error) {
                                          print("Failed to update user: $error");
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(border: Border.all(color: Colors.purple, width: 2), borderRadius: BorderRadius.all(Radius.circular(21))),
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                      child: Text(
                                        isCheck ? 'Followed' : 'Follow',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            // const SizedBox(height: 2),
                            // FutureBuilder(
                            //   future: FirebaseFirestore.instance.collection('Club').doc(productModel.productId).get(),
                            //   builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                            //     if(snapshot.connectionState == ConnectionState.waiting) return Offstage();
                            //     if(snapshot.hasError) return Offstage();
                            //     if(snapshot.hasData){
                            //       return Text(
                            //         maxLines: 2,
                            //         "${snapshot.data!.data() == null ? '' : (snapshot.data!.data() as Map<String, dynamic>)['address'] ?? ''}",
                            //         overflow: TextOverflow.ellipsis,
                            //         style: TextStyle(
                            //             fontSize: 12.0,
                            //             color: Colors.white,
                            //             overflow: TextOverflow.ellipsis
                            //         ),
                            //       ).marginOnly(left: 10.0, right: 10.0);
                            //     }
                            //     return Offstage();
                            //   },
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // Text('Wed Mar 05 2025',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                  // SizedBox(height: 10,),
                  Text(
                    'Upcoming Events',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (upcomingMonthData.isNotEmpty)
                    GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 450.0),
                      itemCount: upcomingMonthData.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            // print('${productDataMap['clubUID'] ?? ''}');
                            if (kIsWeb) {
                              print('web is on ');
                              Get.to(() => BookEvents(
                                    clubUID: upcomingMonthData[index]['clubUID'] ?? '',
                                    eventID: upcomingMonthData[index].id,
                                  ));
                            } else {
                              Get.to(BookEvents(
                                clubUID: upcomingMonthData[index]['clubUID'] ?? '',
                                eventID: upcomingMonthData[index].id,
                              ));
                            }

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
                          },
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
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
                                        child:
                                            // Image.asset('assets/featVenue.png',fit: BoxFit.fill,)
                                            kIsWeb
                                                ? netWorkImage(url: upcomingMonthData[index]['coverImages'][0])
                                                : CachedNetworkImage(
                                                    fit: BoxFit.fill,
                                                    fadeInDuration: const Duration(milliseconds: 100),
                                                    fadeOutDuration: const Duration(milliseconds: 100),
                                                    useOldImageOnUrlChange: true,
                                                    filterQuality: FilterQuality.low,
                                                    imageUrl: upcomingMonthData[index]['coverImages'][0], // Use the first image in the list
                                                    placeholder: (_, __) => const Center(
                                                      child: CircularProgressIndicator(color: Colors.orange),
                                                    ),
                                                  ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat.yMMMd().format(
                                          upcomingMonthData[index]['startTime'] != null ? upcomingMonthData[index]['startTime'].toDate() : DateTime.now(),
                                        ),
                                        style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                                      ),
                                      Text(
                                        upcomingMonthData[index]['title'].toString(),
                                        style: TextStyle(fontWeight: FontWeight.w800, color: Colors.grey, fontSize: 13),
                                      ),
                                      // Text('Rs 300- Rs 799',style: TextStyle(fontWeight: FontWeight.w800,color: Colors.grey),),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  if (upcomingMonthData.isEmpty)
                    SizedBox(
                      height: 200,
                    ),
                  if (upcomingMonthData.isEmpty)
                    Center(
                        child: const Text(
                      'No event available',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                    ))
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
