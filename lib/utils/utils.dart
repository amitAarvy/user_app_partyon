import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudflare/cloudflare.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user/screens/authentication/views/phone.dart';
import 'package:user/screens/help.dart';
import 'package:user/screens/home/controller/home_controller.dart';
import 'package:user/screens/my_booking/booking_list.dart';
import 'package:user/screens/payment/payment_list_view.dart';

import '../screens/authentication/views/user_info.dart';

const String _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();
// final HomeController hc = Get.put(HomeController());

String getRandomString(int length) => String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
      ),
    );

const String cloudFlareAccountID = '89174e54fcc5719f4bfecc8c3b8b216f';
const String cloudFlareToken = 'vb5cg5bPCA_ImMFvDV4SD1f_pHlvBkDdc06ra9SK';
final Cloudflare cloudflare = Cloudflare(
  accountId: cloudFlareAccountID,
  token: cloudFlareToken,
);

Color themeRed() => const Color(0xff000000);

Color matte() => const Color(0xff171717);

Color purpleInd() => const Color(0xff4a58AE);

extension CapExtension on String {
  String get inCaps => isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';

  String get capitalizeFirstOfEach => replaceAll(RegExp(' +'), ' ').split(' ').map((String str) => str.inCaps).join(' ');
}

class ShowOptions extends ChangeNotifier {
  bool showFilter = false;

  void changeFilter(bool val) {
    showFilter = val;
    notifyListeners();
  }
}

String? uid() => FirebaseAuth.instance.currentUser?.uid;
String? phoneNumber() => FirebaseAuth.instance.currentUser?.phoneNumber;

Text headText() => Text(
      'PartyOn',
      style: GoogleFonts.dancingScript(
        color: Colors.white,
        fontSize: 80.sp,
        fontWeight: FontWeight.bold,
      ),
    );

Widget textField(
  String label,
  TextEditingController controller, {
  bool isNum = false,
  isEmail = false,
  isPinCode = false,
  isPhone = false,
  readyOnly = false,
  isFolded = false,
}) =>
    Container(
      width: Get.width,
      height: 130.h,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      padding: EdgeInsets.only(left: isFolded ? 0.w : 20.w, right: isFolded ? 0.w : 20.w),
      child: TextField(
        readOnly: readyOnly == true
            ? readyOnly
            : isEmail == true && isPhone == false
                ? true
                : false,
        // enabled: isEmail==true?false:true,
        keyboardType: isNum == true ? TextInputType.number : TextInputType.text,
        inputFormatters: [if (isPinCode == true) LengthLimitingTextInputFormatter(6) else LengthLimitingTextInputFormatter(30)],
        controller: controller,

        style: GoogleFonts.merriweather(color: Colors.white),
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white70),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          hintStyle: GoogleFonts.ubuntu(),
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70, fontSize: isFolded ? 16.sp : 40.sp),
        ),
      ),
    ).marginOnly(left: 30.w, right: 30.w, bottom: 30.h, top: 20.h);

String getMonthName(int monthNum) {
  switch (monthNum) {
    case 1:
      return 'January';
    case 2:
      return 'February';
    case 3:
      return 'March';
    case 4:
      return 'April';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'August';
    case 9:
      return 'September';
    case 10:
      return 'October';
    case 11:
      return 'November';
    case 12:
      return 'December';
    default:
      return 'January';
  }
}

final HomeController homeController = Get.put(HomeController());

