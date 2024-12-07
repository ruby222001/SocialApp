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

String formatData(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  String year = dateTime.year.toString();
  String month = dateTime.month.toString();
  String day = dateTime.day.toString();
  String formatteddate = day + '/' + month + '/' + year;
  return formatteddate;
}
