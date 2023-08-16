class User {
  String email;
  String password;
  String name;
  String mobile;
  String cnicNumber;
  String cnicExpiry;
  String shippingAddress;
  double shippingLat;
  double shippingLng;
  String cnicFront;
  String cnicBack;
  String method;

  User({
    required this.email,
    required this.password,
    required this.name,
    required this.mobile,
    required this.cnicNumber,
    required this.cnicExpiry,
    required this.shippingAddress,
    required this.shippingLat,
    required this.shippingLng,
    required this.cnicFront,
    required this.cnicBack,
    required this.method,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json["email"],
      password: json["password"],
      name: json["name"],
      mobile: json["mobile"],
      cnicNumber: json["cnicNumber"],
      cnicExpiry: json["cnicExpiry"],
      shippingAddress: json["shippingAddress"],
      shippingLat: json["shippingLat"],
      shippingLng: json["shippingLng"],
      cnicFront: json["cnicFront"],
      cnicBack: json["cnicBack"],
      method: json["method"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
      "name": name,
      "mobile": mobile,
      "cnicNumber": cnicNumber,
      "cnicExpiry": cnicExpiry,
      "shippingAddress": shippingAddress,
      "shippingLat": shippingLat,
      "shippingLng": shippingLng,
      "cnicFront": cnicFront,
      "cnicBack": cnicBack,
      "method": method,
    };
  }
}
