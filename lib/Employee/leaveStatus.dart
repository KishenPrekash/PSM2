import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_a/Employee/applyLeave.dart';
import 'package:flutter_test_a/model/user.dart';
import 'package:intl/intl.dart';

class LeaveStatusScreen extends StatefulWidget {
  final String userId;
  Color primary = const Color(0xffeef444c);

  LeaveStatusScreen({required this.userId});

  @override
  _LeaveStatusScreenState createState() => _LeaveStatusScreenState();
}

class _LeaveStatusScreenState extends State<LeaveStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.primary,
        title: Text('Leave Status'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                _showBottomSheet(context);
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
            .doc(Employee.id)
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
              IconData statusIcon;
              Color statusIconColor;
              DateTime startDate = leaveRequest['startDate'].toDate();
              DateTime endDate = leaveRequest['endDate'].toDate();
              DateTime currentDate = DateTime.now();

              if (currentDate.isAfter(endDate) ||
                  startDate.isBefore(currentDate)) {
                leaveRequest.reference.update({'status': 'Expired'});
                statusIcon = Icons.warning;
                statusIconColor = Colors.yellow;
              } else {
                switch (leaveRequest['status']) {
                  case 'Approved':
                    statusIcon = Icons.check;
                    statusIconColor = Colors.green;

                    break;
                  case 'Rejected':
                    statusIcon = Icons.close;
                    statusIconColor = Colors.red;
                    break;
                  case 'Expired':
                    statusIcon = Icons.warning;
                    statusIconColor = Colors.grey;
                    break;
                  default:
                    statusIcon = Icons.warning;
                    statusIconColor = Colors.yellow;
                }
              }

              return Card(
                margin: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 2.0,
                child: ListTile(
                  title: Text(
                    leaveRequest['leaveType'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5.0),
                      Text(
                        'Start Date: ${DateFormat('EEE, MMM d, yyyy').format(startDate)}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        'End Date: ${DateFormat('EEE, MMM d, yyyy').format(endDate)}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        'Status: ${leaveRequest['status']}',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        color: statusIconColor,
                        size: 30.0,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 30.0,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Delete leave request'),
                                  content: Text(
                                      'Are you sure you want to delete this leave request?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Delete'),
                                      onPressed: () {
                                        _deleteLeaveRequest(leaveRequest);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                      ),
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

Future<void> _deleteLeaveRequest(DocumentSnapshot leaveRequest) async {
  try {
    await leaveRequest.reference.delete();
  } catch (e) {
    print('Error deleting leave request: $e');
  }
}

void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => LeaveRequestScreen(),
  );
}
