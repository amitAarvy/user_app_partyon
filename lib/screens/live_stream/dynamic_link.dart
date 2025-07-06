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
        String isVenue = deepLink.queryParameters['isVenue'] ?? '';
        String fallBackUrl = deepLink.queryParameters['fallbackUrl'] ?? '';
        print('check it event id ${eventID}');
        print('check it event id ${organiserID}');
        print('check it event id ${promoterID}');
        print('check it event id ${clubUID}');
        print('check it event id ${isVenue}');

        if (eventID.isNotEmpty) {
          if(isVenue.toString() == 'true'){
            final querySnapshot = await FirebaseFirestore.instance.collection('VenueAnalysis').get();

            final matchingDocs = querySnapshot.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['isVenue'].toString() == 'true' &&
                  data['eventId'].toString() == eventID;
            }).toList();

            if (matchingDocs.isEmpty) {
              print("No matching document found.");
              return;
            }

            final doc = matchingDocs.first;
            final docId = doc.id;
            final docData = doc.data() as Map<String, dynamic>;

            final currentClick = (docData['noOfClick'] ?? 0) as int;
            final List<dynamic> noOfClickList = List.from(docData['noOfClickList'] ?? []);

            final String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

            bool foundToday = false;

            for (int i = 0; i < noOfClickList.length; i++) {
              final item = noOfClickList[i];
              final itemDate = (item['date'] as Timestamp).toDate();
              final itemStr = DateFormat('yyyy-MM-dd').format(itemDate);

              if (itemStr == todayStr) {
                noOfClickList[i]['click'] = (item['click'] ?? 0) + 1;
                foundToday = true;
                break;
              }
            }

            if (!foundToday) {
              noOfClickList.add({
                'date': Timestamp.now(),
                'click': 1,
              });
            }

            await FirebaseFirestore.instance
                .collection('VenueAnalysis')
                .doc(docId)
                .update({
              'noOfClick': currentClick + 1,
              'noOfClickList': noOfClickList,
            });
          }
          if (promoterID != null ) {
            final querySnapshot = await FirebaseFirestore.instance.collection('PrAnalytics').get();

            final matchingDocs = querySnapshot.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['prId'].toString() == promoterID &&
                  data['eventId'].toString() == eventID;
            }).toList();

            if (matchingDocs.isEmpty) {
              print("No matching document found.");
              return;
            }

            final doc = matchingDocs.first;
            final docId = doc.id;
            final docData = doc.data() as Map<String, dynamic>;

            final currentClick = (docData['noOfClick'] ?? 0) as int;
            final List<dynamic> noOfClickList = List.from(docData['noOfClickList'] ?? []);

            final String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

            bool foundToday = false;

            for (int i = 0; i < noOfClickList.length; i++) {
              final item = noOfClickList[i];
              final itemDate = (item['date'] as Timestamp).toDate();
              final itemStr = DateFormat('yyyy-MM-dd').format(itemDate);

              if (itemStr == todayStr) {
                noOfClickList[i]['click'] = (item['click'] ?? 0) + 1;
                foundToday = true;
                break;
              }
            }

            if (!foundToday) {
              noOfClickList.add({
                'date': Timestamp.now(),
                'click': 1,
              });
            }

            await FirebaseFirestore.instance
                .collection('PrAnalytics')
                .doc(docId)
                .update({
              'noOfClick': currentClick + 1,
              'noOfClickList': noOfClickList,
            });
          }
          Box eventBox = await HiveDB.hiveOpenEventBox();
          HiveDB.putKey(eventBox, eventID, organiserID);
          Get.to(
              BookEvents(
                clubUID: clubUID,
                eventID: eventID,
                organiserID: organiserID,
                promoterID: promoterID,
                isVenue: isVenue.toString()=='true'?true:false,
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
