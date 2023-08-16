import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rent_bazaar/classes/booking.dart';
import 'package:rent_bazaar/classes/product.dart';
import 'package:rent_bazaar/home.dart';
import 'package:rent_bazaar/order_summary.dart';
import 'package:rent_bazaar/product_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class BookProduct extends StatefulWidget {
  Product bookingProduct;

  BookProduct({
    required this.bookingProduct,
  });

  @override
  State<BookProduct> createState() => _BookProductState();
}

class _BookProductState extends State<BookProduct> {
  DateTime? startDate;
  DateTime? endDate;

  String currentUsername = "";

  DateRangePickerController dateController = DateRangePickerController();

  List<DateTime> selectedDates = [];
  List<DateTime> blackoutDates = [];

  bool isLoading = true;

  @override
  void initState() {
    checkBlackouts();
    getCurrentUsername();
    super.initState();
  }

  getCurrentUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString("email");
    FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() {
          currentUsername = element.data()["name"];
        });
      });
    });
  }

  checkBlackouts() {
    FirebaseFirestore.instance
        .collection("bookings")
        .where("productId", isEqualTo: widget.bookingProduct.id)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        Booking booking = Booking.fromJson(element.data());
        setState(() {
          blackoutDates.add(booking.date.toDate());
        });
      });
      setState(() {
        isLoading = false;
      });
    });
  }

  void onSubmit(value) {
    setState(
      () {
        if (value is PickerDateRange) {
          setState(() {
            startDate = value.startDate;
            endDate = value.endDate;
          });
          if (endDate != null) {
            List<DateTime> dates = [];
            int differenceInDays = endDate!.difference(startDate!).inDays;
            bool hasBlackout = false;
            DateTime? blackoutStopper;
            for (int i = 0; i <= differenceInDays; i++) {
              DateTime currentDate = startDate!.add(Duration(days: i));
              if (blackoutDates.contains(currentDate)) {
                hasBlackout = true;
                blackoutStopper = currentDate;
                endDate = blackoutStopper.subtract(
                  Duration(
                    days: 1,
                  ),
                );
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        "Blackout Error",
                      ),
                      content: Text(
                        "You have selected a range that appears to have another booking in between. We have altered the end date to the last available date. Please verify before booking or select a different range. Your start date is ${DateFormat('yyyy-MM-dd').format(startDate!)} and your end date is ${DateFormat('yyyy-MM-dd').format(endDate!)}",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "OK",
                          ),
                        ),
                      ],
                    );
                  },
                );
                break;
              }
            }
            differenceInDays = endDate!.difference(startDate!).inDays;
            for (int i = 0; i <= differenceInDays; i++) {
              DateTime currentDate = startDate!.add(Duration(days: i));
              dates.add(
                  DateTime.parse(DateFormat('yyyy-MM-dd').format(currentDate)));
            }

            setState(() {
              dateController.selectedRange =
                  PickerDateRange(startDate, endDate);
              selectedDates = dates;
            });
            selectedDates.forEach((element) {
              print(element.day);
            });
            if (!hasBlackout) {
              Fluttertoast.showToast(
                  msg: "Dates are available! You can book now.");
            }
          } else {
            setState(() {
              selectedDates = [
                startDate!,
              ];
              endDate = value.startDate;
            });
          }
        }
      },
    );
  }

  formatDate(DateTime formattable) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(formattable);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.red,
        ),
        title: Text(
          "Book ${widget.bookingProduct.title}",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 25,
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                          ),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Terms & Conditions",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: "ProximaBold",
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 2.2,
                                        right: 5,
                                      ),
                                      child: Text(
                                        "1.",
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Please bring Rs." +
                                            ((25 / 100) *
                                                    int.parse(
                                                      widget.bookingProduct
                                                          .averageCost,
                                                    ))
                                                .toString() +
                                            " with you when picking up the product",
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 2.2,
                                        right: 5,
                                      ),
                                      child: Text(
                                        "2.",
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "If you fail to deliver the product back on day of submission, Extra rent for the next day will be charged.",
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 2.2,
                                        right: 5,
                                      ),
                                      child: Text(
                                        "3.",
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Bring your original CNIC for verification for pickup. Exchange will not happen if a valid CNIC is not presented.",
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Text(
                                  "Booking Date: ${selectedDates.isEmpty ? 'Not Specified' : formatDate(selectedDates.first)} - ${selectedDates.isEmpty ? 'Not Specified' : formatDate(selectedDates.last)}",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SfDateRangePicker(
                          controller: dateController,
                          showActionButtons: true,
                          selectionMode: DateRangePickerSelectionMode.range,
                          monthViewSettings: DateRangePickerMonthViewSettings(
                            blackoutDates: blackoutDates,
                            showTrailingAndLeadingDates: true,
                          ),
                          selectionTextStyle:
                              const TextStyle(color: Colors.white),
                          selectionColor: Colors.red,
                          startRangeSelectionColor: Colors.red,
                          endRangeSelectionColor: Colors.red,
                          rangeSelectionColor: Colors.red.withOpacity(
                            0.5,
                          ),
                          confirmText: "Submit Dates",
                          cancelText: '',
                          onSubmit: onSubmit,
                          todayHighlightColor: Colors.transparent,
                          minDate: DateTime.now().add(
                            Duration(
                              days: 1,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () {
                            if (selectedDates.isEmpty) {
                              Fluttertoast.showToast(
                                msg:
                                    "Please select a date or a range by clicking the submit dates button.",
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Booking"),
                                    content: Text(
                                      "You are about to book ${widget.bookingProduct.title} from ${formatDate(selectedDates.first)} to ${formatDate(selectedDates.last)}. Do you confirm?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (_) => OrderSummary(
                                                bookingProduct:
                                                    widget.bookingProduct,
                                                currentUsername:
                                                    currentUsername,
                                                selectedDates: selectedDates,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text("Confirm"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
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
                                    "Checkout",
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
