import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rent_bazaar/classes/booking.dart';
import 'package:rent_bazaar/classes/product.dart';
import 'package:rent_bazaar/classes/rented_product.dart';
import 'package:rent_bazaar/product_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewRentedItems extends StatefulWidget {
  const ViewRentedItems({super.key});

  @override
  State<ViewRentedItems> createState() => _ViewRentedItemsState();
}

class _ViewRentedItemsState extends State<ViewRentedItems> {
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
    var docSnapshot = collection
        .where("userEmail", isEqualTo: email)
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
          "Rented Items",
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
                            "Are you sure you want to cancel this booking? These days (${rentedProducts[index].bracket}) will become available for other people to book.",
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
                                  msg: "Cancelling booking... Please wait.",
                                );
                                var docs = await FirebaseFirestore.instance
                                    .collection("bookings")
                                    .where(
                                      "bookingID",
                                      isEqualTo:
                                          rentedProducts[index].bookingID,
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
                                  rentedProducts = [];
                                });
                                getRentedProducts();
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
                onTap: () {
                  FirebaseFirestore.instance
                      .collection("products")
                      .doc(rentedProducts[index].productId)
                      .get()
                      .then((value) {
                    Product product = Product.fromJson(value.data()!);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetails(product: product),
                      ),
                    );
                  });
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
