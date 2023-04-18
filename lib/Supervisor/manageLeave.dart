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
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 10),
            Text(
              'Manage Leave Requests',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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

                  return Container(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: leaveRequests.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> empData =
                            employees[index].data() as Map<String, dynamic>;
                        Map<String, dynamic> leaveRequestData =
                            leaveRequests[index].data() as Map<String, dynamic>;
                        String name = empData['id'];
                        DateTime startDate =
                            leaveRequestData['startDate'].toDate();
                        DateTime endDate = leaveRequestData['endDate'].toDate();
                        String leaveType = leaveRequestData['leaveType'];
                        String formattedStartDate =
                            DateFormat('dd MMMM yyyy').format(startDate);
                        String formattedEndDate =
                            DateFormat('dd MMMM yyyy').format(endDate);
                        String reason = leaveRequestData['reason'];

                        return Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Request By: $name',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Leave Type: $leaveType',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Start Date: $formattedStartDate',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'End Date: $formattedEndDate',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Reason: $reason',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
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
                                      child: Text(
                                        'Approve',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        primary: Colors.green,
                                      ),
                                    ),
                                    ElevatedButton(
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
                                      child: Text(
                                        'Reject',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        primary: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
