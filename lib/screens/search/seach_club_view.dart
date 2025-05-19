import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/screens/club_details/club_details.dart';
import 'package:user/screens/search/search_provider.dart';
import 'package:user/utils/utils.dart';

class SearchClub extends StatefulWidget {
  const SearchClub({super.key});

  @override
  State<SearchClub> createState() => _SearchClubState();
}

class _SearchClubState extends State<SearchClub> {
  String query = '';
  final String _radioVal = 'clubName';
  int _radioSelected = 1;
  final TextEditingController _search = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final SearchViewController c = Get.put(SearchViewController());
  dynamic searchBuilder;
  List<DocumentSnapshot> clubList = [];
  bool isLoading = true;

  @override
  void initState() {
    getClubList();
    super.initState();
  }

  void getClubList() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('Club').get();
      for (DocumentSnapshot element in querySnapshot.docs) {
        bool isActive = getKeyValueFirestore(element, 'activeStatus') ?? false;
        if (isActive) {
          clubList.add(element);
        }
      }
    } catch (e) {
      isLoading = false;
    }
    isLoading = false;
    setState(() {});
  }

  Widget searchList() {
    if (isLoading) {
      return Column(
        children: [
          SizedBox(
            height: 200.h,
          ),
          Center(
            child: Text(
              'Loading...',
              style: TextStyle(color: Colors.white, fontSize: 70.sp),
            ),
          )
        ],
      );
    } else {
      return SearchListView(
        radioVal: _radioVal,
        clubList: clubList,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: false,
    backgroundColor: matte(),
// appBar: AppBar(title: const Text("Search"),backgroundColor: themeRed(),),
    body: Stack(
      children: [
        if (_search.text.isEmpty == true)
          SizedBox(
            height: Get.height,
            width: Get.width,
            child: Center(
              child: SizedBox(
                height: 800.h,
                width: 800.w,
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).viewPadding.top,
              ),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Search Club',
                  labelStyle: GoogleFonts.ubuntu(color: Colors.white54),
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.white70, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    const BorderSide(color: Colors.blue, width: 1.0),
                  ),
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
                onChanged: c.updateSearch,
                controller: _search,
              ).paddingAll(30.w),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio(
                    value: 1,
                    groupValue: _radioSelected,
                    fillColor: MaterialStateProperty.resolveWith(
                          (Set<MaterialState> states) => Colors.orange,
                    ),
                    focusColor: Colors.white,
                    onChanged: (Object? value) {
                      setState(() {
                        _radioSelected = int.parse(value.toString());
                        c.updateRadio('clubName');
                      });
                    },
                  ),
                  Text(
                    'Name',
                    style: GoogleFonts.ubuntu(color: Colors.white),
                  ),
                  Radio(
                    value: 2,
                    groupValue: _radioSelected,
                    activeColor: Colors.blue,
                    fillColor: MaterialStateProperty.resolveWith(
                          (Set<MaterialState> states) => Colors.orange,
                    ),
                    focusColor: Colors.white,
                    onChanged: (Object? value) {
                      setState(() {
                        _radioSelected = int.parse(value.toString());
                        c.updateRadio('city');
                      });
                    },
                  ),
                  Text(
                    'City',
                    style: GoogleFonts.ubuntu(color: Colors.white),
                  ),
                ],
              ).paddingOnly(bottom: 100.h),
              searchList()
            ],
          ),
        ),
      ],
    ),
  );
}

class SearchListView extends StatefulWidget {
  final String radioVal;
  final List<DocumentSnapshot> clubList;

  const SearchListView({
    required this.clubList,
    required this.radioVal,
    super.key,
  });

  @override
  State<SearchListView> createState() => _SearchListViewState();
}

class _SearchListViewState extends State<SearchListView> {
  final SearchViewController searchController = Get.put(SearchViewController());

  @override
  Widget build(BuildContext context) => Obx(() {
    final searchList = widget.clubList.where(
          (DocumentSnapshot element) => element[searchController.radioVal.value]
          .toString()
          .toLowerCase()
          .contains(searchController.search.toLowerCase()),
    );
    if (searchController.search.isEmpty) {
      return Text(
        '',
        style: TextStyle(color: Colors.white, fontSize: 60.sp),
      );
    } else if (searchList.isEmpty) {
      return Container();
    } else {
      return ListView(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [
          ...searchList.map((DocumentSnapshot data) => GestureDetector(
            onTap: () => Get.to(
              ClubDetails(
                'tag',
                clubName: data['clubName'],
                clubUID: data.id,
                description: data['description'],
              ),
            ),
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
                  SizedBox(
                    height: 250.h,
                    width: 250.h,
                    child: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                        data['coverImage'],
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
                          data['clubName'],
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 50.h,
                        ),
                        Text(
                          data['city'],
                          style: GoogleFonts.ubuntu(
                            color: Colors.white70,
                            fontSize: 35.sp,
                          ),
                        ).paddingOnly(right: 30.w),
                        SizedBox(
                          height: 50.h,
                        ),
                        Text(
                          data['state'],
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
            ).marginOnly(
              left: 20.w,
              right: 20.w,
              top: 30.w,
              bottom: 30.w,
            ),
          ))
        ],
      );
    }
  });
}
