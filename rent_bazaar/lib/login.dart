import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rent_bazaar/admin/admin_home.dart';
import 'package:rent_bazaar/forgot_password.dart';
import 'package:rent_bazaar/home.dart';
import 'package:rent_bazaar/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  login() async {
    if (_formKey.currentState!.validate()) {
      if (emailController.text == "admin@rentbazaar.com" &&
          passwordController.text == "rbadmin@123") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("email", emailController.text);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => AdminHome(),
          ),
          (route) => false,
        );
      } else {
        var collection = FirebaseFirestore.instance.collection('users');
        var docSnapshot = await collection
            .where("email", isEqualTo: emailController.text)
            .limit(1)
            .get();
        if (docSnapshot.size == 1) {
          if (docSnapshot.docs.first.data()['password'] ==
              passwordController.text) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("email", emailController.text);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(),
              ),
              (route) => false,
            );
          } else {
            Fluttertoast.showToast(msg: "Invalid password!");
          }
        } else {
          Fluttertoast.showToast(msg: "Invalid user!");
        }
      }
    }
  }

  signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    UserCredential creds =
        await FirebaseAuth.instance.signInWithCredential(credential);
    print(creds.user!.email);
    var fetchedEmail = creds.user!.email;
    var fetchedName = creds.user!.displayName;
    FirebaseAuth.instance.signOut();
    GoogleSignIn().signOut();
    var collection = FirebaseFirestore.instance.collection('users');
    var docSnapshot =
        await collection.where("email", isEqualTo: fetchedEmail).limit(1).get();
    if (docSnapshot.size == 1) {
      if (docSnapshot.docs.first.data()['method'] == "google") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("email", fetchedEmail!);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(),
          ),
          (route) => false,
        );
      } else {
        Fluttertoast.showToast(
            msg:
                "This user is not registered through google, please enter your password");
        setState(() {
          emailController.text = fetchedEmail!;
        });
      }
    } else {
      Fluttertoast.showToast(msg: "User is not registered! Please signup");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SignupScreen(
            email: fetchedEmail!,
            isGoogle: true,
            name: fetchedName!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(
                        0xFFF18C85,
                      ),
                      Color(
                        0xFFE94A3B,
                      ),
                      Color(
                        0xFFE95146,
                      ),
                    ],
                  ),
                ),
                child: Image.asset(
                  "assets/top.jpeg",
                  // height: 150,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                         //on tap function removed
                    child: Text(
                      "Sign in to your account!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (!value!.contains(
                      "@",
                    )) {
                      return "Please enter a valid email";
                    }
                    if (!value.contains(".")) {
                      return "Please enter a valid email";
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
                    hintText: "Enter email",
                    labelText: "Email",
                    alignLabelWithHint: true,
                    // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                  ),
                ),
              ),
              // SizedBox(
              //   height: 40,
              // ),
              Padding(
                padding: const EdgeInsets.all(14.0),
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

              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ForgotPassword(),
                        ),
                      );
                    },
                    child: Text(
                      "Forgot your password?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: login,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        100,
                      ),
                    ),
                    color: Colors.red,
                    child: ListTile(
                      title: Center(
                        child: Text(
                          "     Sign In",
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
              SizedBox(
                height: 5,
              ),
              InkWell(
                onTap: signInWithGoogle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        100,
                      ),
                    ),
                    child: ListTile(
                      leading: Image.asset(
                        "assets/google.png",
                        height: 30,
                      ),
                      title: Center(
                        child: Text(
                          "Continue with Google",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_right,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignupScreen(
                          isGoogle: false,
                          email: '',
                          name: '',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Don't have an account? Register Now",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.red,
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
