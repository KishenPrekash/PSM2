import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class EmployeeList extends StatelessWidget {
  final CollectionReference _employeeCollectionRef =
      FirebaseFirestore.instance.collection('Employee');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Employee List',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _employeeCollectionRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 16.0),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }

          final employees = snapshot.data!.docs;
          Map<String, List<Map<String, dynamic>>> employeesByDepartment = {};

          // Group employees by department
          for (var employee in employees) {
            Map<String, dynamic> empData =
                employee.data() as Map<String, dynamic>;
            String department = empData['dept'];

            if (employeesByDepartment.containsKey(department)) {
              employeesByDepartment[department]!.add(empData);
            } else {
              employeesByDepartment[department] = [empData];
            }
          }

          return ListView.builder(
            itemCount: employeesByDepartment.length,
            itemBuilder: (context, index) {
              String department = employeesByDepartment.keys.elementAt(index);
              List<Map<String, dynamic>> departmentEmployees =
                  employeesByDepartment[department]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      department,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: departmentEmployees.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> empData = departmentEmployees[index];

                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              if (empData['firstName'] == null) {
                                return Container(
                                  height: 300.0,
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'No record found.',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Container(
                                  height: 300.0,
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              empData['firstName'] +
                                                  ' ' +
                                                  empData['lastName'],
                                              style: const TextStyle(
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            empData['id'],
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
                                      const SizedBox(height: 16.0),
                                      Text(
                                        'Email: ${empData['email']}',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 16.0),
                                      Text(
                                        'Birth Date: ${empData['birthDate']}',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 16.0),
                                      Text(
                                        'Address: ${empData['address']}',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          );
                        },
                        child: Card(
                          elevation: 2.0,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 5.0,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            title: Text(
                              empData['id'],
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              empData['role'],
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            leading: CircleAvatar(
  backgroundColor: Colors.blue[200],
  child: const Icon(
    Icons.person,
    size: 30.0,
    color: Colors.white,
  ),
),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                bool shouldDelete = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Delete Employee"),
                                    content: const Text(
                                        "Are you sure you want to delete this employee?"),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text("Cancel"),
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                      ),
                                      TextButton(
                                        child: const Text("Delete"),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                      ),
                                    ],
                                  ),
                                );
                                if (shouldDelete == true) {
                                  await _employeeCollectionRef
                                      .doc(employees[index].id)
                                      .delete();
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
