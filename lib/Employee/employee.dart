import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_a/Employee/AttendanceHistory.dart';
import 'package:flutter_test_a/Employee/EmpProfile.dart';
import 'package:flutter_test_a/Employee/attendance.dart';
import 'package:flutter_test_a/Employee/leaveStatus.dart';
import 'package:flutter_test_a/Employee/viewPayslip.dart';
import 'package:flutter_test_a/services/location_services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_test_a/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  bool userAvailable = false;

  Color primary = const Color(0xffeef444c);

  int currentIndex = 0;

  List<IconData> navigationIcons = [
    FontAwesomeIcons.check,
    FontAwesomeIcons.calendar,
    FontAwesomeIcons.user,
    FontAwesomeIcons.wpforms,
    FontAwesomeIcons.moneyBill1Wave,
  ];
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    _startLocationService();
    getId().then((value) {
      _getCredentials();
      _getProfilePic();
    });
  }

  void _getCredentials() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(Employee.id)
          .get();

      setState(() {
        Employee.profilePicLink = doc['photo'];
        Employee.canEdit = doc['canEdit'];
        Employee.firstName = doc['firstName'];
        Employee.lastName = doc['lastName'];
        Employee.address = doc['address'];
        Employee.birthDate = doc['birthDate'];
      });
    } catch (e) {
      e.toString();
    }
  }

  void _getProfilePic() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("Employee")
        .doc(Employee.id)
        .get();

    setState(() {
      if ((doc.data()! as Map<String, dynamic>).containsKey('photo')) {
        Employee.profilePicLink = doc['photo'];
        Employee.canEdit = doc['canEdit'];
        Employee.firstName = doc['firstName'];
        Employee.lastName = doc['lastName'];
        Employee.address = doc['address'];
        Employee.birthDate = doc['birthDate'];
      }
    });
  }

  void _startLocationService() async {
    LocationService().initialze();

    LocationService().getLongitude().then((value) {
      setState(() {
        Employee.long = value!;
      });

      LocationService().getLatitude().then((value) {
        setState(() {
          Employee.lat = value!;
        });
      });
    });
  }

  Future<void> getId() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("Employee")
        .where('id', isEqualTo: Employee.employeeId)
        .get();

    setState(() {
      Employee.id = snap.docs[0].id;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          new AttendanceScreen(),
          new CalendarScreen(),
          new EmployeProfile(),
          new LeaveStatusScreen(userId: Employee.employeeId),
          new PayslipScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < navigationIcons.length; i++) ...<Expanded>{
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = i;
                      });
                    },
                    child: Container(
                      height: screenHeight,
                      width: screenWidth,
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              navigationIcons[i],
                              color:
                                  i == currentIndex ? primary : Colors.black54,
                              size: i == currentIndex ? 30 : 26,
                            ),
                            i == currentIndex
                                ? Container(
                                    margin: EdgeInsets.only(top: 6),
                                    height: 3,
                                    width: 22,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(40)),
                                      color: primary,
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              }
            ],
          ),
        ),
      ),
    );
  }
}
