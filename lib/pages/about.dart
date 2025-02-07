import 'package:flutter/material.dart';
import 'package:travel_agency/data/constants.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 300,
              height: 200,
            ),
            SizedBox(height: 80),
            Text(
              'Version: 1.0.0',
              style: TextStyle(
                fontSize: 18,
                
              ),
            ),
            SizedBox(height: 70),
            Text(
              'Obokash Travel App is your ultimate\n travel companion, offering a wide range of destinations, packages, and experiences to make your travel memorable.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 100),
            Text(
              'Developed by: Ifty Rahman',
              style: TextStyle(
                fontSize: 18,
                
              ),
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.facebook,),
                SizedBox(width: 10),
                Icon(Icons.email),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
