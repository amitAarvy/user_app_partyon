import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EntranceData {
  final String categoryName;
  final List<Map<String, String>> subCategory;

  EntranceData(this.categoryName, this.subCategory);
}

List<EntranceData> fetchEntranceData(List entranceList) {
  final entranceDataList = entranceList.map((entranceData) {
    final categoryName = entranceData['categoryName'] as String;
    final subCategory = List<Map<String, String>>.from(
      (entranceData['subCategory'] as List<dynamic>).map((subCategoryData) {
        final entryCategoryName =
        subCategoryData['entryCategoryName'].toString();
        final entryCategoryCount =
        subCategoryData['entryCategoryCount'].toString();
        final entryCategoryPrice =
        subCategoryData['entryCategoryPrice'].toString();
        final entryCategoryCountLeft =
        subCategoryData.containsKey('entryCategoryCountLeft')
            ? subCategoryData['entryCategoryCount'].toString()
            : entryCategoryCount;

        return {
          'entryCategoryName': entryCategoryName,
          'entryCategoryCount': entryCategoryCount,
          'entryCategoryPrice': entryCategoryPrice,
          'entryCategoryCountLeft': entryCategoryCountLeft,
        };
      }).toList(),
    );
    return EntranceData(categoryName, subCategory);
  }).toList();

  return entranceDataList;
}

class TableController extends ChangeNotifier {
  List numTable = List.generate(50, (int index) => 0);
  List priceTable = List.generate(50, (int index) => 0.0);

  List tableName = List.generate(50, (int index) => '');

  updateNumTable(int index, var val) {
    numTable[index] = val;
    notifyListeners();
  }

  updateTableName(int index, String name) {
    tableName[index] = name;
    notifyListeners();
  }

  updatePriceTable(int index, var val) {
    priceTable[index] = val;
    notifyListeners();
  }
}

class EntryTableController extends ChangeNotifier {
  List numTable = List.generate(50, (int index) => 0);
  List priceTable = List.generate(50, (int index) => 0.0);
  List tableName = List.generate(50, (int index) => '');
  List leftBooking = List.generate(50, (int index) => '');

  updateNumTable(int index, var val) {
    numTable[index] = val;
    notifyListeners();
  }

  updateTableName(int index, String name) {
    tableName[index] = name;
    notifyListeners();
  }

  updatePriceTable(int index, var val) {
    priceTable[index] = val;
    notifyListeners();
  }
  updateLeftTable(int index, var val) {
    leftBooking[index] = val;
    notifyListeners();
  }
}

class EntryController extends ChangeNotifier {
  List entryList = [];

  updatePriceEntryList(List updatedList) {
    entryList = [];
    entryList = List.from(updatedList);
    notifyListeners();
  }
}

class BookingProvider extends GetxController {
  final List<RxInt> _bookingCount = List.generate(30, (int index) => 0.obs);
  final _tableBookingList = [].obs;
  final _bookingList = [].obs;

  final _entranceBookingAmount = 0.0.obs;

  List get getBookingList => _bookingList;

  List get getTableBookingList => _tableBookingList;

  double get entranceBookingAmount => _entranceBookingAmount.value;


  int getBookingCount(int index) => _bookingCount[index].value;

   checkValue(index){
    print('check is total book event ${_bookingCount}');
    return _bookingCount;
  }

  double changeEntranceBookingAmount(double val) =>
      _entranceBookingAmount.value = val;

  void modifyBookingList(int categoryIndex, int subCategoryIndex,
      int bookingCount, double bookingAmount,
      {required String subCategoryName, required String categoryName}) {

    if (bookingCount > 0) {
      bool entryUpdated = false;
      for (int i = 0; i < _bookingList.length; i++) {
        if (_bookingList[i]['categoryIndex'] == categoryIndex &&
            _bookingList[i]['subCategoryIndex'] == subCategoryIndex) {
          _bookingList[i]['bookingCount'] = bookingCount;
          _bookingList[i]['bookingCountLeft'] = bookingCount;
          entryUpdated = true;
          break;
        }
      }
      if (!entryUpdated) {
        _bookingList.add({
          'categoryIndex': categoryIndex,
          'subCategoryIndex': subCategoryIndex,
          'bookingCount': bookingCount,
          'bookingCountLeft': bookingCount,
          'bookingAmount': bookingAmount,
          'categoryName': categoryName,
          'subCategoryName': subCategoryName,
        });
      }
    } else {
      _bookingList
          .removeWhere((element) => element['categoryIndex'] == categoryIndex);
    }
  }

  void modifyTableBookingList(
      {required int tableIndex,
        required int bookingCount,
        required double bookingAmount,
        required int seatsAvailable,
        required String tableName}) {
    if (bookingCount > 0) {
      bool entryUpdated = false;
      for (int i = 0; i < _tableBookingList.length; i++) {
        if (_tableBookingList[i]['tableIndex'] == tableIndex) {
          _tableBookingList[i]['bookingCount'] = bookingCount;
          _tableBookingList[i]['bookingCountLeft'] = bookingCount;
          entryUpdated = true;
          break;
        }
      }
      if (!entryUpdated) {
        _tableBookingList.add({
          'tableIndex': tableIndex,
          'bookingCount': bookingCount,
          'bookingCountLeft': bookingCount,
          'tablePrice': bookingAmount,
          'tableName': tableName,
          'seatsAvailable': seatsAvailable,
        });
      }
    } else {
      _tableBookingList
          .removeWhere((element) => element['tableIndex'] == tableIndex);
    }
  }

  int incBookingCount(int index) => ++_bookingCount[index].value;

  int decBookingCount(int index) => --_bookingCount[index].value;

  int changeBookingCount(int index, int val) =>
      _bookingCount[index].value = val;
}
