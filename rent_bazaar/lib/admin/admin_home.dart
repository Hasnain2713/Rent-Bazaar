import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:rent_bazaar/admin/all_bookings.dart';
import 'package:rent_bazaar/admin/all_products.dart';
import 'package:rent_bazaar/admin/all_users.dart';
import 'package:rent_bazaar/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Image.asset(
              "assets/logo.png",
              height: 200,
            ),
            Center(
              child: Text(
                "Admin Panel",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  10,
                ),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllUsers(),
                    ),
                  );
                },
                leading: Icon(
                  CupertinoIcons.person_2,
                  color: Colors.red,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.red,
                ),
                title: Text(
                  "View all Users",
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  10,
                ),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllProducts(),
                    ),
                  );
                },
                leading: Icon(
                  CupertinoIcons.shopping_cart,
                  color: Colors.red,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.red,
                ),
                title: Text(
                  "View all Products",
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  10,
                ),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllBookings(),
                    ),
                  );
                },
                leading: Icon(
                  CupertinoIcons.calendar,
                  color: Colors.red,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.red,
                ),
                title: Text(
                  "View all Bookings",
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Card(
              color: Colors.red,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  10,
                ),
              ),
              child: ListTile(
                onTap: () async {
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  preferences.clear();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Login(),
                    ),
                    (route) => false,
                  );
                },
                leading: Icon(
                  CupertinoIcons.power,
                  color: Colors.white,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
                title: Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
