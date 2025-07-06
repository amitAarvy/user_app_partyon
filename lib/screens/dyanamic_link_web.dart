import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web/web.dart';
import 'package:get/get_core/src/get_main.dart';
import 'bottom-screens.dart';
import 'events/book_events.dart'; // new, preferred style, as you migrate to package:web


// http://localhost:53565/#/Bookingevent?eventID=98909&clubUID=567890u8


  class Bookingevent extends StatefulWidget {
  const Bookingevent({super.key});

  @override
  State<Bookingevent> createState() => _BookingeventState();
}

class _BookingeventState extends State<Bookingevent> {
  Map<String, String>? initialQueryParameters;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialQueryParameters = Uri.parse(window.location.href).queryParameters;
    print('dynamic link check is ${initialQueryParameters}');
    if(initialQueryParameters!.isNotEmpty){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.to(()=>BookEvents(clubUID: initialQueryParameters!['clubUid'].toString(), eventID: initialQueryParameters!['eventId'].toString()));
      });
    }else{
      Get.to(()=>BottomNavigationBarExampleApp());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
