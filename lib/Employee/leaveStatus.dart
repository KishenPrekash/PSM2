import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_a/Employee/applyLeave.dart';
import 'package:flutter_test_a/model/user.dart';
import 'package:intl/intl.dart';

class LeaveStatusScreen extends StatelessWidget {
  final String userId;
  Color primary = const Color(0xffeef444c);

  LeaveStatusScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: Text('Leave Status'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeaveRequestScreen(),
                  ),
                );
              },
              child: const Icon(
                Icons.add,
                size: 26.0,
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Employee")
            .doc(Users.id)
            .collection("leaveRequests")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No leave requests found.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final leaveRequest = snapshot.data!.docs[index];

              return Card(
                child: ListTile(
                  title: Text(leaveRequest['leaveType']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5.0),
                      Text(
                          'Start Date: ${DateFormat('EEE, MMM d, yyyy').format(leaveRequest['startDate'].toDate())}'),
                      SizedBox(height: 5.0),
                      Text(
                          'End Date: ${DateFormat('EEE, MMM d, yyyy').format(leaveRequest['endDate'].toDate())}'),
                      SizedBox(height: 5.0),
                      Text('Reason: ${leaveRequest['reason']}'),
                      SizedBox(height: 5.0),
                      Text('Status: ${leaveRequest['status']}'),
                    ],
                  ),
                ),
              );
              Container();
            },
          );
        },
      ),
    );
  }
}
