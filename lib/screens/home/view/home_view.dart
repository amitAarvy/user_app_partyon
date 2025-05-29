import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:user/screens/browse_live_bands_event_view.dart';
import 'package:user/screens/home/view/club_list_view.dart';
import 'package:user/screens/home/controller/home_controller.dart';
import 'package:user/screens/home/view/home_search.dart';
import 'package:user/screens/home/home_utils.dart';
import 'package:user/screens/home/view/home_view/browse_live_bands_event_list.dart';
import 'package:user/screens/home/view/home_view/next_week_list.dart';
import 'package:user/screens/home/view/home_view/popular_commercial_list.dart';
import 'package:user/screens/home/view/home_view/popular_techno_list.dart';
import 'package:user/screens/home/view/home_view/tonight_list.dart';
import 'package:user/screens/home/view/home_view/upcoming_month_list.dart';
import 'package:user/utils/dynamic_provider.dart';
import 'package:user/utils/utils.dart';
import '../../../utils/heading-widget.dart';
import '../../flash-sale-widget.dart';
import '../../my_booking/booking_list.dart';
import '../../next_week_view.dart';
import '../../nonight_view.dart';
import '../../popular_techno_view.dart';
import '../../this_week_view.dart';
import '../../upcoming_month_view.dart';
import '../../popular_bollywood_view.dart';
import 'home_view/this_week.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int currentPageIndex = 0;
  String? selectedCity;
  TextEditingController searchCity = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final DynamicProvider dynamicProvider = Get.put(DynamicProvider());
  final HomeController homeController = Get.put(HomeController());
  GlobalKey<SliderDrawerState> key = GlobalKey<SliderDrawerState>();
  List favList = [];
  late StreamSubscription stream;

  // List<DocumentSnapshot> clubList = [];
  final ScrollController homeScrollController = ScrollController();
  DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime week = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(const Duration(days: 7));
  DateTime weekEnd = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(const Duration(days: 14));
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(const Duration(days: 30));
  List tonightData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initHome();
    });
  }


  initHome() async {
    try {
      await getCity(context, homeController).whenComplete(EasyLoading.dismiss);
      await getClubList();
      getFav();
      fetchTonightEventData();
      fetchLiveBandsEventData();
      fetchNextWeekEventData();
      fetchUpcomingMonthEventData();
      fetchTechnoListEventData();
      fetchCommercialEventData();
      fetchThisWeekEventData();
    }catch(e){
      log('error is check ${e}');
    }
  }

  List nextWeekEventData = [];
  List liveBandsEventData = [];
  List popularTechnoData = [];
  List upcomingMonthData = [];
  List popularCommercialData = [];
  List thisWeekEventData = [];
  final HomeController hc = Get.put(HomeController());



  void fetchCommercialEventData() async{
    QuerySnapshot data = await FirebaseFirestore.instance
        .collection('Events')
        .where('isActive', isEqualTo: true)
        .where('genre', isEqualTo: "Bollywood Commercial")
    // .where('date', isGreaterThanOrEqualTo: today)
        .get();
    QuerySnapshot clubData =await FirebaseFirestore.instance
        .collection("Club")
        .where("businessCategory", isEqualTo: 1)
        .get();
    popularCommercialData = data.docs;
    popularCommercialData = data.docs.where((element) {
      return clubData.docs.where((e)=>e['city'] == hc.city ||
          e['locality'] == hc.city ||
          hc.showFav == true)
          .map((ele) => ele['clubUID'])
          .contains(element['clubUID']);
    }).toList();
    popularCommercialData = data.docs.where((element) => element['date'].toDate().isAfter(today)).toList();
    popularCommercialData.sort((a, b) => a['date'].toDate().compareTo(b['date'].toDate()));
    popularCommercialData = popularCommercialData.sublist(0, popularCommercialData.length >=10 ? 10 : popularCommercialData.length);
    setState(() {});
  }

  void fetchUpcomingMonthEventData() async{
    QuerySnapshot data = await FirebaseFirestore.instance
        .collection('Events')
        .where('isActive', isEqualTo: true)
        .get();
    QuerySnapshot clubData =await FirebaseFirestore.instance
        .collection("Club")
        .where("businessCategory", isEqualTo: 1)
        .get();
    upcomingMonthData = data.docs;
    print('current city is ${hc.city}');
    if(hc.city =='All City'){
      upcomingMonthData = data.docs.where((element) {
        return clubData.docs
            .map((ele) => ele['clubUID'])
            .contains(element['clubUID']);
      }).toList();
    }else{
      upcomingMonthData = data.docs.where((element) {
        return clubData.docs.where((e)=>e['city'] == hc.city ||
            e['locality'] == hc.city ||
            hc.showFav == true)
            .map((ele) => ele['clubUID'])
            .contains(element['clubUID']);
      }).toList();
    }

    upcomingMonthData = upcomingMonthData.where((element) => element['date'].toDate().isAfter(today)).toList();
    upcomingMonthData.sort((a, b) => a['date'].toDate().compareTo(b['date'].toDate()));
    setState(() {});
  }

  void fetchTechnoListEventData() async{
    QuerySnapshot data = await FirebaseFirestore.instance
        .collection('Events')
        .where('genre', isEqualTo: 'Techno')
        .where('isActive', isEqualTo: true)
        .get();
    QuerySnapshot clubData =await FirebaseFirestore.instance
        .collection("Club")
        .where("businessCategory", isEqualTo: 1)
        .get();
    popularTechnoData = data.docs;
    print('current city is ${hc.city}');
    if(hc.city =='All City'){
      popularTechnoData = data.docs.where((element) {
        return clubData.docs
            .map((ele) => ele['clubUID'])
            .contains(element['clubUID']);
      }).toList();
    }else{
      popularTechnoData = data.docs.where((element) {
        return clubData.docs.where((e)=>e['city'] == hc.city ||
            e['locality'] == hc.city ||
            hc.showFav == true)
            .map((ele) => ele['clubUID'])
            .contains(element['clubUID']);
      }).toList();
    }

    popularTechnoData = popularTechnoData.where((element) => element['date'].toDate().isAfter(today)).toList();
    popularTechnoData.sort((a, b) => a['date'].toDate().compareTo(b['date'].toDate()));
    setState(() {});
  }
  void fetchThisWeekEventData() async{
    DateTime now = DateTime.now();
    int weekday = now.weekday;
    DateTime weekStart = now.subtract(Duration(days: weekday - 1));
    DateTime weekEnds = weekStart.add(Duration(days: 6));  // 6 days after weekStart
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
    thisWeekEventData = data.docs.where((element) {
      return clubData.docs.where((e)=>e['city'] == hc.city ||
          e['locality'] == hc.city ||
          hc.showFav == true)
          .map((ele) => ele['clubUID'])
          .contains(element['clubUID']);
    }).toList();
    thisWeekEventData = thisWeekEventData.where((element) {
      DateTime eventDate = element['date'].toDate(); // Converting to DateTime if it's a Timestamp
      return eventDate.isAfter(weekStart) && eventDate.isBefore(weekEnds);
    }).toList();    thisWeekEventData.sort((a, b) => a['date'].toDate().compareTo(b['date'].toDate()));
    thisWeekEventData = thisWeekEventData.sublist(0, thisWeekEventData.length >=10 ? 10 : thisWeekEventData.length);
    thisWeekEventData = thisWeekEventData.where((element) {
      DateTime eventDate = element['date'].toDate();
      return eventDate.isAfter(DateTime.now());
    },).toList();
    setState(() {});
  }
  void fetchNextWeekEventData() async{
    try {
      QuerySnapshot data = await FirebaseFirestore.instance
          .collection('Events')
          .where('isActive', isEqualTo: true)
      // .where('date', isGreaterThanOrEqualTo: week)
      // .limit(4)
          .get();
      QuerySnapshot clubData = await FirebaseFirestore.instance
          .collection("Club")
          .where("businessCategory", isEqualTo: 1)
          .get();
      nextWeekEventData = data.docs;
      print('check list data is ${nextWeekEventData}');
      if (hc.city == 'All City') {
        nextWeekEventData = data.docs.where((element) {
          return clubData.docs
              .map((ele) => ele['clubUID'])
              .contains(element['clubUID']);
        }).toList();
      } else {
        nextWeekEventData = data.docs.where((element) {
          return clubData.docs.where((e) =>
          e['city'] == hc.city ||
              e['locality'] == hc.city ||
              hc.showFav == true)
              .map((ele) => ele['clubUID'])
              .contains(element['clubUID']);
        }).toList();
      }


      DateTime now = DateTime.now();
      int currentDay = now.weekday;
      int daysToNextMonday = (currentDay == 7) ? 1 : (8 - currentDay);
      DateTime nextMonday = now.add(Duration(days: daysToNextMonday));
      DateTime nextSunday = nextMonday.add(Duration(days: 6));
      nextWeekEventData = nextWeekEventData.where((element) {
        DateTime eventDate = element['date'].toDate();
        return eventDate.isAfter(nextMonday.subtract(Duration(days: 1))) &&
            eventDate.isBefore(nextSunday.add(Duration(days: 1)));
      }).toList();
      nextWeekEventData.sort((a, b) =>
          a['date'].toDate().compareTo(b['date'].toDate()));
      print('check list data is 2${nextWeekEventData}');
      setState(() {});
    }catch(e){
      log(e.toString());
    }
  }
  void fetchLiveBandsEventData() async{
    try {
      QuerySnapshot data = await FirebaseFirestore.instance
          .collection('Events')
          .where('isActive', isEqualTo: true)
          .where('bandType', isEqualTo: "Live band")
      // .where('date', isGreaterThanOrEqualTo: today)
          .get();

      QuerySnapshot clubData = await FirebaseFirestore.instance
          .collection("Club")
          .where("businessCategory", isEqualTo: 1)
          .get();
      liveBandsEventData = data.docs;
      if (hc.city == 'All City') {
        liveBandsEventData = data.docs.where((element) {
          return clubData.docs
              .map((ele) => ele['clubUID'])
              .contains(element['clubUID']);
        }).toList();
      } else {
        liveBandsEventData = data.docs.where((element) {
          return clubData.docs.where((e) =>
          e['city'] == hc.city ||
              e['locality'] == hc.city ||
              hc.showFav == true)
              .map((ele) => ele['clubUID'])
              .contains(element['clubUID']);
        }).toList();
      }

      liveBandsEventData = liveBandsEventData.where((element) =>
          element['date'].toDate().isAfter(today)).toList();
      liveBandsEventData.sort((a, b) =>
          a['date'].toDate().compareTo(b['date'].toDate()));
      liveBandsEventData = liveBandsEventData.sublist(
          0, liveBandsEventData.length >= 10 ? 10 : liveBandsEventData!.length);
      setState(() {});
    }catch(e){
      log('error is check ${e}');
    }
  }

  void fetchTonightEventData() async{
    try {
      QuerySnapshot data = await FirebaseFirestore.instance
          .collection('Events')
          .where('isActive', isEqualTo: true)
          .where('date', isEqualTo: today)
          .get();
      QuerySnapshot clubData = await FirebaseFirestore.instance
          .collection("Club")
          .where("businessCategory", isEqualTo: 1)
          .get();
      tonightData = data.docs;
      if (hc.city == 'All City') {
        tonightData = data.docs.where((element) {
          return clubData.docs
              .map((ele) => ele['clubUID'])
              .contains(element['clubUID']);
        }).toList();
      } else {
        tonightData = data.docs.where((element) {
          return clubData.docs.where((e) =>
          e['city'] == hc.city ||
              e['locality'] == hc.city ||
              hc.showFav == true)
              .map((ele) => ele['clubUID'])
              .contains(element['clubUID']);
        }).toList();
      }

      tonightData.sort((a, b) =>
          a['date'].toDate().compareTo(b['date'].toDate()));
      print('length list of2 ${tonightData.length}');
      tonightData = tonightData.sublist(
          0, tonightData.length >= 10 ? 10 : tonightData.length);
      setState(() {});
    }catch(e){
      log(e.toString());
    }
  }
  List globalSetting =[];

  void getGlobalDetail() async{
    QuerySnapshot data = await FirebaseFirestore.instance
        .collection('globalSettings')
        .get();
    globalSetting = data.docs;

  }

  Future<void> getFav() async {
    stream = FirebaseFirestore.instance
        .collection('User')
        .doc(uid())
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> event) {
      if (event.exists) {
        try {
          Provider.of<FavList>(context, listen: false)
              .updateFavList(event.data()!['fav']);
        } catch (e) {
          Provider.of<FavList>(context, listen: false).updateFavList([]);
        }
      }
    });
  }



  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () => onWillPop(context),
    child: Scaffold(
      backgroundColor: Colors.black,
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer:  drawer(),
      body: Obx(
              () => homeController.showCity == true
              ? HomeSearchCity(
              homeApi: initHome,
              searchCity: searchCity,
              clubList: homeController.clubList,
              isLoading: homeController.isLoading)
              : Container(
            height: Get.height,
            width: Get.width,
            color: themeRed(),
            child: SingleChildScrollView(
              controller: homeScrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: Get.width,
                    height: 340,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/we.gif"),
                        fit: BoxFit.fill,

                      ),
                    ),
                    child: Padding(
                      padding:
                      EdgeInsets.only(top: 80.w, ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Column(
                                children: [
                                  Obx(
                                        () => GestureDetector(
                                          onTap: ()=>_scaffoldKey.currentState?.openDrawer(),
                                          child: Text(homeController.userName.capitalizeFirstOfEach,
                                         style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontSize: 45.sp,
                                          fontWeight: FontWeight.bold,
                                           ),
                                          ),
                                        ),
                                  ).marginOnly(top: 20.h),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      homeController.updateShowCity(!homeController.showCity);
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          child: Obx(
                                                () => Text(
                                              homeController.city,
                                              textAlign:
                                              TextAlign.center,
                                              style: GoogleFonts.ubuntu(
                                                fontSize: 38.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ).marginOnly(left: 20.h),
                                        ),
                                        const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ).marginOnly(left: 20.w),
                          GestureDetector(
                            onTap: () {}, // Open drawer on button tap
                            // key.currentState?.isDrawerOpen == true
                            //     ? key.currentState
                            //     ?.animationController
                            //     .reverse()
                            //     : key.currentState
                            //     ?.animationController
                            //     .forward(),
                            child: SizedBox(
                              height: 200.h,
                              width: 300.h,
                              child: Center(
                                child: Text(
                                  'PartyOn',
                                  style: GoogleFonts.dancingScript(
                                    fontSize: 80.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20.w,
                          ),

                          // SizedBox(
                          //   height: 200.h,
                          //   width: 100.w,
                          //   child: Stack(
                          //     children: [
                          //       // Positioned(
                          //       //   top: -20.h,
                          //       //   right: 0,
                          //       //   child: IconButton(
                          //       //     onPressed: () {
                          //       //       Provider.of<ShowOptions>(context,
                          //       //               listen: false)
                          //       //           .changeFilter(
                          //       //         !Provider.of<ShowOptions>(
                          //       //           context,
                          //       //           listen: false,
                          //       //         ).showFilter,
                          //       //       );
                          //       //     },
                          //       //     icon: Icon(
                          //       //       Icons.filter_list_outlined,
                          //       //       color: Colors.white,
                          //       //       size: 60.h,
                          //       //     ),
                          //       //   ),
                          //       // ),
                          //       // Positioned(
                          //       //   bottom: 0,
                          //       //   right: 0.w,
                          //       //   child: IconButton(
                          //       //     icon: Icon(
                          //       //       Icons.search,
                          //       //       color: Colors.white,
                          //       //       size: 60.h,
                          //       //     ),
                          //       //     onPressed: () {
                          //       //       Get.to(const SearchClub());
                          //       //     },
                          //       //   ),
                          //       // ),
                          //     ],
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  ),
                  // Container(
                  //   width: Get.width,
                  //   height: 340,
                  //   decoration: BoxDecoration(
                  //     image: DecorationImage(
                  //       image: AssetImage("assets/we.gif"),
                  //       fit: BoxFit.fill,
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 100.h,
                  //   child: ListView.builder(
                  //     scrollDirection: Axis.horizontal,
                  //     itemCount: 3,
                  //     itemBuilder: (BuildContext context, int index) {
                  //       String name = '';
                  //       if (index == 0) {
                  //         name = 'Discover';
                  //       }
                  //       if (index == 1) {
                  //         name = 'Genre';
                  //       } else if (index == 2) {
                  //         name = 'Category';
                  //       }
                  //
                  //       return GestureDetector(
                  //         onTap: () {
                  //           if (index == 0) {
                  //             Get.to(() => const Discover());
                  //           }
                  //           // else
                  //           if (index == 1) {
                  //             Get.bottomSheet(
                  //               Card(
                  //                 color: Colors.black,
                  //                 elevation: 5,
                  //                 child: ListView.builder(
                  //                   physics:
                  //                       const BouncingScrollPhysics(),
                  //                   itemCount:
                  //                       AppConst.genreList.length,
                  //                   itemBuilder:
                  //                       (BuildContext context,
                  //                               int index) =>
                  //                           Column(
                  //                     children: [
                  //                       GestureDetector(
                  //                         onTap: () {
                  //                           homeController
                  //                             ..updateFilter(
                  //                               'genre',
                  //                             )
                  //                             ..updateGenre(
                  //                               AppConst
                  //                                   .genreList[index],
                  //                             );
                  //                           Get.back();
                  //                         },
                  //                         child: Container(
                  //                           height: 150.h,
                  //                           width: Get.width,
                  //                           decoration: BoxDecoration(
                  //                             color: AppConst.genreList[
                  //                                         index] ==
                  //                                     homeController
                  //                                         .genre
                  //                                 ? themeRed()
                  //                                 : Colors.black,
                  //                             border: Border.all(
                  //                               color: Colors.white,
                  //                               width: 1.h,
                  //                             ),
                  //                           ),
                  //                           child: Center(
                  //                             child: Text(
                  //                               AppConst
                  //                                   .genreList[index],
                  //                               style: GoogleFonts
                  //                                   .ubuntu(
                  //                                 color: Colors.white,
                  //                                 fontWeight:
                  //                                     FontWeight.bold,
                  //                                 fontSize: 50.sp,
                  //                               ),
                  //                             ),
                  //                           ),
                  //                         ),
                  //                       ),
                  //                     ],
                  //                   ),
                  //                 ),
                  //               ),
                  //             );
                  //           } else if (index == 2) {
                  //             Get.bottomSheet(
                  //               Card(
                  //                 color: Colors.black,
                  //                 elevation: 5,
                  //                 child: ListView.builder(
                  //                   physics:
                  //                       const BouncingScrollPhysics(),
                  //                   itemCount:
                  //                       AppConst.venueTypeList.length,
                  //                   itemBuilder:
                  //                       (BuildContext context,
                  //                               int index) =>
                  //                           Column(
                  //                     children: [
                  //                       GestureDetector(
                  //                         onTap: () {
                  //                           homeController
                  //                             ..updateFilter(
                  //                               'category',
                  //                             )
                  //                             ..updateCategory(
                  //                               AppConst.venueTypeList[
                  //                                   index],
                  //                             );
                  //                           Get.back();
                  //                         },
                  //                         child: Container(
                  //                           height: 150.h,
                  //                           width: Get.width,
                  //                           decoration: BoxDecoration(
                  //                             color: AppConst.venueTypeList[
                  //                                         index] ==
                  //                                     homeController
                  //                                         .category
                  //                                 ? themeRed()
                  //                                 : Colors.black,
                  //                             border: Border.all(
                  //                               color: Colors.white,
                  //                               width: 1.h,
                  //                             ),
                  //                           ),
                  //                           child: Center(
                  //                             child: Text(
                  //                               AppConst.venueTypeList[
                  //                                   index],
                  //                               style: GoogleFonts
                  //                                   .ubuntu(
                  //                                 color: Colors.white,
                  //                                 fontWeight:
                  //                                     FontWeight.bold,
                  //                                 fontSize: 50.sp,
                  //                               ),
                  //                             ),
                  //                           ),
                  //                         ),
                  //                       ),
                  //                     ],
                  //                   ),
                  //                 ),
                  //               ),
                  //             );
                  //           } else if (index == 3) {
                  //             homeController
                  //               ..updateIsEvents(true)
                  //               ..updateFilter('events');
                  //           }
                  //         },
                  //         child: Container(
                  //           height: 80.h,
                  //           width: Get.width / 4,
                  //           decoration: BoxDecoration(
                  //             color: Colors.black,
                  //             borderRadius: BorderRadius.circular(
                  //               20,
                  //             ),
                  //           ),
                  //           child: Row(
                  //             mainAxisAlignment:
                  //                 MainAxisAlignment.center,
                  //             children: [
                  //               Text(
                  //                 name,
                  //                 style: GoogleFonts.openSans(
                  //                   color: Colors.white,
                  //                   fontWeight: FontWeight.bold,
                  //                   fontSize: 40.sp,
                  //                 ),
                  //               )
                  //             ],
                  //           ).marginOnly(
                  //             left: 30.w,
                  //             right: 30.w,
                  //           ),
                  //         ).marginOnly(
                  //           left: 40.w,
                  //           right: 40.w,
                  //           top: 20.h,
                  //           bottom: 10.h,
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                  //heading



                  // HeadingWidget(
                  //   headingTitle: "Featured",
                  //   onTap: () => Get.to(() => const BookingList()),
                  //   buttonText: " > ",
                  // ),
                  //
                  // FeaturedView(),

                  // if (homeController.filter.isNotEmpty)
                  //   ElevatedButton(
                  //     onPressed: () {
                  //       homeController
                  //         ..updateFilter('')
                  //         ..updateGenre('')
                  //         ..updateCategory('')
                  //         ..updateIsEvents(false)
                  //         ..updateShowFav(false);
                  //       Provider.of<L2HProvider>(
                  //         context,
                  //         listen: false,
                  //       ).l2h.clear();
                  //     },
                  //     style: ButtonStyle(
                  //       backgroundColor:
                  //           MaterialStateProperty.resolveWith(
                  //         (Set<MaterialState> states) => themeRed(),
                  //       ),
                  //     ),
                  //     child: const Text('Clear Filters'),
                  //   ),
                  // if (homeController.isLoading)
                  //   const SizedBox()
                  // else if (homeController.filter == 'l2h')
                  //   SingleChildScrollView(
                  //     child: LowToHighView(
                  //       homeScrollController: homeScrollController,
                  //       isL2H: true,
                  //       clubList: homeController.clubList,
                  //     ),
                  //   )
                  // else
                  //   homeController.filter == 'h2l'
                  //       ? SingleChildScrollView(
                  //           child: LowToHighView(
                  //               homeScrollController:
                  //                   homeScrollController,
                  //               clubList: homeController.clubList),
                  //         )
                  //       : ClubListView(
                  //           homeScrollController: homeScrollController,
                  //           clubList: homeController.clubList,
                  //           favList: favList),

                  // Container(
                  //   decoration: BoxDecoration(
                  //     boxShadow: [
                  //       BoxShadow(
                  //         offset: Offset(0, 1.h),
                  //         spreadRadius: 5.h,
                  //         blurRadius: 20.h,
                  //         color: Colors.deepPurple,
                  //       )
                  //     ],
                  //     borderRadius: BorderRadius.circular(22),
                  //     color: Color(0x42DCDCDC),
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       HeadingWidget(
                  //         headingTitle: "Popular Event",
                  //         onTap: () => Get.to(() => const BookingList()),
                  //         buttonText: " > ",
                  //       ),
                  //       PopularView(),
                  //     ],
                  //   ),
                  // ).marginAll(10.0),
                  if(tonightData.isNotEmpty)...[
                    HeadingWidget(
                      headingTitle: "Tonight",
                      onTap: () => Get.to(() =>  TonightList()),
                      buttonText: " > ",
                    ),
                    TonightView(tonightEventData: tonightData,),
                  ],
                  if(thisWeekEventData.isNotEmpty)...[
                    HeadingWidget(
                      headingTitle: "This Week",
                      onTap: () => Get.to(() =>  ThisWeekList()),
                      buttonText: " > ",
                    ),
                    thisWeekView(thisWeekEventData: thisWeekEventData,),
                  ],
                  HeadingWidget(
                    headingTitle: "Trending Genere’s",
                    onTap: () => Get.to(() =>  ThisWeekList()),
                    buttonText: " > ",
                    hideTrailing: true,
                  ),
                  SizedBox(height: 5,),
                  Container(
                    padding:EdgeInsets.all(11),
                    margin:EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color:Colors.deepPurple,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 1.h),
                            spreadRadius: 5.h,
                            blurRadius: 20.h,
                            color: Colors.deepPurple,
                          )
                        ],
                        borderRadius: BorderRadius.circular(22),
                        // color: Color(0x42C3C3C3),
                        // color: Colors.black
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            technoUi('assets/techno.png',callBack: (){Get.to(() => const PopularTechnoList());}),
                            technoUi('assets/rock.png',callBack: (){Get.to(() => const PopularTechnoList(type: 'Rock',));}),
                            technoUi('assets/liveBands.png',callBack: (){Get.to(() => BrowseLiveBandsEventsList());}),
                          ],
                        ),
                        SizedBox(height:10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            technoUi('assets/hipHop.png',callBack: (){Get.to(() => const PopularTechnoList(type: 'Rap/Hip-Hop',));}),
                            technoUi('assets/commerical.png',callBack: (){ Get.to(() => const PopularCommercialList());}),
                            technoUi('assets/afroHouse.png',callBack: (){Get.to(() => const PopularTechnoList(type: 'House',));}),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),

                  // if(nextWeekEventData.isNotEmpty)...[
                  //   HeadingWidget(
                  //     headingTitle: "Next Week",
                  //     onTap: () => Get.to(() =>  NextWeekList()),
                  //     buttonText: " > ",
                  //   ),
                  //   NextWeekView(nextWeekEventData:nextWeekEventData ,),
                  // ],


                  // HeadingWidget(
                  //   headingTitle: "Trending Event",
                  //   onTap: () => Get.to(() => const BookingList()),
                  //   buttonText: " > ",
                  // ),
                  //
                  // TendingView(),
                  if(liveBandsEventData.isNotEmpty)
                    HeadingWidget(
                      headingTitle: "Browse Event by live bands",
                      onTap: () => Get.to(() => BrowseLiveBandsEventsList()),
                      buttonText: " > ",
                    ),
                  if(liveBandsEventData.isNotEmpty)
                    BrowseLiveBandsEventsView(liveBandsEventData: liveBandsEventData,),


                  if(popularTechnoData.isNotEmpty)
                    Container(
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
                          // color: Color(0x42C3C3C3),
                          color: Colors.black
                      ),
                      child:

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          HeadingWidget(
                            headingTitle: "Popular Techno Events",
                            onTap: () => Get.to(() => const PopularTechnoList()),
                            buttonText: " > ",
                          ),
                          PoputerTechnoView(technoEventData: popularTechnoData,),
                        ],
                      ),
                    ).marginAll(10.0),

                  if(upcomingMonthData.isNotEmpty)...[
                    HeadingWidget(
                      headingTitle: "Upcoming Events",
                      onTap: () => Get.to(() => const UpcomingMonthList()),
                      buttonText: " > ",
                    ),

                    UpcomingMonthView(upcomingMonthEventData: upcomingMonthData,),
                  ],

                  if(popularCommercialData.isNotEmpty)
                    Container(
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
                          // color: Color(0x42C3C3C3),
                          color: Colors.black
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          HeadingWidget(
                            headingTitle: "Popular Events by Commercial",
                            onTap: () => Get.to(() => const PopularCommercialList()),
                            buttonText: " > ",
                          ),
                          PoputerBollywoodView(popularCommercialData: popularCommercialData,),
                        ],
                      ),
                    ).marginAll(10.0),
                  HeadingWidget(
                    headingTitle: "Browse Event by Categories",
                    onTap: () => Get.to(() => const BookingList()),
                    buttonText: " > ",
                    hideTrailing: true,
                  ),
                  FlashSaleWidget(),
                ],
              ),
            ),
          ),
        ),
      ),

  );
}
Widget technoUi(String path,{VoidCallback?callBack}){
  return GestureDetector(
    onTap:callBack,
    child: Container(
      height:100,
      width:100,
      decoration:BoxDecoration(
        borderRadius:BorderRadius.all(Radius.circular(11)),
        image:DecorationImage(
          image:AssetImage(path)
        )
      )
    ),
  );
}

