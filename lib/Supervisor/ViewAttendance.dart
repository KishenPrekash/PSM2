import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
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
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Employee')
                    .doc(employees[index].id)
                    .collection('Record')
                    .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Card(
                      child: ListTile(
                        title: Text('Loading...'),
                      ),
                    );
                  }

                  Map<String, dynamic>? record =
                      snapshot.data!.data() as Map<String, dynamic>?;

                  String name = record?['name'] ?? '';
                  String checkInTime = record?['checkIn'] ?? '';
                  String checkInLocation = record?['checkInLocation'] ?? '';
                  String checkOutTime = record?['checkOut'] ?? '';
                  String checkOutLocation = record?['checkOutLocation'] ?? '';

                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8.0),
                          Text('Check-In Time: $checkInTime'),
                          Text('Check-In Location: $checkInLocation'),
                          Text('Check-Out Time: $checkOutTime'),
                          Text('Check-Out Location: $checkOutLocation'),
                        ],
                      ),
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
