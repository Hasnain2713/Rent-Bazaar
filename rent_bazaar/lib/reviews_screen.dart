import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProductReviewScreen extends StatefulWidget {
  final String productId;
  final String userEmail;

  ProductReviewScreen({required this.productId, required this.userEmail});

  @override
  _ProductReviewScreenState createState() => _ProductReviewScreenState();
}

class _ProductReviewScreenState extends State<ProductReviewScreen> {
  TextEditingController reviewController = TextEditingController();
  double rating = 0.0;
  bool hasRated = false;
  String? reviewId;

  @override
  void initState() {
    super.initState();
    checkIfUserHasRated();
  }

  void checkIfUserHasRated() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('productId', isEqualTo: widget.productId)
        .where('userEmail', isEqualTo: widget.userEmail)
        .get();
    if (snapshot.docs.length > 0) {
      setState(() {
        hasRated = true;
        rating = snapshot.docs[0].get('rating');
        reviewController.text = snapshot.docs[0].get('review');
        reviewId = snapshot.docs[0].id;
      });
    }
  }

  void saveReview() async {
    if (hasRated) {
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(reviewId)
          .update({'rating': rating, 'review': reviewController.text});
    } else {
      await FirebaseFirestore.instance.collection('reviews').add({
        'productId': widget.productId,
        'userEmail': widget.userEmail,
        'rating': rating,
        'review': reviewController.text
      });
    }
    Fluttertoast.showToast(msg: "Review saved successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Reviews'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reviews')
                  .where('productId', isEqualTo: widget.productId)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  List<DocumentSnapshot> documents = snapshot.data!.docs;
                  List<Widget> reviews = documents
                      .map((doc) => ListTile(
                            leading: Icon(Icons.star),
                            title: Text(doc.get('review')),
                            subtitle: Text(
                                doc.get('userEmail').toString().split("@")[0]),
                            trailing: Text(doc.get('rating').toString()),
                          ))
                      .toList();
                  return ListView(
                    children: reviews,
                  );
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  hasRated ? 'Edit Review' : 'Add Review',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: <Widget>[
                    Text('Rating: '),
                    SizedBox(width: 16.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              rating = index + 1.0;
                            });
                          },
                          child: Icon(
                            index < rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            size: 30.0,
                            color: Colors.yellow,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: reviewController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Enter your review',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      saveReview();
                    },
                    child: Text(hasRated ? 'Update Review' : 'Submit Review'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
