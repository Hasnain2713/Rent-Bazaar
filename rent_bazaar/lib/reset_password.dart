import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rent_bazaar/login.dart';

class ResetPasswordScreen extends StatefulWidget {
  String otp;
  String email;

  ResetPasswordScreen({required this.otp, required this.email});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool otpVerified = false;

  bool isLoading = false;

  void verifyOtp(String enteredOtp) {
    setState(() {
      otpVerified = (enteredOtp == widget.otp);
      if (otpVerified) {
        Fluttertoast.showToast(
          msg: "OTP verified, please enter your new password",
        );
      }
    });
  }

  Future<void> saveNewPassword() async {
    setState(() {
      isLoading = true;
    });
    String newPassword = passwordController.text;
    String confirmedPassword = confirmPasswordController.text;

    if (newPassword.length >= 6) {
      if (newPassword == confirmedPassword) {
        final userCollection = FirebaseFirestore.instance.collection("users");
        final currentuserDoc =
            await userCollection.where("email", isEqualTo: widget.email).get();

        userCollection.doc(currentuserDoc.docs.first.id).update({
          "password": newPassword,
        }).then(
          (value) {
            Fluttertoast.showToast(
                msg: "Password updated successfully, please login.");
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => Login(),
              ),
              (route) => false,
            );
          },
          onError: (e) {
            Fluttertoast.showToast(
                msg: "Password reset failed, please try again later.");
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => Login(),
              ),
              (route) => false,
            );
          },
        );
      } else {
        Fluttertoast.showToast(msg: "Passwords do not match.");
        setState(() {
          isLoading = true;
        });
      }
    } else {
      Fluttertoast.showToast(msg: "Password should be atleast 6 characters");
      setState(() {
        isLoading = true;
      });
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
                  otpVerified
                      ? "Please enter your new password and save."
                      : "Enter the OTP sent to your email address to continue.",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              /*Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                spreadRadius: 7,
                                offset: Offset(1, 1),
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ]),
                        child: TextFormField(
                          controller: emailController1,
                          // onChanged: ,
                          validator: (value) {
                            if (!value!.contains("@") || !value.contains(".")) {
                              return "          Please enter a valid email address";
                            }
                          },
                          decoration: InputDecoration(
                            hintText: "Email",
                            prefixIcon:
                                Icon(Icons.email, color: Colors.black54),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),*/
              SizedBox(height: 30.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter OTP",
                  ),
                  onChanged: verifyOtp,
                  readOnly: otpVerified,
                ),
              ),
              SizedBox(height: 16.0),
              if (otpVerified)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "New Password",
                        ),
                        readOnly: isLoading,
                      ),
                      SizedBox(height: 16.0),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Confirm New Password",
                        ),
                        readOnly: isLoading,
                      ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
              SizedBox(height: 60),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
              if (!isLoading && otpVerified)
                InkWell(
                  onTap: () {
                    saveNewPassword();
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
                            "Reset",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        trailing: Icon(
                          Icons.key,
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
