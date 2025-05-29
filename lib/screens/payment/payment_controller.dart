import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:user/screens/events/book_event_utils.dart';
import 'package:user/screens/events/book_events_controller.dart';
import 'package:user/screens/my_booking/booking_info.dart';
import 'package:user/utils/utils.dart';






Future<void> paymentSuccess(
    BuildContext context,
    PaymentSuccessResponse? response, {
      required final double amount,
      required final String clubUID,
      String clubID = '',
      required String eventID,
      promoterID = '',
      organiserID = '',
      required List tableList,
      required List entryList,
      required int totalEntranceCount,
      required int totalTableCount,
      required List tableDataList,  Map<String,dynamic>? couponDetail


    }) async {
  String bookingID = 'PTY-${randomAlphaNumeric(5).toUpperCase()}';
  String bookingCode = randomNumeric(4).toString();

  await EasyLoading.show();
  final String ipv6 = await Ipify.ipv64();
  final String? paymentId =
  response != null ? response.paymentId : randomAlphaNumeric(8);
  await FirebaseFirestore.instance
      .collection('Payments')
      .doc(paymentId.toString())
      .set({
    'uname': homeController.userName,
    'eventID': eventID,
    'clubID': clubID,
    'clubUID': clubUID,
    'paymentID': paymentId.toString(),
    'userID': uid(),
    'amount': amount,
    'status': 'S',
    'ipv6': ipv6,
    'date': FieldValue.serverTimestamp(),
    'promoterID': promoterID,
    'totalEntranceCount': totalEntranceCount,
    'totalTableCount': totalTableCount,
    'organiserID': organiserID,
  }).whenComplete(() {
    FirebaseFirestore.instance
        .collection('Bookings')
        .doc(bookingID)
        .set({
      'uname': homeController.userName,
      'bookingCode': bookingCode,
      'bookingID': bookingID,
      'eventID': eventID,
      'clubID': clubID,
      'newNotification':true,
      'clubUID': clubUID,
      'paymentID': paymentId.toString(),
      'userID': uid(),
      'amount': amount,
      "couponCode":couponDetail==null?null:couponDetail['couponCode'],
      "discount":couponDetail==null?null:couponDetail['discount'],
      'status': 'S',
      'ipv6': ipv6,
      'date': FieldValue.serverTimestamp(),
      'entryStatus': 'P',
      'totalEntranceCount': totalEntranceCount,
      'totalTableCount': totalTableCount,
      'promoterID': promoterID,
      'organiserID': organiserID,
      'entryList':entryList,
      'tableList': tableList
    })
        .whenComplete(() async{
          print('yes it is check  ${promoterID}');
          if(promoterID != '') {
            if (couponDetail != null) {
              var userInfo = await FirebaseFirestore.instance
                  .collection('User')
                  .doc(uid())
                  .get();
              final Timestamp dobTimestamp = userInfo['dob']; // dob is a Firestore Timestamp
              DateTime dob = dobTimestamp.toDate();
              int age = calculateAge(dob);
              print('yes it is check  ${age}');
              // if(couponDetail['appliedCoupon'].toString() != 'pr'){
              Map<String, dynamic>? info = userInfo.data();
              print('yes it is check  ${promoterID}');
              couponDetail.addAll({
                'userId': uid(),
                "name": info!['userName'].toString(),
                "mobile_no": phoneNumber(),
                "gender": info['gender'].toString(),
                "age": age,
                'creditAt': DateTime.now(),
              });
              print('check coupon detail is ${couponDetail}');
              List couponDetails = [];
              couponDetails.add(couponDetail);
              var data = await FirebaseFirestore.instance.collection(
                  'AppliedCoupon').get();
              print('yes check updated data is ${promoterID} ');
              if (promoterID != null) {
                print('yes check updated data is ');
                var snapshot = await FirebaseFirestore.instance
                    .collection('PrAnalytics')
                    .get();

                List<DocumentSnapshot> matchingDocs = snapshot.docs.where((
                    doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['prId'].toString() == promoterID.toString() &&
                      data['eventId'].toString() == eventID.toString();
                }).toList();

                if (matchingDocs.isEmpty) {
                  print("No document found matching promoterID and eventID");
                  return;
                }

                final docToUpdate = matchingDocs.first;
                final data = docToUpdate.data() as Map<String, dynamic>;

                await FirebaseFirestore.instance
                    .collection('PrAnalytics')
                    .doc(docToUpdate.id)
                    .update({
                  "noOfReserved": (data['noOfReserved'] ?? 0) + 1,
                  'userList': FieldValue.arrayUnion([
                    {
                      "bookingId": bookingID,
                      'userId': uid(),
                      "name": info['userName'].toString(),
                      "mobile_no": phoneNumber(),
                      "gender": info['gender'].toString(),
                      "age": age,
                      'creditAt': DateTime.now(),
                      'noShow': true,
                      'duration': "",
                      "checkIn": "",
                      "checkOut": "",
                      "type": couponDetail['type'].toString(),
                      'price': amount,
                      'couponDetail': couponDetail,
                    }
                  ])
                });
              }
              print('event id check it jds ${data}');
              List appliedCoupon = data.docs.where((element) =>
              element.id == eventID).toList();
              if (appliedCoupon.isEmpty) {
                await FirebaseFirestore.instance
                    .collection('AppliedCoupon')
                    .doc(eventID)
                    .set({'coupons': FieldValue.arrayUnion(couponDetails),});
              } else {
                await FirebaseFirestore.instance
                    .collection('AppliedCoupon')
                    .doc(eventID)
                    .update({'coupons': FieldValue.arrayUnion(couponDetails),});
              }
              // List alreadyData = data.docs.where((element) => element['eventId'].toString() ==eventID.toString()).toList();

              // if(alreadyData.isEmpty){
              //   couponDetail.addAll({
              //     "totalUseCouponEntry":couponDetail['type'].toString() =='entry'?1:0,
              //     "totalUseCouponTable":couponDetail['type'].toString() !='entry'?1:0
              //   });
              //   await FirebaseFirestore.instance
              //       .collection('CouponVenue')
              //       .add(couponDetail);
              // }else{
              //   if(couponDetail['type'].toString() == 'entry'){
              //
              //   couponDetail['totalUseCouponEntry'] =
              //       int.parse(alreadyData[0]['totalUseCouponEntry'].toString()) + 1;
              //   }else{
              //     couponDetail['totalUseCouponTable'] =
              //         int.parse(alreadyData[0]['totalUseCouponTable'].toString()) + 1;
              //   }

              // }
              // }else{
              // Map<String, dynamic> updateData = {};
              // if (couponDetail['type'].toString() == 'table') {
              //   updateData['totalUseCouponTable'] =
              //       int.parse(couponDetail['totalView'].toString()) + 1;
              // } else {
              //   updateData['totalUseCoupon'] =
              //       int.parse(couponDetail['totalView'].toString()) + 1;
              // }
              // await FirebaseFirestore.instance
              //     .collection('CouponPR')
              //     .doc(couponDetail['id'].toString())
              //     .update(updateData);
              // }
            }
          }else{
            print('check it');
            if (couponDetail != null) {
              var userInfo = await FirebaseFirestore.instance
                  .collection('User')
                  .doc(uid())
                  .get();
              final Timestamp dobTimestamp = userInfo['dob']; // dob is a Firestore Timestamp
              DateTime dob = dobTimestamp.toDate();
              int age = calculateAge(dob);
              print('yes it is check  ${age}');
              // if(couponDetail['appliedCoupon'].toString() != 'pr'){
              Map<String, dynamic>? info = userInfo.data();
              print('yes it is check  ${promoterID}');
              couponDetail.addAll({
                'userId': uid(),
                "name": info!['userName'].toString(),
                "mobile_no": phoneNumber(),
                "gender": info['gender'].toString(),
                "age": age,
                'creditAt': DateTime.now(),
              });
              print('check coupon detail is ${couponDetail}');
              List couponDetails = [];
              couponDetails.add(couponDetail);
              var data = await FirebaseFirestore.instance.collection(
                  'AppliedCoupon').get();
              // if (promoterID != null) {
                print('yes check updated data is ');
                var snapshot = await FirebaseFirestore.instance
                    .collection('VenueAnalysis')
                    .get();

                List<DocumentSnapshot> matchingDocs = snapshot.docs.where((
                    doc) {
                  final data1 = doc.data() as Map<String, dynamic>;
                  return data1['isVenue'].toString() == 'true' &&
                      data1['eventId'].toString() == eventID.toString();
                }).toList();

                if (matchingDocs.isEmpty) {
                  print("No document found matching promoterID and eventID");
                  return;
                }
                print('cehck is data1 $data');
                final docToUpdate = matchingDocs.first;
                final data1 = docToUpdate.data() as Map<String, dynamic>;
              print('cehck is data1$data1');
                await FirebaseFirestore.instance
                    .collection('VenueAnalysis')
                    .doc(docToUpdate.id)
                    .update({
                  "noOfReserved": (data1['noOfReserved'] ?? 0) + 1,
                  'userList': FieldValue.arrayUnion([
                    {
                      "bookingId": bookingID,
                      'userId': uid(),
                      "name": info['userName'].toString(),
                      "mobile_no": phoneNumber(),
                      "gender": info['gender'].toString(),
                      "age": age,
                      'creditAt': DateTime.now(),
                      'noShow': true,
                      'duration': "",
                      "checkIn": "",
                      "checkOut": "",
                      "type": couponDetail['type'].toString(),
                      'price': amount,
                    }
                  ])
                }).catchError((e){
                  print('check error is response ${e}');
                });

              print('event id check it jds ${data}');
              List appliedCoupon = data.docs.where((element) =>
              element.id == eventID).toList();
              if (appliedCoupon.isEmpty) {
                await FirebaseFirestore.instance
                    .collection('AppliedCoupon')
                    .doc(eventID)
                    .set({'coupons': FieldValue.arrayUnion(couponDetails),});
              } else {
                await FirebaseFirestore.instance
                    .collection('AppliedCoupon')
                    .doc(eventID)
                    .update({'coupons': FieldValue.arrayUnion(couponDetails),});
              }
              // List alreadyData = data.docs.where((element) => element['eventId'].toString() ==eventID.toString()).toList();

              // if(alreadyData.isEmpty){
              //   couponDetail.addAll({
              //     "totalUseCouponEntry":couponDetail['type'].toString() =='entry'?1:0,
              //     "totalUseCouponTable":couponDetail['type'].toString() !='entry'?1:0
              //   });
              //   await FirebaseFirestore.instance
              //       .collection('CouponVenue')
              //       .add(couponDetail);
              // }else{
              //   if(couponDetail['type'].toString() == 'entry'){
              //
              //   couponDetail['totalUseCouponEntry'] =
              //       int.parse(alreadyData[0]['totalUseCouponEntry'].toString()) + 1;
              //   }else{
              //     couponDetail['totalUseCouponTable'] =
              //         int.parse(alreadyData[0]['totalUseCouponTable'].toString()) + 1;
              //   }

              // }
              // }else{
              // Map<String, dynamic> updateData = {};
              // if (couponDetail['type'].toString() == 'table') {
              //   updateData['totalUseCouponTable'] =
              //       int.parse(couponDetail['totalView'].toString()) + 1;
              // } else {
              //   updateData['totalUseCoupon'] =
              //       int.parse(couponDetail['totalView'].toString()) + 1;
              // }
              // await FirebaseFirestore.instance
              //     .collection('CouponPR')
              //     .doc(couponDetail['id'].toString())
              //     .update(updateData);
              // }
            }
          }
      //     DocumentSnapshot eve = await FirebaseFirestore.instance.collection('Events').doc(eventID).get();
      // List entList = (eve.data() as Map<String, dynamic>)['entranceList'];
      // print('entrance list is ${entList}');
      // print('entrance list is ${entryList}');
      // if(entList.isNotEmpty){
      //   for (var booking in entryList) {
      //     for (var entrance in entList) {
      //       if (entrance['categoryName'] == booking['categoryName']) {
      //         List subCategoryList = entrance['subCategory'];
      //         for (var subCategory in subCategoryList) {
      //           if (subCategory['entryCategoryName'] == booking['subCategoryName']) {
      //             // Update bookingCountLeft
      //             subCategory['entryCategoryCountLeft'] =
      //                 (subCategory['entryCategoryCountLeft'] ?? 0) - (booking['bookingCount'] ?? 0);
      //             print("Updated entryCategoryCountLeft: ${subCategory['entryCategoryCountLeft']}");
      //           }
      //         }
      //       }
      //     }
      //   }
      //   print('entry list data is ${entList}');
      //   FirebaseFirestore.instance
      //       .collection('Events') // Replace with your Firestore collection name
      //       .doc(eventID) // Replace with your event document ID
      //       .update({"entranceList": entList}) // Update entranceList
      //       .then((_) => print("Firestore update successful"))
      //       .catchError((error) => print("Firestore update failed: $error"));

        // for (int i = 0; i < entryList.length; i++) {
        //   if (i < entList[0]['subCategory'].length) { // Prevent out-of-range error
        //     entList[0]['subCategory'][i]['entryCategoryCountLeft'] =
        //         (entList[0]['subCategory'][i]['entryCategoryCountLeft'] ?? 0) -
        //             (entryList[i]['bookingCount'] ?? 0);
        //   }
        //   print('entry list is ${entList}');
        // }
        // FirebaseFirestore.instance
        //     .collection('Events')
        //     .doc(eventID)
        //     .set({
        //   "entranceList": entList,
        // }, SetOptions(merge: true));
      // }
      // FirebaseDatabase.instance
      //     .ref('Bookings')
      //     .child(bookingID)
      //     .child('entranceList')
      //     .set(entryList);
    })
        .whenComplete(() => FirebaseDatabase.instance
        .ref('Bookings')
        .child(bookingID)
        .child('tableList')
        .set(tableList
        .where((element) => element['tableName'] != '')
        .toList()))
        .whenComplete(() async {
      for (int i = 0; i < tableList.length; i++) {
        if (tableList[i]['tableName'] != '') {
          await FirebaseFirestore.instance
              .collection('Bookings')
              .doc(bookingID)
              .collection('Tables')
              .doc(tableList[i]['tableID'])
              .set(
            {
              'tableID': tableList[i]['tableID'],
              'tableName': tableList[i]['tableName'],
              'tablePrice': tableList[i]['tablePrice'],
              'tableNum': tableList[i]['tableNum'],
              'tableLeft': tableList[i]['tableLeft'],
            },
            SetOptions(merge: true),
          );
        }
      }
    })
        .whenComplete(
            () => FirebaseDatabase.instance.ref('Bookings/$bookingID').set({
          'entryList': entryList,
          'uid': uid(),
          'date': FieldValue.serverTimestamp(),
          'clubUID': clubUID
        }))
        .whenComplete(() {})
        .onError((error, stackTrace) {
      if (kDebugMode) {
        print(error);
      }
    })
        .whenComplete(() => updateEachEntryLeftEvent(context, eventID))
        .whenComplete(() async {

     // await FirebaseFirestore.instance
     //      .collection('Events')
     //      .doc(eventID)
     //      .collection('Tables').get();
     // print('check t;oe left ${tableList}');
     //  for (int i = 0; i < tableList.length; i++) {
     //    print('check table left ${ tableList[i]['tableLeft']}');
     //    print('check t;oe left ${ tableList[i]['tableLeft']}');
     //    // if (tableDataList[i]['tableName'] != '' && tableDataList[i] != '') {
     //   if(tableList[i]['tableName'] !='') {
     //
     //     FirebaseFirestore.instance
     //         .collection('Events')
     //         .doc(eventID)
     //         .collection('Tables')
     //         .doc('table${i + 1}')
     //         .set(
     //       {
     //         'tableLeft': tableList[i]['tableLeft']
     //       },
     //       SetOptions(merge: true),
     //     );
     //   }
     //    }
      // }
      Fluttertoast.showToast(
        msg: 'Payment Successful',
        toastLength: Toast.LENGTH_SHORT,
      );
      EasyLoading.dismiss();

      Get.offAll(BookingInfo(
        clubUID: clubUID,
        clubID: clubID,
        userID: uid()!,
        bookingID: bookingID,
        isRedirected: true, eventId: eventID,
      ));
    });
  });
}


int calculateAge(DateTime dob) {
  DateTime today = DateTime.now();
  int age = today.year - dob.year;
  if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
    age--;
  }
  print('cehck data of birth ${age}');
  return age;
}

updateEachEntryLeftEvent(BuildContext context, String eventID) {
  for (var element
  in Provider.of<EntryController>(context, listen: false).entryList) {
    if (element['bookingCount'] > 0) {
      updateAsTransaction(eventID, element['categoryIndex'].toString(),
          element['subCategoryIndex'].toString(), -element['bookingCount']);
    }
  }
}

