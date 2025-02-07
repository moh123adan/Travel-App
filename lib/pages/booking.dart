import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:travel_agency/widgets/confirmed_screen.dart';

import '../widgets/confirmed.dart';

class BookingPage extends StatefulWidget {
  final String country;
  final String city;
  final String package;
  final String price;
  final String days;

  const BookingPage({
    Key? key,
    required this.country,
    required this.city,
    required this.package,
    required this.price,
    required this.days,
  }) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? _selectedDate;
  int _numberOfPersons = 1;
  int _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _calculateTotalPrice();
  }

  void _calculateTotalPrice() {
    setState(() {
      _totalPrice = int.parse(widget.price) * _numberOfPersons;
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<bool> _processStripePayment() async {
    // This is a mock implementation. In a real app, you would integrate with Stripe SDK here.
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    return true; // Always return success for this example
  }

  void _navigateToConfirmScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ConfirmScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Country: ${widget.country}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'City: ${widget.city}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Package: ${widget.package}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Duration: ${widget.days} days',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Price per person: ${widget.price}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Select Date:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Number of Persons:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      if (_numberOfPersons > 1) {
                        setState(() {
                          _numberOfPersons--;
                          _calculateTotalPrice();
                        });
                      }
                    },
                  ),
                  Text(
                    '$_numberOfPersons',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _numberOfPersons++;
                        _calculateTotalPrice();
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Total Price: $_totalPrice',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select a date!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      bool paymentSuccess = await _processStripePayment();
                      if (paymentSuccess) {
                        String? userEmail =
                            FirebaseAuth.instance.currentUser?.email;
                        if (userEmail != null) {
                          await FirebaseFirestore.instance
                              .collection('bookings')
                              .add({
                            'country': widget.country,
                            'city': widget.city,
                            'package': widget.package,
                            'days': widget.days,
                            'price': _totalPrice,
                            'date': _selectedDate,
                            'numberOfPersons': _numberOfPersons,
                            'email': userEmail,
                          });
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Payment successful!')),
                        );
                        _navigateToConfirmScreen();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Payment failed!')),
                        );
                      }
                    }
                  },
                  child: Text('Book Now with Stripe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

