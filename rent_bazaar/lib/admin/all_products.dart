import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rent_bazaar/classes/booking.dart';
import 'package:rent_bazaar/classes/product.dart';
import 'package:rent_bazaar/component/product_card.dart';
import 'package:rent_bazaar/edit_product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllProducts extends StatefulWidget {
  const AllProducts({super.key});

  @override
  State<AllProducts> createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  bool isLoading = true;

  List<Product> pageProducts = [];

  @override
  void initState() {
    super.initState();
    getAllProducts();
  }

  getAllProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var collection = FirebaseFirestore.instance.collection('products');
    var docSnapshot = await collection.get();
    List<Product> products = [];
    print(docSnapshot.docs);
    docSnapshot.docs.forEach((element) {
      Product fetchedProd = Product.fromJson(element.data());
      products.add(fetchedProd);
    });
    setState(() {
      pageProducts = products;
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
          "All Products",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SizedBox(
              height: MediaQuery.of(context).size.height * 1,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200.00,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 0,
                ),
                itemCount: pageProducts.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      CardProductWidget(
                        product: pageProducts[index],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditProduct(
                                        productID: pageProducts[index].id,
                                        isAdmin: true,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  color: Colors.red,
                                  height: 40,
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                    child: Text(
                                      "Edit",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  Fluttertoast.showToast(
                                      msg: "Deleting product... please wait.");
                                  await FirebaseFirestore.instance
                                      .collection("products")
                                      .doc(pageProducts[index].id)
                                      .delete()
                                      .then((value) {
                                    setState(() {
                                      pageProducts = [];
                                      getAllProducts();
                                    });
                                    Fluttertoast.showToast(
                                        msg: "Product successfully deleted.");
                                  });
                                },
                                child: Container(
                                  color: Colors.red,
                                  height: 40,
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
