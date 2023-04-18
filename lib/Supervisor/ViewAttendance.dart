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
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 10),
            Text(
              'Attendance for ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
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
                  Map<String, dynamic> empData =
                      employees[index].data() as Map<String, dynamic>;

                  String name = empData['id'] ?? '';
                  String checkInTime = record?['checkIn'] ?? '';
                  String checkInLocation = record?['checkInLocation'] ?? '';
                  String checkOutTime = record?['checkOut'] ?? '';
                  String checkOutLocation = record?['checkOutLocation'] ?? '';

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          if (record == null)
                            Text(
                              'No record found',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600],
                              ),
                            ),
                          if (checkInTime.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.timer),
                                SizedBox(width: 8),
                                Text(checkInTime),
                              ],
                            ),
                          if (checkInLocation.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.location_on),
                                SizedBox(width: 8),
                                Text(checkInLocation),
                              ],
                            ),
                          if (checkOutTime.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.timer_off),
                                SizedBox(width: 8),
                                Text(checkOutTime),
                              ],
                            ),
                          if (checkOutLocation.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.location_on),
                                SizedBox(width: 8),
                                Text(checkOutLocation),
                              ],
                            ),
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
