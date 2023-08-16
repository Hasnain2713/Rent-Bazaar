import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rent_bazaar/login.dart';
import 'package:rent_bazaar/reset_password.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  var emailController1 = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  bool isLoading = false;

  sendEmail() async {
    if (formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      var collection = FirebaseFirestore.instance.collection('users');
      var docSnapshot = await collection
          .where("email", isEqualTo: emailController1.text)
          .limit(1)
          .get();
      if (docSnapshot.size == 1) {
        if (docSnapshot.docs.first.data()['method'] == "google") {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
              msg:
                  "This account is registered via Google Sign In. Please use Google Sign In to login.");
        } else {
          sendOtpEmail(emailController1.text);
        }
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "This user doesn't exist in our database");
      }
    }
  }

  Future<void> sendOtpEmail(String toEmail) async {
    setState(() {
      isLoading = true;
    });

    String sendGridAPIKey =
        "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";
    final apiKey = sendGridAPIKey;
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

    // Generate a 6-digit OTP
    final random = Random();
    final otp = List.generate(6, (_) => random.nextInt(10)).join();

    // Build the email message
    final message = {
      'personalizations': [
        {
          'to': [
            {'email': toEmail}
          ]
        }
      ],
      'from': {'email': 'cs1912193@szabist.pk'},
      'subject': 'Rent Bazaar - Reset Password',
      'content': [
        {
          'type': 'text/plain',
          'value':
              'Your OTP is $otp. Please use this to reset your password inside the app.'
        }
      ]
    };

    print(message);

    // Send the email using the SendGrid API
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(message),
    );

    print(response.body);

    if (response.statusCode != 202) {
      setState(() {
        isLoading = true;
      });
      throw Exception('Failed to send OTP email');
    } else {
      Fluttertoast.showToast(
        msg:
            "A verification code has been sent to your email address, please check your email",
      );
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
          builder: (_) => ResetPasswordScreen(
            otp: otp,
            email: emailController1.text,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    MediaQueryData queryData; //
    queryData = MediaQuery.of(context); //
    double pixels = queryData.devicePixelRatio; //

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(//to avoid pixel problem
          children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: w,
                    height: h * 0.28,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 30),
                        SizedBox(height: pixels * h * 0.015), //h*0.1
                        Text(
                          "Reset Password",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Container(
                width: w,
                margin: EdgeInsets.only(left: 20),
                child: Text(
                  "Enter your email address for further assistance!",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              Form(
                key: formkey,
                child: Container(
                  width: w,
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50),
                      TextFormField(
                        controller: emailController1,
                        // onChanged: ,
                        validator: (value) {
                          if (!value!.contains("@") || !value.contains(".")) {
                            return "          Please enter a valid email address";
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
                          hintText: "Enter email address",
                          labelText: "Email",
                          alignLabelWithHint: true,
                          // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 60),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
              if (!isLoading)
                InkWell(
                  onTap: () {
                    print("send email clicked");
                    sendEmail();
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
                            "Send Email",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        trailing: Icon(
                          Icons.email,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(),
                    ),
                    (route) => false,
                  );
                },
                child: RichText(
                  text: TextSpan(
                    text: "Return Back",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              SizedBox(height: w * 0.2),
            ],
          ),
        ),
      ]),
    );
  }
}
