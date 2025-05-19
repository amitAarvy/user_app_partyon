import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user/utils/utils.dart';

class PaymentListView extends StatefulWidget {
  const PaymentListView({super.key});

  @override
  State<PaymentListView> createState() => _PaymentListViewState();
}

class _PaymentListViewState extends State<PaymentListView> {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: matte(),
    appBar: AppBar(
      backgroundColor: themeRed(),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: Get.back,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Payments',
            style: GoogleFonts.ubuntu(
              color: Colors.white,
              fontSize: 60.sp,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          width: 200.w,
        )
      ],
    ),
    body: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(
            width: Get.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SizedBox(
                    child: Center(
                      child: Text(
                        'Date',
                        style: GoogleFonts.ubuntu(
                          color: Colors.orange,
                          fontSize: 50.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    child: Center(
                      child: Text(
                        'Amount',
                        style: GoogleFonts.ubuntu(
                          color: Colors.orange,
                          fontSize: 50.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    child: Center(
                      child: Text(
                        'PaymentID',
                        style: GoogleFonts.ubuntu(
                          color: Colors.orange,
                          fontSize: 50.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    child: Center(
                      child: Text(
                        'Status',
                        style: GoogleFonts.ubuntu(
                          color: Colors.orange,
                          fontSize: 50.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ).paddingAll(20.h),
          ),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('Payments')
                .where('userID', isEqualTo: uid())
                .orderBy('date', descending: true)
                .get(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                );
              }
              if (snapshot.data?.docs.isEmpty == true) {
                return Center(
                  child: Text(
                    'No Payments found',
                    style: GoogleFonts.ubuntu(
                      color: Colors.white,
                      fontSize: 60.sp,
                    ),
                  ),
                );
              }

              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  QueryDocumentSnapshot<Object?>? data =
                  snapshot.data?.docs[index];
                  DateTime date = data?['date'].toDate();
                  return Container(
                    height: 300.h,
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SizedBox(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${date.day}-${date.month}-${date.year}',
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "${date.hour}:${date.minute} ${date.hour < 12 ? 'A.M' : 'P.M'}",
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            child: Center(
                              child: Text(
                                "₹ ${data?["amount"]}",
                                style:
                                GoogleFonts.ubuntu(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            child: Center(
                              child: Text(
                                "${data?["paymentID"]}",
                                style:
                                GoogleFonts.ubuntu(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            child: Center(
                              child: data?['status'] == 'F'
                                  ? Text(
                                'Failed',
                                style: GoogleFonts.ubuntu(
                                  color: Colors.red,
                                ),
                              )
                                  : Text(
                                'Success',
                                style: GoogleFonts.ubuntu(
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).paddingAll(20.h);
                },
              );
            },
          ),
        ],
      ),
    ),
  );
}
