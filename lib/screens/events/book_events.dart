import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:readmore/readmore.dart';
import 'package:user/local_db/hive_db.dart';
import 'package:user/screens/authentication/views/phone.dart';
import 'package:user/screens/events/book_events_controller.dart';
import 'package:user/screens/events/club_layout_view.dart';
import 'package:user/screens/payment/payment_controller.dart';
import 'package:user/screens/payment/payments.dart';
import 'package:user/utils/utils.dart';
import 'book_event_utils.dart';
import 'organiser_event.dart';


class BookEvents extends StatefulWidget {
  final String clubUID, clubID, eventID, organiserID, promoterID;

  const BookEvents({
    this.clubID = "",
    required this.clubUID,
    required this.eventID,
    this.organiserID = '',
    this.promoterID = '',
    super.key,
  });

  @override
  State<BookEvents> createState() => _BookEventsState();
}

class _BookEventsState extends State<BookEvents> {
  final BookingProvider bookingProvider = Get.put(BookingProvider());
  TextEditingController couponController = TextEditingController();
  String eventOrganiserID = '';
  ValueNotifier<bool> isLoadingEvent = ValueNotifier(false);
  // TextEditingController coupon = TextEditingController();
  // ValueNotifier<double> totalAmount = ValueNotifier(0.0);
  double  totalAmount= 0;
  double discountPercentage = 0;

  late DateTime endTime;
  late DateTime startTime;
  late String genre;
  String? aboutEvent;
  late String artistName;
  String address = '';
  String? matchedCouponCode;


ValueNotifier<String?> promoterId =ValueNotifier('');
  ValueNotifier<bool> applyCoupon = ValueNotifier(false);
  ValueNotifier<Map<String,dynamic>?> couponDetail = ValueNotifier(null);

  @override
  void initState() {
    if (kDebugMode) {
      print('evenet kdjkfs ${widget.eventID}');
    }
    super.initState();
    promoterId.value = widget.promoterID;
    getEventOrganiserID();
    // calculateAge(DateTime.parse('November 28, 2000 at 12:00:00AM UTC+5:30'));
  }





  Map<String, dynamic>? organiser;

  ValueNotifier<bool> checkFollow = ValueNotifier(false);
  String followId = '';

  int calculateAge(DateTime dob) {
    DateTime today = DateTime.now();


    int age = today.year - dob.year;

    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }

