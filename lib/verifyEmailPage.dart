import 'dart:async';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test_a/login.dart';

class EmailVerificationScreen extends StatefulWidget {
  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _auth = FirebaseAuth.instance;
  late User _user;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _user.sendEmailVerification();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      _user = _auth.currentUser!;
      await _user.reload();
      if (_user.emailVerified) {
        ElegantNotification.info(
                title: Text("Verified"),
                description: Text("Your email has been verified"))
            .show(context);
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Verification'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Thank you for signing up! Please verify your email address to complete your registration.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            Text(
              'A verification email has been sent to ${_user.email}. Please check your inbox and follow the instructions to complete your account registration.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
