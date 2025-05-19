import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class DynamicProvider extends GetxController {
  var id = "".obs;
  var city = "Select city".obs;

  changeId(String data) => id.value = data;
}

class CityProvider extends ChangeNotifier {}
