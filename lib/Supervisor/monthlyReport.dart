import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MonthlyReport extends StatefulWidget {
  @override
  _MonthlyReportState createState() => _MonthlyReportState();
}

class _MonthlyReportState extends State<MonthlyReport> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  Future<void> _generateMonthlyReportPdf() async {
    DateTime selectedDate = DateTime(_selectedYear, _selectedMonth, 1);

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Employee').get();

    List<Employee> employeeList = [];
    int totalWorkingDays = 0;

    for (QueryDocumentSnapshot employeeSnapshot in snapshot.docs) {
      String employeeId = employeeSnapshot.id;
      DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
          .collection('Employee')
          .doc(employeeId)
          .get();
      String employeeName = employeeDoc.get('id');

      QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
          .collection('Employee')
          .doc(employeeId)
          .collection('Record')
          .where('date', isGreaterThanOrEqualTo: selectedDate)
          .where('date', isLessThan: selectedDate.add(Duration(days: 30)))
          .get();

      int workingDays = 0;
      int absentDays = 0;

      for (QueryDocumentSnapshot attendanceDoc in attendanceSnapshot.docs) {
        if (attendanceDoc.exists && attendanceDoc.data() != null) {
          Map<String, dynamic>? attendanceData =
              attendanceDoc.data() as Map<String, dynamic>?;

          if (attendanceData != null && attendanceData.containsKey('checkIn')) {
            DateTime attendanceDate =
                (attendanceData['date'] as Timestamp).toDate();
            if (_isWorkingDay(attendanceDate)) {
              totalWorkingDays++;
              workingDays++;
            } else {
              totalWorkingDays++;
              absentDays++;
            }
          }
        }
      }

      QuerySnapshot leaveSnapshot = await FirebaseFirestore.instance
          .collection('Employee')
          .doc(employeeId)
          .collection('leaveRequests')
          .where('status', isEqualTo: 'Approved')
          .get();

      int leavesTaken = 0;

      for (QueryDocumentSnapshot leaveDoc in leaveSnapshot.docs) {
        DateTime startDate = leaveDoc['startDate'].toDate();
        DateTime endDate = leaveDoc['endDate'].toDate();

        if (startDate.month == selectedDate.month &&
            endDate.month == selectedDate.month) {
          // Start and end dates are in the same selected month
          leavesTaken++;
        }
      }
      employeeList.add(
        Employee(
          employeeId: employeeId,
          employeeName: employeeName,
          workingDays: workingDays,
          leavesTaken: leavesTaken,
          absentDays: absentDays,
        ),
      );
    }
    int totalActualWorkingDays = _getTotalActualWorkingDays(selectedDate);
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Monthly Report - ${DateFormat('MMMM yyyy').format(selectedDate)}',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20),
              ),
              pw.SizedBox(height: 16),
              pw.Text('Total Employees: ${employeeList.length}'),
              pw.SizedBox(height: 16),
              pw.Text('Employee Report:',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 16)),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                context: context,
                data: [
                  [
                    'Employee Name',
                    'Working Days',
                    'Leaves Taken',
                    'Absent Days'
                  ],
                  for (var employee in employeeList)
                    [
                      employee.employeeName,
                      employee.workingDays.toString(),
                      employee.leavesTaken.toString(),
                      (totalActualWorkingDays -
                              employee.workingDays -
                              employee.leavesTaken)
                          .toString(),
                    ],
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getExternalStorageDirectory();
    final file = File('${output!.path}/monthly_report.pdf');
    await file.writeAsBytes(await pdf.save());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('PDF Generated'),
        content: Text(
            'Monthly report PDF generated successfully.\n\nPath: ${file.path}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  bool _isWorkingDay(DateTime date) {
    return date.weekday != DateTime.saturday && date.weekday != DateTime.sunday;
  }

  int _getTotalActualWorkingDays(DateTime selectedDate) {
    int totalDays = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    int totalWeekends = 0;

    for (int i = 1; i <= totalDays; i++) {
      DateTime currentDate = DateTime(selectedDate.year, selectedDate.month, i);
      if (!_isWorkingDay(currentDate)) {
        totalWeekends++;
      }
    }

    int totalActualWorkingDays = totalDays - totalWeekends;
    return totalActualWorkingDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Monthly Report',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics,
                size: 100,
                color: Colors.blue,
              ),
              SizedBox(height: 16),
              Text(
                'Select Month',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
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
                      DateFormat('MMMM').format(DateTime(2000, index + 1, 1)),
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }),
              ),
              SizedBox(height: 24),
              Text(
                'Select Year',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
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
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _generateMonthlyReportPdf,
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Download Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Employee {
  final String employeeId;
  final int workingDays;
  final String employeeName;
  final int leavesTaken;
  final int absentDays;

  Employee({
    required this.employeeId,
    required this.workingDays,
    required this.employeeName,
    required this.leavesTaken,
    required this.absentDays,
  });
}
