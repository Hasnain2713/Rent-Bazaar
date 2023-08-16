import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:rent_bazaar/add_product.dart';
import 'package:rent_bazaar/classes/product.dart';
import 'package:rent_bazaar/component/product_card.dart';
import 'package:rent_bazaar/edit_product.dart';
import 'package:rent_bazaar/home.dart';
import 'package:rent_bazaar/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewProducts extends StatefulWidget {
  const ViewProducts({super.key});

  @override
  State<ViewProducts> createState() => _ViewProductsState();
}

class _ViewProductsState extends State<ViewProducts> {
  bool ischecked = true;

  String email = "";

  @override
  void initState() {
    super.initState();
    getEmail();
  }

  getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString("email")!;
    });
  }

  Future<List<Product>> getOwnerProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var collection = FirebaseFirestore.instance.collection('products');
    var docSnapshot = await collection
        .where(
          "userEmail",
          isEqualTo: prefs.getString(
            "email",
          ),
        )
        .get();
    List<Product> products = [];
    docSnapshot.docs.forEach((element) {
      Product fetchedProd = Product.fromJson(element.data());
      products.add(fetchedProd);
    });
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.red),
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(),
              ),
              (route) => false,
            );
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.red,
          ),
        ),
        elevation: 0,
        title: Text(
          "Your Products",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder<List<Product>>(
        future: getOwnerProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 5,
                  ),
                  child: Card(
                    elevation: 2,
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            snapshot.data![index].imageURL,
                            height: 100,
                          ),
                        ),
                      ),
                      title: Text(
                        snapshot.data![index].title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(
                          top: 5.0,
                          bottom: 5.0,
                        ),
                        child: Text(
                          snapshot.data![index].description,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                      trailing: Wrap(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProduct(
                                    productID: snapshot.data![index].id,
                                  ),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.edit,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      "Delete Product",
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                    content: Text(
                                      "Are you sure you want to delete this product?",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection("products")
                                              .doc(snapshot.data![index].id)
                                              .delete();
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(
              color: Colors.red,
            ),
          );
        },
      ),
    );
  }
}
