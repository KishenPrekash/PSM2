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
                          // Show employee details
                          // ...
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
                              backgroundImage: empData['photo'] != null
                                  ? NetworkImage(empData['photo'])
                                  : null,
                              child: empData['photo'] == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 30.0,
                                      color: Colors.white,
                                    )
                                  : null,
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
