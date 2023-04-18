import 'dart:async';
import 'dart:io';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:image_compare/image_compare.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_a/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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

  Color primary = const Color(0xffeef444c);

  @override
  void initState() {
    super.initState();
    _getRecord();
  }

  void _getLocation() async {
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
              "Welcome,",
              style: TextStyle(
                color: Colors.black54,
                fontFamily: "NexaRegular",
                fontSize: screenWidth / 20,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "Employee " + Employee.employeeId,
              style: TextStyle(
                fontFamily: "NexaBold",
                fontSize: screenWidth / 18,
              ),
            ),
          ),
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
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(2, 2),
                ),
              ],
              borderRadius: BorderRadius.circular(10),
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
                          fontFamily: "NexaBold",
                          fontSize: 25,
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
                  margin: const EdgeInsets.only(top: 24, bottom: 12),
                  child: Builder(
                    builder: (context) {
                      final GlobalKey<SlideActionState> key = GlobalKey();

                      return SlideAction(
                        text: checkIn == "--/--"
                            ? "Slide to Check In"
                            : "Slide to Check Out",
                        textStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: screenWidth / 20,
                            fontFamily: "NexaRegular"),
                        outerColor: Colors.white,
                        innerColor: primary,
                        key: key,
                        onSubmit: () async {
                          if (Employee.lat != 0) {
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
                              String checkInLoc = snap2['checkInLocation'];
                              checkOutlocation = location;
                              setState(() {
                                checkOut =
                                    DateFormat('hh:mm').format(DateTime.now());
                              });

                              DateTime checkInTime =
                                  DateFormat('hh:mm').parse(checkIn);
                              DateTime checkOutTime =
                                  DateFormat('hh:mm').parse(checkOut);
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
                                ElegantNotification.error(
                                        title: Text("Late"),
                                        description:
                                            Text("You have slide in late"))
                                    .show(context);
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
                                    DateFormat('hh:mm').format(DateTime.now()),
                                'checkOutLocation': checkOutlocation,
                                'workingHours': workingHours.inMinutes,
                                'checkInStatus':
                                    checkInStatus, // Add check-in status to record
                              });
                            } catch (e) {
                              setState(() {
                                checkIn =
                                    DateFormat('hh:mm').format(DateTime.now());
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
                                    DateFormat('hh:mm').format(DateTime.now()),
                                'checkOut': "--/--",
                                'checkOutLocation': "--/--",
                                'checkInLocation': checkInlocation,
                                'workingHours':
                                    0, // Set initial working hours to 0
                                'checkInStatus': checkInStatus,
                              });
                            }
                            key.currentState!.reset();
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
                                    checkOut = DateFormat('hh:mm')
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
                                    'checkOut': DateFormat('hh:mm')
                                        .format(DateTime.now()),
                                    'checkInLocation': checkInlocation,
                                  });
                                } catch (e) {
                                  checkOutlocation = location;
                                  setState(() {
                                    checkIn = DateFormat('hh:mm')
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
                                    'checkIn': DateFormat('hh:mm')
                                        .format(DateTime.now()),
                                    'checkOut': "--/--",
                                    'checkOutLocation': checkOutlocation,
                                  });
                                }
                                key.currentState!.reset();
                              });
                            }
                          }
                        },
                      );
                    },
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 32),
                  child: Text(
                    "You have already check in & out for today! ",
                    style: TextStyle(
                      fontFamily: "NexaRegular",
                      fontSize: screenWidth / 20,
                      color: Colors.black54,
                    ),
                  ),
                ),
          Column(
            children: [
              if (checkInlocation != "")
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Colors.blue[200]!,
                      width: 1.0,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: Colors.blue[300], size: 20),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "Check In Location: " + checkInlocation,
                          style: TextStyle(
                            fontFamily: "NexaRegular",
                            fontSize: 15,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (checkOutlocation != "")
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Colors.orange[200]!,
                      width: 1.0,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: Colors.orange[300], size: 20),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "Check Out Location: " + checkOutlocation,
                          style: TextStyle(
                            fontFamily: "NexaRegular",
                            fontSize: 15,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          )
        ],
      ),
    ));
  }
}
