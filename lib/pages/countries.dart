import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_agency/data/constants.dart';
import 'package:travel_agency/pages/packages.dart';

class CountryListPage extends StatefulWidget {
  @override
  _CountryListPageState createState() => _CountryListPageState();
}

class _CountryListPageState extends State<CountryListPage> {
  List<String> countries = [];
  Map<String, String> countryImages = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    getCountries();
  }

  Future<void> getCountries() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Debug print to check if the function is called
      print('Fetching countries...');

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('packages').get();

      // Debug print to check the number of documents
      print('Number of documents: ${snapshot.docs.length}');

      Set<String> uniqueCountries = {};
      Map<String, String> images = {};

      for (var doc in snapshot.docs) {
        // Debug print to check each document
        print('Document data: ${doc.data()}');

        final data = doc.data();
        if (data.containsKey('country') && data['country'] != null) {
          String country = data['country'].toString();
          uniqueCountries.add(country);

          // If this country doesn't have an image yet and this document has one
          if (!images.containsKey(country) &&
              data.containsKey('country_image') &&
              data['country_image'] != null) {
            images[country] = data['country_image'].toString();
          }
        }
      }

      // Debug print the results
      print('Unique countries found: $uniqueCountries');
      print('Country images found: $images');

      if (mounted) {
        setState(() {
          countries = uniqueCountries.toList()..sort();
          countryImages = images;
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching countries: $error');
      if (mounted) {
        setState(() {
          _error = 'Failed to load countries. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Countries",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          // Add a refresh button
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: getCountries,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: getCountries,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (countries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No countries found'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: getCountries,
              child: Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: getCountries,
      child: ListView.builder(
        padding: EdgeInsets.all(15),
        itemCount: countries.length,
        itemBuilder: (context, index) {
          final country = countries[index];
          final imageUrl = countryImages[country];

          return Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 5,
            margin: EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PackagePage(selectedCountry: country),
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Image with error handling
                  imageUrl != null
                      ? Image.network(
                          imageUrl,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image: $error');
                            return Image.asset(
                              'assets/images/placeholder.jpg',
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/placeholder.jpg',
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                  // Overlay
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          // ignore: deprecated_member_use
                          Colors.black.withOpacity(0.2),
                          // ignore: deprecated_member_use
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  // Country name
                  ListTile(
                    title: Center(
                      child: Text(
                        country,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
