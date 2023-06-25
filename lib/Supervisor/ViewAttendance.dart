import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int lateCount = 0;
  int absentCount = 0;
  int punctualCount = 0;

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
          calculateSummary(employees);
          return Column(
            children: [
              SizedBox(height: 16),
              Text(
                'Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        lateCount.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        'Late',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        absentCount.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Absent',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        punctualCount.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Punctual',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot employee = employees[index];
                    String name = employee['id'];
                    String position = 'Employee';
                    String id = employee.id;
                    String department = employee['dept'];

                    Stream<DocumentSnapshot> recordStream = FirebaseFirestore
                        .instance
                        .collection('Employee')
                        .doc(id)
                        .collection('Record')
                        .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                        .snapshots();

                    return StreamBuilder<DocumentSnapshot>(
                      stream: recordStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        }

                        Map<String, dynamic>? record =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        String checkInTime = record?['checkIn'] ?? '';
                        String checkOutTime = record?['checkOut'] ?? '';

                        Color containerColor;
                        if (checkInTime.compareTo('07:30 AM') > 0) {
                          // employee is absent
                          containerColor = Colors.red;
                        } else if (checkInTime.isEmpty ||
                            checkOutTime.isEmpty) {
                          // employee is late
                          containerColor = Colors.grey;
                        } else {
                          // employee is punctual
                          containerColor = Colors.green;
                        }

                        return Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        position,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        department, // Display the department value
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      checkInTime,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: checkInTime.isEmpty
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      checkOutTime,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: checkOutTime.isEmpty
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
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
          );
        },
      ),
    );
  }

  void calculateSummary(List<QueryDocumentSnapshot> employees) async {
    int lateCount = 0;
    int absentCount = 0;
    int punctualCount = 0;

    // Create a list of futures that will complete when all stream listeners finish
    List<Future> futures = [];

    for (QueryDocumentSnapshot employee in employees) {
      Future<DocumentSnapshot> recordFuture = FirebaseFirestore.instance
          .collection('Employee')
          .doc(employee.id)
          .collection('Record')
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();

      futures.add(recordFuture.then((snapshot) {
        Map<String, dynamic>? record = snapshot.data() as Map<String, dynamic>?;
        if (record == null) {
          absentCount++;
        } else {
          String checkInTime = record['checkIn'] ?? '';
          String checkOutTime = record['checkOut'] ?? '';
          if (checkInTime.isEmpty || checkOutTime.isEmpty) {
            absentCount++;
          } else if (checkInTime.compareTo('08:00 AM') > 0) {
            lateCount++;
          } else {
            punctualCount++;
          }
        }
      }));
    }

    // Wait for all futures to complete before updating the state
    await Future.wait(futures);

    setState(() {
      this.lateCount = lateCount;
      this.absentCount = absentCount;
      this.punctualCount = punctualCount;
    });
  }
}
