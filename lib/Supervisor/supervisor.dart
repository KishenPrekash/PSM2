import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_a/Supervisor/ViewAttendance.dart';
import 'package:flutter_test_a/Supervisor/editProfile.dart';
import 'package:flutter_test_a/Supervisor/employeeList.dart';
import 'package:flutter_test_a/Supervisor/manageLeave.dart';
import 'package:flutter_test_a/model/user.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../login.dart';

class SupervisorScr extends StatefulWidget {
  const SupervisorScr({super.key});

  @override
  State<SupervisorScr> createState() => _SupervisorScrState();
}

class _SupervisorScrState extends State<SupervisorScr> {
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = const Color(0xffeef444c);

  int currentIndex = 0;

  List<IconData> navigationIcons = [
    FontAwesomeIcons.peopleGroup,
    FontAwesomeIcons.clipboardUser,
    FontAwesomeIcons.user,
    FontAwesomeIcons.wpforms,
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getId();
  }

  Future<void> _getId() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("Supervisor")
        .where('id', isEqualTo: Supervisor.supervisorId)
        .get();

    setState(() {
      Supervisor.supervisorId = snap.docs[0].id;
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
          new EmployeeList(),
          new AttendanceScreen(),
          new EditProfileScreen(uid: Supervisor.supervisorId),
          new ManageLeaveScreen(),
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
