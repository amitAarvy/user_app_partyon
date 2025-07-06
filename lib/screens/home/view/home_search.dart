import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:user/local_db/hive_db.dart';
import 'package:user/screens/home/controller/home_controller.dart';
import 'package:user/utils/cities.dart';
import 'package:user/utils/utils.dart';

class HomeSearchCity extends StatefulWidget {
  final TextEditingController searchCity;

  final List clubList;

  final bool isLoading;
  final Function? homeApi;


  const HomeSearchCity({
    super.key,
    required this.searchCity,
    required this.clubList,

    required this.isLoading,  this.homeApi,
  });

  @override
  State<HomeSearchCity> createState() => _HomeSearchCityState();
}

class _HomeSearchCityState extends State<HomeSearchCity> {
  @override
  void dispose() {
    // TODO: implement dispose
    widget.searchCity.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List popularCityList = widget.searchCity.text.isEmpty
        ? CityList.popularCities
        : CityList.popularCities
        .where((element) => element
        .toLowerCase()
        .startsWith(widget.searchCity.text.toLowerCase()))
        .toList();
    return Container(
      color: matte(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: 100.h,
            ),
            SizedBox(
              height: 200.h,
              width: Get.width - 100.w,
              child: TextField(
                controller: widget.searchCity,
                onChanged: (val) {
                  setState(() {});
                },
                style: GoogleFonts.ubuntu(color: Colors.white),
                decoration: InputDecoration(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  labelText: 'Enter city name',
                  labelStyle: GoogleFonts.ubuntu(color: Colors.white),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white70,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (widget.searchCity.text.isNotEmpty) {
                  homeController
                    ..updateCity(
                      widget.searchCity.text
                          .toLowerCase()
                          .capitalizeFirstOfEach,
                    )
                    ..updateShowCity(false);
                  Box cityBox = await HiveDB.hiveOpenCity();
                  await HiveDB.putKey(
                      cityBox, 'homeCity', widget.searchCity.text);
                  await getClubList();
                  widget.homeApi!;


                } else {
                  Fluttertoast.showToast(
                    msg: 'Enter a valid name',
                  );
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith(
                      (Set<MaterialState> states) => Colors.green,
                ),
              ),
              child: const Text('Continue'),
            ),
            ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 50.h),
              shrinkWrap: true,
              itemCount: popularCityList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                popularCityList.sort();
                if (CityList.popularCities[index] == 'Other') {
                  return Container();
                } else {
                  return GestureDetector(
                    onTap: () async {
                      homeController
                        ..updateCity(popularCityList[index])
                        ..updateShowCity(false);
                      Box cityBox = await HiveDB.hiveOpenCity();
                      await HiveDB.putKey(
                          cityBox, 'homeCity', popularCityList[index]);
                      await getClubList();

                      widget.homeApi!();
                    },
                    child: Container(
                      height: 150.h,
                      decoration: BoxDecoration(
                        color: matte(),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Center(
                        child: Text(
                          widget.searchCity.text.isEmpty
                              ? CityList.popularCities[index]
                              : popularCityList[index],
                          style: GoogleFonts.ubuntu(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
