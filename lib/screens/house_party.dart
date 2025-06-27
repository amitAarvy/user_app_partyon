import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:user/screens/home/view/club_list_view.dart';
import 'package:user/screens/home/view/discover_view.dart';
import 'package:user/screens/home/controller/home_controller.dart';
import 'package:user/screens/home/view/home_search.dart';
import 'package:user/screens/home/home_utils.dart';
import 'package:user/utils/app_const.dart';
import 'package:user/utils/dynamic_provider.dart';
import 'package:user/utils/utils.dart';

import '../../../utils/heading-widget.dart';
import 'bottom-screens.dart';
import 'flash-sale-widget.dart';

class HousePartyView extends StatefulWidget {
  const HousePartyView({super.key});

  @override
  State<HousePartyView> createState() => _HousePartyViewState();
}

class _HousePartyViewState extends State<HousePartyView> {
  int currentPageIndex = 0;
  String? selectedCity;
  TextEditingController searchCity = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final DynamicProvider dynamicProvider = Get.put(DynamicProvider());
  final HomeController homeController = Get.put(HomeController());
  GlobalKey<SliderDrawerState> key = GlobalKey<SliderDrawerState>();
  List favList = [];
  bool isFolded = false;
  late StreamSubscription stream;

  // List<DocumentSnapshot> clubList = [];
  final ScrollController homeScrollController = ScrollController();

  @override
  void initState() {
    initHome();
    super.initState();
  }

  void initHome() async {
    await getCity(context, homeController).whenComplete(EasyLoading.dismiss);
    await getClubList();
    getFav();
  }

  Future<void> getFav() async {
    stream = FirebaseFirestore.instance.collection('User').doc(uid()).snapshots().listen((DocumentSnapshot<Map<String, dynamic>> event) {
      if (event.exists) {
        try {
          Provider.of<FavList>(context, listen: false).updateFavList(event.data()!['fav']);
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
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () => onWillPop(context),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SliderDrawer(
            key: key,
            appBar: homeAppBar(context, key, homeController),
            slider: drawer(isFolded: isFolded),
            child: Obx(
              () => homeController.showCity == true
                  ? HomeSearchCity(searchCity: searchCity, clubList: homeController.clubList, isLoading: homeController.isLoading)
                  : Container(
                      height: Get.height,
                      width: Get.width,
                      color: matte(),
                      child: SingleChildScrollView(
                        controller: homeScrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20.h,
                            ),

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
                            HeadingWidget(
                              headingTitle: "Tonight",
                              onTap: () => Get.to(() => const BottomNavigationBarExampleApp()),
                              buttonText: ">",
                            ),

                            FlashSaleWidget(),

                            HeadingWidget(
                              headingTitle: "This Week",
                              onTap: () => Get.to(() => const HousePartyView()),
                              buttonText: ">",
                            ),

                            FlashSaleWidget(),
                            HeadingWidget(
                              headingTitle: "Next Week",
                              onTap: () => Get.to(() => const HousePartyView()),
                              buttonText: ">",
                            ),

                            FlashSaleWidget(),
                            HeadingWidget(
                              headingTitle: "Upcoming Months",
                              onTap: () => Get.to(() => const HousePartyView()),
                              buttonText: ">",
                            ),

                            FlashSaleWidget(),
                            HeadingWidget(
                              headingTitle: "Recommended ",
                              onTap: () => Get.to(() => const HousePartyView()),
                              buttonText: ">",
                            ),

                            FlashSaleWidget(),
                            HeadingWidget(
                              headingTitle: "Choose by music (Genre)",
                              onTap: () => Get.to(() => const HousePartyView()),
                              buttonText: ">",
                            ),

                            FlashSaleWidget(),

                            HeadingWidget(
                              headingTitle: "Choose by category",
                              onTap: () => Get.to(() => const HousePartyView()),
                              buttonText: ">",
                            ),

                            FlashSaleWidget(),

                            HeadingWidget(
                              headingTitle: "All Events",
                              onTap: () => Get.to(() => const HousePartyView()),
                              buttonText: ">",
                            ),

                            if (homeController.filter.isNotEmpty)
                              ElevatedButton(
                                onPressed: () {
                                  homeController
                                    ..updateFilter('')
                                    ..updateGenre('')
                                    ..updateCategory('')
                                    ..updateIsEvents(false)
                                    ..updateShowFav(false);
                                  Provider.of<L2HProvider>(
                                    context,
                                    listen: false,
                                  ).l2h.clear();
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.resolveWith(
                                    (Set<MaterialState> states) => themeRed(),
                                  ),
                                ),
                                child: const Text('Clear Filters'),
                              ),
                            if (homeController.isLoading)
                              const SizedBox()
                            else if (homeController.filter == 'l2h')
                              SingleChildScrollView(
                                child: LowToHighView(
                                  homeScrollController: homeScrollController,
                                  isL2H: true,
                                  clubList: homeController.clubList,
                                ),
                              )
                            else
                              homeController.filter == 'h2l'
                                  ? SingleChildScrollView(
                                      child: LowToHighView(homeScrollController: homeScrollController, clubList: homeController.clubList),
                                    )
                                  : ClubListView(homeScrollController: homeScrollController, clubList: homeController.clubList, favList: favList)
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      );
}

class LowToHighView extends StatefulWidget {
  final List<DocumentSnapshot> clubList;
  final bool isL2H;
  final ScrollController homeScrollController;

  const LowToHighView({required this.clubList, this.isL2H = false, super.key, required this.homeScrollController});

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
        if (a['averageCost'].toString() != "null" && b['averageCost'].toString() != "null") {
          return int.parse(a['averageCost'].toString()) > int.parse(b['averageCost'].toString()) ? 1 : 0;
        } else {
          return 0;
        }
      });
    } else {
      l2hClubList.sort((a, b) {
        if (a['averageCost'].toString() != "null" && b['averageCost'].toString() != "null") {
          return int.parse(a['averageCost'].toString()) < int.parse(b['averageCost'].toString()) ? 1 : 0;
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
  Widget build(BuildContext context) => ClubListView(homeScrollController: widget.homeScrollController, clubList: l2hClubList, favList: const [], isL2HView: true);
}

class EventImage extends GetxController {
  final RxString _eventImage = ''.obs;

  String get eventImage => _eventImage.value;

  String changeEventImage(String val) => _eventImage.value = val;
}
