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
                                onSaved: (value) {
                                  _password = value!;
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
                                onSaved: (value) {
                                  _newPassword = value!;
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
                                onSaved: (value) {
                                  _confirmNewPassword = value!;
                                },
                              ),
                              SizedBox(height: 32.0),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();

                                    // Check if old password matches with database
                                    QuerySnapshot snapshot =
                                        await FirebaseFirestore
                                            .instance
                                            .collection('Supervisor')
                                            .where('id', isEqualTo: widget.uid)
                                            .where('password',
                                                isEqualTo: _password)
                                            .get();
                                    if (snapshot.docs.length == 1) {
                                      // Update password in database
                                      await FirebaseFirestore.instance
                                          .collection('supervisors')
                                          .doc(snapshot.docs[0].id)
                                          .update({'password': _newPassword});

                                      // Show success message and clear form
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Password updated successfully'),
                                        ),
                                      );
                                      _formKey.currentState!.reset();
                                    } else {
                                      // Show error message
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'The old password is incorrect'),
                                        ),
                                      );
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
