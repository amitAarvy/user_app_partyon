// ignore_for_file: file_names, prefer_const_constructors, prefer_const_literals_to_create_immutables


import 'package:flutter/material.dart';
import 'app-constant.dart';

class HeadingWidget extends StatelessWidget {
  final String headingTitle;
  // final String headingSubTitle;
  final VoidCallback onTap;
  final String buttonText;
  final bool hideTrailing;
  const HeadingWidget({
    super.key,
    required this.headingTitle,
    // required this.headingSubTitle,
    required this.onTap,
    required this.buttonText,
    this.hideTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.0,vertical: 0.0),
      child: Padding(
        padding: EdgeInsets.all(2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headingTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
                // Text(
                //   headingSubTitle,
                //   style: TextStyle(
                //     fontWeight: FontWeight.w500,
                //     fontSize: 12.0,
                //     color: Colors.grey,
                //   ),
                // ),
              ],
            ),
            if(!hideTrailing)
              GestureDetector(
                onTap: onTap,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: Color(0x42F30000),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14.0,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