Widget drawer({isFolded = false}) => Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.pink, Colors.red],
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180.h,
          ),
          GestureDetector(
            onTap: () {
              Get.to(
                UserInfoData(
                  email: (phoneNumber() ?? '').toString(),
                  isPhone: true,
                  isProfile: true,
                ),
              );
            },
            child: CircleAvatar(
              backgroundImage: const AssetImage('assets/profile.png'),
              radius: 150.h,
              backgroundColor: Colors.black,
            ),
          ),
          Obx(
            () => Text(
              homeController.userName,
              style: GoogleFonts.ubuntu(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 60.sp,
              ),
            ),
          ).marginAll(30.h),
          SizedBox(
            height: 30.h,
          ),
          Divider(
            color: Colors.white,
            thickness: 1,
            indent: 50.w,
            endIndent: 50.w,
          ),
          SizedBox(
            height: Get.width - (isFolded ? 400 : 0),
            width: Get.width,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Opacity(
                    opacity: 0.2,
                    child: SizedBox(
                      height: 600.h,
                      width: 600.h,
                      child: Image.asset('assets/logo.png'),
                    ),
                  ),
                ),
                Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.home,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Home',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        Get.to(() => const PaymentListView());
                      },
                      leading: const Icon(
                        FontAwesomeIcons.buildingColumns,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Payments',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // ListTile(
                    //   onTap: () {
                    //     Get.to(() => const BookingList());
                    //   },
                    //   leading: const Icon(
                    //     FontAwesomeIcons.ticket,
                    //     color: Colors.white,
                    //   ),
                    //   title: Text(
                    //     'My Bookings',
                    //     style: GoogleFonts.montserrat(
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                    ListTile(
                      onTap: () {
                        Get.to(const Help());
                      },
                      leading: const Icon(
                        Icons.help,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Help',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        FirebaseAuth.instance.signOut().whenComplete(() => Get.off(const PhoneLogin()));
                      },
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                      title: Text(
                        'Log Out',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

Future<void> openMap(double latitude, double longitude) async {
  final url = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
  );
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    Fluttertoast.showToast(msg: 'Could not launch $url');
  }
}

Widget eventCarousel(List images, {bool isNetworkImage = false}) => CarouselSlider(
    items: images
        .map((image) => Builder(
              builder: (BuildContext context) => Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.zero,
                // decoration: const BoxDecoration(color: Colors.amber),
                child: isNetworkImage
                    ? kIsWeb
                        ? Image.network(
                            '$image',
                            errorBuilder: (_, __, ___) => Center(
                                child: Icon(
                              Icons.image,
                              color: Colors.white,
                              size: 300.h,
                            )),
                            fit: BoxFit.fill,
                          )
                        : CachedNetworkImage(
                            imageUrl: image,
                            errorWidget: (_, __, ___) => Center(
                                child: Icon(
                              Icons.image,
                              color: Colors.white,
                              size: 300.h,
                            )),
                            fit: BoxFit.fill,
                            placeholder: (_, __) => const SizedBox(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          )
                    : Image.file(
                        image!,
                        fit: BoxFit.cover,
                      ),
              ),
            ))
        .toList(),
    options: CarouselOptions(
      // height: 400,
      aspectRatio: 9 / 16,
      viewportFraction: 1,
      initialPage: 0,
      enableInfiniteScroll: false,
      reverse: false,
      autoPlay: false,
      autoPlayInterval: const Duration(seconds: 3),
      autoPlayAnimationDuration: const Duration(milliseconds: 800),
      autoPlayCurve: Curves.fastOutSlowIn,
      enlargeCenterPage: true,
      enlargeFactor: 0.3,
      scrollDirection: Axis.horizontal,
    ));

Future<bool> onWillPop(BuildContext context) async {
  bool exit = false;
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Are you sure?'),
      content: const Text('Do you want to exit the app?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () {
            exit = true;
            Navigator.of(context).pop(true);
          },
          child: const Text('Yes'),
        ),
      ],
    ),
  );
  return exit;
}

dynamic getKeyValueFirestore(DocumentSnapshot documentSnapshot, String keyName) {
  Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>;
  if (documentSnapshot.exists && data.containsKey(keyName)) {
    return documentSnapshot.get(keyName);
  } else {
    return null;
  }
}

Widget customisedButton(
  String buttonText, {
  required Function() onTap,
  Color? buttonColor,
}) =>
    ElevatedButton(onPressed: () => onTap(), style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => buttonColor ?? Colors.red)), child: Text(buttonText));
