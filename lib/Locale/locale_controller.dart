import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';


class MyLocaleController extends GetxController {
  SharedPreferences? sharedPref;

  // Define a default locale in case SharedPreferences is not initialized yet
  Locale initialLang = Locale("en");

  @override
  void onInit() {
    super.onInit();
    // Initialize SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      sharedPref = prefs;
      // Update the initializing locale based on the stored language in SharedPreferences
      String? storedLanguage = sharedPref!.getString("lang");
      if (storedLanguage != null) {
        initialLang = Locale(storedLanguage);
      }
      // Rebuild the UI with the correct language
      update();
    });
  }

  //Locale
  void changeLanguage(String codeLanguage) {
    Locale locale = Locale(codeLanguage);
    // Update language in SharedPreferences
    sharedPref?.setString("lang", codeLanguage);
    // Update the locale used by Get to trigger UI updates
    Get.updateLocale(locale);
  }
}




