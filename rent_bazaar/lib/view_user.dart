import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:rent_bazaar/classes/user.dart';
import 'package:rent_bazaar/view_photo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewUser extends StatefulWidget {
  String userEmail;

  ViewUser({required this.userEmail});

  @override
  State<ViewUser> createState() => _ViewUserState();
}

class _ViewUserState extends State<ViewUser> {
  User? owner;

  @override
  void initState() {
    super.initState();
    getOwner();
  }

  getOwner() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String currentUser = preferences.getString("email")!;
    var collection = FirebaseFirestore.instance.collection('users');
    var docSnapshot = await collection
        .where(
          "email",
          isEqualTo: widget.userEmail,
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: owner == null
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.red,
                ),
              )
            : SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
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
                              "User Info",
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
                          // ListTile(
                          //   onTap: () {
                          //     // Navigator.push(
                          //     //   context,
                          //     //   MaterialPageRoute(
                          //     //     builder: (context) => MapScreen(
                          //     //       latitude: owner!.shippingLat,
                          //     //       longitude: owner!.shippingLng,
                          //     //       name: owner!.name,
                          //     //     ),
                          //     //   ),
                          //     // );
                          //   },
                          //   title: Text(
                          //     "Address",
                          //     style: TextStyle(
                          //       color: Colors.grey,
                          //       fontSize: 12,
                          //     ),
                          //   ),
                          //   subtitle: Text(
                          //     owner!.shippingAddress,
                          //     style: TextStyle(
                          //       color: Colors.red,
                          //       fontSize: 15,
                          //     ),
                          //   ),
                          //   // trailing: Icon(
                          //   //   Icons.location_on,
                          //   //   color: Colors.red,
                          //   //   size: 30,
                          //   // ),
                          // ),
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
              ),
      ),
    );
  }
}
