import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NotesProvider with ChangeNotifier {
  bool isLoading = false;
  File? _selectedPicture;
  File? get getSelectedImage => _selectedPicture;
  Future<void> getAllNotes() async {}
  Future<bool> createNewNote(Map<String, dynamic> noteContent) async {
    try {
      isLoading = true;
      notifyListeners();
      // uploadPictureToStorage
      String _imageUrl = await _uploadPictureToStorage();
      if (_imageUrl != "") {
        noteContent["data"]["images"] = [_imageUrl];
      }
      await FirebaseFirestore.instance.collection("notes").add(noteContent);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Error: ${e.toString()}");
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> editExistingNote(String noteReference) async {
    noteReference = "3GQwByAbcKTipsc5KaWc";

    var noteContent = {
      "color": "${Colors.blue.toString()}",
      "createdAt": Timestamp.fromDate(DateTime.now()),
      "type": "normal",
      "userId": "3pyvimYIOuPuWCvEuy5QSmeebAp1",
      "data": {
        "audios": [],
        "images": [""],
        "details": "updated Note",
        "title": "Updated Note",
      }
    };
    await FirebaseFirestore.instance
        .collection("notes")
        .doc(noteReference)
        .set(noteContent);
    isLoading = false;
    notifyListeners();
  }

  Future<void> removeExistingNote(String noteReference) async {
    noteReference = "3GQwByAbcKTipsc5KaWc";
    await FirebaseFirestore.instance
        .collection("notes")
        .doc(noteReference)
        .delete();
    isLoading = false;
    notifyListeners();
  }

  Future<void> findByName(String name) async {
    final lowerCaseName = name.toLowerCase();

    final querySnapshot = await FirebaseFirestore.instance
        .collection("notes")
        .where('title', isEqualTo: lowerCaseName)
        .get();

    // Process query results (handle the notes fetched based on your needs)
    // This example simply prints the retrieved note titles
    for (var doc in querySnapshot.docs) {
      print(doc.get('title'));
    }
  }

  Future<void> sortByDate(String noteReference) async {}

  Future<String> _uploadPictureToStorage() async {
    //implementar logica para guardar imagen en storage y obtener su url
    try {
      if (_selectedPicture == null) return "";
      //definir upload task
      var stamp = DateTime.now();
      UploadTask task = FirebaseStorage.instance
          .ref("notas/imagen_${stamp}.png")
          .putFile(_selectedPicture!);
      //ejecutartask
      await task;
      //recuperar la url
      return await task.storage
          .ref("notas/imagen_${stamp}.png")
          .getDownloadURL();
    } catch (e) {
      print("Error al subir archivo al storage");
      return "";
    }
  }

  Future<void> takePicture() async {
    //implementar logica para tomar foto con la camara
    isLoading = true;
    notifyListeners();
    await _getImage();
    isLoading = false;
    notifyListeners();
  }

  Future<void> _getImage() async {
    // implementar logica para generar file con la foto tomada
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxHeight: 720,
        maxWidth: 720);
    if (pickedFile != null) {
      _selectedPicture = File(pickedFile.path);
    } else {
      print("No image selected");
      _selectedPicture = null;
    }
  }
}
