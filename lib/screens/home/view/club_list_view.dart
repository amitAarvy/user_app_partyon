import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudflare/cloudflare.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:user/screens/club_details/club_details.dart';
import 'package:user/screens/home/view/home_view.dart';
import 'package:user/screens/live_stream/live_video_player.dart';
import 'package:user/utils/networkImage.dart';
import 'package:user/utils/utils.dart';

import '../controller/home_controller.dart';

class ClubListView extends StatefulWidget {
  final List<DocumentSnapshot> clubList;
  final List favList;
  final bool isL2HView;

  final ScrollController homeScrollController;

  const ClubListView({
    required this.clubList,
    required this.favList,
    this.isL2HView = false,
    required this.homeScrollController,
    super.key,
  });

  @override
  State<ClubListView> createState() => _ClubListViewState();
}

class _ClubListViewState extends State<ClubListView> {
  final HomeController homeController = Get.put(HomeController());
  List<DocumentSnapshot> documentSnapshot = [];
  List paginatedList = [];
  int pageIndex = 1;
  int count = 0;
  int itemPerPage = 30;

  @override
  void initState() {
    initPaginatedList().whenComplete(() async {
      for (var element in widget.clubList) {
        String? imageUrl = getKeyValueFirestore(element, 'coverImage');
        if (imageUrl != null) {
          await precacheImage(CachedNetworkImageProvider(imageUrl), context);
        }
      }
    });
    widget.homeScrollController.addListener(() {
      if (widget.homeScrollController.position.pixels >
          0.75 * widget.homeScrollController.position.maxScrollExtent &&
          count == 0) {
        pageIndex += 1;
        count += 1;
        initPaginatedList();
      }
    });
    super.initState();
  }

  Future<void> initPaginatedList() async {
    List clubList = [...widget.clubList];
    int totalItems = itemPerPage * pageIndex;
    paginatedList = clubList.sublist(
        0, totalItems < clubList.length ? totalItems : clubList.length);
    setState(() {});
    count = 0;
    log("GGG1${widget.clubList.toString()}");
    log("GGG2${widget.favList.toString()}");
    log("GGG3${widget.isL2HView}");
    log("GGG4${widget.homeScrollController}");
  }
  // Future<void> initPaginatedList() async {
  //   List clubList = [...widget.clubList];
  //
  //   // Ensure clubList contains DocumentSnapshot instances
  //   if (clubList.isNotEmpty && clubList.first is DocumentSnapshot) {
  //     // Extract data from Firestore DocumentSnapshots
  //     List<Map> extractedClubList = clubList.map((snapshot) {
  //       if (snapshot is DocumentSnapshot) {
  //         // Safely extract data from the snapshot and check if it exists
  //         var data = snapshot.data();
  //         if (data != null) {
  //           return data as Map<String, dynamic>;
  //         } else {
  //           log("Warning: Data for document is null");
  //           return {};  // Return an empty map if no data is found
  //         }
  //       }
  //       return {};  // Return an empty map if the type is incorrect
  //     }).toList();
  //
  //     int totalItems = itemPerPage * pageIndex;
  //
  //     // Paginate the extracted list of data
  //     paginatedList = extractedClubList.sublist(
  //         0, totalItems < extractedClubList.length ? totalItems : extractedClubList.length
  //     );
  //
  //     setState(() {});
  //     count = 0;
  //
  //     // Log extracted data for debugging purposes
  //     log("GGG1 Extracted Club List: ${extractedClubList.toString()}");
  //     log("GGG2 Favorite List: ${widget.favList.toString()}");
  //     log("GGG3 isL2HView: ${widget.isL2HView}");
  //     log("GGG4 Home Scroll Controller: ${widget.homeScrollController}");
  //   } else {
  //     log("Error: widget.clubList is empty or does not contain DocumentSnapshot instances");
  //   }
  // }

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: EdgeInsets.only(top: 50.h),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: paginatedList.length,
    itemBuilder: (BuildContext context, int index) {
      String heroTag = randomAlphaNumeric(8);
      DocumentSnapshot data = paginatedList[index];
      List categoryList = getKeyValueFirestore(data, 'category') ?? [];

      DateTime? date;
      bool isFav = false;
      Widget clubCardWidget() => ClubCard(
        heroTag: heroTag,
        clubData: data,
        isFav: isFav,
        isShowFav: true,
        clubUID: data.id,
      );
      return Obx(() {
        try {
          if (homeController.isEvents == true) {
            date = data['eventDate'].toDate();
          } else {
            date = DateTime(2099);
          }
        } catch (e) {
          date = DateTime(2100);
        }
        try {
          Map favMap = {'clubID': data.id, 'clubUID': data.id};
          if (homeController.showFav &&
              homeController.filter == 'fav' &&
              Provider.of<FavList>(context).favList.isNotEmpty &&
              Provider.of<FavList>(context).favList.any((element) {
                return mapEquals(element, favMap);
              })) {
            return clubCardWidget();
          } else if (homeController.filter == 'genre' &&
              homeController.genre ==
                  (getKeyValueFirestore(data, 'genre') ?? '')) {
            return clubCardWidget();
          } else if (homeController.filter == 'category' &&
              categoryList.contains(homeController.category)) {
            return clubCardWidget();
          } else if (homeController.filter.isEmpty) {
            return clubCardWidget();
          } else if (widget.isL2HView) {
            return clubCardWidget();
          } else {
            return const SizedBox();
          }
        } catch (e) {
          return Container();
        }
      });
    },
  );
}

