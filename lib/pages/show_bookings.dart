import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting

class ShowBookingsPage extends StatefulWidget {
  @override
  _ShowBookingsPageState createState() => _ShowBookingsPageState();
}

class _ShowBookingsPageState extends State<ShowBookingsPage> {
  late String? _userEmail;
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _getUserEmail();
  }

  void _getUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email;
      });
      _fetchBookings();
    }
  }

  void _fetchBookings() {
    FirebaseFirestore.instance
        .collection('bookings')
        .where('email', isEqualTo: _userEmail)
        .get()
        .then((querySnapshot) {
      setState(() {
        _bookings = querySnapshot.docs.map((doc) => doc.data()).toList();
      });
    }).catchError((error) {
      print('Failed to fetch bookings: $error');
      // Handle error
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
      ),
      body: _userEmail == null
          ? Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(child: Text('No bookings found'))
              : ListView.builder(
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    // Check if the 'date' field is not null
                    final date = booking['date'];
                    final formattedDate = date != null
                        ? DateFormat('dd-MM-yyyy')
                            .format((date as Timestamp).toDate())
                        : 'N/A';
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Material(
                        borderRadius: BorderRadius.circular(15),
                        elevation: 5,
                        child: ListTile(
                          title: Text(
                            'Package: ${booking['package']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Date: $formattedDate', // Use formatted date
                            style: TextStyle(fontSize: 16),
                          ),
                          tileColor: Colors.blue[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          trailing: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.cancel),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
