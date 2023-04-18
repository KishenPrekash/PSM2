import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 10),
            Text(
              'Employee List',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          }

          final employees = snapshot.data!.docs;

          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> empData =
                  employees[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 2.0,
                margin: EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 5.0,
                ),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  title: Text(
                    empData['id'],
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    empData['role'],
                    style: TextStyle(fontSize: 16.0),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[200],
                    backgroundImage: empData['photo'] != null
                        ? NetworkImage(empData['photo'])
                        : null,
                    child: empData['photo'] == null
                        ? Icon(
                            Icons.person,
                            size: 30.0,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      bool shouldDelete = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Delete Employee"),
                          content: Text(
                              "Are you sure you want to delete this employee?"),
                          actions: <Widget>[
                            TextButton(
                              child: Text("Cancel"),
                              onPressed: () => Navigator.pop(context, false),
                            ),
                            TextButton(
                              child: Text("Delete"),
                              onPressed: () => Navigator.pop(context, true),
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
              );
            },
          );
        },
      ),
    );
  }
}
