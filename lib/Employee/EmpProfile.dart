import 'dart:io';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_a/login.dart';
import 'package:flutter_test_a/model/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeProfile extends StatefulWidget {
  const EmployeProfile({Key? key}) : super(key: key);

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
  void initState() {
    super.initState();
    // Initialize the text controllers with the values from Firestore
    loadEmployeeDetails();
  }

  void loadEmployeeDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final employeeDoc =
          FirebaseFirestore.instance.collection('Employee').doc(user.uid);
      final employeeSnapshot = await employeeDoc.get();
      if (employeeSnapshot.exists) {
        final data = employeeSnapshot.data();
        setState(() {
          firstNameController.text = data?['firstName'] ?? '';
          lastNameController.text = data?['lastName'] ?? '';
          addressController.text = data?['address'] ?? '';
          birth = data?['birthDate'] ?? '';
        });
      }
    }
  }

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
                      CoolAlert.show(
                        context: context,
                        type: CoolAlertType.confirm,
                        text: "Do you want to logout?",
                        confirmBtnText: 'Yes',
                        cancelBtnText: 'No',
                        confirmBtnColor: Colors.green,
                        onConfirmBtnTap: () {
                          logout(context);
                        },
                      );
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
                ? textField("First Name", firstNameController)
                : field("First Name", firstNameController),
            isEditing
                ? textField("Last Name", lastNameController)
                : field("Last Name", lastNameController),
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
                  ),
                ),
              ),
            ),
            isEditing
                ? textField("Address", addressController)
                : field("Address", addressController),
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
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await FirebaseFirestore.instance
                          .collection("Employee")
                          .doc(user.uid)
                          .update({
                        'firstName': firstName,
                        'lastName': lastName,
                        'address': address,
                        'birthDate': birthDate,
                        'canEdit': false,
                      });
                    }

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

  Widget field(String title, TextEditingController controller) {
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
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.black54,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              controller.text,
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

  Widget textField(String title, TextEditingController controller) {
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
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.black54,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: Colors.black54,
                fontFamily: "NexaBold",
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }
}