class LowToHighView extends StatefulWidget {
  final List<DocumentSnapshot> clubList;
  final bool isL2H;
  final ScrollController homeScrollController;

  const LowToHighView(
      {required this.clubList,
        this.isL2H = false,
        super.key,
        required this.homeScrollController});

  @override
  State<LowToHighView> createState() => _LowToHighViewState();
}

class _LowToHighViewState extends State<LowToHighView> {
  bool showEvent = false;
  List<DocumentSnapshot> l2hClubList = [];

  sortList() {
    l2hClubList = widget.clubList;
    if (widget.isL2H) {
      l2hClubList.sort((a, b) {
        if (a['averageCost'].toString() != "null" &&
            b['averageCost'].toString() != "null") {
          return int.parse(a['averageCost'].toString()) >
              int.parse(b['averageCost'].toString())
              ? 1
              : 0;
        } else {
          return 0;
        }
      });
    } else {
      l2hClubList.sort((a, b) {
        if (a['averageCost'].toString() != "null" &&
            b['averageCost'].toString() != "null") {
          return int.parse(a['averageCost'].toString()) <
              int.parse(b['averageCost'].toString())
              ? 1
              : 0;
        } else {
          return 0;
        }
      });
    }
    setState(() {});
  }

  @override
  void initState() {
    sortList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => ClubListView(
      homeScrollController: widget.homeScrollController,
      clubList: l2hClubList,
      favList: const [],
      isL2HView: true);
}

class EventImage extends GetxController {
  final RxString _eventImage = ''.obs;

  String get eventImage => _eventImage.value;

  String changeEventImage(String val) => _eventImage.value = val;
}
