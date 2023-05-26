import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_excel/excel.dart' as excel;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class PayslipScreen extends StatefulWidget {
  const PayslipScreen({Key? key}) : super(key: key);

  @override
  _PayslipScreenState createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

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
              'Payslip',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Select Month:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 16),
                  DropdownButton<int>(
                    value: _selectedMonth,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedMonth = value!;
                      });
                    },
                    items: List.generate(12, (index) {
                      return DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text(
                          DateFormat('MMMM')
                              .format(DateTime(2000, index + 1, 1)),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Select Year:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 16),
                  DropdownButton<int>(
                    value: _selectedYear,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedYear = value!;
                      });
                    },
                    items: List.generate(5, (index) {
                      int year = DateTime.now().year - index;
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(
                          year.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _downloadPayslip,
              child: Text('Download Payslip'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPayslip() async {
    String selectedMonth =
        DateFormat('MMMM').format(DateTime(2000, _selectedMonth, 1));
    String payslipFileName = 'Payslip_${selectedMonth}_$_selectedYear.xlsx';

    // Query the employee's information
    DocumentSnapshot employeeSnapshot = await FirebaseFirestore.instance
        .collection('Employee')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    String employeeName = employeeSnapshot['id'];

    // Query the attendance records for the selected month and year
    QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
        .collection('Employee')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Record')
        .where('date',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(DateTime(_selectedYear, _selectedMonth, 1)))
        .where('date',
            isLessThanOrEqualTo: Timestamp.fromDate(
                DateTime(_selectedYear, _selectedMonth + 1, 0)))
        .get();

    // Calculate the total working hours for the month
    int totalWorkingHours = 0;
    for (QueryDocumentSnapshot record in attendanceSnapshot.docs) {
      DateTime checkIn = DateFormat('hh:mm').parse(record['checkIn']);
      DateTime checkOut = record['checkOut'] != '--/--'
          ? DateFormat('hh:mm').parse(record['checkOut'])
          : DateTime.now();
      Duration workingHours = checkOut.difference(checkIn);
      totalWorkingHours += workingHours.inMinutes;
    }

    // Calculate earnings
    double regularHours = totalWorkingHours / 60;
    double overtimeHours = 0;
    double totalEarnings = regularHours * 8;
    String earningsDescription =
        '- Regular Hours (${regularHours.toStringAsFixed(1)} x 8/hour): \$${totalEarnings.toStringAsFixed(2)}';

    // Create the Excel workbook and worksheet
    final workbook = Excel.createExcel();
    final sheetName =
        'Sheet_${DateFormat('MMMM_yyyy').format(DateTime(_selectedYear, _selectedMonth, 1))}';
    final sheet = workbook[sheetName];

    // Write the employee name and pay period
    sheet.appendRow(['Employee Name: $employeeName']);
    sheet.appendRow(['Pay Period: $selectedMonth $_selectedYear']);
    sheet.appendRow([]);

    // Write the header row
    sheet.appendRow([
      'Date',
      'Check In',
      'Check In Location',
      'Check Out',
      'Check Out Location',
      'Working Hours'
    ]);

    // Write the attendance records to the worksheet
    for (QueryDocumentSnapshot record in attendanceSnapshot.docs) {
      String date =
          DateFormat('MMMM d, yyyy').format(record['date'].toDate()).toString();
      String checkIn = record['checkIn'].toString();
      String checkInLocation = record['checkInLocation'].toString();
      String checkOut = record['checkOut'].toString();
      String checkOutLocation = record['checkOutLocation'].toString();
      String workingHours = record['workingHours'] != null
          ? record['workingHours'].toString()
          : '-';

      sheet.appendRow([
        date,
        checkIn,
        checkInLocation,
        checkOut,
        checkOutLocation,
        workingHours
      ]);
    }
    sheet.appendRow([]);

    // Write the total working hours to the worksheet
    sheet.appendRow(
        ['Total Hours Worked:', '', '', '', '', totalWorkingHours.toString()]);
    sheet.appendRow([]);

    sheet.appendRow(['Earnings']);
    sheet.appendRow([earningsDescription]);
    sheet.appendRow([]);

    Directory? directory = await getExternalStorageDirectory();

    if (directory != null) {
      String filePath = path.join(directory.path, payslipFileName);

      // Write the total working hours to the worksheet
      sheet.appendRow(
          ['Total Working Hours:', '', '', '', '', totalWorkingHours]);

      // Save the Excel file to device storage
      final encoded = workbook.encode();
      File(filePath).writeAsBytesSync(encoded!);

      File file = File(filePath);
      if (await file.exists()) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Payslip downloaded to $filePath'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('An error occurred while downloading the payslip.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }
}
