import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:rent_bazaar/add_product.dart';
import 'package:rent_bazaar/classes/product.dart';
import 'package:rent_bazaar/component/product_card.dart';
import 'package:rent_bazaar/login.dart';
import 'package:rent_bazaar/report_screen.dart';
import 'package:rent_bazaar/view_bookings.dart';
import 'package:rent_bazaar/view_products.dart';
import 'package:rent_bazaar/view_rented_items.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool ischecked = true;

  String email = "";

  List<Product> pageProducts = [];

  @override
  void initState() {
    super.initState();
    getEmail();
    getAllProducts();
  }

  getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString("email")!;
    });
  }

  getAllProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var collection = FirebaseFirestore.instance.collection('products');
    if (prefs.getString("email") == null) {
      var docSnapshot = await collection.get();
      List<Product> products = [];
      print(docSnapshot.docs);
      docSnapshot.docs.forEach((element) {
        Product fetchedProd = Product.fromJson(element.data());
        products.add(fetchedProd);
      });
      setState(() {
        pageProducts = products;
      });
    } else {
      var docSnapshot = await collection
          .where(
            "userEmail",
            isNotEqualTo: prefs.getString(
              "email",
            ),
          )
          .get();
      List<Product> products = [];
      docSnapshot.docs.forEach((element) {
        Product fetchedProd = Product.fromJson(element.data());
        products.add(fetchedProd);
      });
      setState(() {
        pageProducts = products;
      });
    }
  }

  searchProducts(String query) async {
    if (query.trim() != "") {
      setState(() {
        pageProducts = [];
      });
      var collection = FirebaseFirestore.instance.collection('products');
      var docSnapshot =
          await collection.where("titleAsArray", arrayContains: query).get();
      List<Product> products = [];
      print(docSnapshot.docs);
      docSnapshot.docs.forEach((element) {
        Product fetchedProd = Product.fromJson(element.data());
        products.add(fetchedProd);
      });
      setState(() {
        pageProducts = products;
      });
    } else {
      getAllProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.red),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Rent Bazaar Home",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.red,
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Text(
              email,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            if (email != "")
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddProduct(),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(
                    "Add Products",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  leading: Icon(
                    Icons.group,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            if (email != "")
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewProducts(),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(
                    "View Products",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  leading: Icon(
                    Icons.shop,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            if (email != "")
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewRentedItems(),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(
                    "View Rented Items",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  leading: Icon(
                    Icons.shopping_bag,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            if (email != "")
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewBookings(),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(
                    "View Bookings",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  leading: Icon(
                    Icons.event_busy,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            if (email != "")
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportScreen(
                        attenderEmail: email,
                      ),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(
                    "Report",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  leading: Icon(
                    Icons.flag,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            if (email != "")
              GestureDetector(
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.clear();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Login(),
                    ),
                    (route) => false,
                  );
                },
                child: ListTile(
                  title: Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  leading: Icon(
                    Icons.power_settings_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            if (email == "")
              GestureDetector(
                onTap: () async {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Login(),
                    ),
                    (route) => false,
                  );
                },
                child: ListTile(
                  title: Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  leading: Icon(
                    Icons.power_settings_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.8),
                    spreadRadius: -10,
                    blurRadius: 20,
                    offset: Offset(1, 4),
                  )
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  searchProducts(value);
                },
                cursorColor: Colors.grey,
                decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: BorderSide.none),
                    hintText: 'Search Item',
                    hintStyle:
                        const TextStyle(color: Colors.grey, fontSize: 15),
                    contentPadding: EdgeInsets.only(top: 20),
                    prefixIcon: Container(
                      width: 70,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 15,
                          ),
                          Icon(
                            Icons.search,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.00,
                childAspectRatio: 0.85,
                mainAxisSpacing: 1,
                crossAxisSpacing: 0,
              ),
              itemCount: pageProducts.length,
              itemBuilder: (context, index) {
                return CardProductWidget(
                  product: pageProducts[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
