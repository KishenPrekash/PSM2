import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test_a/login.dart';
import 'package:flutter_test_a/model/user.dart';

class EditProfileScreen extends StatefulWidget {
  final String uid;

  EditProfileScreen({required this.uid});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _empID = '';
  String _role = '';
  String _password = '';
  String _newPassword = '';
  String _confirmNewPassword = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 10),
            Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: Icon(Icons.logout),
            color: Colors.black,
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Supervisor')
            .doc(Supervisor.supervisorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          if (data != null) {
            _password = data['password'] as String;
            _role = data['role'] as String;
            _empID = data['id'] as String;
          } else {
            return Center(
              child: Text('Employee not found'),
            );
          }
          return Container(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.0),
                      Text(
                        'Name: ${_empID}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Role: ${_role}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: 32.0),
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Change Password',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16.0),
                              TextFormField(
                                initialValue: '',
                                decoration: InputDecoration(
                                  labelText: 'Old Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter the old password';
                                  } else if (value != _password) {
                                    return 'The old password is incorrect';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  _password = value;
                                },
                              ),
                              SizedBox(height: 16.0),
                              TextFormField(
                                initialValue: '',
                                decoration: InputDecoration(
                                  labelText: 'New Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a new password';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  _newPassword = value;
                                },
                              ),
                              SizedBox(height: 16.0),
                              TextFormField(
                                initialValue: '',
                                decoration: InputDecoration(
                                  labelText: 'Confirm New Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please confirm the new password';
                                  } else if (value != _newPassword) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  _confirmNewPassword = value;
                                },
                              ),
                              SizedBox(height: 32.0),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();

                                    // Check if old password matches with database
                                    DocumentSnapshot supervisorSnapshot =
                                        await FirebaseFirestore.instance
                                            .collection('Supervisor')
                                            .doc(widget.uid)
                                            .get();

                                    if (supervisorSnapshot.exists) {
                                      // Document exists, check if password matches
                                      Map<String, dynamic>? supervisorData =
                                          supervisorSnapshot.data()
                                              as Map<String, dynamic>?;

                                      if (supervisorData != null) {
                                        String storedPassword =
                                            supervisorData['password']
                                                as String;

                                        if (_password == storedPassword) {
                                          // Password matches, perform further operations if needed

                                          // Update password in the database
                                          await FirebaseFirestore.instance
                                              .collection('Supervisor')
                                              .doc(widget.uid)
                                              .update(
                                                  {'password': _newPassword});
                                          User? user =
                                              FirebaseAuth.instance.currentUser;
                                          if (user != null) {
                                            await user
                                                .updatePassword(_newPassword);
                                          }

                                          // Show success message and clear the form
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Password updated successfully'),
                                            ),
                                          );
                                          _formKey.currentState!.reset();
                                        } else {
                                          // Password does not match, display error message
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'The old password is incorrect'),
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('No record found'),
                                          ),
                                        );
                                      }
                                    } else {
                                      // Document does not exist, handle error or display appropriate message
                                    }
                                  }
                                },
                                child: Text('Update Password'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
