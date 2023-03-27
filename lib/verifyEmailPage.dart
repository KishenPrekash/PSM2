import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailScreen extends StatelessWidget {
  final String email;

  VerifyEmailScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF64B5F6),
              Color(0xFF2196F3),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Verify Your Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  'Please verify your email address to continue using our app.',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                SizedBox(height: 20.0),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.0),
                if (user != null && !user.emailVerified)
                  ElevatedButton(
                    onPressed: () async {
                      await user.sendEmailVerification();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Verification email sent.'),
                        ),
                      );
                    },
                    child: Text('Send Verification Email'),
                  )
                else if (user == null)
                  Text(
                    'You are not currently signed in.',
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  )
                else
                  Text(
                    'A verification email has already been sent to $email. Please check your inbox or spam folder.',
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
