import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_a/login.dart';
import 'package:flutter_test_a/model/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeProfile extends StatefulWidget {
  const EmployeProfile({super.key});

  @override
  State<EmployeProfile> createState() => _EmployeProfileState();
}

class _EmployeProfileState extends State<EmployeProfile> {
  double screenHeight = 0;
  double screenWidth = 0;
  bool isEditing = false;
  Color primary = const Color(0xffeef444c);
  String birth = "Date of Birth";

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 10),
                  Text(
                    'Employee Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      logout(context);
                    },
                    child: const Icon(
                      Icons.logout,
                      color: Colors.black,
                      size: 26.0,
                    ),
                  ),
                )
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 30, bottom: 24),
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: primary,
                image: DecorationImage(
                  image: NetworkImage(Employee.profilePicLink),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "${Employee.employeeId}",
                style: const TextStyle(
                  fontFamily: "NexaBold",
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(
              height: 19,
            ),
            isEditing
                ? textField("First Name", "First name", firstNameController)
                : field("First Name", Employee.firstName),
            isEditing
                ? textField("Last Name", "Last name", lastNameController)
                : field("Last Name", Employee.lastName),
            const Align(
              alignment: Alignment.center,
              child: Text(
                "Date of Birth",
                style: TextStyle(
                  fontFamily: "NexaBold",
                  color: Colors.black87,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (isEditing) {
                  showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1960),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: primary,
                              secondary: primary,
                              onSecondary: Colors.white,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(primary: primary),
                            ),
                            textTheme: const TextTheme(
                              headline4: TextStyle(
                                fontFamily: "NexaBold",
                              ),
                              overline: TextStyle(
                                fontFamily: "NexaBold",
                              ),
                              button: TextStyle(
                                fontFamily: "NexaBold",
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      }).then((value) {
                    setState(() {
                      birth = DateFormat("dd/MM/yyyy").format(value!);
                    });
                  });
                }
              },
              child: Container(
                height: kToolbarHeight,
                width: 356,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.only(left: 11),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.black54,
                  ),
                ),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isEditing ? birth : Employee.birthDate,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontFamily: "NexaBold",
                        fontSize: 16,
                      ),
                    )),
              ),
            ),
            isEditing
                ? textField("Address", "Address", addressController)
                : field("Address", Employee.address),
            GestureDetector(
              onTap: () async {
                if (isEditing) {
                  String firstName = firstNameController.text;
                  String lastName = lastNameController.text;
                  String address = addressController.text;
                  String birthDate = birth;

                  if (firstName.isEmpty) {
                    showSnackBar("Please enter your firstname!");
                  } else if (lastName.isEmpty) {
                    showSnackBar("Please enter your lastname!");
                  } else if (birthDate.isEmpty) {
                    showSnackBar("Please select your birth date !");
                  } else if (address.isEmpty) {
                    showSnackBar("Please enter your address!");
                  } else {
                    await FirebaseFirestore.instance
                        .collection("Employee")
                        .doc(Employee.id)
                        .update({
                      'firstName': firstName,
                      'lastName': lastName,
                      'address': address,
                      'birthDate': birthDate,
                      'canEdit': false,
                    });

                    setState(() {
                      isEditing = false;
                      setState(() {
                        Employee.canEdit = false;
                        Employee.firstName = firstName;
                        Employee.lastName = lastName;
                        Employee.birthDate = birthDate;
                        Employee.address = address;
                      });
                    });
                  }
                } else {
                  setState(() {
                    isEditing = true;
                  });
                }
              },
              child: Container(
                height: kToolbarHeight,
                width: 250,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: primary,
                ),
                child: Center(
                  child: Text(
                    isEditing ? "SAVE" : "EDIT",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "NexaBold",
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget field(String title, String text) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "NexaBold",
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          height: kToolbarHeight,
          width: 356,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.only(left: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: Colors.black54,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black54,
                fontFamily: "NexaBold",
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget textField(
      String tittle, String hint, TextEditingController controller) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            tittle,
            style: const TextStyle(
              fontFamily: "NexaBold",
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: TextFormField(
            enabled: isEditing,
            controller: controller,
            cursorColor: Colors.black54,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.black54,
                fontFamily: "NexaBold",
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black54,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          text,
        ),
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
