import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadRecipeImage(dynamic imageFile, String recipeId) async {
    try {
      if (imageFile == null) return null;
      
      String fileName = 'recipe_${recipeId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('recipe_images').child(fileName);

      UploadTask uploadTask;
      if (kIsWeb) {
        if (imageFile is! Uint8List) return null;
        uploadTask = ref.putData(
          imageFile,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        if (imageFile is! File) return null;
        uploadTask = ref.putFile(imageFile);
      }
      
      // Await the upload fully
      TaskSnapshot snapshot = await uploadTask;
      
      // Get the download URL only after successful upload
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<bool> deleteRecipeImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}