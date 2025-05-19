import 'package:get/get.dart';

class IndexProvider extends GetxController {
  var index = 0.obs;

  void changeIndex(int val) {
    index.value = val;
  }
}
