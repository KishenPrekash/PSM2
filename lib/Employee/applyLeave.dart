import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_a/Employee/employee.dart';
import 'package:flutter_test_a/Employee/leaveStatus.dart';
import 'package:flutter_test_a/model/user.dart';
import 'package:intl/intl.dart';

class LeaveRequestScreen extends StatefulWidget {
  @override
  _LeaveRequestScreenState createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final leaveTypes = ['Vacation', 'Sick', 'Personal', 'Other'];
  String selectedLeaveType = 'Vacation';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String reason = '';
  String status = '';

  Color primary = const Color(0xffeef444c);

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  Future<void> _submitLeaveRequest() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("Employee")
        .where('id', isEqualTo: Users.userId)
        .get();

    FirebaseFirestore.instance
        .collection("Employee")
        .doc(snap.docs[0].id)
        .collection('leaveRequests')
        .add({
      'leaveType': selectedLeaveType,
      'startDate': startDate,
      'endDate': endDate,
      'reason': reason,
      'status': "Pending",
    }).then((value) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Leave Request Submitted'),
          content: Text('Your leave request has been submitted.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => LeaveRequestScreen()));
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to submit leave request.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => LeaveRequestScreen()));
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        title: Text('Leave Request'),
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          },
          child: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Leave Type',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: selectedLeaveType,
                onChanged: (value) {
                  setState(() {
                    selectedLeaveType = value!;
                  });
                },
                items: leaveTypes.map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20.0),
              Text(
                'Start Date',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('EEE, MMM d, yyyy').format(startDate)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: primary),
                    onPressed: () => _selectStartDate(context),
                    child: Text('Select'),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Text(
                'End Date',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('EEE, MMM d, yyyy').format(endDate)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: primary),
                    onPressed: () => _selectEndDate(context),
                    child: Text('Select'),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Text(
                'Reason for Leave',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                maxLines: null,
                onChanged: (value) {
                  setState(() {
                    reason = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter reason for leave',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: primary),
                  onPressed: () => _submitLeaveRequest(),
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
