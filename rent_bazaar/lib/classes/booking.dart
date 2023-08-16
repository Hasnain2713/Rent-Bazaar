import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  String bookingID;
  String productId;
  String productName;
  String userEmail;
  String ownerEmail;
  String userName;
  String bracket;
  Timestamp date;

  Booking({
    required this.bookingID,
    required this.productId,
    required this.productName,
    required this.userEmail,
    required this.ownerEmail,
    required this.userName,
    required this.bracket,
    required this.date,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingID: json['bookingID'],
      productId: json['productId'],
      productName: json['productName'],
      userEmail: json['userEmail'],
      ownerEmail: json['ownerEmail'],
      userName: json['userName'],
      bracket: json['bracket'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingID': this.bookingID,
      'productId': this.productId,
      'productName': this.productName,
      'userEmail': this.userEmail,
      'ownerEmail': this.ownerEmail,
      'userName': this.userName,
      'bracket': this.bracket,
      'date': this.date,
    };
  }
}
