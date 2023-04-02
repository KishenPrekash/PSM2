import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_a/model/user.dart';
import 'package:intl/intl.dart';

class EmployeeScreen extends StatefulWidget {
  @override
  _EmployeeScreenState createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  late Stream<QuerySnapshot> _recordsStream;
  late List<DocumentSnapshot> _records = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Payslips'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Employee")
            .doc(Users.id)
            .collection("Record")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No records found.'),
            );
          }

          // Group records by month and year
          Map<String, List<DocumentSnapshot>> recordsByMonth = {};
          for (var record in snapshot.data!.docs) {
            var monthYear =
                DateFormat('MMMM yyyy').format(record['date'].toDate());
            if (recordsByMonth[monthYear] == null) {
              recordsByMonth[monthYear] = [];
            }
            recordsByMonth[monthYear]!.add(record);
          }

          // Build list of month headers and payslips
          List<Widget> monthWidgets = [];
          recordsByMonth.forEach((monthYear, records) {
            var payPeriod =
                DateFormat('MMM yyyy').format(records[0]['date'].toDate());
            var totalHours = 0.0;
            var totalPay = 0.0;
            records.forEach((record) {
              if (record['checkIn'] != "--/--" &&
                  record['checkOut'] != "--/--") {
                DateTime checkInDateTime =
                    DateFormat('HH:mm').parse(record['checkIn']);
                DateTime checkOutDateTime =
                    DateFormat('HH:mm').parse(record['checkOut']);
                if (checkInDateTime != null && checkOutDateTime != null) {
                  var duration = checkOutDateTime.difference(checkInDateTime);
                  totalHours += duration.inMinutes / 60.0;
                  totalPay += duration.inMinutes / 60.0 * 15.0; // $15 per hour
                }
              }
            });
            var payWidget = Column(
              children: [
                Text('Pay Period: $payPeriod'),
                Text('Total Hours: ${totalHours.toStringAsFixed(2)}'),
                Text('Total Pay: \$$totalPay'),
              ],
            );
            monthWidgets.addAll([Divider(), payWidget]);
          });

          return ListView(children: monthWidgets);
        },
      ),
    );
  }
}
