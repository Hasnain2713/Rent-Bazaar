import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:rent_bazaar/add_address.dart';
import 'package:rent_bazaar/login.dart';

import 'classes/user.dart';

class SignupScreen extends StatefulWidget {
  bool isGoogle;
  String email;
  String name;

  SignupScreen({
    required this.isGoogle,
    required this.email,
    required this.name,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController cnicNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  String address = "";

  double? lat;
  double? lng;

  String cnicExpiryDate = "Not Selected";

  bool isLoading = false;

  String? cnicFront;
  String? cnicBack;

  final _formKey = GlobalKey<FormState>();

  selectImageType(BuildContext context, bool isFront) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.white,
          child: Wrap(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  getImage(isFront, false);
                },
                child: ListTile(
                  leading: Icon(
                    CupertinoIcons.photo,
                    color: Colors.black,
                  ),
                  title: Text(
                    "Gallery",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  getImage(isFront, true);
                },
                child: ListTile(
                  leading: Icon(
                    CupertinoIcons.camera,
                    color: Colors.black,
                  ),
                  title: Text(
                    "Camera",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  getImage(bool isFront, bool isCamera) async {
    var image = await ImagePicker().pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 40);
    File imageF = File(image!.path);
    final bytes = imageF.readAsBytesSync().lengthInBytes;
    final kb = bytes / 1024;
    final mb = kb / 1024;
    if (mb > 10) {
      Fluttertoast.showToast(
        msg: "Image is larger than 5 mb, please upload a smaller image",
      );
    } else {
      setState(() {
        if (isFront) {
          cnicFront = image.path;
        } else {
          cnicBack = image.path;
        }
      });
    }
  }

  Future<String> uploadImageToFirebase(
      BuildContext context, imagePath, bool isFront) async {
    File imageFile = File(imagePath);
    await FirebaseStorage.instance
        .ref()
        .child('${nameController.text}/cnicFront')
        .putFile(imageFile)
        .then((fileUpload) {
      return fileUpload.ref.getDownloadURL();
    }).onError((error, stackTrace) {
      return "false";
    });
    return "false";
  }

  signup(BuildContext context) async {
    String cnicFrontURL = "";
    String cnicBackURL = "";
    if (_formKey.currentState!.validate()) {
      if (emailController.text == "admin@rentbazaar.com") {
        Fluttertoast.showToast(
          msg: "Please choose a different email address",
        );
        return;
      }
      if (address != "") {
        if (cnicFront != null) {
          if (cnicBack != null) {
            if (cnicExpiryDate != "Not Selected") {
              var collection = FirebaseFirestore.instance.collection('users');
              var docSnapshot = await collection
                  .where("email", isEqualTo: emailController.text)
                  .limit(1)
                  .get();
              if (docSnapshot.size == 0) {
                setState(() {
                  isLoading = true;
                });
                Fluttertoast.showToast(
                    msg: "Setting up your account, this may take a while...");
                File cnicFrontFile = File(cnicFront!);
                await FirebaseStorage.instance
                    .ref()
                    .child('${nameController.text}/cnicFront')
                    .putFile(cnicFrontFile)
                    .then((fileUpload) async {
                  cnicFrontURL = await fileUpload.ref.getDownloadURL();
                  File cnicBackFile = File(cnicBack!);
                  await FirebaseStorage.instance
                      .ref()
                      .child('${nameController.text}/cnicBack')
                      .putFile(cnicBackFile)
                      .then((fileUpload) async {
                    cnicBackURL = await fileUpload.ref.getDownloadURL();
                    Fluttertoast.showToast(
                        msg:
                            "Images uploaded successfully. Registering your details.");

                    final docUser =
                        FirebaseFirestore.instance.collection('users').doc();
                    User registeringUser = User(
                      email: emailController.text,
                      name: nameController.text,
                      password: passwordController.text,
                      method: widget.isGoogle ? "google" : "email",
                      cnicFront: cnicFrontURL,
                      mobile: mobileController.text,
                      cnicBack: cnicBackURL,
                      cnicExpiry: cnicExpiryDate,
                      cnicNumber: cnicNumberController.text,
                      shippingAddress: address,
                      shippingLat: lat!,
                      shippingLng: lng!,
                    );
                    await docUser
                        .set(registeringUser.toJson())
                        .onError((error, stackTrace) {
                      Fluttertoast.showToast(
                          msg:
                              "There is something wrong, please try again later!");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Login(),
                        ),
                      );
                    });
                    Fluttertoast.showToast(
                        msg: "Account registered! Please log in now!");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Login(),
                      ),
                    );
                  }).onError((error, stackTrace) {
                    Fluttertoast.showToast(
                        msg:
                            "An error occurred while signing you up, please try again later.");
                  });
                }).onError((error, stackTrace) {
                  Fluttertoast.showToast(
                      msg:
                          "An error occurred while signing you up, please try again later.");
                });
              } else {
                Fluttertoast.showToast(
                    msg:
                        "This email is already registered. Please try again later.");
              }
            } else {
              Fluttertoast.showToast(
                  msg: "Please select your CNIC expiry date");
            }
          } else {
            Fluttertoast.showToast(msg: "Please upload your CNIC back image");
          }
        } else {
          Fluttertoast.showToast(msg: "Please upload your CNIC front image");
        }
      } else {
        Fluttertoast.showToast(msg: "Please select your address");
      }
    }
  }

