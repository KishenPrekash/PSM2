import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:elegant_notification/elegant_notification.dart';
import 'package:local_auth/local_auth.dart';
import 'package:image_compare/image_compare.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_test_a/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:geocoding/geocoding.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  String checkIn = "--/--";
  String checkOut = "--/--";
  String location = " ";
  String checkInlocation = " ";
  String checkOutlocation = " ";
  String checkInStatus = " ";
  final LocalAuthentication localAuth = LocalAuthentication();

  Color primary = const Color(0xffeef444c);

  @override
  void initState() {
    super.initState();
    _getRecord();
  }

  void _getLocation() async {
    // Get the location
    List<Placemark> placemark =
        await placemarkFromCoordinates(Employee.lat, Employee.long);
    setState(() {
      location =
          "${placemark[0].street},${placemark[0].administrativeArea},${placemark[0].postalCode},${placemark[0].country}";
    });
  }

  void _getRecord() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('id', isEqualTo: Employee.employeeId)
          .get();

      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(snap.docs[0].id)
          .collection("Record")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();

      setState(() {
        checkIn = snap2['checkIn'];
        checkOut = snap2['checkOut'];
        checkInlocation = snap2['checkInLocation'];
        checkOutlocation = snap2['checkOutLocation'];
        checkInStatus = snap2['checkInStatus'];
      });
    } catch (e) {
      setState(() {
        checkIn = "--/--";
        checkOut = "--/--";
        checkInlocation = "--";
        checkOutlocation = "--";
        checkInStatus = "--";
      });
    }
  }

  Future<bool> authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await localAuth.authenticate(
          localizedReason: 'Authenticate to check in/out',
          options: const AuthenticationOptions(biometricOnly: true));
    } on PlatformException catch (e) {
      print(e);
    }
    return authenticated;
  }

  bool isEmployeeInCompanyLocation() {
    // Replace companyLat and companyLng with the latitude and longitude of the company's location
    double companyLat = 1.55636628;
    double companyLng = 103.648055;

    // Replace employeeLat and employeeLng with the latitude and longitude of the employee's current location
    double employeeLat = Employee.lat;
    double employeeLng = Employee.long;

    // Calculate the distance between the employee's location and the company's location
    double distance =
        calculateDistance(employeeLat, employeeLng, companyLat, companyLng);

    // Set a threshold distance within which the employee is considered to be in the company's location
    double thresholdDistance = 1000; // Adjust the threshold distance as needed

    // Check if the distance is within the threshold distance
    return distance <= thresholdDistance;
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Radius of the Earth in kilometers

    double dLat = _toRadians(lat2 - lat1);
    double dLng = _toRadians(lng2 - lng1);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  double _toRadians(double degree) {
    return degree * (math.pi / 180);
  }

  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(top: 32),
            child: Text(
              "Welcome," + Employee.employeeId,
              style: TextStyle(
                color: Colors.black54,
                fontFamily: "NexaRegular",
                fontSize: screenWidth / 20,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: TextStyle(
                      fontFamily: 'NexaRegular',
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        DateTime.now().day.toString(),
                        style: TextStyle(
                          fontFamily: 'NexaRBold',
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMMM yyyy').format(DateTime.now()),
                        style: TextStyle(
                          fontFamily: 'NexaRegular',
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Time',
                    style: TextStyle(
                      fontFamily: 'NexaRegular',
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 4),
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      return Text(
                        DateFormat('HH:mm:ss a').format(DateTime.now()),
                        style: TextStyle(
                          fontFamily: 'NexaRegular',
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 32),
            child: Text(
              "Today's Status",
              style: TextStyle(
                fontFamily: "NexaBold",
                fontSize: screenWidth / 18,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 32),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Check In",
                        style: TextStyle(
                          fontFamily: "NexaRegular",
                          fontSize: 20,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        checkIn,
                        style: const TextStyle(
                          color: Colors.red,
                          fontFamily: "NexaBold",
                          fontSize: 25,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Location",
                              style: TextStyle(
                                fontFamily: "NexaRegular",
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              checkInlocation,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontFamily: "NexaBold",
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(
                  color: Colors.grey,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Check Out",
                        style: TextStyle(
                          fontFamily: "NexaRegular",
                          fontSize: 20,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        checkOut,
                        style: const TextStyle(
                          fontFamily: "NexaBold",
                          fontSize: 25,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Location",
                              style: TextStyle(
                                fontFamily: "NexaRegular",
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              checkOutlocation,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontFamily: "NexaBold",
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          checkOut == "--/--"
              ? Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 12),
                  child: Builder(
                    builder: (context) {
                      final GlobalKey<SlideActionState> key = GlobalKey();

                      return SlideAction(
                        text: checkIn == "--/--" ? "Check In" : "Check Out",
                        textStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: screenWidth / 20,
                            fontFamily: "NexaRegular"),
                        outerColor: Colors.white,
                        innerColor: Colors.blue,
                        key: key,
                        onSubmit: () async {
                          if (Employee.lat != 0) {
                            _getLocation();
                            final now = DateTime.now();
                            if (!isEmployeeInCompanyLocation()) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Cannot slide in"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "You are not in the company's location.",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        SizedBox(height: 10.0),
                                        TextButton(
                                          child: Text(
                                            "OK",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.blue),
                                            padding: MaterialStateProperty.all(
                                              EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 10.0,
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    backgroundColor: Colors.white,
                                    elevation: 5.0,
                                    contentPadding: EdgeInsets.all(20.0),
                                  );
                                },
                              );
                              return; // Do not proceed with check-in
                            }
                            if (now.hour >= 8 &&
                                now.minute > 0 &&
                                checkOut == null) {
                              // Employee is late
                              ElegantNotification.error(
                                title: Text("Late"),
                                description: Text("You have checked in late"),
                              ).show(context);
                              setState(() {
                                checkInStatus = 'Late';
                              });
                            }
                            if (now.hour >= 17 && checkOut == null) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Cannot slide in"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "You cannot slide in after 5pm",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        SizedBox(height: 10.0),
                                        TextButton(
                                          child: Text(
                                            "OK",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.blue),
                                            padding: MaterialStateProperty.all(
                                              EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 10.0,
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    backgroundColor: Colors.white,
                                    elevation: 5.0,
                                    contentPadding: EdgeInsets.all(20.0),
                                  );
                                },
                              );
                              return; // Do not proceed with check-in
                            } else if (now.weekday == DateTime.saturday ||
                                now.weekday == DateTime.sunday) {
                              // Show a message to the user and do not get the location
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Cannot slide in"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          "You cannot slide in during weekends",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        SizedBox(height: 10.0),
                                        TextButton(
                                          child: Text(
                                            "OK",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.blue),
                                            padding: MaterialStateProperty.all(
                                              EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 10.0,
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    backgroundColor: Colors.white,
                                    elevation: 5.0,
                                    contentPadding: EdgeInsets.all(20.0),
                                  );
                                },
                              );
                              return; // Do not proceed with getting the location
                            }

                            final pickedFile = await ImagePicker()
                                .getImage(source: ImageSource.camera);
                            if (pickedFile == null) {
                              // User did not take a picture
                              return;
                            }

                            // Verify the picture with the picture stored in Firebase
                            final storageRef = FirebaseStorage.instance
                                .ref()
                                .child('employee_photos/${Employee.id}');
                            final downloadUrl =
                                await storageRef.getDownloadURL();
                            final pic1 = await http.get(Uri.parse(downloadUrl));
                            final bytes1 = pic1.bodyBytes;
                            final pic2 = await pickedFile.readAsBytes();

                            final result = await compareImages(
                              src1: bytes1,
                              src2: pic2,
                              algorithm: PixelMatching(),
                            );
                            print(result);
                            if (result < 0.9) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Cannot slide in"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "The picture you took does not match the picture we have on file.",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        SizedBox(height: 10.0),
                                        TextButton(
                                          child: Text(
                                            "OK",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                              Colors.blue,
                                            ),
                                            padding: MaterialStateProperty.all(
                                              EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 10.0,
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    backgroundColor: Colors.white,
                                    elevation: 5.0,
                                    contentPadding: EdgeInsets.all(20.0),
                                  );
                                },
                              );
                              return; // Do not proceed with check-in
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Successfully Recorded"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }

                            final snap = await FirebaseFirestore.instance
                                .collection("Employee")
                                .where('id', isEqualTo: Employee.employeeId)
                                .get();
                            final snap2 = await FirebaseFirestore.instance
                                .collection("Employee")
                                .doc(snap.docs[0].id)
                                .collection("Record")
                                .doc(DateFormat('dd MMMM yyyy')
                                    .format(DateTime.now()))
                                .get();
                            try {
                              String checkIn = snap2['checkIn'];
                              String checkInLoc = snap2['checkInLocation'];
                              checkOutlocation = location;
                              setState(() {
                                checkOut =
                                    DateFormat('HH:mm').format(DateTime.now());
                              });

                              DateTime checkInTime =
                                  DateFormat('HH:mm').parse(checkIn);
                              DateTime checkOutTime =
                                  DateFormat('HH:mm').parse(checkOut);
                              Duration workingHours =
                                  checkOutTime.difference(checkInTime);
                              DateTime expectedCheckInTime = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  8,
                                  0,
                                  0);
                              if (checkInTime.isAfter(expectedCheckInTime)) {
                                setState(() {
                                  checkInStatus = 'Late';
                                });
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: Text("Late Check-In"),
                                    content: Text("You have checked in late"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              await FirebaseFirestore.instance
                                  .collection("Employee")
                                  .doc(snap.docs[0].id)
                                  .collection("Record")
                                  .doc(DateFormat('dd MMMM yyyy')
                                      .format(DateTime.now()))
                                  .update({
                                'date': Timestamp.now(),
                                'checkIn': checkIn,
                                'checkInLocation': checkInLoc,
                                'checkOut':
                                    DateFormat('HH:mm').format(DateTime.now()),
                                'checkOutLocation': checkOutlocation,
                                'workingHours': workingHours.inMinutes,
                                'checkInStatus':
                                    checkInStatus, // Add check-in status to record
                              });
                            } catch (e) {
                              setState(() {
                                checkIn =
                                    DateFormat('HH:mm').format(DateTime.now());
                              });
                              checkInlocation = location;
                              DateTime expectedCheckInTime = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  8,
                                  0,
                                  0);
                              if (DateTime.now().isAfter(expectedCheckInTime)) {
                                setState(() {
                                  checkInStatus = 'Late';
                                });
                              }
                              await FirebaseFirestore.instance
                                  .collection("Employee")
                                  .doc(snap.docs[0].id)
                                  .collection("Record")
                                  .doc(DateFormat('dd MMMM yyyy')
                                      .format(DateTime.now()))
                                  .set({
                                'date': Timestamp.now(),
                                'checkIn':
                                    DateFormat('HH:mm').format(DateTime.now()),
                                'checkOut': "--/--",
                                'checkOutLocation': "--/--",
                                'checkInLocation': checkInlocation,
                                'workingHours':
                                    0, // Set initial working hours to 0
                                'checkInStatus': checkInStatus,
                              });
                            }
                            if (key.currentState != null) {
                              key.currentState!.reset();
                            }
                          } else {
                            final now = DateTime.now();
                            final workingHourStart =
                                DateTime(now.year, now.month, now.day, 8, 0);
                            final workingHourEnd =
                                DateTime(now.year, now.month, now.day, 17, 0);
                            if (now.isBefore(workingHourStart)) {
                              // User is trying to check-in before working hours
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text("Check-In Error"),
                                  content: Text(
                                      "You cannot check-in before 8:00 AM."),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            } else if (now.isAfter(workingHourEnd)) {
                              // User is trying to check-in after working hours
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text("Check-In Error"),
                                  content: Text(
                                      "You cannot check-in after 5:00 PM."),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              Timer(const Duration(seconds: 3), () async {
                                _getLocation();
                                final snap = await FirebaseFirestore.instance
                                    .collection("Employee")
                                    .where('id', isEqualTo: Employee.employeeId)
                                    .get();
                                final snap2 = await FirebaseFirestore.instance
                                    .collection("Employee")
                                    .doc(snap.docs[0].id)
                                    .collection("Record")
                                    .doc(DateFormat('dd MMMM yyyy')
                                        .format(DateTime.now()))
                                    .get();
                                try {
                                  String checkIn = snap2['checkIn'];
                                  checkInlocation = location;
                                  setState(() {
                                    checkOut = DateFormat('HH:mm')
                                        .format(DateTime.now());
                                  });
                                  await FirebaseFirestore.instance
                                      .collection("Employee")
                                      .doc(snap.docs[0].id)
                                      .collection("Record")
                                      .doc(DateFormat('dd MMMM yyyy')
                                          .format(DateTime.now()))
                                      .update({
                                    'date': Timestamp.now(),
                                    'checkIn': checkIn,
                                    'checkOut': DateFormat('HH:mm')
                                        .format(DateTime.now()),
                                    'checkInLocation': checkInlocation,
                                  });
                                } catch (e) {
                                  checkOutlocation = location;
                                  setState(() {
                                    checkIn = DateFormat('HH:mm')
                                        .format(DateTime.now());
                                  });
                                  await FirebaseFirestore.instance
                                      .collection("Employee")
                                      .doc(snap.docs[0].id)
                                      .collection("Record")
                                      .doc(DateFormat('dd MMMM yyyy')
                                          .format(DateTime.now()))
                                      .set({
                                    'date': Timestamp.now(),
                                    'checkIn': DateFormat('HH:mm')
                                        .format(DateTime.now()),
                                    'checkOut': "--/--",
                                    'checkOutLocation': checkOutlocation,
                                  });
                                }
                                if (key.currentState != null) {
                                  key.currentState!.reset();
                                }
                              });
                            }
                          }
                        },
                      );
                    },
                  ),
                )
              : Card(
                  margin: const EdgeInsets.only(top: 10, bottom: 32),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "You have already checked in & out for today!",
                      style: TextStyle(
                        fontFamily: "NexaRegular",
                        fontSize: screenWidth / 20,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    ));
  }
}



  // final pickedFile = await ImagePicker()
  //                               .getImage(source: ImageSource.camera);
  //                           if (pickedFile == null) {
  //                             // User did not take a picture
  //                             return;
  //                           }

  //                           // Verify the picture with the picture stored in Firebase
  //                           final storageRef = FirebaseStorage.instance
  //                               .ref()
  //                               .child('employee_photos/${Employee.id}');
  //                           final downloadUrl =
  //                               await storageRef.getDownloadURL();
  //                           final pic1 = await http.get(Uri.parse(downloadUrl));
  //                           final bytes1 = pic1.bodyBytes;
  //                           final pic2 = await pickedFile.readAsBytes();

  //                           final result = await compareImages(
  //                               src1: bytes1,
  //                               src2: pic2,
  //                               algorithm: ChiSquareDistanceHistogram());

  //                           if (result < 0.9) {
  //                             showDialog(
  //                               context: context,
  //                               builder: (BuildContext context) {
  //                                 return AlertDialog(
  //                                   title: Text("Cannot slide in"),
  //                                   content: Column(
  //                                     mainAxisSize: MainAxisSize.min,
  //                                     children: [
  //                                       Text(
  //                                         "The picture you took does not match the picture we have on file.",
  //                                         style: TextStyle(
  //                                           fontSize: 16.0,
  //                                         ),
  //                                       ),
  //                                       SizedBox(height: 10.0),
  //                                       TextButton(
  //                                         child: Text(
  //                                           "OK",
  //                                           style: TextStyle(
  //                                             fontSize: 16.0,
  //                                             fontWeight: FontWeight.bold,
  //                                             color: Colors.white,
  //                                           ),
  //                                         ),
  //                                         style: ButtonStyle(
  //                                           backgroundColor:
  //                                               MaterialStateProperty.all(
  //                                             Colors.blue,
  //                                           ),
  //                                           padding: MaterialStateProperty.all(
  //                                             EdgeInsets.symmetric(
  //                                               horizontal: 20.0,
  //                                               vertical: 10.0,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                         onPressed: () {
  //                                           Navigator.of(context).pop();
  //                                         },
  //                                       ),
  //                                     ],
  //                                   ),
  //                                   shape: RoundedRectangleBorder(
  //                                     borderRadius: BorderRadius.circular(20.0),
  //                                   ),
  //                                   backgroundColor: Colors.white,
  //                                   elevation: 5.0,
  //                                   contentPadding: EdgeInsets.all(20.0),
  //                                 );
  //                               },
  //                             );
  //                             return; // Do not proceed with check-in
  //                           } else {
  //                             ScaffoldMessenger.of(context).showSnackBar(
  //                               SnackBar(
  //                                 content: Text("Successfully Recorded"),
  //                                 backgroundColor: Colors.red,
  //                               ),
  //                             );
  //                           }

  // final List<BiometricType> availableBiometrics =
  //                               await localAuth.getAvailableBiometrics();
  //                           print(availableBiometrics);

  //                           bool isAuthenticated = await localAuth.authenticate(
  //                               localizedReason: 'Authenticate to proceed',
  //                               options: const AuthenticationOptions(
  //                                   stickyAuth: true));

  //                           if (!isAuthenticated) {
  //                             // Authentication failed, show an error message
  //                             showDialog(
  //                               context: context,
  //                               builder: (BuildContext context) {
  //                                 return AlertDialog(
  //                                   title: Text("Authentication Failed"),
  //                                   content: Column(
  //                                     mainAxisSize: MainAxisSize.min,
  //                                     children: [
  //                                       Text(
  //                                         "You are not authenticated. Please try again.",
  //                                         style: TextStyle(
  //                                           fontSize: 16.0,
  //                                         ),
  //                                       ),
  //                                       SizedBox(height: 10.0),
  //                                       TextButton(
  //                                         child: Text(
  //                                           "OK",
  //                                           style: TextStyle(
  //                                             fontSize: 16.0,
  //                                             fontWeight: FontWeight.bold,
  //                                             color: Colors.white,
  //                                           ),
  //                                         ),
  //                                         style: ButtonStyle(
  //                                           backgroundColor:
  //                                               MaterialStateProperty.all(
  //                                                   Colors.blue),
  //                                           padding: MaterialStateProperty.all(
  //                                             EdgeInsets.symmetric(
  //                                               horizontal: 20.0,
  //                                               vertical: 10.0,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                         onPressed: () {
  //                                           Navigator.of(context).pop();
  //                                         },
  //                                       ),
  //                                     ],
  //                                   ),
  //                                   shape: RoundedRectangleBorder(
  //                                     borderRadius: BorderRadius.circular(20.0),
  //                                   ),
  //                                   backgroundColor: Colors.white,
  //                                   elevation: 5.0,
  //                                   contentPadding: EdgeInsets.all(20.0),
  //                                 );
  //                               },
  //                             );
  //                             return; // Do not proceed with check-in
  //                           }



// final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
// if (pickedFile == null) {
//   // User did not take a picture
//   return;
// }

// // Verify the picture with the picture stored in Firebase
// final storageRef = FirebaseStorage.instance.ref().child('employee_photos/${Employee.id}');
// final downloadUrl = await storageRef.getDownloadURL();
// final pic1 = await http.get(Uri.parse(downloadUrl));
// final bytes1 = pic1.bodyBytes;
// final pic2 = await pickedFile.readAsBytes();

// // Load the face detector
// final faceDetector = GoogleMlKit.vision.faceDetector();

// // Detect faces in the first image
// final inputImage1 = InputImage.fromBytes(bytes1, inputImageData: InputImageData(imageRotation: 0));
// final faces1 = await faceDetector.processImage(inputImage1);

// // Load the face detector
// final inputImage2 = InputImage.fromBytes(pic2, inputImageData: InputImageData(imageRotation: 0));
// final faces2 = await faceDetector.processImage(inputImage2);

// // Compare the number of detected faces
// if (faces1.isNotEmpty && faces2.isNotEmpty) {
//   // Compare the faces using your chosen comparison algorithm (e.g., PixelMatching)
//   final result = await compareImages(
//     src1: bytes1,
//     src2: pic2,
//     algorithm: PixelMatching(),
//   );
//   print('Face similarity:', result);
// } else {
//   print('No faces detected in one or both images.');
// }

// // Dispose of the face detector
// faceDetector.close();
