import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rent_bazaar/classes/booking.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllBookings extends StatefulWidget {
  const AllBookings({super.key});

  @override
  State<AllBookings> createState() => _AllBookingsState();
}

class _AllBookingsState extends State<AllBookings> {
  bool isLoading = true;

  List<Booking> previousBookings = [];

  @override
  void initState() {
    super.initState();
    getPreviousBookings();
  }

  getPreviousBookings() async {
    List<Booking> _bookings = [];
    var collection = FirebaseFirestore.instance.collection("bookings");
    var docsRef = await collection.get();
    docsRef.docs.forEach((element) {
      Booking _booking = Booking.fromJson(element.data());

      _bookings.add(_booking);
    });
    setState(() {
      previousBookings = _bookings;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.red,
        ),
        title: Text(
          "All Bookings",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: previousBookings.length,
                      itemBuilder: (context, index) {
                        Booking booking = previousBookings[index];

                        return Card(
                          child: ListTile(
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        "Cancel Booking",
                                      ),
                                      content: Text(
                                        "Are you sure you want to cancel this booking? These days (${previousBookings[index].bracket}) will become available for people to book.",
                                      ),
                                      actions: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "No",
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            Fluttertoast.showToast(
                                              msg:
                                                  "Cancelling booking... Please wait.",
                                            );
                                            var docs = await FirebaseFirestore
                                                .instance
                                                .collection("bookings")
                                                .where(
                                                  "bookingID",
                                                  isEqualTo:
                                                      previousBookings[index]
                                                          .bookingID,
                                                )
                                                .get();
                                            docs.docs.forEach((element) async {
                                              await FirebaseFirestore.instance
                                                  .collection("bookings")
                                                  .doc(element.id)
                                                  .delete();
                                            });
                                            Navigator.pop(context);
                                            setState(() {
                                              previousBookings = [];
                                            });
                                            getPreviousBookings();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Cancel Booking",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            onTap: () {},
                            title: Text(
                              booking.productName,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "For: " +
                                      DateFormat.MMMMEEEEd().format(
                                        booking.date.toDate(),
                                      ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "By: " + booking.userEmail,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "From: " + booking.ownerEmail,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
