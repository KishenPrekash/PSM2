import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test_a/model/user.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';

import 'package:mailer/smtp_server.dart';

class ManageLeaveScreen extends StatefulWidget {
  @override
  _ManageLeaveScreenState createState() => _ManageLeaveScreenState();
}

class _ManageLeaveScreenState extends State<ManageLeaveScreen> {
  void addToHistoryCollection(
      String supervisorId, Map<String, dynamic> leaveRequestData) {
    // Assuming you have a "supervisorId" variable available
    FirebaseFirestore.instance
        .collection('Supervisor')
        .doc(supervisorId)
        .collection('history')
        .add(leaveRequestData)
        .then((value) {
      print('Leave request added to history collection');
    }).catchError((error) {
      print('Failed to add leave request to history collection: $error');
    });
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'History',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Supervisor')
                      .doc(Supervisor.supervisorId)
                      .collection('history')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text('Loading...');
                    }

                    List<QueryDocumentSnapshot> historyItems =
                        snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: historyItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        Map<String, dynamic> leaveRequestData =
                            historyItems[index].data() as Map<String, dynamic>;
                        String name = leaveRequestData['requestBy'];
                        DateTime startDate =
                            leaveRequestData['startDate'].toDate();
                        DateTime endDate = leaveRequestData['endDate'].toDate();
                        String leaveType = leaveRequestData['leaveType'];
                        String formattedStartDate =
                            DateFormat('dd MMMM yyyy').format(startDate);
                        String formattedEndDate =
                            DateFormat('dd MMMM yyyy').format(endDate);
                        String reason = leaveRequestData['reason'];
                        String status = leaveRequestData['status'];

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
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Leave Type: $leaveType',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Start Date: $formattedStartDate',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'End Date: $formattedEndDate',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Reason: $reason',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Status: $status',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
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
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            color: Colors.black,
            onPressed: () {
              _showBottomSheet(context);
            },
          ),
        ],
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
                    return const Card(
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
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: leaveRequests.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> empData =
                            employees[index].data() as Map<String, dynamic>;
                        Map<String, dynamic> leaveRequestData =
                            leaveRequests[index].data() as Map<String, dynamic>;
                        String name = leaveRequestData['requestBy'];
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
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Leave Type: $leaveType',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Start Date: $formattedStartDate',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'End Date: $formattedEndDate',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Reason: $reason',
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Confirm Approval'),
                                              content: const Text(
                                                  'Are you sure you want to approve this request?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('Approve'),
                                                  onPressed: () {
                                                    // Update the status to "Approved"
                                                    FirebaseFirestore.instance
                                                        .collection("Employee")
                                                        .doc(leaveRequests[
                                                                index]
                                                            .reference
                                                            .parent
                                                            .parent!
                                                            .id) // assuming user.uid is the ID of the employee
                                                        .get()
                                                        .then((DocumentSnapshot
                                                            documentSnapshot) async {
                                                      if (documentSnapshot
                                                          .exists) {
                                                        String employeeEmail =
                                                            documentSnapshot[
                                                                'email'];

                                                        // Update the leave request status to "Approved"
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "Employee")
                                                            .doc(leaveRequests[
                                                                    index]
                                                                .reference
                                                                .parent
                                                                .parent!
                                                                .id)
                                                            .collection(
                                                                'leaveRequests')
                                                            .doc(leaveRequests[
                                                                    index]
                                                                .id)
                                                            .update({
                                                          'status': 'Approved'
                                                        });
                                                        Map<String, dynamic>
                                                            leaveRequestData = {
                                                          'requestBy': name,
                                                          'startDate':
                                                              startDate,
                                                          'endDate': endDate,
                                                          'leaveType':
                                                              leaveType,
                                                          'reason': reason,
                                                          'status': 'Approved',
                                                        };

                                                        addToHistoryCollection(
                                                            Supervisor
                                                                .supervisorId,
                                                            leaveRequestData);

                                                        // Send email to the employee
                                                        String username =
                                                            'ttasting66@outlook.com';
                                                        String password =
                                                            'Kp211200@';

                                                        final smtpServer =
                                                            SmtpServer(
                                                                'smtp.office365.com',
                                                                port: 587,
                                                                ssl: false,
                                                                username:
                                                                    username,
                                                                password:
                                                                    password);
                                                        final message =
                                                            Message()
                                                              ..from = Address(
                                                                  username,
                                                                  'Admin')
                                                              ..recipients.add(
                                                                  employeeEmail)
                                                              ..subject =
                                                                  'Leave Request Approved'
                                                              ..text =
                                                                  'Your leave request has been approved.';

                                                        try {
                                                          final sendReport =
                                                              await send(
                                                                  message,
                                                                  smtpServer);
                                                          // ignore: use_build_context_synchronously
                                                          CoolAlert.show(
                                                            context: context,
                                                            type: CoolAlertType
                                                                .success,
                                                            text:
                                                                'Message sent: ${sendReport.toString()}',
                                                          );
                                                        } on MailerException catch (e) {
                                                          // ignore: use_build_context_synchronously
                                                          CoolAlert.show(
                                                            context: context,
                                                            type: CoolAlertType
                                                                .success,
                                                            text:
                                                                'Message not sent. ${e.toString()}',
                                                          );
                                                        }
                                                      } else {
                                                        print(
                                                            'Document does not exist on the database');
                                                      }
                                                    });
                                                    // Close the dialog box
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
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
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Confirm Rejection'),
                                              content: const Text(
                                                  'Are you sure you want to reject this request?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('Reject'),
                                                  onPressed: () {
                                                    // Update the status to "Rejected"
                                                    FirebaseFirestore.instance
                                                        .collection("Employee")
                                                        .doc(leaveRequests[
                                                                index]
                                                            .reference
                                                            .parent
                                                            .parent!
                                                            .id) // assuming user.uid is the ID of the employee
                                                        .get()
                                                        .then((DocumentSnapshot
                                                            documentSnapshot) async {
                                                      if (documentSnapshot
                                                          .exists) {
                                                        String employeeEmail =
                                                            documentSnapshot[
                                                                'email'];

                                                        // Update the leave request status to "Approved"
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "Employee")
                                                            .doc(leaveRequests[
                                                                    index]
                                                                .reference
                                                                .parent
                                                                .parent!
                                                                .id)
                                                            .collection(
                                                                'leaveRequests')
                                                            .doc(leaveRequests[
                                                                    index]
                                                                .id)
                                                            .update({
                                                          'status': 'Rejected'
                                                        });
                                                        Map<String, dynamic>
                                                            leaveRequestData = {
                                                          'requestBy': name,
                                                          'startDate':
                                                              startDate,
                                                          'endDate': endDate,
                                                          'leaveType':
                                                              leaveType,
                                                          'reason': reason,
                                                          'status': 'Rejected',
                                                        };

                                                        addToHistoryCollection(
                                                            Supervisor
                                                                .supervisorId,
                                                            leaveRequestData);

                                                        // Send email to the employee
                                                        String username =
                                                            'ttasting66@outlook.com';
                                                        String password =
                                                            'Kp211200@';

                                                        final smtpServer =
                                                            SmtpServer(
                                                                'smtp.office365.com',
                                                                port: 587,
                                                                ssl: false,
                                                                username:
                                                                    username,
                                                                password:
                                                                    password);
                                                        final message =
                                                            Message()
                                                              ..from = Address(
                                                                  username,
                                                                  'Admin')
                                                              ..recipients.add(
                                                                  employeeEmail)
                                                              ..subject =
                                                                  'Leave Request Rejected'
                                                              ..text =
                                                                  'Your leave request has been rejected.';

                                                        try {
                                                          final sendReport =
                                                              await send(
                                                                  message,
                                                                  smtpServer);
                                                          // ignore: use_build_context_synchronously
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  SnackBar(
                                                            content: Text(
                                                                'Message sent: ${sendReport.toString()}'),
                                                          ));
                                                        } on MailerException catch (e) {
                                                          // ignore: use_build_context_synchronously
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  SnackBar(
                                                            content: Text(
                                                                'Message not sent. ${e.toString()}'),
                                                          ));
                                                        }
                                                      } else {
                                                        print(
                                                            'Document does not exist on the database');
                                                      }
                                                    });
                                                    // Close the dialog box
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
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
