import 'package:get/get.dart';

class SearchGetX extends GetxController {
  var search = "".obs;

  updateSearch(String val) => search.value = val;
}

class SearchViewController extends GetxController {
  var search = "".obs;
  var radioVal = "clubName".obs;

  updateSearch(String val) => search.value = val;

  updateRadio(String val) => radioVal.value = val;
}
