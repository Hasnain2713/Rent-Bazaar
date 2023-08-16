class Product {
  String id;
  String title;
  String averageCost;
  String rentPerDay;
  String imageURL;
  String userEmail;
  String description;

  Product({
    required this.id,
    required this.title,
    required this.averageCost,
    required this.rentPerDay,
    required this.imageURL,
    required this.userEmail,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      averageCost: json['averageCost'],
      rentPerDay: json['rentPerDay'],
      imageURL: json['imageURL'],
      userEmail: json['userEmail'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "averageCost": averageCost,
      "rentPerDay": rentPerDay,
      "imageURL": imageURL,
      "userEmail": userEmail,
      "description": description,
    };
  }
}
