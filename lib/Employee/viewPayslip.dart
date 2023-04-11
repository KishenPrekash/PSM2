import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test_a/model/user.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';

class PayslipScreen extends StatefulWidget {
  @override
  _PayslipScreenState createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> {
  late String selectedMonth;
  late String selectedYear;
  double hourlyRate = 20.0; // Change this to the employee's actual hourly rate
  List<Map<String, dynamic>> attendanceData = [];

  Future<void> getAttendanceData() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("Employee")
        .where('id', isEqualTo: Users.userId)
        .get();

    String formattedMonth = DateFormat.MMMM()
        .format(DateTime.parse("2023-" + selectedMonth + "-01"));
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Employee")
        .doc(snap.docs[0].id)
        .collection("Record")
        .where('date',
            isGreaterThanOrEqualTo: DateTime(int.parse(selectedYear),
                DateTime.parse(formattedMonth).month, 1),
            isLessThan: DateTime(int.parse(selectedYear),
                DateTime.parse(formattedMonth).month + 1, 1))
        .get();

    setState(() {
      List<Map<String, dynamic>> attendanceData = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  double calculateTotalHours() {
    double totalHours = 0.0;
    attendanceData.forEach((record) {
      DateTime checkIn = record['checkIn'].toDate();
      DateTime checkOut = record['checkOut'].toDate();
      Duration duration = checkOut.difference(checkIn);
      totalHours += duration.inMinutes / 60.0;
    });
    return totalHours;
  }

  double calculateSalary() {
    double totalHours = calculateTotalHours();
    return totalHours * hourlyRate;
  }

  Future<void> generatePayslip() async {
    final pdf = pw.Document();
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("Employee")
        .where('id', isEqualTo: Users.userId)
        .get();
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Payslip for ${selectedMonth} ${selectedYear}',
                style: pw.TextStyle(fontSize: 20),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Employee ID: ${snap.docs[0].id}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Total hours worked: ${calculateTotalHours()}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Hourly rate: \$${hourlyRate}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Total salary: \$${calculateSalary()}',
                style: pw.TextStyle(fontSize: 16),
              ),
            ],
          );
        },
      ),
    );
    // Save the PDF file to device storage and get the file path
    final String filePath = await savePDF(pdf);
    // TODO: Provide a download link to the employee
  }

  Future<String> savePDF(pw.Document pdf) async {
    // Save the PDF file to device storage and return the
// file path
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/payslip.pdf");
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payslip'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select month and year:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedMonth,
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                    });
                  },
                  items: List.generate(
                          12,
                          (index) => DateFormat.yMMM()
                              .format(DateTime(2000, index + 1)))
                      .map((month) => DropdownMenuItem(
                            value: month,
                            child: Text(month),
                          ))
                      .toList(),
                  hint: Text('Month'),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedYear,
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                    });
                  },
                  items:
                      List.generate(10, (index) => DateTime.now().year - index)
                          .map((year) => DropdownMenuItem(
                                value: year.toString(),
                                child: Text(year.toString()),
                              ))
                          .toList(),
                  hint: Text('Year'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await getAttendanceData();
                await generatePayslip();
              },
              child: Text('Download Payslip'),
            ),
          ],
        ),
      ),
    );
  }
}
