import 'package:flutter/material.dart';
import 'package:flutter_test_a/model/user.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PayslipScreen extends StatefulWidget {
  const PayslipScreen({Key? key}) : super(key: key);

  @override
  _PayslipScreenState createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().month;
    _selectedYear = DateTime.now().year;
  }

  void _onMonthChanged(int? value) {
    setState(() {
      _selectedMonth = value!;
    });
  }

  void _onYearChanged(int? value) {
    setState(() {
      _selectedYear = value!;
    });
  }

  void _downloadPayslip() async {
    String selectedMonth = _months[_selectedMonth - 1];
    String payslipFileName = 'Payslip_${selectedMonth}_$_selectedYear.pdf';

    // Query the attendance records for the selected month and year
    QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
        .collection('Employee')
        .doc(Employee.id) // replace with the employee's ID
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
      totalWorkingHours += workingHours.inHours;
    }

    // Calculate the salary based on the total working hours
    double hourlyRate = 10.0; // replace with the employee's hourly rate
    double totalSalary = totalWorkingHours * hourlyRate;

    // Create the PDF document
    final pdfLib.Document pdf = pdfLib.Document();

    pdf.addPage(
      pdfLib.Page(
        build: (pdfLib.Context context) {
          return pdfLib.Center(
            child: pdfLib.Column(
              mainAxisAlignment: pdfLib.MainAxisAlignment.center,
              children: <pdfLib.Widget>[
                pdfLib.Text(
                  'Payslip for ${selectedMonth} ${_selectedYear}',
                  style: pdfLib.TextStyle(
                    fontSize: 20.0,
                    fontWeight: pdfLib.FontWeight.bold,
                  ),
                ),
                pdfLib.SizedBox(height: 20.0),
                pdfLib.Text(
                  'Total working hours: ${totalWorkingHours} hours',
                  style: pdfLib.TextStyle(fontSize: 16.0),
                ),
                pdfLib.SizedBox(height: 10.0),
                pdfLib.Text(
                  'Hourly rate: ${hourlyRate}',
                  style: pdfLib.TextStyle(fontSize: 16.0),
                ),
                pdfLib.SizedBox(height: 10.0),
                pdfLib.Text(
                  'Total salary: ${totalSalary}',
                  style: pdfLib.TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Get the directory for saving the file
    final Directory directory = await getApplicationDocumentsDirectory();
    final String documentPath = directory.path;

    // Save the PDF file
    final File file = File('$documentPath/$payslipFileName');
    await file.writeAsBytes(await pdf.save());

    // Open the PDF file
    //OpenFile.open('$documentPath/$payslipFileName');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payslip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select month:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            DropdownButton<int>(
              value: _selectedMonth,
              onChanged: _onMonthChanged,
              items: List.generate(_months.length, (index) {
                return DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text(_months[index]),
                );
              }),
            ),
            SizedBox(height: 16),
            Text(
              'Select year:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            DropdownButton<int>(
              value: _selectedYear,
              onChanged: _onYearChanged,
              items: List.generate(10, (index) {
                int year = DateTime.now().year - index;
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text(year.toString()),
                );
              }),
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _downloadPayslip,
                child: Text('Download Payslip'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
