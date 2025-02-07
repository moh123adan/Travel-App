import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'admin_login.dart';

class AddDataPage extends StatefulWidget {
  @override
  _AddDataPageState createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage> {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _packageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();

  File? _selectedImage;
  Uint8List? _webImage;
  bool _isLoading = false;
  String? _base64Image;

  Widget _buildImagePreview() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (kIsWeb) {
      if (_webImage != null) {
        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Image.memory(
            _webImage!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      }
    } else {
      if (_selectedImage != null) {
        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Image.file(
            _selectedImage!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    return Center(
      child: Icon(
        Icons.add_a_photo,
        size: 100,
        color: Colors.grey,
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          // Handle web platform
          final bytes = await image.readAsBytes();
          _base64Image = base64Encode(bytes);
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          // Handle mobile platform
          setState(() {
            _selectedImage = File(image.path);
            _webImage = null;
            _base64Image = null;
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      _showErrorDialog('Failed to pick image. Please try again.');
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _webImage = null;
      _base64Image = null;
    });
  }

  Future<String?> _uploadImageToImgBB() async {
    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse('https://api.imgbb.com/1/upload');
      late http.MultipartRequest request;
      late http.StreamedResponse response;

      if (kIsWeb) {
        // For web platform, use base64 data
        if (_base64Image != null) {
          final body = {
            'key': '45a7b0069a5542187628a448ca0ea525',
            'image': _base64Image,
          };

          final response = await http.post(uri, body: body);

          if (response.statusCode == 200) {
            final jsonData = jsonDecode(response.body);
            return jsonData['data']['url'];
          }
        }
      } else {
        // For mobile platform, use file upload
        if (_selectedImage != null) {
          request = http.MultipartRequest('POST', uri)
            ..fields['key'] = '45a7b0069a5542187628a448ca0ea525'
            ..files.add(
              await http.MultipartFile.fromPath(
                'image',
                _selectedImage!.path,
              ),
            );

          response = await request.send();

          if (response.statusCode == 200) {
            final responseData = await response.stream.toBytes();
            final responseString = String.fromCharCodes(responseData);
            final jsonData = jsonDecode(responseString);
            return jsonData['data']['url'];
          }
        }
      }

      print('Failed to upload image. Status code: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error uploading image to ImgBB: $e');
      return null;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addPackageData() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_selectedImage != null || _webImage != null) {
        imageUrl = await _uploadImageToImgBB();
        if (imageUrl == null) {
          _showErrorDialog('Failed to upload image. Please try again.');
          return;
        }
      }

      await FirebaseFirestore.instance.collection('packages').add({
        'city': _cityController.text.trim(),
        'country': _countryController.text.trim(),
        'package': _packageController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': int.parse(_priceController.text.trim()),
        'days': int.parse(_daysController.text.trim()),
        if (imageUrl != null) 'country_image': imageUrl,
        'created_at': FieldValue.serverTimestamp(),
      });

      _showSuccessDialog();
      _clearForm();
    } catch (e) {
      print('Error adding package data: $e');
      _showErrorDialog('Failed to add package. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _validateInputs() {
    if (_cityController.text.isEmpty ||
        _countryController.text.isEmpty ||
        _packageController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _daysController.text.isEmpty) {
      _showErrorDialog('Please fill in all fields');
      return false;
    }
    try {
      int.parse(_priceController.text.trim());
      int.parse(_daysController.text.trim());
    } catch (e) {
      _showErrorDialog('Price and days must be valid numbers');
      return false;
    }
    return true;
  }

  void _clearForm() {
    _cityController.clear();
    _countryController.clear();
    _packageController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _daysController.clear();
    setState(() {
      _selectedImage = null;
      _webImage = null;
      _base64Image = null;
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    _countryController.dispose();
    _packageController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Package added successfully!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Travel Package'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AdminLoginPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _countryController,
                    decoration: InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _packageController,
                    decoration: InputDecoration(
                      labelText: 'Package Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _daysController,
                    decoration: InputDecoration(
                      labelText: 'Number of Days',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  _buildImagePreview(),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _pickImage,
                        icon: Icon(Icons.add_photo_alternate),
                        label: Text('Add Image'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _clearImage,
                        icon: Icon(Icons.clear),
                        label: Text('Clear Image'),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addPackageData,
                      child: Text('Add Package'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
