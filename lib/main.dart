import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'package:user/firebase_options.dart';
import 'package:user/screens/authentication/views/phone.dart';
import 'package:user/screens/authentication/views/user_info.dart';
import 'package:user/screens/bottom-screens.dart';
import 'package:user/screens/events/book_events_controller.dart';
import 'package:user/screens/home/view/home_view.dart';
import 'package:user/screens/home/controller/home_controller.dart';
import 'package:user/screens/live_stream/dynamic_link.dart';
import 'package:user/screens/welcome.dart';
import 'package:user/utils/dynamic_provider.dart';
import 'package:user/utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      name: 'MyApp',
      options: Platform.isIOS
          ? DefaultFirebaseOptions.ios
          : DefaultFirebaseOptions.android);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void _setSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setSystemUI();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(1080, 2340),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (BuildContext context, Widget? child) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: ShowOptions()),
              ChangeNotifierProvider.value(value: CityProvider()),
              // ChangeNotifierProvider.value(value: EntryTableController()),
              ChangeNotifierProvider.value(value: FavList()),
              ChangeNotifierProvider.value(value: L2HProvider()),
              // ChangeNotifierProvider.value(value: EntryController()),
              ChangeNotifierProvider(create: (_) => EntryController()),
              ChangeNotifierProvider(create: (_) => EntryTableController()),
            ],
            child: GetMaterialApp(
                builder: EasyLoading.init(),
                debugShowCheckedModeBanner: false,
                onInit: () async {
                  await Hive.initFlutter();
                  initDynamicLinks(BuildContext context) async {
                    PendingDynamicLinkData? data =
                    await FirebaseDynamicLinks.instance.getInitialLink();
                    Uri? deepLink = data?.link;
                    final Map<String, String>? queryParams =
                        deepLink?.queryParameters;
                    if (queryParams?.isNotEmpty == true) {
                      if (!context.mounted) return;
                      FirebaseDynamicLinkEvent.retrieveDynamicLink(
                          context, deepLink!);
                    }
                    FirebaseDynamicLinks.instance.onLink.listen(
                            (PendingDynamicLinkData dynamicLinkData) {
                          Uri deepLink = dynamicLinkData.link;
                          final Map<String, String> queryParams =
                              deepLink.queryParameters;
                          if (queryParams.isNotEmpty) {
                            FirebaseDynamicLinkEvent.retrieveDynamicLink(
                                context, deepLink);
                          }
                          debugPrint('DynamicLinks onLink $deepLink');
                        }, onError: (e) async {
                      debugPrint('DynamicLinks onError $e');
                    });
                  }
                  if (!context.mounted) return;
                  initDynamicLinks(context);
                },
                title: 'PartyOn User',
                theme: ThemeData(
                  useMaterial3: false,
                  primarySwatch: Colors.indigo,
                  textTheme: GoogleFonts.montserratTextTheme(
                    Theme.of(context).textTheme,
                  ),
                ),
                home: UpgradeAlert(
                  child: const Welcome(
                    initPage: InitPage(),
                  ),
                ))));
  }
}

class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  // Future<void> initCFL() async {
  //   final Cloudflare cloudflare = Cloudflare(
  //     accountId: c_accountID,
  //     token: c_token,
  //   );
  //   await cloudflare.init();
  // }

  Future<void> getHome() async {
    //if user found navigate to home else signup
    try {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(uid())
          .get()
          .then((DocumentSnapshot<Map<String, dynamic>> value) {
        if (value.exists) {
          Get.off(() => const BottomNavigationBarExampleApp());
        } else {
          Get.off(UserInfoData(
            email: FirebaseAuth.instance.currentUser?.email ?? '',
          ));
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      await Get.off(UserInfoData(
        email: FirebaseAuth.instance.currentUser?.email ?? '',
      ));
    }
  }

  @override
  void initState() {
    // initCFL();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser != null) {
        getHome();
      } else {
        Get.off(const PhoneLogin());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Container();
}