class ClubCard extends StatefulWidget {
  final dynamic heroTag, isFav, isShowFav, clubUID;
  final DocumentSnapshot clubData;

  const ClubCard({
    required this.clubData,
    required this.heroTag,
    required this.isFav,
    required this.clubUID,
    this.isShowFav = false,
    super.key,
  });

  @override
  State<ClubCard> createState() => _ClubCardState();
}

class _ClubCardState extends State<ClubCard> {
  bool showEvent = false;
  final HomeController hc = Get.put(HomeController());
  final Cloudflare cloudflare = Cloudflare(
    accountId: cloudFlareAccountID,
    token: cloudFlareToken,
  );
  final EventImage eventImg = Get.put(EventImage());

  Widget noEventImage() => Container(
    height: Get.height,
    width: Get.width,
    color: Colors.black,
    child: Center(
      child: Text(
        'No Events Today',
        style: GoogleFonts.ubuntu(
          fontSize: 60.sp,
          color: Colors.white,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Consumer<FavList>(
      builder: (BuildContext context, FavList favData, Widget? child) {
        bool isFav = false;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Provider.of<L2HProvider>(context, listen: false).addToL2H({
            'data': widget.clubData,
            'uid': widget.clubUID,
            'clubID': widget.clubData.id
          });
        });

        if (Provider.of<FavList>(context).favList.isNotEmpty) {
          Map favMap = {
            'clubID': widget.clubData.id,
            'clubUID': widget.clubUID
          };
          if (Provider.of<FavList>(context).favList.any((element) {
            if (mapEquals(element, favMap)) {
              return true;
            } else {
              return false;
            }
          })) {
            isFav = true;
          }
        } else {
          isFav = false;
        }
        return Obx(
              () => (widget.clubData['city'] == hc.city ||
              widget.clubData['locality'] == hc.city ||
              hc.showFav == true)
              ? GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClubDetails(
                    widget.heroTag,
                    clubName: widget.clubData['clubName'],
                    description: widget.clubData['description'],
                    clubUID: widget.clubUID,
                  ),
                ),
              );
            },
            child: Container(
              height: 800.h,
              width: Get.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 1.h),
                    spreadRadius: 5.h,
                    blurRadius: 20.h,
                    color: Colors.deepPurple,
                  )
                ],
                color: Colors.white,
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Hero(
                        tag: widget.heroTag,
                        child: Container(
                          height: 700.h,
                          width: Get.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                          ),
                          child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              child: FutureBuilder<Map<String, dynamic>>(
                                  future:
                                  HomeController.getCoverImageDetails(
                                      widget.clubData),
                                  builder: (context, snapshot) {
                                    final data = snapshot.data;
                                    print('check data image is ${getKeyValueFirestore(
                                        widget.clubData,
                                        'coverImage')}');
                                    return
                                      kIsWeb?
                                      netWorkImage(url: showEvent &&
                                          data != null
                                          ? data['isValidEventCover']
                                          ? data['eventCover']
                                          : ''
                                          : getKeyValueFirestore(
                                          widget.clubData,
                                          'coverImage')):

                                      CachedNetworkImage(
                                          fit: BoxFit.fill,
                                          fadeInDuration: const Duration(
                                              milliseconds: 100),
                                          fadeOutDuration: const Duration(
                                              milliseconds: 100),
                                          useOldImageOnUrlChange: true,
                                          filterQuality: FilterQuality.low,
                                          imageUrl: showEvent &&
                                              data != null
                                              ? data['isValidEventCover']
                                              ? data['eventCover']
                                              : ''
                                              : getKeyValueFirestore(
                                              widget.clubData,
                                              'coverImage'),
                                          placeholder: (_, __) => const Center(
                                              child:
                                              CircularProgressIndicator(
                                                  color:
                                                  Colors.orange)),
                                          errorWidget: (_, __, ___) =>
                                              noEventImage());
                                  })),
                        ),
                      ),
                      Container(
                        height: 100.h,
                        width: Get.width,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                          color: Colors.black,
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: Get.width / 2,
                              child: Text(
                                "${(getKeyValueFirestore(
                                  widget.clubData,
                                  "clubName",
                                ) ?? "").toString().capitalizeFirst}",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ).paddingOnly(left: 30.w),
                            ),
                            Text(
                              "Open Till  ${getKeyValueFirestore(widget.clubData, "closeTime") ?? 'N/A'}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 35.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ).paddingOnly(right: 30.w),
                          ],
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        height: Get.height,
                        width: Get.width / 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black,
                              Colors.black38,
                              Colors.black12
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: Get.height,
                        width: Get.width / 2 - 20.w,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black12,
                              Colors.black38,
                              Colors.black54,
                              Colors.black,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ).marginOnly(bottom: 100.h),
                  // live now hided in club list
                  // Align(
                  //   alignment: Alignment.topRight,
                  //   child: Container(
                  //     height: 300.h,
                  //     width: 200.h,
                  //     decoration: const BoxDecoration(
                  //       color: Colors.transparent,
                  //     ),
                  //     child: Center(
                  //       child: Column(
                  //         children: [
                  //           IconButton(
                  //             icon: Icon(
                  //               Icons.circle,
                  //               size: 50.h,
                  //               color: Colors.red,
                  //             ),
                  //             onPressed: () async {
                  //               await EasyLoading.show();
                  //               await FirebaseFirestore.instance
                  //                   .collection('Admin')
                  //                   .doc('Club')
                  //                   .collection(widget.clubUID)
                  //                   .doc(widget.clubData.id)
                  //                   .get()
                  //                   .then((DocumentSnapshot<
                  //                           Map<String, dynamic>>
                  //                       value) async {
                  //                 try {
                  //                   if (value.exists) {
                  //                     await cloudflare.init();
                  //                     final CloudflareHTTPResponse<
                  //                             CloudflareLiveInput?>
                  //                         response = await cloudflare
                  //                             .liveInputAPI
                  //                             .get(
                  //                       id: getKeyValueFirestore(
                  //                               value, 'videoID') ??
                  //                           '',
                  //                     );
                  //                     CloudflareLiveInput? data =
                  //                         response.body;
                  //                     await EasyLoading.dismiss();
                  //
                  //                     if (data?.status?.current?.state !=
                  //                             'disconnected' &&
                  //                         data != null &&
                  //                         data.recording.mode !=
                  //                             LiveInputRecordingMode
                  //                                 .off) {
                  //                       final responseList =
                  //                           await cloudflare.liveInputAPI
                  //                               .getVideos(
                  //                         id: value.get('videoID')!,
                  //                       );
                  //                       final List<CloudflareStreamVideo>?
                  //                           videoList = responseList.body;
                  //                       Get.to(VideoPlayerScreen(
                  //                           title: Text(
                  //                             "${(widget.clubData["clubName"]).toString().capitalizeFirst}",
                  //                             style: const TextStyle(
                  //                               overflow:
                  //                                   TextOverflow.ellipsis,
                  //                               color: Colors.white,
                  //                               fontWeight:
                  //                                   FontWeight.bold,
                  //                             ),
                  //                           ),
                  //                           videoURL: (videoList?[0]
                  //                                   .playback
                  //                                   ?.dash)
                  //                               .toString()));
                  //                     } else {
                  //                       await EasyLoading.dismiss();
                  //                       await Fluttertoast.showToast(
                  //                         msg:
                  //                             'Live Stream not available',
                  //                       );
                  //                     }
                  //                   }
                  //                 } catch (e) {
                  //                   await EasyLoading.dismiss();
                  //                   await Fluttertoast.showToast(
                  //                     msg: 'Live Stream not available',
                  //                   );
                  //                 }
                  //               });
                  //             },
                  //           ),
                  //           Text(
                  //             'Live Now',
                  //             style: GoogleFonts.ubuntu(
                  //               color: Colors.white,
                  //               fontSize: 33.sp,
                  //             ),
                  //           )
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      height: 210.h,
                      width: 150.h,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              FontAwesomeIcons.music,
                              size: showEvent == false ? 60.h : 70.h,
                              color: showEvent == false
                                  ? Colors.pink
                                  : Colors.amber,
                            ),
                            onPressed: () {
                              setState(() {
                                showEvent = !showEvent;
                              });
                            },
                          ),
                          Text(
                            'Event',
                            style: GoogleFonts.ubuntu(
                              color: Colors.white,
                              fontSize: 35.sp,
                            ),
                          )
                        ],
                      ),
                    ),
                  ).marginOnly(bottom: 100.h),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      height: 210.h,
                      width: 150.h,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(
                              isFav == true
                                  ? FontAwesomeIcons.solidHeart
                                  : FontAwesomeIcons.heart,
                              size: 60.h,
                              color: Colors.pink,
                            ),
                            onPressed: () {
                              List favMap = [
                                {
                                  'clubUID': widget.clubUID,
                                  'clubID': widget.clubData.id
                                }
                              ];

                              FirebaseFirestore.instance
                                  .collection('User')
                                  .doc(uid())
                                  .set(
                                {
                                  'fav': isFav == false
                                      ? FieldValue.arrayUnion(
                                    favMap,
                                  )
                                      : FieldValue.arrayRemove(
                                    favMap,
                                  )
                                },
                                SetOptions(
                                  merge: true,
                                ),
                              ).whenComplete(() {
                                FirebaseFirestore.instance
                                    .collection('Favorites')
                                    .doc(
                                  widget.clubUID + widget.clubData.id,
                                )
                                    .set(
                                  {
                                    'favorites': isFav == false
                                        ? FieldValue.arrayUnion(
                                      [uid().toString()],
                                    )
                                        : FieldValue.arrayRemove(
                                        [uid().toString()])
                                  },
                                  SetOptions(merge: true),
                                );
                              });
                            },
                          ),
                          Text(
                            'Fav',
                            style: GoogleFonts.ubuntu(
                              color: Colors.white,
                              fontSize: 35.sp,
                            ),
                          )
                        ],
                      ),
                    ),
                  ).marginOnly(bottom: 100.w),
                ],
              ),
            ).marginOnly(bottom: 40.w, right: 10.w, left: 10.w),
          ):hc.city =='All City'?
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClubDetails(
                        widget.heroTag,
                        clubName: widget.clubData['clubName'],
                        description: widget.clubData['description'],
                        clubUID: widget.clubUID,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 800.h,
                  width: Get.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 1.h),
                        spreadRadius: 5.h,
                        blurRadius: 20.h,
                        color: Colors.deepPurple,
                      )
                    ],
                    color: Colors.white,
                  ),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Hero(
                            tag: widget.heroTag,
                            child: Container(
                              height: 700.h,
                              width: Get.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                              ),
                              child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                  child: FutureBuilder<Map<String, dynamic>>(
                                      future:
                                      HomeController.getCoverImageDetails(
                                          widget.clubData),
                                      builder: (context, snapshot) {
                                        final data = snapshot.data;
                                        print('check data image is ${getKeyValueFirestore(
                                            widget.clubData,
                                            'coverImage')}');
                                        return
                                          kIsWeb?
                                          netWorkImage(url: showEvent &&
                                              data != null
                                              ? data['isValidEventCover']
                                              ? data['eventCover']
                                              : ''
                                              : getKeyValueFirestore(
                                              widget.clubData,
                                              'coverImage')):

                                          CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              fadeInDuration: const Duration(
                                                  milliseconds: 100),
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 100),
                                              useOldImageOnUrlChange: true,
                                              filterQuality: FilterQuality.low,
                                              imageUrl: showEvent &&
                                                  data != null
                                                  ? data['isValidEventCover']
                                                  ? data['eventCover']
                                                  : ''
                                                  : getKeyValueFirestore(
                                                  widget.clubData,
                                                  'coverImage'),
                                              placeholder: (_, __) => const Center(
                                                  child:
                                                  CircularProgressIndicator(
                                                      color:
                                                      Colors.orange)),
                                              errorWidget: (_, __, ___) =>
                                                  noEventImage());
                                      })),
                            ),
                          ),
                          Container(
                            height: 100.h,
                            width: Get.width,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                              color: Colors.black,
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: Get.width / 2,
                                  child: Text(
                                    "${(getKeyValueFirestore(
                                      widget.clubData,
                                      "clubName",
                                    ) ?? "").toString().capitalizeFirst}",
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ).paddingOnly(left: 30.w),
                                ),
                                Text(
                                  "Open Till  ${getKeyValueFirestore(widget.clubData, "closeTime") ?? 'N/A'}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 35.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ).paddingOnly(right: 30.w),
                              ],
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: Get.height,
                            width: Get.width / 2,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black,
                                  Colors.black38,
                                  Colors.black12
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: Get.height,
                            width: Get.width / 2 - 20.w,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black12,
                                  Colors.black38,
                                  Colors.black54,
                                  Colors.black,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ).marginOnly(bottom: 100.h),
                      // live now hided in club list
                      // Align(
                      //   alignment: Alignment.topRight,
                      //   child: Container(
                      //     height: 300.h,
                      //     width: 200.h,
                      //     decoration: const BoxDecoration(
                      //       color: Colors.transparent,
                      //     ),
                      //     child: Center(
                      //       child: Column(
                      //         children: [
                      //           IconButton(
                      //             icon: Icon(
                      //               Icons.circle,
                      //               size: 50.h,
                      //               color: Colors.red,
                      //             ),
                      //             onPressed: () async {
                      //               await EasyLoading.show();
                      //               await FirebaseFirestore.instance
                      //                   .collection('Admin')
                      //                   .doc('Club')
                      //                   .collection(widget.clubUID)
                      //                   .doc(widget.clubData.id)
                      //                   .get()
                      //                   .then((DocumentSnapshot<
                      //                           Map<String, dynamic>>
                      //                       value) async {
                      //                 try {
                      //                   if (value.exists) {
                      //                     await cloudflare.init();
                      //                     final CloudflareHTTPResponse<
                      //                             CloudflareLiveInput?>
                      //                         response = await cloudflare
                      //                             .liveInputAPI
                      //                             .get(
                      //                       id: getKeyValueFirestore(
                      //                               value, 'videoID') ??
                      //                           '',
                      //                     );
                      //                     CloudflareLiveInput? data =
                      //                         response.body;
                      //                     await EasyLoading.dismiss();
                      //
                      //                     if (data?.status?.current?.state !=
                      //                             'disconnected' &&
                      //                         data != null &&
                      //                         data.recording.mode !=
                      //                             LiveInputRecordingMode
                      //                                 .off) {
                      //                       final responseList =
                      //                           await cloudflare.liveInputAPI
                      //                               .getVideos(
                      //                         id: value.get('videoID')!,
                      //                       );
                      //                       final List<CloudflareStreamVideo>?
                      //                           videoList = responseList.body;
                      //                       Get.to(VideoPlayerScreen(
                      //                           title: Text(
                      //                             "${(widget.clubData["clubName"]).toString().capitalizeFirst}",
                      //                             style: const TextStyle(
                      //                               overflow:
                      //                                   TextOverflow.ellipsis,
                      //                               color: Colors.white,
                      //                               fontWeight:
                      //                                   FontWeight.bold,
                      //                             ),
                      //                           ),
                      //                           videoURL: (videoList?[0]
                      //                                   .playback
                      //                                   ?.dash)
                      //                               .toString()));
                      //                     } else {
                      //                       await EasyLoading.dismiss();
                      //                       await Fluttertoast.showToast(
                      //                         msg:
                      //                             'Live Stream not available',
                      //                       );
                      //                     }
                      //                   }
                      //                 } catch (e) {
                      //                   await EasyLoading.dismiss();
                      //                   await Fluttertoast.showToast(
                      //                     msg: 'Live Stream not available',
                      //                   );
                      //                 }
                      //               });
                      //             },
                      //           ),
                      //           Text(
                      //             'Live Now',
                      //             style: GoogleFonts.ubuntu(
                      //               color: Colors.white,
                      //               fontSize: 33.sp,
                      //             ),
                      //           )
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          height: 210.h,
                          width: 150.h,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  FontAwesomeIcons.music,
                                  size: showEvent == false ? 60.h : 70.h,
                                  color: showEvent == false
                                      ? Colors.pink
                                      : Colors.amber,
                                ),
                                onPressed: () {
                                  setState(() {
                                    showEvent = !showEvent;
                                  });
                                },
                              ),
                              Text(
                                'Event',
                                style: GoogleFonts.ubuntu(
                                  color: Colors.white,
                                  fontSize: 35.sp,
                                ),
                              )
                            ],
                          ),
                        ),
                      ).marginOnly(bottom: 100.h),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          height: 210.h,
                          width: 150.h,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Column(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isFav == true
                                      ? FontAwesomeIcons.solidHeart
                                      : FontAwesomeIcons.heart,
                                  size: 60.h,
                                  color: Colors.pink,
                                ),
                                onPressed: () {
                                  List favMap = [
                                    {
                                      'clubUID': widget.clubUID,
                                      'clubID': widget.clubData.id
                                    }
                                  ];

                                  FirebaseFirestore.instance
                                      .collection('User')
                                      .doc(uid())
                                      .set(
                                    {
                                      'fav': isFav == false
                                          ? FieldValue.arrayUnion(
                                        favMap,
                                      )
                                          : FieldValue.arrayRemove(
                                        favMap,
                                      )
                                    },
                                    SetOptions(
                                      merge: true,
                                    ),
                                  ).whenComplete(() {
                                    FirebaseFirestore.instance
                                        .collection('Favorites')
                                        .doc(
                                      widget.clubUID + widget.clubData.id,
                                    )
                                        .set(
                                      {
                                        'favorites': isFav == false
                                            ? FieldValue.arrayUnion(
                                          [uid().toString()],
                                        )
                                            : FieldValue.arrayRemove(
                                            [uid().toString()])
                                      },
                                      SetOptions(merge: true),
                                    );
                                  });
                                },
                              ),
                              Text(
                                'Fav',
                                style: GoogleFonts.ubuntu(
                                  color: Colors.white,
                                  fontSize: 35.sp,
                                ),
                              )
                            ],
                          ),
                        ),
                      ).marginOnly(bottom: 100.w),
                    ],
                  ),
                ).marginOnly(bottom: 40.w, right: 10.w, left: 10.w),
              )
              : Container(),
        );
      });
}
