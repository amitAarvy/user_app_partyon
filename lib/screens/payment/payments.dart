import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:random_string/random_string.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:user/screens/payment/payment_controller.dart';
import 'package:user/utils/utils.dart';

class Payments extends StatefulWidget {
  final double amount;
  final String clubUID, clubID, eventID, promoterID, organiserID;
  final List tableList, entryList, tableDataList;
  final int totalEntranceCount;
  final int totalTableCount;
  final Map<String, dynamic>? couponCodeDetail;

  const Payments({
    super.key,
    this.couponCodeDetail,
    required this.clubID,
    required this.clubUID,
    required this.eventID,
    required this.amount,
    required this.entryList,
    required this.tableList,
    required this.totalEntranceCount,
    required this.totalTableCount,
    required this.tableDataList,
    this.promoterID = '',
    this.organiserID = '',
  });

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  static const MethodChannel platform = MethodChannel('razorpay_flutter');
  late Razorpay _razorpay;
  late List localEntryList;
  late List localTableList;

  @override
  void initState() {
    super.initState();

    print('check amount is ${widget.amount}');
    localEntryList = List.from(widget.entryList); // Preserve original data
    localTableList = List.from(widget.tableList); // Preserve original data

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    if (widget.totalTableCount != 0) {
      print('check it tableList is ${widget.tableList}');
      updateTable(tableList: localTableList);

    } else {
      updateEntry(evenList: localEntryList);
    }
    print('check table list: ${widget.tableList}');
    print('check table count: ${widget.totalTableCount}');
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> openCheckout() async {
    Map<String, Object> options = {
      // 'key': 'rzp_test_rxNWplsh8FCMMs',
      'key': 'rzp_live_um0gFkBW3RX3fA',
      // 'secret': 'woOvOOkFDqhRjdxTJtkCux5z',
      'amount': (widget.amount * 100).toInt(), // in paise
      'name': 'PartyOn Entertainment PVT LTD',
      'description': 'Payment',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
        'email': ''
      },
      // 'external': {
      //   'wallets': ['paytm']
      // }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> updateEntry({bool paymentStatus = false, required List evenList}) async {
    final eventRef = FirebaseFirestore.instance.collection('Events').doc(widget.eventID);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final eventSnapshot = await transaction.get(eventRef);

        if (!eventSnapshot.exists) {
          throw Exception('Event does not exist');
        }

        final entList = List.from((eventSnapshot.data() as Map<String, dynamic>)['entranceList']);

        for (var booking in evenList) {
          bool matched = false;
          for (var entrance in entList) {
            if (entrance['categoryName'] == booking['categoryName']) {
              final subCategoryList = entrance['subCategory'];
              for (var subCategory in subCategoryList) {
                if (subCategory['entryCategoryName'] == booking['subCategoryName']) {
                  int currentCount = subCategory['entryCategoryCountLeft'] ?? 0;
                  int bookingCount = booking['bookingCount'] ?? 0;

                  if (!paymentStatus) {
                    if (currentCount == 0) {
                      Fluttertoast.showToast(msg: 'Entry sold out', backgroundColor: Colors.white, textColor: Colors.black);
                      // Fluttertoast.showToast(msg: 'Entry sold out',backgroundColor: Colors.white,textColor: Colors.black);
                      // Get.back();
                      // shouldUpdate = false;
                      paymentStatus = true;

                      return;
                    }
                    if (currentCount >= bookingCount) {
                      subCategory['entryCategoryCountLeft'] = currentCount - bookingCount;
                      matched = true;
                    } else {
                      Fluttertoast.showToast(msg: 'Entry sold out', backgroundColor: Colors.white, textColor: Colors.black);
                      // Get.back();
                      paymentStatus = true;
                      return;
                    }
                  } else {
                    subCategory['entryCategoryCountLeft'] = currentCount + bookingCount;
                    matched = true;
                  }
                }
              }
            }
          }

          if (!matched) {
            print("No match found for booking: $booking");
          }
        }

        // Update the event document with the modified entrance list
        transaction.update(eventRef, {"entranceList": entList});
      });

