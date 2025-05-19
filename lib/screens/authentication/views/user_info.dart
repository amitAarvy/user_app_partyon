import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:user/screens/authentication/views/phone.dart';
import 'package:user/screens/home/view/home_view.dart';
import 'package:user/utils/cities.dart';
import 'package:user/utils/utils.dart';

import '../../bottom-screens.dart';

class UserInfoData extends StatefulWidget {
  final String email;
  final bool isPhone;
  final bool isProfile;

  const UserInfoData({this.isPhone = false, required this.email,this.isProfile =false, super.key});

  @override
  State<UserInfoData> createState() => _UserInfoDataState();
}

class _UserInfoDataState extends State<UserInfoData> {
  String address = '', locality = '', pincode = '';
  dynamic latitude, longitude;
  String location = 'Null, Press Button';
  bool dialogOther = false;
  DateTime? _selectedDate;

  ValueNotifier<DateTime?> selectDOB = ValueNotifier(null);

  void _showDOBPickerDialog(BuildContext context) {
    DateTime selectedDate = DateTime(2000, 1, 1);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: EdgeInsets.all(20),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Select Date of Birth",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 180,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: selectedDate,
                      maximumDate: DateTime.now(),
                      minimumYear: 1900,
                      maximumYear: DateTime.now().year,
                      onDateTimeChanged: (DateTime dateTime) {
                        setDialogState(() {
                          selectedDate = dateTime;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.black),
                          ),
                          child: Text("Cancel", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          print("DOB Selected: ${selectedDate.toLocal()}");
                          selectDOB.value = selectedDate.toLocal();
                          // Optionally: call setState or update a ValueNotifier
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 30),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text("Save", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _openDatePicker(BuildContext context) {
    BottomPicker.date(
      pickerTitle: Text(
        'Set your Birthday',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.blue,
        ),
      ),
      dateOrder: DatePickerDateOrder.dmy,
      initialDateTime: DateTime(1996, 10, 22),
      maxDateTime: DateTime(1998),
      minDateTime: DateTime(1980),
      height:0.5.sh,
      pickerTextStyle: TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      onChange: (index) {
        print(index);
      },
      onSubmit: (index) {
        selectDOB.value = index;
      },
      onDismiss: (p0) {
        print(p0);
      },
      bottomPickerTheme: BottomPickerTheme.plumPlate,
    ).show(context);
  }

  String dropState = 'Andhra Pradesh',
      dropValueCity = 'Select City';

  final TextEditingController _userName = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController _otherCity = TextEditingController();

  List<String> itemsState = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chandigarh',
    'Chhattisgarh',
    'Dadra & Nagar Haveli',
    'Daman & Diu',
    'Delhi NCR',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jammu & Kashmir',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Lakshadweep',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Orissa',
    'Pondicherry',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal'
  ];

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        await Fluttertoast.showToast(msg: 'Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      await Fluttertoast.showToast(
        msg:
        'Location permissions are permanently denied. Go to app settings and enable location permissions',
      );
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> getAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      for (String i in itemsState) {
        if (i == place.administrativeArea) {
          dropState = place.administrativeArea!;
        } else if (place.administrativeArea == 'Delhi') {
          dropState = 'Delhi NCR';
        }
      }
    });
  }

  Future<void> getAddress() async {
    await EasyLoading.show();
    try {
      Position position = await _getGeoLocationPosition();
      location = 'Lat: ${position.latitude} , Long: ${position.longitude}';
      await getAddressFromLatLong(position)
          .whenComplete(() => EasyLoading.dismiss());
    } catch (e) {
      await EasyLoading.dismiss();
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    if(widget.isProfile){
    fetchProfileData();
    }else{
      getAddress();
    }
  }
  ValueNotifier<String> selectGender = ValueNotifier('Male');
  fetchProfileData()async{
    var data = await FirebaseFirestore.instance.collection('User').doc(uid()).get();
    print('check profile data is ${data.data()}');
    var userInfo = data.data() as Map<String,dynamic>;
    _userName.text = userInfo['userName']??'';
    selectDOB.value = (userInfo['dob'] as Timestamp).toDate();
    dropState = userInfo['state']??'';
    dropValueCity = userInfo['city']??'';
    selectGender.value = userInfo['gender']??'Male';

    setState(() {

    });
}

  @override
  Widget build(BuildContext context) {
    // final TextEditingController emailController =
    //     TextEditingController(text: widget.email);
    if (dropValueCity == 'Other') {
      setState(() {
        dialogOther = true;
      });
    } else {
      setState(() {
        _otherCity.text = '';
        dialogOther = false;
      });
    }

    //

    
    List stateCity = getStateCity(dropState);

    List<String> itemsCity = ['Select City', ...stateCity];

    return Scaffold(
      backgroundColor: matte(),
      appBar: widget.isProfile?
      AppBar(
        backgroundColor: themeRed(),
        centerTitle: true,
        title: Text(
          kIsWeb?"Partyon": 'Profile',
          style: GoogleFonts.ubuntu(fontSize: 50.sp, color: Colors.orangeAccent,fontWeight: FontWeight.w700),
        ),
      ):
          PreferredSize(preferredSize: Size.fromHeight(0), child: AppBar())
      ,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              if(!widget.isProfile)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Profile',
                    style: GoogleFonts.ubuntu(
                      fontSize: 60.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ).marginOnly(left: 40.w, bottom: 40.w),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('Gender',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ValueListenableBuilder(
                  valueListenable: selectGender,
                  builder: (context, value, child) => Row(
                    children: [
                      genderWidget(title: 'Male',groupValue: value.toString(),notifier: selectGender),
                      genderWidget(title: 'Female',groupValue: value.toString(),notifier: selectGender),
                    ],
                  ),),
              ),
              SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('Name',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                  ],
                ),
              ),
              textField('Enter Name', _userName,),
              SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('DOB',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                  ],
                ),
              ),
              ValueListenableBuilder(
                valueListenable: selectDOB,
                builder: (context, value, child) =>
                 GestureDetector(
                    onTap: (){
                      // _openDatePicker(context);
                      _showDOBPickerDialog(context);
                    },
                    child: Container(
                      height: 130.h,
                      width: Get.width - 100.w,
                      decoration:
                      BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(color: Colors.grey)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Center(child: Text(value==null?'Select Date of Birth':DateFormat('dd-MM-yyyy').format(DateTime.parse(value.toString())),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.grey),)),
                          ],
                        ),
                      ),
                    )),
              ),
              SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('State',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                  ],
                ),
              ),
          
              // textField("Email", _email,
              //     isEmail: true, isPhone: widget.isPhone),
              // SizedBox(
              //   height: 20.h,
              // ),
              Container(
                height: 130.h,
                width: Get.width - 100.w,
                decoration:
                BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(color: Colors.grey)),
                child: Center(
                  child: DropdownButton<String>(
                    items: itemsState
                        .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                          alignment: Alignment.center,
                          value: value,
                          child: Text(value),
                        ))
                        .toList(),
                    onChanged: (String? val) {
                      setState(() {
                        dropState = val!;
                        dropValueCity = 'Select City';
                      });
                    },
                    value: dropState,
                    style: const TextStyle(color: Colors.white70),
                    dropdownColor: Colors.black,
                  ),
                ),
              ).marginOnly(left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('City',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                  ],
                ),
              ),
              Container(
                height: 130.h,
                width: Get.width - 100.w,
                decoration:
                BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(color: Colors.grey)),
                child: Center(
                  child: DropdownButton<String>(
                    items: (itemsCity)
                        .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                          alignment: Alignment.center,
                          value: value,
                          child: Text(value),
                        ))
                        .toList(),
                    onChanged: (String? val) {
                      setState(() {
                        dropValueCity = val!;
                      });
                    },
                    value: dropValueCity,
                    style: const TextStyle(color: Colors.white70),
                    dropdownColor: Colors.black,
                  ),
                ),
              ).marginOnly(left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
              dialogOther == true
                  ? ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    // false = user must tap button, true = tap outside dialog
                    builder: (BuildContext dialogContext) => AlertDialog(
                      title: const Text('Enter City name'),
                      content: SizedBox(
                        height: 300.0,
                        width: 300.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            TextField(
                              controller: _otherCity,
                              decoration: const InputDecoration(
                                labelText: 'Enter city name',
                              ),
                            ).marginSymmetric(horizontal: 50.w),
                            ElevatedButton(
                              onPressed: () {
                                if (_otherCity.text.isEmpty) {
                                  Fluttertoast.showToast(
                                    msg: 'Enter a valid city name',
                                  );
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.resolveWith(
                                      (Set<MaterialState> states) =>
                                  Colors.green,
                                ),
                              ),
                              child:  Text('Continue'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  dropValueCity = 'Select City';
                                  dialogOther = false;
                                });
                                Navigator.of(context).pop();
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.resolveWith(
                                      (Set<MaterialState> states) =>
                                  Colors.red,
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                        (Set<MaterialState> states) => Colors.black,
                  ),
                ),
                child: const Text('Choose Other City'),
              )
                  : Container(),
              SizedBox(
                height: 50.h,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GestureDetector(
                  onTap: () {
                    if (FirebaseAuth.instance.currentUser != null) {
                      if (dropValueCity != 'Select City' &&
                          _userName.text.isNotEmpty &&
                          dropState != '') //c.city!="Select City"&&
                          {
                        if (dropValueCity == 'Other' && _otherCity.text.isEmpty) {
                          Fluttertoast.showToast(
                            msg: 'Provide other city name',
                          );
                        } else {
                          EasyLoading.show();
          if(widget.isProfile){
            FirebaseFirestore.instance
                .collection('User')
                .doc(uid())
                .update(
              {
                'userName': _userName.text,
                'age': age.text,
                'city': dropValueCity == 'Other'
                    ? _otherCity.text.capitalizeFirstOfEach
                    : dropValueCity,
                'state': dropState,
                'gender':selectGender.value,
                'phoneNumber':phoneNumber(),
                'dob':selectDOB.value,
                'uid': uid()
              },
              // SetOptions(merge: true),
            ).whenComplete(() {
              EasyLoading.dismiss();
              Navigator.pushReplacement(
                context,
                PageTransition(
                  duration: const Duration(milliseconds: 750),
                  type: PageTransitionType.leftToRightWithFade,
                  child: const BottomNavigationBarExampleApp(),
                ),
              );
            });
          }else{
            FirebaseFirestore.instance
                .collection('User')
                .doc(uid())
                .set(
              {
                'userName': _userName.text,
                'age': age.text,
                'city': dropValueCity == 'Other'
                    ? _otherCity.text.capitalizeFirstOfEach
                    : dropValueCity,
                'state': dropState,
                'gender':selectGender.value,
                'phoneNumber':phoneNumber(),
                'dob':selectDOB.value,
                'uid': uid()
              },
              SetOptions(merge: true),
            ).whenComplete(() {
              EasyLoading.dismiss();
              if(widget.isProfile){
                Get.back();
              }else{
              Navigator.pushReplacement(
                context,
                PageTransition(
                  duration: const Duration(milliseconds: 750),
                  type: PageTransitionType.leftToRightWithFade,
                  child: const BottomNavigationBarExampleApp(),
                ),
              );
              }
            });
          }

                        }
                      } else {
                        Fluttertoast.showToast(
                          msg: 'Kindly fill all required fields',
                        );
                      }
                    } else {
                      Fluttertoast.showToast(msg: 'Invalid User');
                    }
                  },
                  child: Container(
                    height: 120.h,
                    width: 1.sw,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        widget.isProfile?'Update': 'Continue',
                        style: GoogleFonts.ubuntu(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ),
                ).marginAll(20.h),
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance
                      .signOut()
                      .whenComplete(() => Get.off(const PhoneLogin()));
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                        (Set<MaterialState> states) => Colors.black,
                  ),
                ),
                child: Text(
                  'Back to Login',
                  style: GoogleFonts.ubuntu(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget genderWidget({String?groupValue ,String? title,ValueNotifier? notifier}){
    return Row(
      children: [
        Radio(
          hoverColor: Colors.grey,
          autofocus: true,
          activeColor: Colors.orangeAccent,
          focusColor: Colors.grey,
          value: title.toString(), groupValue: groupValue, onChanged: (value) {
          notifier!.value = title;
        },),
        SizedBox(width: 5,),
        Text(title.toString(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),)

      ],
    );
  }
}
