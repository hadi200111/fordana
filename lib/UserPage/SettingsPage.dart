import 'package:CampusConnect/Locale/locale_controller.dart';
import 'package:CampusConnect/UserPage/ChangePasswordPage.dart';
import 'package:CampusConnect/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkModeEnabled = false;
  String selectedLanguage = 'English';
  bool areNotificationsEnabled = true;
  bool isAutoSaveEnabled = false;
  bool isLocationEnabled = true;
  bool isLockedApp = false;
  bool useFingerPrint = true;
  double fontSize = 16;

  List<Map<String, String>> languageItems = [];

  @override
  void initState() {
    super.initState();
    updateLanguageItems();
  }

  void updateLanguageItems() {
    setState(() {
      languageItems = [
        {'value': 'English', 'text': 'english'.tr},
        {'value': 'Arabic', 'text': 'arabic'.tr},
        {'value': 'Spanish', 'text': 'spanish'.tr},
        {'value': 'French', 'text': 'french'.tr},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    MyLocaleController controllerLang = Get.find();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple.shade600,
        title: Text(
          "settings".tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 8.0), // Add padding to the top
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.dark_mode_outlined,
                    color: Colors.deepPurple.shade400,
                    size: 30,
                  ),
                  title: Text("dark".tr),
                  subtitle: Text("dark1".tr),
                  trailing: Switch(
                    value: isDarkModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        isDarkModeEnabled = value;
                        // Perform action to change theme to dark mode
                        MyApp.themeNotifier.value = MyApp.themeNotifier.value == ThemeMode.light
                            ? ThemeMode.dark
                            : ThemeMode.light;
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.language_outlined,
                    color: Colors.deepPurple.shade400,
                    size: 30,
                  ),
                  title: Text("language".tr),
                  subtitle: DropdownButton<String>(
                    value: selectedLanguage,
                    onChanged: (newValue) {
                      setState(() {
                        selectedLanguage = newValue!;
                        if (selectedLanguage == 'Arabic') {
                          controllerLang.changeLanguage("ar");
                        } else {
                          controllerLang.changeLanguage("en");
                        }
                        updateLanguageItems();
                      });
                    },
                    items: languageItems.map((item) {
                      return DropdownMenuItem<String>(
                        value: item['value'],
                        child: Text(item['text']!),
                      );
                    }).toList(),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: Colors.deepPurple.shade400,
                    size: 30,
                  ),
                  title: Text("notification".tr),
                  subtitle: Text("noti".tr),
                  trailing: Switch(
                    value: areNotificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        areNotificationsEnabled = value;
                        // Perform action to enable or disable notifications
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.save_sharp,
                    color: Colors.deepPurple.shade400,
                    size: 30,
                  ),
                  title: Text("save".tr),
                  subtitle: Text("save1".tr),
                  trailing: Switch(
                    value: isAutoSaveEnabled,
                    onChanged: (value) {
                      setState(() {
                        isAutoSaveEnabled = value;
                        // Perform action to enable or disable auto save feature
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.location_on_sharp,
                    color: Colors.deepPurple.shade400,
                    size: 30,
                  ),
                  title: Text("location".tr),
                  subtitle: Text("location1".tr),
                  trailing: Switch(
                    value: isLocationEnabled,
                    onChanged: (value) {
                      setState(() {
                        isLocationEnabled = value;
                        // Perform action to enable or disable location services
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.text_fields,
                    color: Colors.deepPurple.shade500,
                    size: 30,
                  ),
                  title: Text("font".trArgs([fontSize.toInt().toString()])),
                  subtitle: Slider(
                    value: fontSize,
                    min: 12,
                    max: 24,
                    divisions: 4,
                    onChanged: (value) {
                      setState(() {
                        fontSize = value;
                        // Perform action to change font size
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.phonelink_lock_sharp,
                    color: Colors.deepPurple.shade400,
                    size: 30,
                  ),
                  title: Text("lock".tr),
                  subtitle: Text("lock1".tr),
                  trailing: Switch(
                    value: isLockedApp,
                    onChanged: (value) {
                      setState(() {
                        isLockedApp = value;
                        // Perform action to enable or disable location services
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.fingerprint_outlined,
                    color: Colors.deepPurple.shade400,
                    size: 30,
                  ),
                  title: Text("fingerprint".tr),
                  subtitle: Text("fingerprint1".tr),
                  trailing: Switch(
                    value: useFingerPrint,
                    onChanged: (value) {
                      setState(() {
                        useFingerPrint = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20), // Add some space above the button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                      );
                    },
                    icon: Icon(Icons.lock_outline),
                    label: Text("password".tr),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurple.shade400, // Text color
                    ),
                  ),
                ),
                SizedBox(height: 20), // Add some space below the button if needed
                // Add more settings as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}
