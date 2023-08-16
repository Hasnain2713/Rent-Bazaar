import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rent_bazaar/admin/admin_home.dart';
import 'package:rent_bazaar/firebase_options.dart';
import 'package:rent_bazaar/home.dart';
import 'package:rent_bazaar/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Widget homeScreen = HomePage();
  if (prefs.getString("email") != null) {
    if (prefs.getString("email") == "admin@rentbazaar.com") {
      homeScreen = AdminHome();
    }
  }
  runApp(MyApp(
    homeScreen: homeScreen,
  ));
}

class MyApp extends StatelessWidget {
  Widget homeScreen;

  MyApp({required this.homeScreen});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: homeScreen,
    );
  }
}
