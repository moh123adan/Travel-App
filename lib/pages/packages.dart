import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_agency/data/constants.dart';
import 'package:travel_agency/data/get_data.dart';
import 'package:travel_agency/pages/booking.dart'; // Import the BookingPage

class PackagePage extends StatefulWidget {
  final String selectedCountry;

  const PackagePage({Key? key, required this.selectedCountry})
      : super(key: key);

  @override
  State<PackagePage> createState() => _PackagePageState();
}

class _PackagePageState extends State<PackagePage> {
  List<String> docIDs = [];
  bool isLoading = true; // Add a boolean to track loading state

  @override
  void initState() {
    super.initState();
    getdocID(); // Call getdocID function when the widget is initialized
  }

  Future<void> getdocID() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("packages")
        .where("country", isEqualTo: widget.selectedCountry)
        .get();

    final uniqueDocIDs = <String>{};

    snapshot.docs.forEach((document) {
      uniqueDocIDs.add(document.reference.id);
    });

    setState(() {
      docIDs = uniqueDocIDs.toList();
      isLoading = false; // Set loading state to false after data is fetched
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Packages",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
            ),
            Text(
              "        CHOOSE\n YOUR PACKAGE!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            // Show a loading indicator while data is being fetched
            isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: ListView.builder(
                        itemCount: docIDs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: Material(
                              borderRadius: BorderRadius.circular(15),
                              elevation: 5,
                              child: ListTile(
                                onTap: () async {
                                  // Retrieve package details from Firestore
                                  DocumentSnapshot packageSnapshot =
                                      await FirebaseFirestore.instance
                                          .collection("packages")
                                          .doc(docIDs[
                                              index]) // Assuming docIDs contains document IDs of packages
                                          .get();

                                  // Extract package name and price
                                  String packageName = packageSnapshot[
                                      'package']; 
                                  String cityName = packageSnapshot[
                                      'city'];
                                  String days = packageSnapshot['days']
                                      .toString(); // Convert to String
                                  String packagePrice = packageSnapshot['price']
                                      .toString(); // Convert to String

                                  // Navigate to BookingPage with package, price, and country
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookingPage(
                                        country: widget.selectedCountry,
                                        city: cityName,
                                        package: packageName,
                                        price: packagePrice,
                                        days: days,
                                      ),
                                    ),
                                  );
                                },
                                title:
                                    GetPackageData(documentId: docIDs[index]),
                                tileColor: kPrimaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}