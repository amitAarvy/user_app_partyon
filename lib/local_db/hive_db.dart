import 'package:hive/hive.dart';

//Hive DB functions to create boxes and put and get keys
class HiveDB {
  static hiveOpenUserBox() async => await Hive.openBox('userBox');

  static hiveOpenEventBox() async => await Hive.openBox('eventBox');

  static hiveOpenCity() async => await Hive.openBox('cityBox');

  static putKey(Box box, String key, dynamic value) async =>
      await box.put(key, value);

  static getKey(Box box, String key) async => await box.get(key);
}
