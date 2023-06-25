import 'dart:io';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_excel/excel.dart' as excel;
import 'package:pdf/widgets.dart' as pw;
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
    int workingDays = 0;
    int absentDays = 0;
    int approvedLeaveDays = 0;
    int totalWorkingDays = 0;
    String selectedMonth =
        DateFormat('MMMM').format(DateTime(2000, _selectedMonth, 1));
    String payslipFileName = 'Payslip_${selectedMonth}_$_selectedYear.pdf';

    for (int day = 1;
        day <= DateTime(_selectedYear, _selectedMonth + 1, 0).day;
        day++) {
      DateTime currentDate = DateTime(_selectedYear, _selectedMonth, day);

      // Check if the current date is a weekday (Monday to Friday)
      if (currentDate.weekday >= 1 && currentDate.weekday <= 5) {
        totalWorkingDays++;
      }
    }

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
    double totalWorkingHours = 0;
    for (QueryDocumentSnapshot record in attendanceSnapshot.docs) {
      DateTime checkIn = DateFormat('hh:mm').parse(record['checkIn']);
      DateTime checkOut = record['checkOut'] != '--/--'
          ? DateFormat('hh:mm').parse(record['checkOut'])
          : DateTime.now();
      Duration workingHours = checkOut.difference(checkIn);
      totalWorkingHours += workingHours.inHours;
      workingDays++;
    }

    QuerySnapshot leaveSnapshot = await FirebaseFirestore.instance
        .collection('Employee')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('leaveRequests')
        .where('status', isEqualTo: 'Approved')
        .get();

    for (QueryDocumentSnapshot record in leaveSnapshot.docs) {
      DateTime startDate = record['startDate'].toDate();
      DateTime endDate = record['endDate'].toDate();

      // Check if the leave period overlaps with the selected month
      if (startDate.year == _selectedYear &&
          startDate.month == _selectedMonth) {
        // Calculate the number of days in the leave period
        int leaveDays = endDate.difference(startDate).inDays + 1;

        // Increment absentDays for each leave day
        absentDays += leaveDays;

        // Increment approvedLeaveDays for each leave day
        approvedLeaveDays += leaveDays;
      }
    }

    double regularHours = totalWorkingHours / 1;
    double overtimeHours = 0;
    double totalEarnings = regularHours * 8;
    String earningsDescription =
        '- Regular Hours (${regularHours.toStringAsFixed(1)} x 8/hour): \$${totalEarnings.toStringAsFixed(2)}';

    // Create the PDF document
    final pdf = pw.Document();

    // Create the PDF content
    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => <pw.Widget>[
          pw.Header(
            level: 0,
            child: pw.Text('Employee Name: $employeeName'),
          ),
          pw.Header(
            level: 1,
            child: pw.Text('Pay Period: $selectedMonth $_selectedYear'),
          ),
          pw.Header(
            level: 1,
            child: pw.Text('Working Days: $workingDays'),
          ),
          pw.Header(
            level: 1,
            child: pw.Text('Approved Leave Days: $approvedLeaveDays'),
          ),
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              [
                'Date',
                'Check In',
                'Check In Location',
                'Check Out',
                'Check Out Location',
                'Working Hours (seconds)'
              ],
              // Attendance records
              ...attendanceSnapshot.docs.map((record) => [
                    DateFormat('MMMM d, yyyy')
                        .format(record['date'].toDate())
                        .toString(),
                    record['checkIn'].toString(),
                    record['checkInLocation'].toString(),
                    record['checkOut'].toString(),
                    record['checkOutLocation'].toString(),
                    record['workingHours'] != null
                        ? record['workingHours'].toString()
                        : '-',
                  ]),
            ],
          ),
          pw.Header(
            level: 1,
            child: pw.Text('Total Hours Worked: $totalWorkingHours'),
          ),
          pw.Header(
            level: 1,
            child: pw.Text('Earnings'),
          ),
          pw.Text(earningsDescription),
        ],
      ),
    );

    Directory? directory = await getExternalStorageDirectory();

    if (directory != null) {
      String filePath = '${directory.path}/$payslipFileName';

      final File file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      if (await file.exists()) {
        // ignore: use_build_context_synchronously
        CoolAlert.show(
          context: context,
          type: CoolAlertType.success,
          text: 'Payslip downloaded to $filePath!',
        );
      } else {
        // ignore: use_build_context_synchronously
        CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          title: 'Oops...',
          text: 'Sorry, something went wrong',
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
    }
  }
}