      if (!paymentStatus) {
        if(widget.amount.toString() == '0.0'){
          await paymentSuccess(
            context,
            null,
            amount: widget.amount,
            clubUID: widget.clubUID,
            tableList: widget.tableList,
            promoterID: widget.promoterID,
            organiserID: widget.organiserID,
            eventID: widget.eventID,
            couponDetail: widget.couponCodeDetail,
            clubID: widget.clubID,
            entryList: localEntryList,
            totalEntranceCount: widget.totalEntranceCount,
            tableDataList: widget.tableDataList,
            totalTableCount: widget.totalTableCount,
          );
        }else{
          openCheckout();
        }

      } else {
        Get.back();
      }
    } catch (e) {
      print('Transaction failed: $e');
      Fluttertoast.showToast(msg: 'An error occurred. Please try again.');
    }
  }

  Future<void> updateTable({
    bool paymentStatus = false,
    required List tableList,
  }) async {

    final tableCollection = FirebaseFirestore.instance.collection('Events').doc(widget.eventID)
        .collection('Tables');

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        for (int i = 0; i < tableList.length; i++) {
          final tableDocRef = tableCollection.doc('table${i + 1}');
          final tableSnapshot = await transaction.get(tableDocRef);

          if (!tableSnapshot.exists) {
            throw Exception('Table does not exist: table${i + 1}');
          }

          final data = tableSnapshot.data() as Map<String, dynamic>;
          int tableLeft = int.parse(data['tableLeft'].toString());
          int requested = int.parse(tableList[i]['tableNum'].toString());

          if (paymentStatus) {
            transaction.update(tableDocRef, {
              "tableLeft": tableLeft + requested,
            });
            Get.back();
            return; // move to next table
          }

          if (tableList[i]['tableName'].toString() == data['tableName'].toString()) {
            if (tableLeft < requested) {
              Fluttertoast.showToast(
                msg: 'Booking failed: seats may be sold out.',
                backgroundColor: Colors.white,
                textColor: Colors.black,
              );
              Get.back();
              return;
              // throw Exception('Not enough seats on ${data['tableName']}, requested: $requested, left: $tableLeft');
            }
            transaction.update(tableDocRef, {
              "tableLeft": tableLeft - requested,
            });{
              if(widget.amount.toString() == '0.0'){
                await paymentSuccess(
                  context,
                  null,
                  amount: widget.amount,
                  clubUID: widget.clubUID,
                  tableList: widget.tableList,
                  promoterID: widget.promoterID,
                  organiserID: widget.organiserID,
                  eventID: widget.eventID,
                  couponDetail: widget.couponCodeDetail,
                  clubID: widget.clubID,
                  entryList: localEntryList,
                  totalEntranceCount: widget.totalEntranceCount,
                  tableDataList: widget.tableDataList,
                  totalTableCount: widget.totalTableCount,
                );
              }else{
                openCheckout();
              }

            }}
        }
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Booking failed: seats may be sold out.',
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
      Get.back();
    }
  }

  Future<void> handlePaymentSuccess(PaymentSuccessResponse response) async {
    await paymentSuccess(
      context,
      response,
      amount: widget.amount,
      clubUID: widget.clubUID,
      tableList: widget.tableList,
      promoterID: widget.promoterID,
      organiserID: widget.organiserID,
      eventID: widget.eventID,
      couponDetail: widget.couponCodeDetail,
      clubID: widget.clubID,
      entryList: localEntryList,
      totalEntranceCount: widget.totalEntranceCount,
      tableDataList: widget.tableDataList,
      totalTableCount: widget.totalTableCount,
    );
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {

    if (widget.totalTableCount != 0) {
      print('check it tableList is ${widget.tableList}');
      updateTable(paymentStatus: true,tableList: localTableList);
    } else {
      updateEntry(paymentStatus: true, evenList: localEntryList);
    }

    final String ipv6 = await Ipify.ipv64();
    final String paymentID = 'pay_${randomAlphaNumeric(14)}';

    await FirebaseFirestore.instance
        .collection('Payments')
        .doc(paymentID)
        .set({
      'eventID': widget.eventID,
      'clubID': widget.clubID,
      'clubUID': widget.clubUID,
      'paymentID': paymentID,
      'userID': uid(),
      'amount': widget.amount,
      'status': 'F',
      'ipv6': ipv6,
      'date': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    Fluttertoast.showToast(msg: 'Payment Failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (widget.totalTableCount != 0) {
      print('check it tableList is ${widget.tableList}');
      updateTable(paymentStatus: true,tableList: localTableList);
    } else {
      updateEntry(paymentStatus: true, evenList: localEntryList);
    }
    // updateEntry(paymentStatus: true, evenList: localEntryList);
    Fluttertoast.showToast(
      msg: 'EXTERNAL_WALLET: ${response.walletName}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Fluttertoast.showToast(msg: 'Please complete the payment first.');
        return false; // Prevent back press
      },
      child: const Scaffold(
        body: Center(
          child: Offstage()
          // CircularProgressIndicator(color: Colors.orange),
        ),
      ),
    );
  }
}
