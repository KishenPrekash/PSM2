import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_a/model/user.dart';
import 'package:intl/intl.dart';

class LeaveStatusScreen extends StatelessWidget {
  final String userId;

  LeaveStatusScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Status'),
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
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
