import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:frontend/helpers/uri_parser/uri_parse.dart';
import 'package:frontend/models/tag.dart';
import 'package:frontend/app_theme.dart';

/// Uploads the algorithm to the database. This function is called when the user
/// presses the [SubmitButton] widget in the [InputScreen].
///
/// The whole process is roughly defined by the following steps:
///
///  - UPLOAD DATA --> get id
///  - GET IMAGE FROM API --> get image bytes
///  - UPLOAD IMAGE TO FIREBASE <-- use the id and image bytes
///  - UPLOAD IMAGE LINK TO SQL DB
///  - UPLOAD TAGS
///
/// In case any step is interrupted or error occurs the changes are undone using
/// the [undoTransactionChanges] internal function and a snackBar is shown to
/// the user.
Future uploadLogic({
  required ScaffoldMessengerState scaffoldMessengerContext,
  required BuildContext context,
  required String title,
  required String description,
  required List<Tag> tags,
  required String code,
  required String mapCode,
  required bool isPython,
}) async {
  final firebase = FirebaseAuth.instance;
  final currentUser = firebase.currentUser;
  final dynamic nodeResponse;
  final http.Response thumbnailResponse;
  final String imageBytes;
  final String imageURL;

  /// Error message snack bar
  SnackBar snackBar({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return SnackBar(
      backgroundColor: color,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 45.0,
          ),
          const SizedBox(width: 5.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.white),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// Delete mechanism to undo previous transactions.
  Future undoTransactionChanges(
      {required int id, required bool fromFirebaseToo}) async {
    // Delete data from SQL database
    final nodeUrl = nodeUri('remove');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      "algo_id": id,
    });
    await http.delete(nodeUrl, headers: headers, body: body);
    // Delete image from firebase storage
    if (fromFirebaseToo) {
      final storageRef = FirebaseStorage.instance.ref();
      final desertRef = storageRef.child("algo_images/$id.jpg");

      await desertRef.delete();
    }
  }

  /// The function navigates back to the input screen by popping all routes until the route with the
  /// name '/inputAlgoDetails' is reached.
  void navigateToInputScreen() {
    Navigator.popUntil(
        context, ModalRoute.withName('/input_algorithm_details'));
  }

  // Upload data to SQL db
  try {
    final nodeUrl = nodeUri('create');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'title': title,
      "code": code,
      "description": description,
      "user_creator": currentUser!.uid,
      "api": isPython ? 1 : 0,
    });
    nodeResponse = await http.post(nodeUrl, headers: headers, body: body);
  } catch (e) {
    // Inform the user
    scaffoldMessengerContext.clearSnackBars();
    scaffoldMessengerContext.showSnackBar(
      snackBar(
        color: GeeLogicColourScheme.red,
        icon: Icons.error_outline_outlined,
        subtitle: e.toString(),
        title: "Something went wrong!",
      ),
    );

    // Navigate to the original input screen
    navigateToInputScreen();
    return;
  }

  // Get id of uploaded algorithm
  final int algoId = jsonDecode(nodeResponse.body)["insertId"];

  // Get thumbnail image
  try {
    final thumbnailUrl = thumbnailUri('get_thumbnail');
    Map<String, String> body = {
      'data': mapCode,
    };
    thumbnailResponse = await http.post(thumbnailUrl, body: body);
    imageBytes = thumbnailResponse.body;
    if (thumbnailResponse.statusCode != 200) {
      throw Exception('There was an error processing the image.');
    }
  } catch (e) {
    // Inform the user
    scaffoldMessengerContext.clearSnackBars();
    scaffoldMessengerContext.showSnackBar(
      snackBar(
        color: GeeLogicColourScheme.red,
        icon: Icons.error_outline_outlined,
        subtitle: e.toString(),
        title: "Something went wrong!",
      ),
    );

    // Undo transaction changes
    await undoTransactionChanges(id: algoId, fromFirebaseToo: false);

    // Navigate to the original input screen
    navigateToInputScreen();
    return;
  }

  // Upload to Firebase
  try {
    List<int> byteData = base64Decode(imageBytes);
    Uint8List uint8List = Uint8List.fromList(byteData);
    final imageStorageRef = FirebaseStorage.instance
        .ref()
        .child('algo_images')
        .child('$algoId.jpg');
    // upload image to firebase
    await imageStorageRef.putData(uint8List);
    imageURL = await imageStorageRef.getDownloadURL();
  } catch (e) {
    // Inform the user
    scaffoldMessengerContext.clearSnackBars();
    scaffoldMessengerContext.showSnackBar(
      snackBar(
        color: GeeLogicColourScheme.red,
        icon: Icons.error_outline_outlined,
        subtitle: e.toString(),
        title: "Something went wrong!",
      ),
    );

    // Undo transaction changes
    await undoTransactionChanges(id: algoId, fromFirebaseToo: false);

    // Navigate to the original input screen
    navigateToInputScreen();
    return;
  }

  // Upload image data to SQL db
  try {
    final imageUrl = nodeUri('add_image');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({"algo_id": algoId, "photo": imageURL});
    final response = await http.patch(imageUrl, headers: headers, body: body);
    if (response.statusCode != 200) {
      throw Exception('There was an error processing the image.');
    }
  } catch (e) {
    // Inform the user
    scaffoldMessengerContext.clearSnackBars();
    scaffoldMessengerContext.showSnackBar(
      snackBar(
        color: GeeLogicColourScheme.red,
        icon: Icons.error_outline_outlined,
        subtitle: e.toString(),
        title: "Something went wrong!",
      ),
    );

    // Undo transaction changes
    await undoTransactionChanges(id: algoId, fromFirebaseToo: true);

    // Navigate to the original input screen
    navigateToInputScreen();
    return;
  }

  // Upload tags data to SQL db
  try {
    for (Tag tag in tags) {
      final tagUrl = nodeUri('add_tag');
      final headers = {'Content-Type': 'application/json'};
      final body = json.encode({
        "algo_id": algoId,
        "tag_id": tag.tagId,
      });
      final response = await http.post(
        tagUrl,
        headers: headers,
        body: body,
      );
      if (response.statusCode != 200) {
        throw Exception('There was an error processing the image.');
      }
    }
  } catch (e) {
    // Inform the user
    scaffoldMessengerContext.clearSnackBars();
    scaffoldMessengerContext.showSnackBar(
      snackBar(
        color: GeeLogicColourScheme.red,
        icon: Icons.error_outline_outlined,
        subtitle: e.toString(),
        title: "Something went wrong!",
      ),
    );

    // Undo transaction changes
    await undoTransactionChanges(id: algoId, fromFirebaseToo: true);

    // Navigate to the original input screen
    navigateToInputScreen();
    return;
  }

  // Show confirmation of successful completion to user to user
  scaffoldMessengerContext.clearSnackBars();
  scaffoldMessengerContext.showSnackBar(
    snackBar(
      color: GeeLogicColourScheme.green,
      icon: Icons.check,
      subtitle: "Your algorithm has been successfully added to our database!",
      title: "Algorithm created",
    ),
  );
}
