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
  final String clubUID, clubID, eventID,promoterID,organiserID;
  final List tableList, entryList,tableDataList;
  final int totalEntranceCount;
  final int totalTableCount;
  final Map<String, dynamic>? couponCodeDetail;

  const Payments({
    this.couponCodeDetail,
    required this.clubID,
    required this.clubUID,
    required this.eventID,
    required this.amount,
    required this.entryList,
    required this.tableList,
    required this.totalEntranceCount,
    required this.totalTableCount,
    this.promoterID='',
    this.organiserID='',
    super.key, required this.tableDataList,
  });

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  static const MethodChannel platform = MethodChannel('razorpay_flutter');

  late Razorpay _razorpay;

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            color: Colors.orange,
          )
        ],
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    openCheckout();
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  Future<void> openCheckout() async {
    Map<String, Object> options = {
      // 'key': 'rzp_live_um0gFkBW3RX3fA',
      'key': 'rzp_test_rxNWplsh8FCMMs',
      // 'secret': 'woOvOOkFDqhRjdxTJtkCux5z',
      'amount': widget.amount * 100,
      'name': 'PartyOn Entertainment PVT LTD',
      'description': 'Payment',
      'retry': {'enabled': true, 'max_count': 1},
      // 'customer_id':uid(),
      'send_sms_hash': true,
      'prefill': {
        FirebaseAuth.instance.currentUser?.phoneNumber ?? "": '',
        'email': ''
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('check promoter id is ${widget.promoterID}');
    await paymentSuccess(context, response,
        amount: widget.amount,
        clubUID: widget.clubUID,
        tableList: widget.tableList,
        promoterID: widget.promoterID,
        organiserID: widget.organiserID,
        eventID: widget.eventID,
        couponDetail: widget.couponCodeDetail,
        clubID: widget.clubID,
        entryList: widget.entryList,
        totalEntranceCount: widget.totalEntranceCount,
        tableDataList: widget.tableDataList,
        totalTableCount: widget.totalTableCount,
    );
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    print('check error is ${response.error}');
    print('check error is ${response.message}');
    print('check error is ${response.code}');
    final String ipv6 = await Ipify.ipv64();
    final String paymentID = 'pay_${randomAlphaNumeric(14)}';

    await FirebaseFirestore.instance.collection('Payments').doc(paymentID).set({
      'eventID': widget.eventID,
      'clubID': widget.clubID,
      'clubUID': widget.clubUID,
      'paymentID': paymentID,
      'userID': uid(),
      'amount': widget.amount,
      'status': 'F',
      'ipv6': ipv6,
      'date': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)).whenComplete(() {
      Fluttertoast.showToast(
        msg: 'Payment Failed',
        toastLength: Toast.LENGTH_SHORT,
      );

      Get.back();
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: 'EXTERNAL_WALLET: ${response.walletName!}',
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}
