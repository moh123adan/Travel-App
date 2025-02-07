import 'package:flutter/material.dart';

class TextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;
  final String? updatedText; // New parameter for updated text value

  const TextBox({
    Key? key,
    required this.text,
    required this.sectionName,
    required this.onPressed,
    this.updatedText, // Initialize with null
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 10,
        bottom: 17,
        top: 5,
      ),
      margin: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionName,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              IconButton(
                onPressed: onPressed,
                icon: Icon(Icons.settings),
              ),
            ],
          ),
          Text(
            updatedText ?? text, // Use updatedText if it's not null
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}