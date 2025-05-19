import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:user/local_db/hive_db.dart';
import 'package:user/screens/events/book_events.dart';

FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

class FirebaseDynamicLinkService {
  Future<void> retrieveDynamicLink(BuildContext context) async {
    try {
      final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri? deepLink = data?.link;

      if (deepLink != null) {
        if (deepLink.queryParameters.containsKey('videoId') && deepLink.queryParameters.containsKey('artistId')) {
          String? videoId = deepLink.queryParameters['videoId'];
          String? artistId = deepLink.queryParameters['artistId'];
          if (kDebugMode) {
            print('video $videoId $artistId');
          }
          // Navigator.of(context).push(MaterialPageRoute(
          //     builder: (context) => editVideo(
          //           videoId: videoId,
          //           artistId: artistId,
          //         )));
        }
      } else {}

      // FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData dynamicLink) async {
      //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => editVideo()));
      // });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  static Future<String> createDynamicLink(
      bool short,
      String channel,
      String? artistId,
      ) async {
    String linkMessage;

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://partyonn.page.link',
      link: Uri.parse(
        'https://partyonn.page.link.com?channel=$channel&artistId=${artistId.toString()}',
      ),
      androidParameters: const AndroidParameters(
        packageName: 'com.partyon.user',
      ),
    );

    final ShortDynamicLink url;
    url = await FirebaseDynamicLinks.instance.buildShortLink(
      parameters,
      shortLinkType: ShortDynamicLinkType.unguessable,
    );

    linkMessage = url.shortUrl.toString();
    return linkMessage;
  }
}

class FirebaseDynamicLinkEvent {
  static Future<void> retrieveDynamicLink(BuildContext context, Uri deepLink) async {
    try {
      if (deepLink.queryParameters.containsKey('eventID') && deepLink.queryParameters.containsKey('organiserID')) {
        String eventID = deepLink.queryParameters['eventID'] ?? '';
        String organiserID = deepLink.queryParameters['organiserID'] ?? '';
        String promoterID = deepLink.queryParameters['promoterID'] ?? '';
        String clubUID = deepLink.queryParameters['clubUID'] ?? '';
        String fallBackUrl = deepLink.queryParameters['fallbackUrl'] ?? '';

        if (eventID.isNotEmpty) {
          if(promoterID != null){
            var data = await FirebaseFirestore.instance.collection('PrAnalytics').get();
          List data1 =  data.docs.where((element) => element['prId'].toString() ==promoterID).where((e)=>e.id.toString()==eventID.toString()).toList();
            final docData = data1[0].data() as Map<String, dynamic>;
            if(docData.containsKey('noOfClickList') ==true){

            List noOfClick = data1[0]['noOfClickList']??[];
            String todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
            for (int i = 0; i < noOfClick.length; i++) {
              var entryDate = (noOfClick[i]['date'] as Timestamp).toDate();
              String entryDateStr = DateFormat('yyyy-MM-dd').format(entryDate);
              if (entryDateStr.toString() == todayString.toString()) {
                noOfClick[i]['click'] = int.parse(noOfClick[i]['click'].toString()) + 1;
                break;
              }
            }
            await FirebaseFirestore.instance.collection('PrAnalytics').doc(data1[0].id).update({
              "noOfClick": data1[0]['noOfClick']+1,
              "noOfClickList":noOfClick
            });
          }else{
              List noOfClick = [];
                noOfClick.add({
                  'date': DateTime.now(),
                  'click': 1,
                });
            await FirebaseFirestore.instance.collection('PrAnalytics').doc(data1[0].id).update({
              "noOfClick": data1[0]['noOfClick']+1,
              "noOfClickList":noOfClick
            });
            }
          }
          Box eventBox = await HiveDB.hiveOpenEventBox();
          HiveDB.putKey(eventBox, eventID, organiserID);
          Get.to(
              BookEvents(
            clubUID: clubUID,
            eventID: eventID,
            organiserID: organiserID,
            promoterID: promoterID,
           )
         );
        } else {
          Fluttertoast.showToast(msg: 'Event not found');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  static Future<String> createDynamicLink(
      bool short,
      String eventID,
      String? organiserID,
      ) async {
    String linkMessage;

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://partyonn.page.link',
      link: Uri.parse(
        'https://partyonn.page.link.com?eventID=$eventID&organiserID=${organiserID.toString()}',
      ),
      androidParameters: const AndroidParameters(packageName: 'com.partyon.user'),
      iosParameters: const IOSParameters(bundleId: 'hashtag.partyon.user'),
    );

    final ShortDynamicLink url;
    url = await FirebaseDynamicLinks.instance.buildShortLink(
      parameters,
      shortLinkType: ShortDynamicLinkType.unguessable,
    );

    linkMessage = url.shortUrl.toString();
    return linkMessage;
  }
}
