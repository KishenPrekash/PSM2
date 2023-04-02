import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageLeaveScreen extends StatefulWidget {
  @override
  _ManageLeaveScreenState createState() => _ManageLeaveScreenState();
}

class _ManageLeaveScreenState extends State<ManageLeaveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Attendance for ${DateFormat('dd MMMM yyyy').format(DateTime.now())}'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Employee').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<QueryDocumentSnapshot> employees = snapshot.data!.docs;

          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (BuildContext context, int index) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Employee')
                    .doc(employees[index].id)
                    .collection('leaveRequests')
                    .where('status', isEqualTo: 'Pending')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Card(
                      child: ListTile(
                        title: Text('Loading...'),
                      ),
                    );
                  }

                  List<QueryDocumentSnapshot> leaveRequests =
                      snapshot.data!.docs;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: leaveRequests.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> leaveRequestData =
                              leaveRequests[index].data()
                                  as Map<String, dynamic>;
                          DateTime startDate =
                              leaveRequestData['startDate'].toDate();
                          DateTime endDate =
                              leaveRequestData['endDate'].toDate();
                          String leaveType = leaveRequestData['leaveType'];
                          String formattedStartDate =
                              DateFormat('dd MMMM yyyy').format(startDate);
                          String formattedEndDate =
                              DateFormat('dd MMMM yyyy').format(endDate);
                          String reason = leaveRequestData['reason'];

                          return Card(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Leave Type: $leaveType'),
                                  Text('Start Date: $formattedStartDate'),
                                  Text('End Date: $formattedEndDate'),
                                  Text('Reason: $reason'),
                                  ButtonBar(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection("Employee")
                                              .doc(leaveRequests[index]
                                                  .reference
                                                  .parent
                                                  .parent!
                                                  .id)
                                              .collection('leaveRequests')
                                              .doc(leaveRequests[index].id)
                                              .update({'status': 'Approved'});
                                        },
                                        child: Text('Approve'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection("Employee")
                                              .doc(leaveRequests[index]
                                                  .reference
                                                  .parent
                                                  .parent!
                                                  .id)
                                              .collection('leaveRequests')
                                              .doc(leaveRequests[index].id)
                                              .update({'status': 'Rejected'});
                                        },
                                        child: Text('Reject'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
