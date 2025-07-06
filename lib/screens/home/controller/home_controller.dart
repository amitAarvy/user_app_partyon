import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:user/utils/utils.dart';

String getFilterValue(String filter) {
  DateTime date = Timestamp.now().toDate();
  if (filter == 'category') {
    return homeController.category;
  } else if (filter == 'genre') {
    return homeController.genre;
  } else if (filter == 'events') {
    return '${date.day}-${date.month}-${date.year}';
  } else {
    return '';
  }
}


Future<void> getClubList() async {
  try {
    homeController.clubList = [];
    homeController.isLoading = true;
    print('homeCity is check ${ homeController.city}');
    QuerySnapshot querySnapshot;
    if( homeController.city =='All City'){
       querySnapshot = await FirebaseFirestore.instance
          .collection('Club')
          .where('activeStatus', isEqualTo: true)
          .where('businessCategory',isEqualTo: 1)
          .limit(100)
          .get();
    }else{
       querySnapshot = await FirebaseFirestore.instance
          .collection('Club')
          .where('activeStatus', isEqualTo: true)
          .where('city', isEqualTo: homeController.city)
          .where('businessCategory',isEqualTo: 1)
          .limit(50)
          .get();
    }

    // QuerySnapshot clubData =await FirebaseFirestore.instance
    //     .collection("Club")
    //     .where("businessCategory", isEqualTo: 1)
    //     .get();
    // List clubList = querySnapshot.docs;
    // clubList = clubList.where((element) {
    //   print('user is now ${element['clubUID']}');
    //   return clubData.docs
    //       .map((ele) => ele['clubUID'])
    //       .contains(element['clubUID']);
    // }).toList();

    print('check list is ${querySnapshot.docs}');

    for (DocumentSnapshot element in querySnapshot.docs) {
      bool isActive = getKeyValueFirestore(element, 'activeStatus') ?? false;
      // if (isActive ==true) {
        homeController.clubList.add(element);
      // }else{
      //   homeController.clubList.add(element);
      // }
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    homeController.isLoading = false;
  }
  homeController.isLoading = false;
}


class HomeController extends GetxController {
  final RxString _userName = "...".obs;
  final RxDouble _lat = 0.0.obs, _long = 0.0.obs;
  final RxString _city = "Select city".obs;
  final RxBool _showCity = false.obs;

  final RxBool _isLoading = true.obs;
  final RxString _filter = "".obs;
  final RxString _genre = "".obs;
  final RxBool _isEvents = false.obs;
  final RxString _category = "Club".obs;

  final RxBool _highToLow = false.obs;

  final RxBool _showEvent = false.obs;
  final RxBool _showFav = false.obs;

  final _pageCount = 1.obs;

  final RxList<DocumentSnapshot> _clubList = <DocumentSnapshot>[].obs;

  List<DocumentSnapshot> get clubList => _clubList;

  bool get isLoading => _isLoading.value;

  int get pageCount => _pageCount.value;

  String get userName => _userName.value;

  bool get showEvent => _showEvent.value;

  bool get showFav => _showFav.value;

  String get genre => _genre.value;

  bool get isEvents => _isEvents.value;

  bool get highToLow => _highToLow.value;

  String get city => _city.value;

  bool get showCity => _showCity.value;

  double get lat => _lat.value;

  double get long => _long.value;

  String get filter => _filter.value;

  String get category => _category.value;

  set isLoading(bool val) => _isLoading.value = val;

  set clubList(List<DocumentSnapshot> val) => _clubList.value = val;

  set pageCount(int val) => _pageCount.value = val;

  bool updateShowEvent(bool value) => _showEvent.value = value;

  bool updateShowFav(bool value) => _showFav.value = value;

  String updateFilter(String filter) => _filter.value = filter;

  bool updateIsEvents(bool isEvents) => _isEvents.value = isEvents;

  String updateGenre(String genre) => _genre.value = genre;

  String updateCategory(String category) => _category.value = category;

  updateUserName(String userName) {
    _userName.value = userName;
  }

  updateLatLong({required double lat, required double long}) {
    _lat.value = lat;
    _long.value = long;
  }

  updateCity(String data) {
    _city.value = data;
  }

  updateShowCity(bool data) {
    _showCity.value = data;
  }

  static Future<Map<String, dynamic>> getCoverImageDetails(
      DocumentSnapshot clubData) async {
    DocumentSnapshot? documentSnapshot = clubData;
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime tomorrow = today.add(const Duration(days: 1));
    bool isValidEventCover = false;
    String eventCover = '';
    try {
      eventCover =
          getKeyValueFirestore(documentSnapshot, 'eventCoverImages') ?? '';
      if (eventCover.isNotEmpty) {
        DateTime eventStartTime =
        documentSnapshot.get('eventStartTime').toDate();

        if (eventStartTime.isBefore(tomorrow) &&
            eventStartTime.isAfter(today)) {
          isValidEventCover = true;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return {'isValidEventCover': isValidEventCover, 'eventCover': eventCover};
  }
}

class FavList extends ChangeNotifier {
  List favList = [];

  updateFavList(List favList) {
    this.favList = [...favList];
    notifyListeners();
  }
}

class L2HProvider extends ChangeNotifier {
  List l2h = [];

  addToL2H(var val) {
    l2h.add(val);
    notifyListeners();
  }
}
