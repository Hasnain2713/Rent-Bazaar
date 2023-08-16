import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsScreen extends StatefulWidget {
  final String productID;
  final String name;

  CommentsScreen({
    required this.productID,
    required this.name,
  });

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyReply = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final _replyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Comments',
          style: TextStyle(
            color: Colors.red,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.red),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('comments')
                  .where('productID', isEqualTo: widget.productID)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> comments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot comment = comments[index];

                    return Column(
                      children: [
                        ListTile(
                          title: Text(comment['text']),
                          subtitle: Text(comment['username']),
                          trailing: IconButton(
                            icon: Icon(Icons.reply),
                            onPressed: () =>
                                _showReplyDialog(context, comment.id),
                          ),
                          isThreeLine: true,
                        ),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('comments')
                              .doc(comment.id)
                              .collection('replies')
                              .orderBy('timestamp', descending: false)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return SizedBox.shrink();
                            }

                            List<DocumentSnapshot> replies =
                                snapshot.data!.docs;

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: replies.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot reply = replies[index];

                                return ListTile(
                                  title: Text(reply['text']),
                                  subtitle: Text(reply['username']),
                                  dense: true,
                                );
                              },
                            );
                          },
                        ),
                        Divider(
                          color: Colors.grey,
                          thickness: 2,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a comment';
                  }
                  return null;
                },
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _addComment(context),
            child: Text('Add Comment'),
          ),
        ],
      ),
    );
  }

  void _addComment(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String username = widget.name; // replace with user's name
      String comment = _commentController.text;

      await FirebaseFirestore.instance.collection('comments').add({
        'productID': widget.productID,
        'username': username,
        'text': comment,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _showReplyDialog(BuildContext context, String commentID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reply'),
          content: Form(
            key: _formKeyReply,
            child: TextFormField(
              controller: _replyController,
              decoration: InputDecoration(hintText: 'Enter your reply...'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a reply';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('REPLY'),
              onPressed: () => _addReply(
                context,
                commentID,
                _replyController.text,
              ),
            ),
          ],
        );
      },
    );
  }

  void _addReply(BuildContext context, String commentID, String _reply) async {
    if (_formKeyReply.currentState!.validate()) {
      String username = widget.name; // replace with user's name
      String reply = _reply;

      await FirebaseFirestore.instance
          .collection('comments')
          .doc(commentID)
          .collection('replies')
          .add({
        'username': username,
        'text': reply,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        _replyController.clear();
      });
      Navigator.pop(context);
    }
  }
}
