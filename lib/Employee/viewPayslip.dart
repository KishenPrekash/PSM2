import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_a/model/user.dart';
import 'package:intl/intl.dart';

class PayslipScreen extends StatefulWidget {
  final String employeeId;

  PayslipScreen({required this.employeeId});

  @override
  _PayslipScreenState createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _attendanceRecords = [];
  double _hourlyRate = 20.0;
  double _grossPay = 0.0;
  double _deductions = 0.0;
  double _netPay = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAttendanceRecords();
  }

  void _loadAttendanceRecords() async {
    final attendanceRef = FirebaseFirestore.instance
        .collection("Employee")
        .doc(widget.employeeId)
        .collection("Record");
    final attendanceSnapshot = await attendanceRef
        .where('date', isGreaterThanOrEqualTo: _getMonthStartDate())
        .where('date', isLessThanOrEqualTo: _getMonthEndDate())
        .get();

    final attendanceData =
        attendanceSnapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      _attendanceRecords = attendanceData;
    });

    _calculatePayslip();
  }

  void _calculatePayslip() {
    double totalHoursWorked = 0.0;
    _attendanceRecords.forEach((record) {
      final checkInTime = record['checkInTime'].toDate();
      final checkOutTime = record['checkOutTime'].toDate();
      final hoursWorked = _calculateHours(checkInTime, checkOutTime);
      totalHoursWorked += hoursWorked;
    });

    _grossPay = totalHoursWorked * _hourlyRate;
    _deductions = _grossPay * 0.2; // 20% deduction for taxes, etc.
    _netPay = _grossPay - _deductions;
  }

  double _calculateHours(DateTime startTime, DateTime endTime) {
    final difference = endTime.difference(startTime);
    return difference.inMinutes / 60.0;
  }

  DateTime _getMonthStartDate() {
    return DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  DateTime _getMonthEndDate() {
    final lastDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    return DateTime(
        _selectedDate.year, _selectedDate.month, lastDayOfMonth.day);
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadAttendanceRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payslip'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Month:',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2021),
                      lastDate: DateTime(2030),
                    ).then((date) {
                      if (date != null) {
                        _onDateSelected(date);
                      }
                    });
                  },
                  child: Text(
                    DateFormat.yMMMM().format(_selectedDate),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _attendanceRecords.length,
              itemBuilder: (context, index) {
                final record = _attendanceRecords[index];
                final date = record['date'].toDate();
                final checkInTime = record['checkIn'].toDate();
                final checkOutTime = record['checkOut'].toDate();
                final hoursWorked = _calculateHours(checkInTime, checkOutTime);
                return ListTile(
                  title: Text(DateFormat.yMd().format(date)),
                  subtitle:
                      Text('Hours worked: ${hoursWorked.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gross Pay: ${_grossPay.toStringAsFixed(2)}'),
                Text('Deductions: ${_deductions.toStringAsFixed(2)}'),
                Text('Net Pay: ${_netPay.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
