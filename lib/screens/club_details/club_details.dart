import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:user/screens/events/event_details.dart';
import 'package:user/utils/details_utils.dart';
import 'package:user/utils/networkImage.dart';
import 'package:user/utils/utils.dart';

import '../events/book_events.dart';
import 'club_details_provider.dart';

class ClubDetails extends StatefulWidget {
  final String tag, clubName, clubUID, description, discoverImage;
  final DateTime? eventDate;
  final bool isDiscover;

  const ClubDetails(
    this.tag, {
    required this.clubName,
    required this.clubUID,
    required this.description,
    this.isDiscover = false,
    this.discoverImage = '',
    this.eventDate,
    super.key,
  });

  @override
  State<ClubDetails> createState() => _ClubDetailsState();
}

class _ClubDetailsState extends State<ClubDetails> {
  int index = 0;
  bool isPastEvent = true, isUpcomingEvent = true, isTodayEvent = true;
  final List<String> galleryImages = [];
  List<DocumentSnapshot> pastEventList = [], todayEventsList = [], upcomingEventsList = [];
  final List<String> menuImages = [];
  final IndexProvider indexProvider = Get.put(IndexProvider());

  Widget aboutMenu() => Container(
        height: 120.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => indexProvider.changeIndex(0),
              child: Obx(
                () => Text(
                  'About',
                  style: GoogleFonts.montserrat(
                    color: indexProvider.index.value == 0 ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 45.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 40.w),
            const Text(
              '|',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 40.w),
            GestureDetector(
              onTap: () => indexProvider.changeIndex(1),
              child: Obx(
                () => Text(
                  'Events',
                  style: GoogleFonts.montserrat(
                    color: indexProvider.index.value == 1 ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 45.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 40.w),
            const Text(
              '|',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 40.w),
            GestureDetector(
              onTap: () async {
                try {
                  await FirebaseFirestore.instance.collection('Club').doc(widget.clubUID).get().then((data) {
                    if (data.exists) {
                      openMap(data.data()?['latitude'], data.data()?['longitude']);
                    }
                  });
                } catch (e) {
                  Fluttertoast.showToast(msg: 'Something went wrong');
                }
              },
              child: Text(
                'Location',
                style: GoogleFonts.montserrat(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 45.sp,
                ),
              ),
            ),
          ],
        ).paddingSymmetric(horizontal: 100.w),
      ).marginOnly(left: 75.w, right: 75.w, top: 75.h, bottom: 20.h);

  Widget headerMenu() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          aboutMenu(),
        ],
      );

  @override
  void initState() {
    super.initState();
    initEventListCall();
    if (kDebugMode) {
      print('club id is ${widget.clubUID}');
      print('club id is ${widget.clubName}');
      print('club id is ${widget.clubUID}');
      print('club id is ${widget.clubUID}');
    }
  }

  void initEventListCall() async {
    try {
      final getData = await FirebaseFirestore.instance.collection('Events').where('clubUID', isEqualTo: widget.clubUID.toString()).where('isActive', isEqualTo: true).orderBy('date', descending: true).get();
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
      for (DocumentSnapshot documentSnapshot in getData.docs) {
        DateTime endTime = documentSnapshot.get('endTime').toDate();
        DateTime startTime = documentSnapshot.get('startTime').toDate();
        if (startTime.millisecondsSinceEpoch < today.millisecondsSinceEpoch) {
          pastEventList.add(documentSnapshot);
        } else if (startTime.millisecondsSinceEpoch >= today.millisecondsSinceEpoch && startTime.millisecondsSinceEpoch < tomorrow.millisecondsSinceEpoch) {
          todayEventsList.add(documentSnapshot);
        } else if (startTime.millisecondsSinceEpoch >= tomorrow.millisecondsSinceEpoch) {
          upcomingEventsList.add(documentSnapshot);
        }
      }
      setState(() {});
    } catch (e) {
      Fluttertoast.showToast(msg: 'Something went wrong.Please try again');
    }
  }

  Widget eventCard({required List asset, required String tag, required String title, required DateTime date, required String location, required String genre, required String artistName, required DocumentSnapshot data}) => GestureDetector(
        onTap: () async {
          Get.to(BookEvents(
            clubUID: widget.clubUID,
            eventID: data.id,
          )

              // EventDetails(
              //   asset,
              //   tag,
              //   title,
              //   date,
              //   location,
              //   genre,
              //   artistName,
              //   eventID: data.id,
              //   clubUID: widget.clubUID,
              //   startTime: data.get('startTime').toDate(),
              //   endTime: data.get('endTime').toDate(),
              //   aboutEvent: data.get('briefEvent') ?? '',
              // ),
              );
        },
        child: Container(
          height: 350.h,
          width: Get.width - 100.w,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 1.h),
                spreadRadius: 5.h,
                blurRadius: 20.h,
                color: Colors.deepPurple,
              )
            ],
            color: Colors.black,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Hero(
                tag: tag,
                child: SizedBox(
                  height: 250.h,
                  width: 250.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: kIsWeb
                        ? netWorkImage(url: asset.isNotEmpty ? asset[0] : '')
                        : CachedNetworkImage(
                            imageUrl: asset.isNotEmpty ? asset[0] : '',
                            placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            fit: BoxFit.fill,
                          ),
                  ),
                ),
              ),
              SizedBox(
                width: 50.w,
              ),
              SizedBox(
                width: Get.width - 400.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 50.h,
                    ),
                    Text(
                      '${date.day} ${getMonthName(date.month)}, ${date.year}',
                      style: GoogleFonts.ubuntu(
                        color: Colors.white70,
                        fontSize: 35.sp,
                      ),
                    )
                  ],
                ),
              )
            ],
          ).marginOnly(left: 40.w),
        ),
      ).marginOnly(
        left: 20.w,
        right: 20.w,
        top: 30.w,
        bottom: 30.w,
      );

  Widget eventsList(List<DocumentSnapshot> eventList) {
    if (eventList.isNotEmpty) {
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: eventList.length,
        itemBuilder: (BuildContext context, int index) {
          try {
            DocumentSnapshot documentSnapshot = eventList[index];

            String tag = getRandomString(5);
            List asset = getKeyValueFirestore(documentSnapshot, 'coverImages') ?? [];
            String title = documentSnapshot.get('title') ?? '';
            DateTime eventDate = documentSnapshot.get('date').toDate();

            String location = '';
            String genre = documentSnapshot.get('genre');
            String artistName = documentSnapshot.get('artistName');
            return eventCard(
              asset: asset,
              tag: tag,
              title: title,
              date: eventDate,
              location: location,
              genre: genre,
              data: documentSnapshot,
              artistName: artistName,
            );
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }
          return null;
        },
      );
    } else {
      return Text(
        'No Events Found',
        style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 50.sp, fontWeight: FontWeight.bold),
      ).paddingSymmetric(vertical: 30.h);
    }
  }

  Widget eventListHeading(String title, {bool isPast = false, isToday = false, isUpcoming = false}) => Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (isPast) isPastEvent = (!isPastEvent);
                if (isToday) isTodayEvent = (!isTodayEvent);
                if (isUpcoming) isUpcomingEvent = !isUpcomingEvent;
              });
            },
            child: Text(
              title,
              style: GoogleFonts.ubuntu(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 47.sp,
              ),
            ),
          ),
        ],
      ).paddingSymmetric(vertical: 40.h, horizontal: 24.w);

  @override
  void dispose() {
    // TODO: implement dispose
    indexProvider.changeIndex(0);
    super.dispose();
  }

  Widget imageCarousel(List imageList) => CarouselSlider(
        items: imageList
            .map(
              (final item) => Container(
                height: 800.h,
                width: Get.width,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  child: kIsWeb
                      ? netWorkImage(url: item)
                      : CachedNetworkImage(
                          imageUrl: item,
                          filterQuality: FilterQuality.low,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.deepPurple,
                            ),
                          ),
                          errorWidget: (_, __, ___) => Center(
                            child: Text(
                              imageList.isEmpty ? 'No Images found' : 'No cover Image Found',
                              style: GoogleFonts.ubuntu(
                                color: Colors.white,
                                fontSize: 60.sp,
                              ),
                            ),
                          ),
                          fit: BoxFit.fill,
                        ),
                ),
              ).marginAll(5.w),
            )
            .toList(),
        options: CarouselOptions(
          height: 800.h,
          aspectRatio: 16 / 9,
          viewportFraction: 0.8,
          initialPage: 0,
          reverse: false,
          autoPlay: false,
          enableInfiniteScroll: true,
          autoPlayInterval: const Duration(
            seconds: 3,
          ),
          autoPlayAnimationDuration: const Duration(
            milliseconds: 800,
          ),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          scrollDirection: Axis.horizontal,
        ),
      ).paddingOnly(top: 20.w);

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: matte(),
      appBar: eventAppBar(widget.clubName),
      body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Obx(
            () => Column(children: [
              if (indexProvider.index.value == 0)
                SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: Column(
                    children: [
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('Club').doc(widget.clubUID).get(),
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot,
                        ) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox(
                              height: Get.height,
                              width: Get.width,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.orange,
                                ),
                              ),
                            );
                          }
                          if (snapshot.hasError || snapshot.data?.exists == false) {
                            return Expanded(
                              child: Center(
                                child: Text(
                                  'Something went wrong',
                                  style: GoogleFonts.ubuntu(
                                    color: Colors.white,
                                    fontSize: 60.sp,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            var location = snapshot.data?.get('address') + ' , ' + snapshot.data?.get('area') + '\n' + snapshot.data?.get('city') + ' , ' + snapshot.data?.get('state');

                            var openTime = snapshot.data?.get('openTime');
                            var closeTime = snapshot.data?.get('closeTime');
                            String avgCost = "₹ ${snapshot.data?.get("averageCost")}";

                            if (snapshot.data?.get('coverImage') != '') {
                              galleryImages.add(
                                snapshot.data?.get('coverImage'),
                              );
                            }

                            List data = snapshot.data?.get('galleryImages');

                            for (var i in data) {
                              galleryImages.add(i);
                            }
                            try {
                              List data = snapshot.data?.get('menuImages');
                              for (var i in data) {
                                menuImages.add(i);
                              }
                            } catch (e) {
                              if (kDebugMode) {
                                print(e);
                              }
                            }

                            return Column(
                              children: [
                                imageCarousel(galleryImages).paddingOnly(bottom: 50.h),
                                headerMenu(),
                                Container(
                                  decoration: const BoxDecoration(),
                                  width: Get.width,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      aboutDetails(
                                        'assets/location.png',
                                        'Location',
                                        location,
                                      ),
                                      aboutDetails(
                                        'assets/open.png',
                                        'Opening Timing',
                                        openTime,
                                      ),
                                      aboutDetails(
                                        'assets/close.png',
                                        'Closing Timing',
                                        closeTime,
                                      ),
                                      aboutDetails(
                                        'assets/cost.png',
                                        'Average Cost',
                                        avgCost,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          menuImages.isNotEmpty == true
                                              ? Get.defaultDialog(
                                                  title: 'Menu',
                                                  titleStyle: GoogleFonts.ubuntu(
                                                    color: Colors.white,
                                                  ),
                                                  backgroundColor: Colors.black,
                                                  content: SizedBox(
                                                    height: 800.h,
                                                    width: Get.width,
                                                    child: CarouselSlider(
                                                      items: menuImages
                                                          .map(
                                                            (String item) => SizedBox(
                                                              height: 500.h,
                                                              width: 500.h * 16 / 9,
                                                              child: PhotoView(
                                                                imageProvider: CachedNetworkImageProvider(
                                                                  item,
                                                                ),
                                                                loadingBuilder: (_, __) => const Center(
                                                                  child: CircularProgressIndicator(
                                                                    color: Colors.orange,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                          .toList(),
                                                      options: CarouselOptions(
                                                        height: 500.h,
                                                        aspectRatio: 16 / 9,
                                                        viewportFraction: 0.95,
                                                        reverse: false,
                                                        autoPlay: false,
                                                        enableInfiniteScroll: false,
                                                        autoPlayInterval: const Duration(
                                                          seconds: 3,
                                                        ),
                                                        autoPlayAnimationDuration: const Duration(milliseconds: 800),
                                                        autoPlayCurve: Curves.fastOutSlowIn,
                                                        enlargeCenterPage: true,
                                                        scrollDirection: Axis.horizontal,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Fluttertoast.showToast(
                                                  msg: 'No Menu added',
                                                );
                                        },
                                        child: aboutDetails(
                                          'assets/menu.png',
                                          'Menu',
                                          'Click here to view',
                                        ),
                                      ),
                                    ],
                                  ),
                                ).marginAll(50.h),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                )
              else
                Container(),
              if (indexProvider.index.value == 1)
                Column(
                  children: [
                    SizedBox(
                      width: Get.width,
                      height: 800.h,
                      child: Stack(
                        children: [
                          SizedBox(
                            width: Get.width,
                            height: 800.h,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: widget.isDiscover
                                  ? CachedNetworkImage(
                                      imageUrl: widget.discoverImage,
                                      fit: BoxFit.fill,
                                      errorWidget: (_, __, ___) => CachedNetworkImage(
                                        imageUrl: galleryImages[0],
                                      ),
                                    )
                                  : imageCarousel(galleryImages),
                            ),
                          ),
                          if (widget.isDiscover == true)
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                height: 75.h,
                                width: 250.w,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                ),
                                child: Center(
                                  child: Text(
                                    '${widget.eventDate?.day}-${widget.eventDate?.month}-${widget.eventDate?.year}',
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                      fontSize: 35.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            Container()
                        ],
                      ),
                    ).marginAll(20.w),
                    headerMenu(),
                    Text(
                      widget.description,
                      style: GoogleFonts.ubuntu(
                        color: Colors.white,
                        fontSize: 45.sp,
                      ),
                    ).marginAll(30.w),
                    eventListHeading('Past Events', isPast: true),
                    if (isPastEvent) eventsList(pastEventList),
                    eventListHeading('Today Events', isToday: true),
                    if (isTodayEvent) eventsList(todayEventsList),
                    eventListHeading('Upcoming Events', isUpcoming: true),
                    if (isUpcomingEvent) eventsList(upcomingEventsList),
                  ],
                ),
              SizedBox(
                height: 20,
              ),
            ]),
          )));
}
