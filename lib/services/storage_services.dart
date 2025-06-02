import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static Future<String> uploadItemImage(File file) async {
    final uuid = Uuid();
    final ref = FirebaseStorage.instance.ref().child('items/${uuid.v4()}');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