    return age;
  }
  getEventOrganiserID() async {
    print('check uid is ${uid()}');
    try{
      isLoadingEvent.value = true;
      final DocumentSnapshot documentSnapshot =
      await FirebaseFirestore.instance.collection('Events').doc(widget.eventID).get();
      eventOrganiserID = documentSnapshot.get('organiserID') ?? '';
      print('event orgaiserId is ${eventOrganiserID}');
      if(eventOrganiserID !=''){
        DocumentSnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
            .collection('Organiser')
            .doc(eventOrganiserID)  // Use .doc() for direct lookup
            .get();
        organiser = data.data();
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Follow')
            .where('uid', isEqualTo: eventOrganiserID)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          Map<String, dynamic> data = querySnapshot.docs[0].data() as Map<String, dynamic>;
          checkFollow.value = data['follow'].toString() == 'true'?true:false;
          followId = querySnapshot.docs[0].id;  // Use this if you need the document ID
        }
      }

      DocumentReference eventRef = FirebaseFirestore.instance.collection('Events').doc(widget.eventID);

      eventRef.get().then((documentSnapshots) {
        if (documentSnapshots.exists) {
          print('check view it ${documentSnapshots.get('view')}');
          if (documentSnapshots.get('view') is List) {
            List<dynamic> viewList = List.from(documentSnapshots.get('view'));

            if (!viewList.contains(uid())) {
              viewList.add(uid());

              // Update Firestore with the modified list
              eventRef.update({'view': viewList}).then((_) {
                print("User added to view list!");
              }).catchError((error) {
                print("Failed to update user: $error");
              });
            }
          } else {
            // If 'view' doesn't exist, create a new list with userId
            eventRef.update({'view': [uid()]}).then((_) {
              print("View list created and user added!");
            }).catchError((error) {
              print("Failed to create view list: $error");
            });
          }
        } else {
          print("Document does not exist.");
        }
      }).catchError((error) {
        print("Error fetching document: $error");
      });



      startTime = documentSnapshot.get('startTime').toDate();
      endTime = documentSnapshot.get('endTime').toDate();
      genre = documentSnapshot.get('genre') ?? '';
      aboutEvent = documentSnapshot.get('briefEvent') ?? '';
      artistName = documentSnapshot.get('artistName') ?? '';
      // address = documentSnapshot.get('artistName') ?? '';
      await FirebaseFirestore.instance
          .collection("Club")
          .doc(widget.clubUID)
          .get()
          .then((doc) async {
        if (doc.exists) {
          address = '${getKeyValueFirestore(doc, 'address',) ?? ''}, ${getKeyValueFirestore(doc, 'area',) ?? ''} ${getKeyValueFirestore(doc, 'city',) ?? ''} ${getKeyValueFirestore(doc, 'state',) ?? ''}';
          setState(() {});
        }
      });
      if(widget.promoterID != null){
        var data = await FirebaseFirestore.instance.collection('PrAnalytics').get();
        List data1 =  data.docs.where((element) => element['prId'].toString() ==widget.promoterID).where((e)=>e.id.toString()==widget.eventID.toString()).toList();
        await FirebaseFirestore.instance.collection('PrAnalytics').doc(data1[0].id).update({
          "noOfView": data1[0]['noOfView']+1
        });
      }
     setState(() {});
    }catch(e){
      print('log print ${e}');
    }finally{
      isLoadingEvent.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: themeRed(),
        title: GestureDetector(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                kIsWeb?"Partyon": 'Book Events',
                style: GoogleFonts.ubuntu(fontSize: 50.sp, color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              String imageURL = '';
              await FirebaseFirestore.instance
                  .collection('Club')
                  .doc(widget.clubUID)
                  .get()
                  .then((DocumentSnapshot<Map<String, dynamic>> value) => imageURL = value.data()?['layoutImage'] ?? '');
              if (imageURL.isNotEmpty) {
                Get.to(ClubLayout(imageURL: imageURL));
              } else {
                Fluttertoast.showToast(msg: 'No table layout');
              }
            },
            child: SizedBox(
              height:100.h,
              width: 150.h,
              child: Center(
                child: Text(
                  'Table Layout',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 35.sp),
                ),
              ),
            ).paddingAll(10.w),
          )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: isLoadingEvent,
        builder: (context, bool isLoading, child) {
          if(isLoading){
            return Center(child: CircularProgressIndicator(color: Colors.white,),);
          }
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
               children: [
                 FutureBuilder<DocumentSnapshot>(
                   future: FirebaseFirestore.instance.collection('Events').doc(widget.eventID).get(),
                   builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                     if (!snapshot.hasData) {
                       return SizedBox(
                         height: Get.height,
                         width: Get.width,
                         child: const Center(
                           child: Text('No data found for this event'),
                         ),
                       );
                     } else if (snapshot.connectionState == ConnectionState.waiting) {
                       return SizedBox(
                         height: Get.height,
                         width: Get.width,
                         child: const Center(
                           child: CircularProgressIndicator(
                             color: Colors.orange,
                           ),
                         ),
                       );
                     } else {
                       DocumentSnapshot<Object?>? data = snapshot.data;
                       List<EntranceData> entranceList = fetchEntranceData(data?['entranceList']);
                       if (kDebugMode) {
                         // print(entranceList[0].subCategory);
                       }
                       //print("data11: ${data.toString()}");

                       DateTime date = data?.get('date').toDate();
                       return Column(
                         children: [
                           SizedBox(
                             height: 5.h,
                           ),
                           Card(
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(20),
                             ),
                             color: Colors.black,
                             child: Container(
                               decoration: BoxDecoration(
                                 // boxShadow: [
                                 //   BoxShadow(
                                 //     offset: Offset(0, 1.h),
                                 //     spreadRadius: 5.h,
                                 //     blurRadius: 20.h,
                                 //     color: Colors.deepPurple,
                                 //   )
                                 // ],
                                 color: Colors.black,
                                 borderRadius: BorderRadius.circular(15),
                               ),
                               height: 16.2 / 9 * Get.width + ( 320.h),
                               width: Get.width,
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   SizedBox(
                                     height: 16 / 9 * Get.width,
                                     width: Get.width,
                                     child: ClipRRect(
                                       borderRadius: BorderRadius.circular(15),
                                       child: eventCarousel(getKeyValueFirestore(data!, 'coverImages') ?? [], isNetworkImage: true),
                                     ),
                                   ).paddingAll(20.w),
                                   Expanded(
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Text(
                                           "${getKeyValueFirestore(data, 'title').toString().capitalize}",
                                           textAlign: TextAlign.start,
                                           overflow: TextOverflow.ellipsis,
                                           style: GoogleFonts.ubuntu(
                                             color: Colors.white,
                                             fontSize: 50.sp,
                                           ),
                                         ),
                                         Text(
                                           DateFormat('dd MMMM, yyyy').format(date),
                                           overflow: TextOverflow.visible,
                                           style: GoogleFonts.ubuntu(
                                             color: Colors.orange,
                                             fontSize: 50.sp,
                                           ),
                                         ),
                                         Row(
                                           mainAxisAlignment: MainAxisAlignment.center,
                                           mainAxisSize: MainAxisSize.min,
                                           children: [
                                             Text(
                                               DateFormat('hh : mm a').format(data.get('startTime').toDate()),
                                               overflow: TextOverflow.visible,
                                               style: GoogleFonts.ubuntu(
                                                 color: Colors.grey,
                                                 fontSize: 50.sp,
                                               ),
                                             ),
                                             Text(
                                               "- ${DateFormat('hh : mm a').format(data.get("endTime").toDate())}",
                                               overflow: TextOverflow.visible,
                                               style: GoogleFonts.ubuntu(
                                                 color: Colors.grey,
                                                 fontSize: 50.sp,
                                               ),
                                             ),
                                           ],
                                         ),
                                       ],
                                     ).paddingOnly(
                                       left: 30.w,
                                       right: 10.w,
                                       top: 20.h,
                                       bottom: 0.h,
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                           ).paddingAll(10.w),
                           Divider(color: Colors.grey.shade200,),
                           SizedBox(height: 10,),
                           Row(
                             children: [
                               // Icon(Icons.category, color: Colors.white, size: 60.h),
                               const SizedBox(width: 5),
                               Text(" ${genre}", style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),

                             ],
                           ),
                           SizedBox(height: 10,),
                           Divider(color: Colors.grey.shade200,),
                           SizedBox(
                             height: 50.h,
                           ),
                           if (aboutEvent != null)
                             Row(
                               children: [
                                 Card(
                                   shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(20),
                                   ),
                                   color: Colors.black,
                                   child: Container(
                                       width: 400,
                                       decoration: BoxDecoration(
                                         // boxShadow: [
                                         //   BoxShadow(
                                         //     offset: Offset(0, 1.h),
                                         //     spreadRadius: 5.h,
                                         //     blurRadius: 20.h,
                                         //     color: Colors.deepPurple,
                                         //   )
                                         // ],
                                         color: Colors.black,
                                         borderRadius: BorderRadius.circular(15),
                                       ),
                                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.stretch,
                                         children: [
                                           Text("Event info ",
                                               style: GoogleFonts.adamina(
                                                   fontSize: 22,
                                                   fontWeight: FontWeight.w700,
                                                   color: Colors.white,
                                                   decoration: TextDecoration.underline,
                                                   decorationColor: Colors.white,
                                                   decorationThickness: 1)),
                                           const SizedBox(height: 15),
                                           // Text(aboutEvent ?? '', style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                                           // const SizedBox(height: 15),
                                           // Row(
                                           //   children: [
                                           //     Icon(Icons.calendar_month_outlined, color: Colors.white, size: 60.h),
                                           //     const SizedBox(width: 5),
                                           //     Text("Date: ${DateFormat.yMMMMEEEEd().format(date)}",
                                           //         style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                                           //   ],
                                           // ),
                                           // const SizedBox(height: 15),
                                           // Row(
                                           //   children: [
                                           //     Icon(Icons.watch_later, color: Colors.white, size: 60.h),
                                           //     const SizedBox(width: 5),
                                           //     Text(
                                           //         "Time: ${TimeOfDay(hour: startTime.hour, minute: startTime.minute).hourOfPeriod.toString()}:${TimeOfDay(hour: startTime.hour, minute: startTime.minute).minute.toString().padLeft(2, '0')} ${TimeOfDay(hour: startTime.hour, minute: startTime.minute).period.name} Onwards",
                                           //         style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                                           //   ],
                                           // ),
                                           Column(crossAxisAlignment: CrossAxisAlignment.start,
                                             children: [
                                               Container(
                                                 color: Colors.black, // Background color to contrast white text
                                                 child: SizedBox(
                                                   width: 0.9.sw,
                                                   child: ReadMoreText(
                                                     "${getKeyValueFirestore(data, 'briefEvent').toString().capitalize}",
                                                     trimMode: TrimMode.Line,
                                                     trimLines: 6,
                                                     textAlign: TextAlign.start,
                                                     style: GoogleFonts.ubuntu(
                                                       color: Colors.white,
                                                       fontSize: 20,
                                                     ),
                                                     colorClickableText: Colors.white, // Make "Show more" visible
                                                     trimCollapsedText: 'Read more',
                                                     trimExpandedText: 'Read less',
                                                     lessStyle: GoogleFonts.ubuntu(
                                                       color: Colors.orange,
                                                       fontSize: 20,
                                                     ),
                                                     moreStyle: GoogleFonts.ubuntu(
                                                       color: Colors.orange,
                                                       fontSize: 20,
                                                     ),
                                                   ),
                                                 ),
                                               ),

                                             ],
                                           ),
                                           const SizedBox(height: 10),
                                           Row(
                                             children: [
                                               Icon(Icons.timelapse, color: Colors.white, size: 60.h),
                                               const SizedBox(width: 5),
                                               Text(" ${endTime.difference(startTime).inHours} hours",
                                                   style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                                             ],
                                           ),
                                           const SizedBox(height: 10),
                                           // Row(
                                           //   children: [
                                           //     Icon(Icons.music_note_outlined, color: Colors.white, size: 60.h),
                                           //     const SizedBox(width: 5),
                                           //     Text("Artist: ${artistName}",
                                           //         style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                                           //   ],
                                           // ),
                                           // const SizedBox(height: 15),
                                           // Row(
                                           //   children: [
                                           //     Icon(Icons.category, color: Colors.white, size: 60.h),
                                           //     const SizedBox(width: 5),
                                           //     Text("Genre: ${genre}", style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                                           //   ],
                                           // ),
                                           const SizedBox(height: 5),
                                           // Text("Band Type: ${bandType}", style: TextStyle(fontSize: 15)),
                                         ],
                                       )
                                     // Padding(
                                     //   padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                                     //   child: Column(crossAxisAlignment: CrossAxisAlignment.start ,
                                     //     children: [
                                     //      Text("Duration: 6 hours ",
                                     //        style:TextStyle(color: Colors.white,
                                     //            fontSize: 16,fontWeight: FontWeight.w600),),
                                     //       Text("Artist: hgjdsjyd ",
                                     //         style:TextStyle(color: Colors.white,
                                     //             fontSize: 16,fontWeight: FontWeight.w600),),
                                     //       Text("Genre: Bollywood Commercial ",
                                     //         style:TextStyle(color: Colors.white,
                                     //             fontSize: 16,fontWeight: FontWeight.w600),),
                                     //     ],
                                     //   ),
                                     // ),
                                   ),
                                 ),
                               ],
                             ),
                           SizedBox(
                             height: 50.h,
                           ),
                           /*Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 20),
                             child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                               children: [Text("See what's in store",
                                 style:TextStyle(color: Colors.white,
                                     fontSize: 22,fontWeight: FontWeight.w600),
                               ),Text("Available once you have a ticket",
                                 style: TextStyle(color: Colors.white,fontSize: 14),),
                                 SizedBox(
                                   height: 40.h,
                                 ),
                                 Row(
                                   mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                   children: [Text("Experience",
                                     style: TextStyle(color: Colors.white,fontSize: 14),),
                                     Text("Thu 10 jul",
                                       style: TextStyle(color: Colors.white,fontSize: 14),
                                     ),
                                     Text("Experience",
                                       style: TextStyle(color: Colors.white,fontSize: 14),)
                                   ],)],),
                           ),*/
                           Align(
                             alignment: Alignment.centerLeft,
                             child: Text("Lineup",
                                 style: GoogleFonts.adamina(
                                     fontSize: 22,
                                     fontWeight: FontWeight.w700,
                                     color: Colors.white,
                                     decorationColor: Colors.white)),
                           ),
                           SizedBox(
                             height: 20.h,
                           ),
                           Card(
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(20),
                             ),
                             color: Colors.black,
                             child: Container(
                               width: double.infinity,
                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                               decoration: BoxDecoration(
                                 // boxShadow: [
                                 //   BoxShadow(
                                 //     offset: Offset(0, 1.h),
                                 //     spreadRadius: 5.h,
                                 //     blurRadius: 20.h,
                                 //     color: Colors.deepPurple,
                                 //   )
                                 // ],
                                 color: Colors.black,
                                 borderRadius: BorderRadius.circular(15),
                               ),
                               child: Column(
                                 children: [
                                   Row(
                                     children: [
                                       Icon(Icons.music_note_outlined, color: Colors.white, size: 90.h),
                                       const SizedBox(width: 5),
                                       Text("${artistName}", style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                                     ],
                                   ),
                                 ],
                               ),
                             ),
                           ),
                           SizedBox(
                             height: 50.h,
                           ),
                           Align(
                             alignment: Alignment.centerLeft,
                             child: Text("Venue",
                                 style: GoogleFonts.adamina(
                                     fontSize: 22,
                                     fontWeight: FontWeight.w700,
                                     color: Colors.white,
                                     decorationColor: Colors.white)),
                           ),
                           SizedBox(
                             height: 20.h,
                           ),


                           Row(
                             children: [
                               Icon(Icons.door_back_door_outlined, color: Colors.white, size: 70.h),
                               const SizedBox(width: 5),
                               Text("Doors open at ${TimeOfDay(hour: startTime.hour, minute: startTime.minute).hourOfPeriod.toString()}:${TimeOfDay(hour: startTime.hour, minute: startTime.minute).minute.toString().padLeft(2, '0')} ${TimeOfDay(hour: startTime.hour, minute: startTime.minute).period.name}", style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                             ],
                           ),

                           Row(
                             children: [
                               Icon(Icons.location_on, color: Colors.white, size: 70.h),
                               const SizedBox(width: 5),
                               Text("${address??''}", style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                             ],
                           ),
                           SizedBox(height: 10,),

                           GestureDetector(
                             onTap:() async{
                               try {
                                 await FirebaseFirestore.instance
                                     .collection('Club')
                                     .doc(widget.clubUID)
                                     .get()
                                     .then((data) {
                                   if (data.exists) {
                                     openMap(data.data()?['latitude'], data.data()?['longitude']);
                                   }
                                 });
                               } catch (e) {
                                 Fluttertoast.showToast(msg: 'Something went wrong');
                               }
                             },
                             child: Container(
                               height:200,
                               margin: EdgeInsets.all(10),
                               decoration: BoxDecoration(
                                 color: Colors.grey[800],
                                 borderRadius: BorderRadius.circular(12),
                               ),
                               child: Stack(
                                 children: [
                                   Center(
                                     child: Text(
                                       '${address}',
                                       style: TextStyle(color: Colors.white70, fontSize: 16),
                                     ),
                                   ),
                                   const Align(
                                     alignment: Alignment.center,
                                     child: Icon(
                                       Icons.location_on,
                                       color: Colors.yellow,
                                       size: 40,
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                           ),
                           SizedBox(
                             height: 20.h,
                           ),
                           if(getKeyValueFirestore(data, 'organiserID') !=null)
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 10),
                             child: GestureDetector(
                               onTap:(){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>OrganiserEvent(clubName:organiser!['companyMame'].toString(),clubUid: getKeyValueFirestore(data, 'organiserID'),organiserData: organiser,)));
                             },
                               child: Container(
                                 decoration: BoxDecoration(
                                   color: Colors.grey[800],
                                   borderRadius: BorderRadius.all(Radius.circular(11)),
                                 ),
                                 child: Padding(
                                   padding: const EdgeInsets.all(8.0),
                                   child: Column(
                                     children: [
                                       Text('Curated By',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600,color: Colors.white),),
                                       SizedBox(height: 20,),
                                       AspectRatio(
                                           aspectRatio: 16/9,
                                       child: Image.network(organiser!['profile_image'].toString(),fit: BoxFit.cover,),),
                                       SizedBox(height:10),

                                       Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                         children: [
                                           // SizedBox(
                                           //     height:50,
                                           //     width:50,
                                           //     child: Image.network(organiser!['profile_image'].toString())),
                                           Text(organiser!['companyMame'].toString(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.w800,color: Colors.white),),
                                           Icon(Icons.arrow_forward_ios,color: Colors.white)
                                         ],
                                       ),
                                       SizedBox(height: 20,),
                                       Divider(color: Colors.grey.shade200,),
                                       ValueListenableBuilder(
                                         valueListenable: checkFollow,
                                         builder: (context, bool isCheck, child) =>
                                         Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children: [
                                             Text('Become a Follower\n10 Followers',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w800,color: Colors.grey),),
                                             InkWell(
                                               onTap: ()async{

                                                 if(followId  ==''){
                                                     FirebaseFirestore.instance.collection('Follow').add({
                                                       'uid': getKeyValueFirestore(data, 'organiserID'),
                                                       'follow': true,
                                                     }).then((value) {
                                                       checkFollow.value = true;
                                                        print("User Added");
                                                     }).catchError((error) {
                                                        print("Failed to add user: $error");
                                                        });
                                                     }
                                                 else{
                                                   FirebaseFirestore.instance.collection('Follow').doc(followId).update({
                                                     'uid': getKeyValueFirestore(data, 'organiserID'),
                                                     'follow': isCheck==true?false:true,
                                                   }).then((_) {
                                                     checkFollow.value = isCheck==true?false:true;
                                                     print("User updated successfully!");
                                                   }).catchError((error) {
                                                     print("Failed to update user: $error");
                                                   });

                                                 }
                                               },
                                               child: Container(
                                                 decoration: BoxDecoration(
                                                   border:Border.all(color: Colors.purple,width: 2),
                                                   borderRadius: BorderRadius.all(Radius.circular(21))
                                                 ),
                                                 padding: EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                                                 child: Text(isCheck?'Followed':'Follow',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w800,color: Colors.white),),

                                               ),
                                             )
                                           ],
                                         ),
                                       ),

                                     ],
                                   ),
                                 ),
                               ),
                             ),
                           ),


                           SizedBox(
                             height: 50.h,
                           ),
                           Card(
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(20),
                             ),
                             color: Colors.black,
                             child: Container(
                               decoration: BoxDecoration(
                                 // boxShadow: [
                                 //   BoxShadow(
                                 //     offset: Offset(0, 1.h),
                                 //     spreadRadius: 5.h,
                                 //     blurRadius: 20.h,
                                 //     color: Colors.deepPurple,
                                 //   )
                                 // ],
                                 color: Colors.black,
                                 borderRadius: BorderRadius.circular(15),
                               ),
                               child: Column(
                                 children: [
                                   EntranceDataWidget(
                                     eventID: widget.eventID,
                                   )
                                 ],
                               ),
                             ),
                           ),
                           SizedBox(height: 30.h),
                           StreamBuilder<QuerySnapshot>(
                             stream: FirebaseFirestore.instance.collection('Events').doc(widget.eventID).collection('Tables').snapshots(),
                             builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> tableSnapshot) {
                               if (!tableSnapshot.hasData) {
                                 return Container();
                               } else if (tableSnapshot.connectionState == ConnectionState.waiting) {
                                 return const Center(
                                   child: CircularProgressIndicator(
                                     color: Colors.orange,
                                   ),
                                 );
                               } else {
                                 return Column(
                                   children: [
                                     Row(
                                       children: [
                                         Text(
                                           'Tables',
                                           style: const TextStyle(color: Colors.orange),
                                         ).paddingOnly(
                                           left: 40.w,
                                           top: 20.w,
                                           right: 20.w,
                                           bottom: 20.w,
                                         ),
                                       ],
                                     ),
                                     Text(
                                       'Tap on table name to check inclusions(if any)',
                                       style: GoogleFonts.ubuntu(color: Colors.white),
                                     ),
                                     Card(
                                       color: Colors.black,
                                       shape: RoundedRectangleBorder(
                                         borderRadius: BorderRadius.circular(20),
                                       ),
                                       child: Container(
                                         decoration: BoxDecoration(
                                           // boxShadow: [
                                           //   BoxShadow(
                                           //     offset: Offset(0, 1.h),
                                           //     spreadRadius: 5.h,x`
                                           //     blurRadius: 20.h,
                                           //     color: Colors.deepPurple,
                                           //   )
                                           // ],
                                           color: Colors.black,
                                           borderRadius: BorderRadius.circular(15),
                                         ),
                                         child: ListView.builder(
                                           physics: const NeverScrollableScrollPhysics(),
                                           shrinkWrap: true,
                                           itemCount: tableSnapshot.data?.docs.length,
                                           itemBuilder: (BuildContext context, int index) {
                                             QueryDocumentSnapshot<Object?>? tableData = tableSnapshot.data?.docs[index];
                                             SchedulerBinding.instance.addPostFrameCallback((_) {
                                               Provider.of<EntryTableController>(
                                                 context,
                                                 listen: false,
                                               ).updateNumTable(index, 0);
                                               // c.tablePrice
                                               //     .insert(index, tableData?["tablePrice"]);
                                               Provider.of<EntryTableController>(
                                                 context,
                                                 listen: false,
                                               ).updatePriceTable(
                                                 index,
                                                 tableData?['tablePrice'],
                                               );
                                               Provider.of<EntryTableController>(
                                                 context,
                                                 listen: false,
                                               ).updateTableName(
                                                 index,
                                                 tableData?['tableName'],
                                               );

                                               if (tableData?['tableLeft'] == 0) {
                                                 Provider.of<EntryTableController>(
                                                   context,
                                                   listen: false,
                                                 ).updateNumTable(index, 0);
                                               }
                                             });
                                             return TableList(
                                               index: index,
                                               tableData: tableData!,
                                             );
                                           },
                                         ),
                                       ),
                                     ),
                                   ],
                                 );
                               }
                             },
                           ),
                           SizedBox(
                             height: 250.h,
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 ValueListenableBuilder(
                                   valueListenable: applyCoupon,
                                   builder: (context, bool value, child) =>
                                       SizedBox(
                                         width: 700.w,
                                         child: TextField(readOnly: value,
                                           keyboardType: TextInputType.text, // or any type like TextInputType.number
                                           inputFormatters: [
                                             UpperCaseTextFormatter(),
                                           ],
                                           controller: couponController,
                                           style: const TextStyle(color: Colors.white),
                                           decoration: InputDecoration(
                                             labelText: 'Enter coupon code',
                                             labelStyle: const TextStyle(color: Colors.white),
                                             enabledBorder: OutlineInputBorder(
                                               borderSide: BorderSide(color: themeRed()),
                                             ),
                                             focusedBorder: const OutlineInputBorder(
                                               borderSide: BorderSide(color: Colors.blue),
                                             ),
                                           ),
                                         ),
                                       ),
                                 ),
                                 ValueListenableBuilder(
                                     valueListenable: applyCoupon,
                                     builder: (context, bool value, child) =>
                                         Consumer2<EntryTableController, EntryController>(
                                           builder: (context, tableData, entryData, _) {
                                             double tablePrice = 0.0;
                                             int entryQty = 0;
                                             for (int i = 0; i < tableData.numTable.length; i++) {
                                               tablePrice += tableData.priceTable[i] * tableData.numTable[i];
                                             }
                                             double entryPrice = 0;
                                             for (var element in entryData.entryList) {
                                               print('check qty ${element['bookingCount']}');
                                               entryQty = element['bookingCount'];
                                               entryPrice += element['bookingAmount'] * element['bookingCount'];
                                             }
                                             return Center(
                                               child: ElevatedButton(
                                                 onPressed: value
                                                     ? () {
                                                   applyCoupon.value = false;
                                                   matchedCouponCode = '';
                                                   couponDetail.value = null;
                                                 }
                                                     : () async {
                                                   if (couponController.text.isEmpty) {
                                                     Fluttertoast.showToast(msg: 'Please enter coupon code');
                                                     return;
                                                   }

                                                   print('check ${couponController.text}');
                                                   int totalEntranceCount = 0;
                                                   int totalTableCount = 0;

                                                   for (int i = 0; i < tableData.numTable.length; i++) {
                                                     totalTableCount += int.parse(tableData.numTable[i].toString());
                                                   }

                                                   for (var element in entryData.entryList) {
                                                     totalEntranceCount += int.parse(element['bookingCount'].toString());
                                                   }
                                                   final double amount = tablePrice + entryPrice;

                                                   var data1 = await FirebaseFirestore.instance.collection('CouponPR').where('eventId',isEqualTo: widget.eventID).get();
                                                   List eventCoupons = data1.docs;

                                                   if (totalEntranceCount > 0 || totalTableCount > 0) {
                                                     if(getKeyValueFirestore(data, 'entryManagementCouponList').toString() != 'null' || getKeyValueFirestore(data, 'entryManagementCouponList').toString() != 'null'){
                                                       print('check 1');
                                                       final enteredCode = couponController.text.trim();
                                                       if(getKeyValueFirestore(data, 'entryManagementCouponList')['couponCode'].toString() == enteredCode){
                                                         print('check 2');
                                                         couponDetail.value = {
                                                           "appliedCoupon":'venue',
                                                           'eventDetail':data,
                                                           'eventId':widget.eventID,
                                                           'totalView':0,
                                                           "data": getKeyValueFirestore(data, 'entryManagementCouponList'),
                                                           "type": 'entry',
                                                           'coupon': getKeyValueFirestore(data, 'entryManagementCouponList')['tableCoupon']
                                                         };

                                                         applyCoupon.value = true;
                                                         print('Coupon matched: $couponDetail');
                                                         double couponDiscount =0;
                                                         if (couponDetail.value != null && couponDetail.value!['data']['discount'] != null) {
                                                           couponDiscount = double.parse(couponDetail.value!['data']['discount'].toString()) / 100;
                                                         }
                                                         discountPercentage = couponDiscount;
                                                         final double discountAmount = amount * couponDiscount ;
                                                         totalAmount = amount - discountAmount;
                                                       }else if(getKeyValueFirestore(data, 'tableManagementCouponList')['couponCode'].toString() == enteredCode){
                                                         print('check 3');
                                                         couponDetail.value = {
                                                           "appliedCoupon":'venue',
                                                           'eventId':widget.eventID,
                                                           "data": getKeyValueFirestore(data, 'tableManagementCouponList'),
                                                           'totalView':0,
                                                           "type": 'table',
                                                           'coupon': getKeyValueFirestore(data, 'tableManagementCouponList')['tableCoupon']
                                                         };
                                                         applyCoupon.value = true;
                                                         print('Coupon matched: $couponDetail');
                                                         double couponDiscount =0;
                                                         if (couponDetail.value != null && couponDetail.value!['data']['discount'] != null) {
                                                           couponDiscount = double.parse(couponDetail.value!['data']['discount'].toString()) / 100;
                                                         }
                                                         discountPercentage = couponDiscount;
                                                         final double discountAmount =amount * couponDiscount ;
                                                         totalAmount = amount - discountAmount;
                                                       }else{
                                                         print('check 4');
                                                         if (eventCoupons.isNotEmpty) {
                                                           final enteredCode = couponController.text.trim();
                                                           bool matchFound = false;
                                                           for (var doc in eventCoupons) {
                                                             final entryCode = doc['entryCoupon']
                                                                 .toString() == 'null'
                                                                 ? null
                                                                 : doc['entryCoupon']['couponCode']
                                                                 .toString();
                                                             final tableCode = doc['tableCoupon']
                                                                 .toString() == 'null'
                                                                 ? null
                                                                 : doc['tableCoupon']['couponCode']
                                                                 .toString();

                                                             print('check table coupon code $tableCode');
                                                             if (entryCode != null) {
                                                               if (totalEntranceCount > 0 &&
                                                                   enteredCode == entryCode) {
                                                                 promoterId.value = doc['prId'].toString();
                                                                 matchedCouponCode = entryCode;
                                                                 couponDetail.value = {
                                                                   "appliedCoupon":doc['isInf']==true?'inf':'pr',
                                                                   "totalView": doc['totalUseCoupon'],
                                                                   "id": doc.id,
                                                                   "type": 'entry',
                                                                   'eventId':widget.eventID,
                                                                   'data': doc['entryCoupon'],
                                                                   'coupon': doc['entryCoupon']['couponCode']
                                                                 };
                                                                 matchFound = true;
                                                                 break;
                                                               }
                                                             }

                                                             if (tableCode != null) {
                                                               // print('check data is $totalTableCount ');
                                                               if (
                                                                   enteredCode == tableCode){
                                                                 print('yes check coupon');
                                                                 promoterId.value = doc['prId'].toString();
                                                                 matchedCouponCode = tableCode;
                                                                 couponDetail.value = {
                                                                   "appliedCoupon":doc['isInf']==true?'inf':'pr',
                                                                   'eventId':widget.eventID,
                                                                   'data': doc['tableCoupon'],
                                                                   'coupon': doc['tableCoupon']['couponCode'],
                                                                   "totalView": doc['totalUseCouponTable'],
                                                                   "id": doc.id,
                                                                   "type": 'table',

                                                                 };
                                                                 matchFound = true;
                                                                 break;
                                                               }
                                                             }
                                                           }

                                                           if (matchFound) {
                                                             applyCoupon.value = true;
                                                             print('Coupon matched: $couponDetail');
                                                             double couponDiscount =0;
                                                             if (couponDetail.value != null && couponDetail.value!['data']['discount'] != null) {
                                                               couponDiscount = double.parse(couponDetail.value!['data']['discount'].toString()) / 100;
                                                             }
                                                             discountPercentage = couponDiscount;
                                                             final double discountAmount =amount * couponDiscount ;
                                                             totalAmount = amount - discountAmount;
                                                           } else {
                                                             Fluttertoast.showToast(
                                                                 msg: 'No valid coupon code found for this event.');
                                                           }
                                                         } else {
                                                           Fluttertoast.showToast(
                                                               msg: 'No coupon code found for this event.');
                                                         }
                                                       }
                                                     }else{
                                                       print('check 5');
                                                       if (eventCoupons.isNotEmpty) {
                                                         final enteredCode = couponController.text.trim();
                                                         bool matchFound = false;
                                                         for (var doc in eventCoupons) {
                                                           final entryCode = doc['entryCoupon']
                                                               .toString() == 'null'
                                                               ? null
                                                               : doc['entryCoupon']['couponCode']
                                                               .toString();
                                                           final tableCode = doc['tableCoupon']
                                                               .toString() == 'null'
                                                               ? null
                                                               : doc['tableCoupon']['couponCode']
                                                               .toString();

                                                           if (entryCode != null) {
                                                             if (totalEntranceCount > 0 &&
                                                                 enteredCode == entryCode) {
                                                               promoterId.value = doc['prId'].toString();
                                                               matchedCouponCode = entryCode;
                                                               couponDetail.value = {
                                                                 "appliedCoupon":"pr",
                                                                 "totalView": doc['totalUseCoupon'],
                                                                 "id": doc.id,
                                                                 "type": 'entry',
                                                                 'data': doc['entryCoupon']
                                                               };
                                                               matchFound = true;
                                                               break;
                                                             }
                                                           }

                                                           if (tableCode != null) {
                                                             if (totalTableCount > 0 &&
                                                                 enteredCode == tableCode) {
                                                               promoterId.value = doc['prId'].toString();
                                                               matchedCouponCode = tableCode;
                                                               couponDetail.value = {
                                                                 "totalView": doc['totalUseCouponTable'],
                                                                 "id": doc.id,
                                                                 "type": 'table',
                                                                 'data': doc['tableCoupon']
                                                               };
                                                               matchFound = true;
                                                               break;
                                                             }
                                                           }
                                                         }

                                                         if (matchFound) {
                                                           applyCoupon.value = true;
                                                           print('Coupon matched: $couponDetail');
                                                           double couponDiscount =0;
                                                           if (couponDetail.value != null && couponDetail.value!['data']['discount'] != null) {
                                                             couponDiscount = double.parse(couponDetail.value!['data']['discount'].toString()) / 100;
                                                           }
                                                           discountPercentage = couponDiscount;
                                                           final double discountAmount = amount * couponDiscount ;
                                                           totalAmount = amount - discountAmount;
                                                         } else {
                                                           Fluttertoast.showToast(
                                                               msg: 'No valid coupon code found for this event.');
                                                         }
                                                       } else {
                                                         Fluttertoast.showToast(
                                                             msg: 'No coupon code found for this event.');
                                                       }
                                                     }

                                                   } else {
                                                     Fluttertoast.showToast(
                                                         msg: 'Please add entry or table management.');
                                                   }
                                                   print('check promtoer id ${promoterId.value}');
                                                 },
                                                 style: ButtonStyle(
                                                   backgroundColor: MaterialStateProperty.all(themeRed()),
                                                 ),
                                                 child: Text(
                                                   value ? 'Cancel' : 'Apply',
                                                   style: TextStyle(color: value ? Colors.red : Colors.white),
                                                 ),
                                               ).paddingAll(30.w),
                                             );
                                           },
                                         )

                                 )
                               ],
                             ),
                           ),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.start,
                             children: [
                               ValueListenableBuilder(
                                 valueListenable: couponDetail,
                                 builder: (context, Map<String,dynamic>? data, child) =>
                                     Text(
                                       'Applied Discount: ${data==null?'0':data['data']['discount']}',
                                       style: GoogleFonts.ubuntu(color: Colors.grey, fontSize: 50.sp),
                                     ).paddingOnly(left: 50.w),
                               )
                             ],
                           ),
                           SizedBox(
                             height: 10.h,
                           ),
                         ],
                       );
                     }
                   },
                 ),


                 // Row(
                 //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 //   children: [
                 //     Text(
                 //       'Total',
                 //       style: GoogleFonts.merriweather(
                 //         fontSize: 60.sp,
                 //         color: Colors.white,
                 //       ),
                 //     ).paddingOnly(left: 60.w),
                 //     Align(
                 //       alignment: Alignment.bottomRight,
                 //       child: Column(
                 //         children: [
                 //           Container(
                 //             decoration: BoxDecoration(
                 //               boxShadow: [
                 //                 BoxShadow(
                 //                   offset: Offset(0, 1.h),
                 //                   spreadRadius: 5.h,
                 //                   blurRadius: 20.h,
                 //                   color: Colors.deepPurple,
                 //                 )
                 //               ],
                 //               color: Colors.orange,
                 //               borderRadius: BorderRadius.circular(15),
                 //             ),
                 //             height: 150.h,
                 //             width: 350.w,
                 //             child: Consumer<EntryTableController>(
                 //               builder: (BuildContext context,
                 //                       EntryTableController data, Widget? child) =>
                 //                   Center(
                 //                 child: Consumer<EntryController>(
                 //                   builder: (context, entryData, child) {
                 //                     double tablePrice = 0.0;
                 //                     for (int i = 0;
                 //                         i < data.numTable.length;
                 //                         i++) {
                 //                       tablePrice +=
                 //                           data.priceTable[i] * data.numTable[i];
                 //                     }
                 //                     double entryPrice = 0;
                 //                     for (var element in entryData.entryList) {
                 //                       entryPrice += element['bookingAmount'] *
                 //                           element['bookingCount'];
                 //                     }
                 //
                 //                     return GestureDetector(
                 //                       onTap: () async {
                 //                         if (uid() != null) {
                 //                           Box eventBox =
                 //                               await HiveDB.hiveOpenEventBox();
                 //                           final organiserID =
                 //                               eventBox.get(widget.eventID) ?? '';
                 //                           //below code is commented to check promotion and organiser
                 //                           List tableData = [];
                 //                           if (tablePrice > 0) {
                 //                             tableData = List.generate(
                 //                                 50, (int index) => []);
                 //                             for (int i = 0;
                 //                                 i < data.tableName.length;
                 //                                 i++) {
                 //                               tableData[i] = {
                 //                                 'tableID': randomAlphaNumeric(5)
                 //                                     .toUpperCase(),
                 //                                 'tableName': data.tableName[i],
                 //                                 'tableNum': data.numTable[i],
                 //                                 'tableLeft': data.numTable[i],
                 //                                 'tablePrice': data.priceTable[i]
                 //                               };
                 //                             }
                 //                           }
                 //                           int totalEntranceCount = 0;
                 //                           int totalTableCount = 0;
                 //                           for (int i = 0;
                 //                               i < data.numTable.length;
                 //                               i++) {
                 //                             totalTableCount += int.parse(
                 //                                 data.numTable[i].toString());
                 //                           }
                 //                           for (var element
                 //                               in entryData.entryList) {
                 //                             totalEntranceCount += int.parse(
                 //                                 element['bookingCount']
                 //                                     .toString());
                 //                           }
                 //
                 //                           final double amount =
                 //                               tablePrice + entryPrice;
                 //
                 //                           if (amount > 0) {
                 //                             await Get.to(
                 //                               Payments(
                 //                                 amount: amount,
                 //                                 tableDataList: tableData,
                 //                                 eventID: widget.eventID,
                 //                                 clubID: widget.clubID,
                 //                                 clubUID: widget.clubUID,
                 //                                 entryList: bookingProvider
                 //                                     .getBookingList,
                 //                                 tableList: tableData,
                 //                                 promoterID: widget.promoterID,
                 //                                 organiserID: widget.organiserID,
                 //                                 totalEntranceCount:
                 //                                     totalEntranceCount,
                 //                                 totalTableCount: totalTableCount,
                 //                               ),
                 //                             );
                 //                           } else if (bookingProvider
                 //                                   .getBookingList.isNotEmpty ||
                 //                               bookingProvider.getTableBookingList
                 //                                   .isNotEmpty) {
                 //                             if (!context.mounted) return;
                 //                             paymentSuccess(context, null,
                 //                                 tableDataList: tableData,
                 //                                 amount: amount,
                 //                                 clubUID: widget.clubUID,
                 //                                 tableList: bookingProvider
                 //                                     .getTableBookingList,
                 //                                 eventID: widget.eventID,
                 //                                 entryList: bookingProvider
                 //                                     .getBookingList,
                 //                                 clubID: widget.clubID,
                 //                                 organiserID:
                 //                                     eventOrganiserID.isNotEmpty
                 //                                         ? eventOrganiserID
                 //                                         : widget.organiserID
                 //                                                 .isNotEmpty
                 //                                             ? widget.organiserID
                 //                                             : organiserID,
                 //                                 promoterID: widget.promoterID,
                 //                                 totalEntranceCount:
                 //                                     totalEntranceCount,
                 //                                 totalTableCount: totalTableCount);
                 //                           }
                 //                         } else {
                 //                           Get.to(PhoneLogin(
                 //                             eventID: widget.eventID,
                 //                           ));
                 //                         }
                 //                       },
                 //                       child: Column(
                 //                         mainAxisAlignment:
                 //                             MainAxisAlignment.center,
                 //                         children: [
                 //                           Text(
                 //                             '₹ ${tablePrice + entryPrice}',
                 //                             style: GoogleFonts.ubuntu(
                 //                               color: Colors.white,
                 //                               fontSize: 45.sp,
                 //                             ),
                 //                           ),
                 //                           Text(
                 //                             tablePrice + entryPrice > 0
                 //                                 ? 'Tap to Pay'
                 //                                 : 'Tap to Book',
                 //                             style: GoogleFonts.ubuntu(
                 //                               color: Colors.white,
                 //                             ),
                 //                           )
                 //                         ],
                 //                       ),
                 //                     );
                 //                   },
                 //                 ),
                 //               ),
                 //             ),
                 //           ),
                 //         ],
                 //       ),
                 //     ).paddingAll(40.w),
                 //   ],
                 // )
               ],
             ),
          );
        },

      ),
      bottomNavigationBar: Container(
       height: 120,
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         crossAxisAlignment: CrossAxisAlignment.center,
         children: [
           Text(
             'Total',
             style: GoogleFonts.merriweather(
               fontSize: 60.sp,
               color: Colors.white,
             ),
           ).paddingOnly(left: 60.w),
           Align(
             alignment: Alignment.bottomRight,
             child: Column(
               children: [
                 Container(
                   decoration: BoxDecoration(
                     boxShadow: [
                       BoxShadow(
                         offset: Offset(0, 1.h),
                         spreadRadius: 5.h,
                         blurRadius: 20.h,
                         color: Colors.deepPurple,
                       )
                     ],
                     color: Colors.orange,
                     borderRadius: BorderRadius.circular(15),
                   ),
                   // height: kIsWeb?350.h:150.h,
                   width: 350.w,
                   child: Center(
                     child: ValueListenableBuilder(
                       valueListenable: promoterId,
                       builder: (context, prId, child) =>
                        ValueListenableBuilder(
                         valueListenable: applyCoupon,
                         builder: (context,bool isApply, child) =>
                          ValueListenableBuilder(
                           valueListenable: couponDetail,
                           builder: (context,Map<String,dynamic>? value, child) =>
                            Consumer<EntryTableController>(
                             builder: (BuildContext context, EntryTableController data, Widget? child) => Center(
                               child: Consumer<EntryController>(
                                 builder: (context, entryData, child) {
                                   double tablePrice = 0.0;
                                   for (int i = 0; i < data.numTable.length; i++) {
                                     tablePrice += data.priceTable[i] * data.numTable[i];
                                   }
                                   double entryPrice = 0;
                                   for (var element in entryData.entryList) {
                                     entryPrice += element['bookingAmount'] * element['bookingCount'];
                                   }
                                   print('check table price and entry price is ${entryPrice} \n ${tablePrice}');
                                   if(isApply){
                                     double  discount = discountPercentage ;
                                     print('check discount is ${discount}');
                                     print('check discount is ${discountPercentage }');
                                     if(entryPrice != 0.0){
                                       print('check discount is ${entryPrice}');
                                       double price = entryPrice * discount;
                                       print('check amount is ${entryPrice - price}');
                                       double sub = entryPrice - price;
                                       totalAmount = sub ;
                                     }else{
                                       double price = tablePrice * discount;
                                       totalAmount =  tablePrice - price;
                                     }
                                   }

                                   return GestureDetector(
                                     onTap: () async {
                                       print('check promoter id ${promoterId.value}');
                                       if (uid() != null) {
                                         Box eventBox = await HiveDB.hiveOpenEventBox();
                                         final organiserID = eventBox.get(widget.eventID) ?? '';
                                         //below code is commented to check promotion and organiser
                                         List tableData = [];
                                         if (tablePrice > 0) {
                                           tableData = List.generate(data.tableName.length, (int index) => []);
                                           for (int i = 0; i < data.tableName.length; i++) {
                                             tableData[i] = {
                                               'tableID': randomAlphaNumeric(5).toUpperCase(),
                                               'tableName': data.tableName[i],
                                               'tableNum': data.numTable[i],
                                               'tableLeft': data.numTable[i],
                                               'tablePrice': data.priceTable[i]
                                             };
                                           }
                                         }
                                         int totalEntranceCount = 0;
                                         int totalTableCount = 0;
                                         for (int i = 0; i < data.numTable.length; i++) {
                                           totalTableCount += int.parse(data.numTable[i].toString());
                                         }
                                         for (var element in entryData.entryList) {
                                           totalEntranceCount += int.parse(element['bookingCount'].toString());
                                         }
                                         final double amount = tablePrice + entryPrice;
                                         double couponDiscount = 0;
                                         if (value != null && value['data']['discount'] != null) {
                                           couponDiscount = double.parse(value['data']['discount'].toString()) / 100;
                                         }
                                         final double discountAmount =amount * couponDiscount ;
                                         final double couponCodeAmount = amount - discountAmount;
                                         print('check coupon amount value ${couponCodeAmount}');
                                         print('check promoter id is ${widget.promoterID}');
                                         print('check promoter id is ${tableData}');
                                         if (couponCodeAmount > 0) {
                                           await Get.to(
                                             Payments(
                                               couponCodeDetail: value,
                                               amount: couponCodeAmount,
                                               tableDataList: tableData,
                                               eventID: widget.eventID,
                                               clubID: widget.clubID,
                                               clubUID: widget.clubUID,
                                               entryList: bookingProvider.getBookingList,
                                               tableList: tableData,
                                               promoterID: prId.toString(),
                                               organiserID: widget.organiserID,
                                               totalEntranceCount: totalEntranceCount,
                                               totalTableCount: totalTableCount,
                                             ),
                                           );
                                         } else if (bookingProvider.getBookingList.isNotEmpty ||
                                             bookingProvider.getTableBookingList.isNotEmpty) {
                                           if (!context.mounted) return;
                                           paymentSuccess(context, null,
                                               tableDataList: tableData,
                                               amount: amount,
                                               couponDetail: value,
                                               clubUID: widget.clubUID,
                                               tableList: bookingProvider.getTableBookingList,
                                               eventID: widget.eventID,
                                               entryList: bookingProvider.getBookingList,
                                               clubID: widget.clubID,
                                               organiserID: eventOrganiserID.isNotEmpty
                                                   ? eventOrganiserID
                                                   : widget.organiserID.isNotEmpty
                                                   ? widget.organiserID
                                                   : organiserID,
                                               promoterID: prId,
                                               totalEntranceCount: totalEntranceCount,
                                               totalTableCount: totalTableCount
                                           );
                                         }
                                       } else {
                                         Get.to(PhoneLogin(
                                           eventID: widget.eventID,
                                         ));
                                       }
                                     },
                                     child: Padding(
                                       padding: const EdgeInsets.symmetric(vertical: 10),
                                       child: Column(
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         children: [
                                           Text(
                                             '₹ ${totalAmount == 0.0?tablePrice + entryPrice:totalAmount}',
                                             style: GoogleFonts.ubuntu(
                                               color: Colors.white,
                                               fontSize:45.sp,
                                             ),
                                           ),
                                           Text(
                                             tablePrice + entryPrice > 0 ? 'Tap to Pay' : 'Tap to Book',
                                             style: GoogleFonts.ubuntu(
                                               color: Colors.white,
                                             ),
                                           )
                                         ],
                                       ),
                                     ),
                                   );
                                 },
                               ),
                             ),
                           ),
                         ),
                       ),
                     ),
                   ),
                 ),
               ],
             ),
           ).paddingAll(10.w),
         ],
       ),
              ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

