import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_agency/data/constants.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<RegisterPage> {
  // Text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneNumberController =
      TextEditingController(); // New controller for phone number

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    _usernameController.dispose();
    _phoneNumberController.dispose(); // Dispose the new controller
    super.dispose();
  }

  Future<void> signUp(BuildContext context) async {
    // Show loading dialog
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(
              color: kPrimaryColor,
            ),
          );
        });

    if (passwordConfirmed()) {
      if (_passwordController.text.trim().length >= 6) {
        try {
          // Check if email already exists in Firestore
          final existingUser = await FirebaseFirestore.instance
              .collection('users')
              .doc(_emailController.text.trim())
              .get();

          if (existingUser.exists) {
            // Show snackbar if email already exists
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    "Email already exists! Try logging in or use a different email"),
                duration: Duration(seconds: 5),
              ),
            );
            return; // Stop execution
          }

          // Create user in Firebase Authentication
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          // Save user details to Firestore with email as document ID
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_emailController.text.trim())
              .set({
            'email': _emailController.text.trim(),
            'username': _usernameController.text.trim(),
            'phoneNumber':
                _phoneNumberController.text.trim(), // Save phone number
          });

          // User successfully created
        } catch (error) {
          // Handle any errors
          print("Error creating user: $error");
          // Show error message in a Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${error.toString()}"),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Show password length error message in a Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Password should be 6 or more characters!"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Show password mismatch error message in a Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Passwords do not match!"),
          duration: Duration(seconds: 2),
        ),
      );
    }
    Navigator.of(context).pop(); // Close loading dialog
  }

  bool passwordConfirmed() {
    return _passwordController.text.trim() ==
        _confirmpasswordController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/logo.png', // Replace 'assets/logo.png' with your logo image path
                width: 350,
                height: 250,
              ),
              SizedBox(height: 15),
              Text(
                "Ready to travel?",
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 173, 216, 230),
                ),
              ),
              Text(
                'Register below with your details.',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 50),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: MaterialTextField(
                  controller: _usernameController,
                  keyboardType: TextInputType.text,
                  hint: 'Username',
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.person_outline),
                  suffixIcon: const Icon(Icons.text_fields),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: MaterialTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  hint: 'Email',
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.email_outlined),
                  suffixIcon: const Icon(Icons.check),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: MaterialTextField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  hint: 'Phone Number',
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.phone),
                  suffixIcon: const Icon(Icons.phone_android),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: MaterialTextField(
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  hint: 'Password',
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: const Icon(Icons.visibility_off),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: MaterialTextField(
                  controller: _confirmpasswordController,
                  keyboardType: TextInputType.visiblePassword,
                  hint: 'Confirm Password',
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: const Icon(Icons.visibility_off),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: InkWell(
                  onTap: () => signUp(context),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 87, 185, 255), // Updated color
                        borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already a member?"),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: Text(
                        " Login now",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
