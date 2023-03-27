import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';
// import 'model.dart';

class resetPassword extends StatefulWidget {
  @override
  _resetPasswordState createState() => _resetPasswordState();
}

class _resetPasswordState extends State<resetPassword> {
  _resetPasswordState();

  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(0, 158, 119, 119),
        elevation: 0,
        title: const Text(
          "Reset Password",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter Email',
                    enabled: true,
                    contentPadding: const EdgeInsets.only(
                        left: 14.0, bottom: 8.0, top: 8.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.white),
                      borderRadius: new BorderRadius.circular(10),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: new BorderSide(color: Colors.white),
                      borderRadius: new BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value!.length == 0) {
                      return "Email cannot be empty";
                    }
                    if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                        .hasMatch(value)) {
                      return ("Please enter a valid email");
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) {
                    emailController.text = value!;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(
                  height: 20,
                ),
                firebaseButton(context, "Reset Password", () {
                  FirebaseAuth.instance
                      .sendPasswordResetEmail(email: emailController.text)
                      .then((value) => Navigator.of(context).pop());
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Container firebaseButton(BuildContext context, String title, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.black26;
          }
          return Colors.white;
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
      ),
    ),
  );
}
