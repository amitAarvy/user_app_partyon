import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:user/local_db/hive_db.dart';
import 'package:user/screens/home/controller/home_controller.dart';
import 'package:user/screens/search/seach_club_view.dart';
import 'package:user/utils/location.dart';
import 'package:user/utils/utils.dart';

Future<void> getCity(BuildContext context, HomeController homeController) async {
  await EasyLoading.show();
  await FirebaseFirestore.instance.collection('User').doc(uid()).get().then((DocumentSnapshot<Map<String, dynamic>> value) async {
    if (value.exists) {
      Box cityBox = await HiveDB.hiveOpenCity();
      String? homeCity = await HiveDB.getKey(cityBox, 'homeCity');
      if (homeCity != null) {
        homeController.updateUserName(value.data()?['userName']);
        homeController.updateCity(homeCity);
      } else {
        homeController
          ..updateUserName(value.data()?['userName'])
          ..updateCity(value.data()?['city']);
      }
    } else {
      Fluttertoast.showToast(msg: 'Something went wrong');
    }
  });
}

Future<void> getLocation(BuildContext context) async {
  await EasyLoading.show();
  try {
    await getGeoLocationPosition().then((Position value) {
      homeController.updateLatLong(lat: value.latitude, long: value.longitude);
      EasyLoading.dismiss();
    });
  } catch (e) {
    await EasyLoading.dismiss();
  }
}

Widget headerOptionAppBar(String title, Function() onTap) => GestureDetector(
      onTap: () => onTap(),
      child: Container(
        height: 75.h,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.ubuntu(
              fontSize: 35.sp,
              color: Colors.white,
            ),
          ),
        ).marginOnly(left: 30.w, right: 30.w),
      ).marginOnly(left: 20.w, right: 20.w, top: 10.h),
    );

Widget homeAppBar(BuildContext context, GlobalKey<SliderDrawerState> key, HomeController homeController) => SliderAppBar(
      appBarColor: themeRed(),
      appBarPadding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
      drawerIconColor: Colors.white,
      drawerIcon: Container(),
      appBarHeight: MediaQuery.of(context).viewPadding.top + (Provider.of<ShowOptions>(context).showFilter == false ? 200.h : 300.h),
      trailing: Container(),
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      Obx(
                        () => Text(
                          homeController.userName,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 41.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ).marginOnly(top: 20.h),
                      GestureDetector(
                        onTap: () {
                          homeController.updateShowCity(!homeController.showCity);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              child: Obx(
                                () => Text(
                                  homeController.city,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 38.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
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
                onTap: () => key.currentState?.isDrawerOpen == true ? key.currentState?.animationController.reverse() : key.currentState?.animationController.forward(),
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
              SizedBox(
                height: 200.h,
                width: 100.w,
                child: Stack(
                  children: [
                    Positioned(
                      top: -20.h,
                      right: 0,
                      child: IconButton(
                        onPressed: () {
                          Provider.of<ShowOptions>(context, listen: false).changeFilter(
                            !Provider.of<ShowOptions>(
                              context,
                              listen: false,
                            ).showFilter,
                          );
                        },
                        icon: Icon(
                          Icons.filter_list_outlined,
                          color: Colors.white,
                          size: 60.h,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0.w,
                      child: IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 60.h,
                        ),
                        onPressed: () {
                          Get.to(const SearchClub());
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          if (Provider.of<ShowOptions>(context, listen: false).showFilter == true)
            SizedBox(
              height: 75.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  headerOptionAppBar('Relevance', () {}),
                  headerOptionAppBar('Cost: Low to High', () {
                    homeController.updateFilter('l2h');
                  }),
                  headerOptionAppBar('Cost: High to Low', () {
                    homeController.updateFilter('h2l');
                  }),
                  headerOptionAppBar('Favourites', () {
                    homeController.updateShowFav(true);
                    homeController.updateFilter('fav');
                  }),
                ],
              ),
            )
          else
            Container()
        ],
      ),
    );
