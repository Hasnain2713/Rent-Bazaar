import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rent_bazaar/book_product.dart';
import 'package:rent_bazaar/classes/product.dart';
import 'package:rent_bazaar/classes/user.dart';
import 'package:rent_bazaar/comments_screen.dart';
import 'package:rent_bazaar/home.dart';
import 'package:rent_bazaar/map_screen.dart';
import 'package:rent_bazaar/reviews_screen.dart';
import 'package:rent_bazaar/view_photo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetails extends StatefulWidget {
  Product product;

  ProductDetails({required this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  User? owner;
  User? rentee;

  String currentUser = "";

  bool canSeeOwner = false;

  checkCanSeeOwner() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email")!;
    var collection = FirebaseFirestore.instance.collection("bookings");
    var docSnapshot = await collection
        .where(
          "productId",
          isEqualTo: widget.product.id,
        )
        .where(
          "userEmail",
          isEqualTo: email,
        )
        .get();
    if (docSnapshot.size > 0) {
      setState(() {
        canSeeOwner = true;
      });
    }
  }

  getOwner() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      currentUser = preferences.getString("email")!;
    });
    var collection = FirebaseFirestore.instance.collection('users');
    var docSnapshot = await collection
        .where(
          "email",
          isEqualTo: widget.product.userEmail,
        )
        .limit(1)
        .get();
    setState(() {
      owner = User.fromJson(
        docSnapshot.docs.first.data(),
      );
    });
    print(owner!.name);
  }

  @override
  void initState() {
    getOwner();
    checkCanSeeOwner();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (_) => HomePage(),
          ),
          (route) => false,
        );
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Product Details", style: TextStyle(color: Colors.black)),
          leading: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => HomePage(),
                  ),
                  (route) => false,
                );
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.red,
              )),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: owner != null && owner!.email == currentUser
            ? null
            : FloatingActionButton.extended(
                backgroundColor: Colors.red,
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => BookProduct(
                        bookingProduct: widget.product,
                      ),
                    ),
                  );
                },
                label: Text("Book Product"),
                icon: Icon(
                  Icons.polymer_rounded,
                ),
              ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => PhotoViewer(
                                      imageProvider: NetworkImage(
                                        widget.product.imageURL,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  15,
                                ),
                                child: Image.network(
                                  widget.product.imageURL,
                                  // height: 3,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            // color: Colors.grey,
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 5,
                                  // height: MediaQuery.of(context).size.height*0.01,
                                ),
                                Text(
                                  maxLines: 2,
                                  widget.product.title.toUpperCase(),
                                  // _items[index].toString(),
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 25,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  widget.product.description,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "Rs. " + widget.product.rentPerDay,
                                          // _itemNum[index].toString(),
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                          ),
                                        ),
                                        Text(
                                          "Per Day",
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "Rs. " +
                                              ((25 / 100) *
                                                      int.parse(
                                                        widget.product
                                                            .averageCost,
                                                      ))
                                                  .toString(),
                                          // _itemNum[index].toString(),
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                          ),
                                        ),
                                        Text(
                                          "Security Deposit",
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => CommentsScreen(
                              productID: widget.product.id,
                              name: currentUser,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "View Comments",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => ProductReviewScreen(
                              productId: widget.product.id,
                              userEmail: currentUser,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "View Reviews",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                if (owner == null)
                  Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  ),
                if (canSeeOwner)
                  if (owner != null && owner!.email != currentUser)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  "Owner Info",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  "Name",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                subtitle: Text(
                                  owner!.name,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  "Email",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                subtitle: Text(
                                  owner!.email,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  "Phone",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                subtitle: Text(
                                  owner!.mobile,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 15,
                                  ),
                                ),
                                trailing: GestureDetector(
                                  onTap: () {
                                    launch(
                                      "https://wa.me/92${owner!.mobile}",
                                    );
                                  },
                                  child: Image.asset(
                                    "assets/whatsapp.png",
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  "CNIC Number",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                subtitle: Text(
                                  owner!.cnicNumber,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  "CNIC Expiry",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                subtitle: Text(
                                  owner!.cnicExpiry,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MapScreen(
                                        latitude: owner!.shippingLat,
                                        longitude: owner!.shippingLng,
                                        name: owner!.name,
                                      ),
                                    ),
                                  );
                                },
                                title: Text(
                                  "Address",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                subtitle: Text(
                                  owner!.shippingAddress,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 15,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 30,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  "Proof of CNIC",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                subtitle: Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (_) => PhotoViewer(
                                              imageProvider: NetworkImage(
                                                owner!.cnicFront,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Image.network(
                                        owner!.cnicFront,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (_) => PhotoViewer(
                                              imageProvider: NetworkImage(
                                                owner!.cnicBack,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Image.network(
                                        owner!.cnicBack,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                if (owner != null && owner!.email == currentUser)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Text(
                        "This Product is owned by you",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
