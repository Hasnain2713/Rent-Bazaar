import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_bazaar/admin/all_products.dart';
import 'package:rent_bazaar/classes/product.dart';
import 'package:rent_bazaar/home.dart';
import 'package:rent_bazaar/product_details.dart';
import 'package:rent_bazaar/view_products.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProduct extends StatefulWidget {
  String productID;
  bool isAdmin;

  EditProduct({
    required this.productID,
    this.isAdmin = false,
  });

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  TextEditingController rentController = TextEditingController();

  bool isLoading = false;

  String? productImage;

  Product? product;

  final _formKey = GlobalKey<FormState>();

  getProductDetails() {
    FirebaseFirestore.instance
        .collection("products")
        .doc(widget.productID)
        .get()
        .then((value) {
      setState(() {
        product = Product.fromJson(value.data()!);
        titleController.text = product!.title;
        descriptionController.text = product!.description;
        valueController.text = product!.averageCost;
        rentController.text = product!.rentPerDay;
      });
    });
  }

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
                  getImage(false);
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
                  getImage(true);
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

  getImage(bool isCamera) async {
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
        productImage = image.path;
      });
    }
  }

  Future<String> uploadImageToFirebase(BuildContext context, imagePath) async {
    File imageFile = File(imagePath);
    await FirebaseStorage.instance
        .ref()
        .child('products/')
        .putFile(imageFile)
        .then((fileUpload) {
      return fileUpload.ref.getDownloadURL();
    }).onError((error, stackTrace) {
      return "false";
    });
    return "false";
  }

  saveDetails(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      if (productImage == null) {
        setState(() {
          isLoading = true;
        });
        Product toUploadProduct = Product(
          id: widget.productID,
          title: titleController.text.toLowerCase(),
          averageCost: valueController.text,
          rentPerDay: rentController.text,
          imageURL: product!.imageURL,
          userEmail: prefs.getString("email")!,
          description: descriptionController.text,
        );
        Map<String, dynamic> toUploadProductJson = toUploadProduct.toJson();
        var titleArray = [];
        for (int i = 1; i < titleController.text.length + 1; i++) {
          titleArray.add(titleController.text.toLowerCase().substring(0, i));
        }
        Map<String, dynamic> titleArrayJson = {
          "titleAsArray": titleArray,
        };
        toUploadProductJson.addAll(titleArrayJson);
        final docProduct = FirebaseFirestore.instance
            .collection("products")
            .doc(widget.productID);
        await docProduct.update(toUploadProductJson).then((value) {
          Fluttertoast.showToast(msg: "Your product was successfully updated.");
          if (!widget.isAdmin) {
            Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(
                builder: (_) => HomePage(),
              ),
              (route) => false,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetails(
                  product: toUploadProduct,
                ),
              ),
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => AllProducts(),
              ),
              (route) => false,
            );
          }
        }).onError((error, stackTrace) {
          Fluttertoast.showToast(
              msg:
                  "There was a problem while updating your product, please try again later.");
        });
      } else {
        setState(() {
          isLoading = true;
        });
        Fluttertoast.showToast(
            msg: "Please wait while we save your product...");
        File productImageFile = File(productImage!);
        await FirebaseStorage.instance
            .ref()
            .child('${prefs.getString("email")!}/products/${widget.productID}')
            .putFile(productImageFile)
            .then((fileUpload) async {
          String productImageURL = await fileUpload.ref.getDownloadURL();
          Product toUploadProduct = Product(
            id: widget.productID,
            title: titleController.text.toLowerCase(),
            averageCost: valueController.text,
            rentPerDay: rentController.text,
            imageURL: productImageURL,
            userEmail: prefs.getString("email")!,
            description: descriptionController.text,
          );
          Map<String, dynamic> toUploadProductJson = toUploadProduct.toJson();
          var titleArray = [];
          for (int i = 1; i < titleController.text.length + 1; i++) {
            titleArray.add(titleController.text.toLowerCase().substring(0, i));
          }
          Map<String, dynamic> titleArrayJson = {
            "titleAsArray": titleArray,
          };
          toUploadProductJson.addAll(titleArrayJson);
          final docProduct = FirebaseFirestore.instance
              .collection("products")
              .doc(widget.productID);
          await docProduct.update(toUploadProductJson).then((value) {
            Fluttertoast.showToast(
                msg: "Your product was successfully uploaded.");
            if (!widget.isAdmin) {
              Navigator.pushAndRemoveUntil(
                context,
                CupertinoPageRoute(
                  builder: (_) => HomePage(),
                ),
                (route) => false,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetails(
                    product: toUploadProduct,
                  ),
                ),
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => AllProducts(),
                ),
                (route) => false,
              );
            }
          }).onError((error, stackTrace) {
            Fluttertoast.showToast(
                msg:
                    "There was a problem while uploading your product, please try again later.");
          });
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getProductDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Edit Product",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.black,
          ),
        ),
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
      body: product == null
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            )
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: titleController,
                        validator: (value) {
                          if (value!.length < 3) {
                            return "Please enter a valid title.";
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
                          hintText: "Enter Title (This will show up in search)",
                          labelText: "Product Title",
                          alignLabelWithHint: true,
                          // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        "Tip: When adding a title, mention the product type first instead of the company. For Example \n\nMechanical Keyboard HP ✅\n\nHP Mechanical Keyboard ❌ ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        maxLength: 100,
                        maxLines: 3,
                        controller: descriptionController,
                        validator: (value) {
                          if (value!.length < 15) {
                            return "Please enter atleast 15 characters.";
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
                          hintText: "Enter Product Description",
                          labelText: "Description",
                          alignLabelWithHint: true,
                          // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: valueController,
                        validator: (value) {
                          if (int.parse(value!) < 1) {
                            return "Please enter a valid cost.";
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
                          hintText: "Enter Average Product Cost",
                          labelText: "Product Value",
                          alignLabelWithHint: true,
                          // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: rentController,
                        validator: (value) {
                          if (int.parse(value!) < 1) {
                            return "Please enter a valid cost.";
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
                          hintText: "Enter Per Day Rent",
                          labelText: "Product Rent",
                          alignLabelWithHint: true,
                          // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Product Image:",
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
                              productImage == null
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.network(
                                        product!.imageURL,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.file(
                                        File(
                                          productImage!,
                                        ),
                                      ),
                                    ),
                              ElevatedButton(
                                child: Text('Replace'),
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
                          saveDetails(context);
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
                                  "Save Product",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              trailing: Icon(
                                Icons.save,
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
