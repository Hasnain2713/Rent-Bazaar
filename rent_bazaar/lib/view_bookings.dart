import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rent_bazaar/classes/booking.dart';
import 'package:rent_bazaar/view_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewBookings extends StatefulWidget {
  const ViewBookings({super.key});

  @override
  State<ViewBookings> createState() => _ViewBookingsState();
}

class _ViewBookingsState extends State<ViewBookings> {
  List<Booking> rentedProducts = [];

  @override
  void initState() {
    super.initState();
    getRentedProducts();
  }

  getRentedProducts() async {
    List<Booking> _bookings = [];
    List<String> productIDs = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email")!;

    var collection = FirebaseFirestore.instance.collection("bookings");
    await collection
        .where("ownerEmail", isEqualTo: email)
        .orderBy("date")
        .get()
        .then(
      (value) {
        value.docs.forEach((element) {
          Booking thisBooking = Booking.fromJson(element.data());
          setState(() {
            rentedProducts.add(thisBooking);
          });
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.red,
        ),
        backgroundColor: Colors.white,
        title: Text(
          "Bookings",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: rentedProducts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewUser(
                        userEmail: rentedProducts[index].userEmail,
                      ),
                    ),
                  );
                },
                title: Text(
                  rentedProducts[index].productName,
                ),
                subtitle: Text(
                  DateFormat.MMMMEEEEd().format(
                    rentedProducts[index].date.toDate(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
