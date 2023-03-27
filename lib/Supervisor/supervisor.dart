import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../login.dart';

class Supervisor extends StatefulWidget {
  const Supervisor({super.key});

  @override
  State<Supervisor> createState() => _SupervisorState();
}

class _SupervisorState extends State<Supervisor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Supervisor"),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: Icon(
              Icons.logout,
            ),
          )
        ],
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }
}