  selectCnicExpiry(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().add(
        Duration(
          days: 181,
        ),
      ),
      //which date will display when user open the picker
      firstDate: DateTime.now().add(
        Duration(
          days: 180,
        ),
      ),
      //what will be the previous supported year in picker
      lastDate: DateTime.now().add(
        Duration(
          days: 3650,
        ),
      ),
    ) //what will be the up to supported date in picker
        .then((pickedDate) {
      //then usually do the future job
      if (pickedDate == null) {
        //if user tap cancel then this function will stop
        return;
      }
      final _dayFormatter = DateFormat('d');
      final _monthFormatter = DateFormat('MM');
      final _yearFormatter = DateFormat('yyyy');
      setState(() {
        cnicExpiryDate = _dayFormatter.format(pickedDate) +
            '/' +
            _monthFormatter.format(pickedDate) +
            '/' +
            _yearFormatter.format(pickedDate);
      });
    });
  }

  @override
  void initState() {
    setState(() {
      emailController.text = widget.email;
      nameController.text = widget.name;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.red,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Rent Bazaar User Signup",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.red
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  readOnly: widget.isGoogle,
                  controller: emailController,
                  validator: (value) {
                    if (!value!.contains(
                      "@",
                    )) {
                      return "Please enter a valid email";
                    }
                    if (!value.contains(
                      ".",
                    )) {
                      return "Please enter a valid email";
                    }
                  },
                  decoration: InputDecoration(
                    suffixIcon: widget.isGoogle
                        ? Icon(
                            Icons.verified,
                            color: Colors.red,
                          )
                        : null,
                    fillColor: Colors.grey.withOpacity(
                      0.5,
                    ),
                    filled: widget.isGoogle,
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.red, width: 2.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.red, width: 2.0),
                    ),
                    hintText: "Enter email address",
                    labelText: "Email",
                    alignLabelWithHint: true,
                    // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value!.length < 3) {
                      return "Please enter a valid full name.";
                    }
                  },
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.red, width: 2.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.red, width: 2.0),
                    ),
                    hintText: "Enter Full Name from CNIC",
                    labelText: "Full Name",
                    alignLabelWithHint: true,
                    // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                  ),
                ),
              ),
              if (!widget.isGoogle)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: passwordController,
                    validator: (value) {
                      if (value!.length < 6) {
                        return "Please enter at least 6 characters";
                      }
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2.0),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2.0),
                      ),
                      hintText: "Enter account password",
                      labelText: "Password",
                      alignLabelWithHint: true,
                      // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: mobileController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.length != 11) {
                      return "Please enter 11 digits starting with 0 eg: 0321*******";
                    }
                  },
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.red, width: 2.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.red, width: 2.0),
                    ),
                    hintText: "0321XXXXXXX",
                    labelText: "Mobile Number",
                    alignLabelWithHint: true,
                    // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(10.0),
              //   child: TextFormField(
              //     controller: addressController,
              //     validator: (value) {
              //       if (value!.length < 10) {
              //         return "Please enter a valid & detailed shipping address";
              //       }
              //     },
              //     decoration: InputDecoration(
              //       enabledBorder: const OutlineInputBorder(
              //         borderSide:
              //             const BorderSide(color: Colors.red, width: 2.0),
              //       ),
              //       focusedBorder: const OutlineInputBorder(
              //         borderSide:
              //             const BorderSide(color: Colors.red, width: 2.0),
              //       ),
              //       hintText: "Enter your shipping address",
              //       labelText: "Address",
              //       alignLabelWithHint: true,
              //       // hintStyle: TextStyle(color: AppColors.primaryColorLight),
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () async {
                    ReturnerAddress addressReturned = await Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => AddAddress(),
                      ),
                    );
                    print("returned address: ${addressReturned.address}");
                    setState(() {
                      address = addressReturned.address;
                      lat = addressReturned.lat;
                      lng = addressReturned.lang;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        address != "" ? address : "Select Address",
                      ),
                      trailing: Icon(
                        Icons.location_on,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: cnicNumberController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.length != 13) {
                      return "Please enter 13 digits ex: 42201********";
                    }
                  },
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.red, width: 2.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.red, width: 2.0),
                    ),
                    hintText: "13 Digit National Identity Number",
                    labelText: "CNIC Number",
                    alignLabelWithHint: true,
                    // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  selectCnicExpiry(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Text(
                        "CNIC Expiry Date: $cnicExpiryDate",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.edit,
                        color: Colors.red,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  "CNIC Front Image:",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                height: 150,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        cnicFront == null
                            ? Icon(
                                Icons.image,
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.file(
                                  File(
                                    cnicFront!,
                                  ),
                                ),
                              ),
                        ElevatedButton(
                          child: Text('ADD'),
                          onPressed: () {
                            selectImageType(context, true);
                          },
                          style: ElevatedButton.styleFrom(
                            // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                            textStyle: TextStyle(
                              fontSize: 20,
                              // fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.all(10),
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  "CNIC Back Image:",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                height: 150,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        cnicBack == null
                            ? Icon(
                                Icons.image,
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.file(
                                  File(
                                    cnicBack!,
                                  ),
                                ),
                              ),
                        ElevatedButton(
                          child: Text('ADD'),
                          onPressed: () {
                            selectImageType(context, false);
                          },
                          style: ElevatedButton.styleFrom(
                            // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                            textStyle: TextStyle(
                              fontSize: 20,
                              // fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.all(10),
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                ),
              if (!isLoading)
                InkWell(
                  onTap: () {
                    signup(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            "     Sign Up",
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
      ),
    );
  }
}
