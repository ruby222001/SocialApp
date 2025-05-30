import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//display error message to user
void displayMessageToUser(String message, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(message),
          ));
}

String formatData(dynamic timestamp) {
  DateTime dateTime;

  if (timestamp is Timestamp) {
    dateTime = timestamp.toDate();
  } else if (timestamp is String) {
    dateTime = DateTime.tryParse(timestamp) ?? DateTime.now();
  } else {
    return "Invalid date";
  }

  String year = dateTime.year.toString();
  String month = dateTime.month.toString().padLeft(2, '0');
  String day = dateTime.day.toString().padLeft(2, '0');
  String formattedDate = '$day/$month/$year';
  return formattedDate;
}
