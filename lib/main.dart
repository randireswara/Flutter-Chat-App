import 'package:chat_app/app/controllers/auth_controller.dart';
import 'package:chat_app/app/utilz/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await GetStorage.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthC = Get.put(AuthController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthC.firstInitialized(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Obx(
              () => GetMaterialApp(
                title: "ChatApp",
                initialRoute: AuthC.isSkipIntro.isTrue
                    ? AuthC.isAuth.isTrue
                        ? Routes.HOME
                        : Routes.LOGIN
                    : Routes.INTRODUCTION,
                getPages: AppPages.routes,
              ),
            );
          }

          return SplashScreen();
        });
  }
}
