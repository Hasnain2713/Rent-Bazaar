import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rent_bazaar/classes/booking.dart';
import 'package:rent_bazaar/classes/product.dart';
import 'package:rent_bazaar/home.dart';
import 'package:rent_bazaar/product_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderSummary extends StatefulWidget {
  Product bookingProduct;
  String currentUsername;
  List<DateTime> selectedDates;

  OrderSummary({
    required this.bookingProduct,
    required this.currentUsername,
    required this.selectedDates,
  });

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  bool isLoading = false;

  formatDate(DateTime formattable) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(formattable);
    return formattedDate;
  }

  bookNow() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      String bookingID = widget.bookingProduct.id +
          DateTime.now().millisecondsSinceEpoch.toString();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      widget.selectedDates.forEach((element) async {
        Booking newBookingDate = Booking(
          bookingID: bookingID,
          ownerEmail: widget.bookingProduct.userEmail,
          productId: widget.bookingProduct.id,
          productName: widget.bookingProduct.title,
          userEmail: prefs.getString("email")!,
          userName: widget.currentUsername,
          bracket:
              "${formatDate(widget.selectedDates.first)} till ${formatDate(widget.selectedDates.last)}",
          date: Timestamp.fromDate(element),
        );
        await FirebaseFirestore.instance
            .collection("bookings")
            .add(
              newBookingDate.toJson(),
            )
            .then((value) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
            msg: "Booking successful!",
          );
        }).catchError((error) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
            msg: "Booking failed! Please try again later.",
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
            (route) => false,
          );
          return;
        });
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetails(
            product: widget.bookingProduct,
          ),
        ),
        (route) => false,
      );
    }
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
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.red,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Order Summary",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Please check all details before placing order.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            "Booking Date:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            "${formatDate(widget.selectedDates.first)} till ${formatDate(widget.selectedDates.last)}",
                            style: TextStyle(),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            "Days Booked:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            "${widget.selectedDates.length}",
                            style: TextStyle(),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            "Total Rent:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            "Rs.${widget.selectedDates.length * int.parse(widget.bookingProduct.rentPerDay)} (Rs.${widget.bookingProduct.rentPerDay}/day)",
                            style: TextStyle(),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            "Amount to Pay:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            "Rs. " +
                                ((25 / 100) *
                                        int.parse(
                                          widget.bookingProduct.averageCost,
                                        ))
                                    .toString(),
                            style: TextStyle(),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            double remainder = ((25 / 100) *
                                    int.parse(
                                      widget.bookingProduct.averageCost,
                                    )) -
                                (widget.selectedDates.length *
                                    int.parse(
                                        widget.bookingProduct.rentPerDay));
                            String info = "You need to pay Rs." +
                                ((25 / 100) *
                                        int.parse(
                                          widget.bookingProduct.averageCost,
                                        ))
                                    .toString() +
                                " because the total cost of this product is Rs.${widget.bookingProduct.averageCost}. According to our policies, you have to pay 25% of the amount of the total cost for the product you are booking. After you return the product, ";
                            if (((25 / 100) *
                                        int.parse(
                                          widget.bookingProduct.averageCost,
                                        )) -
                                    (widget.selectedDates.length *
                                        int.parse(
                                            widget.bookingProduct.rentPerDay)) <
                                0) {
                              info +=
                                  "You will have to pay the owner ${remainder.abs()} more as rent.";
                            } else {
                              info += "The owner will give you $remainder back";
                            }
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return SimpleDialog(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Text(
                                          info,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 15.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "Okay",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.red,
                                size: 16,
                              ),
                              Center(
                                child: Text(
                                  "  How does this work?   ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          title: Text(
                            "Select Payment Method",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Radio(
                            value: "cod",
                            groupValue: "cod",
                            onChanged: (value) {},
                          ),
                          title: Text(
                            "Cash on Delivery",
                            style: TextStyle(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  if (isLoading)
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  if (!isLoading)
                    InkWell(
                      onTap: () {
                        bookNow();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              100,
                            ),
                          ),
                          color: Colors.red,
                          child: ListTile(
                            title: Center(
                              child: Text(
                                "Book Now",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_right,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
