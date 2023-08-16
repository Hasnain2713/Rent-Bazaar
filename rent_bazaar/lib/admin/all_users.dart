import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rent_bazaar/classes/user.dart';

class AllUsers extends StatefulWidget {
  const AllUsers({super.key});

  @override
  State<AllUsers> createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  Stream<QuerySnapshot<Map<String, dynamic>>> getParents() {
    return FirebaseFirestore.instance.collection("users").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 25,
          ),
          ListTile(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.red,
              ),
            ),
            title: Center(
              child: Text(
                "All Users",
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: getParents(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<User> allUsers = [];
                snapshot.data!.docs.forEach((element) {
                  print(element.data()['name']);
                  User _parent = User.fromJson(
                    element.data(),
                  );
                  allUsers.add(_parent);
                });
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.87,
                  child: ListView.builder(
                    itemCount: allUsers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                          ),
                          elevation: 4,
                          child: Column(
                            children: [
                              ListTile(
                                onTap: () {},
                                leading: Icon(
                                  Icons.person,
                                  color: Colors.red,
                                ),
                                trailing: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                            "Delete User",
                                          ),
                                          content: Text(
                                            "Are you sure you want to delete this user? All product and booking data associated to this user will be deleted.",
                                          ),
                                          actions: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
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
                                                  msg:
                                                      "Deleting User, this may take a while... Please wait.",
                                                );
                                                var docsProduct =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("products")
                                                        .where(
                                                          "userEmail",
                                                          isEqualTo:
                                                              allUsers[index]
                                                                  .email,
                                                        )
                                                        .get();
                                                docsProduct.docs
                                                    .forEach((element) async {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection("products")
                                                      .doc(element.id)
                                                      .delete();
                                                });
                                                var docsBooking =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("bookings")
                                                        .where(
                                                          "userEmail",
                                                          isEqualTo:
                                                              allUsers[index]
                                                                  .email,
                                                        )
                                                        .get();
                                                docsBooking.docs
                                                    .forEach((element) async {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection("bookings")
                                                      .doc(element.id)
                                                      .delete();
                                                });
                                                var docUser =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("users")
                                                        .where(
                                                          "email",
                                                          isEqualTo:
                                                              allUsers[index]
                                                                  .email,
                                                        )
                                                        .limit(1)
                                                        .get();

                                                await FirebaseFirestore.instance
                                                    .collection("users")
                                                    .doc(docUser.docs.first.id)
                                                    .delete();
                                                Navigator.pop(context);
                                                setState(() {
                                                  allUsers = [];
                                                });
                                                getParents();
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Delete User",
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
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      allUsers[index].name,
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "CNIC: " + allUsers[index].cnicNumber,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Address: " +
                                          allUsers[index].shippingAddress,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          allUsers[index].email,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return SizedBox(
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
