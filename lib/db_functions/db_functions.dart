import 'package:camera_app/models/imagemodel.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

ValueNotifier<List<ImageModel>> imageNotifier = ValueNotifier([]);

Future<void> getImageFromDb() async {
  final imageDb = await Hive.openBox<ImageModel>('imageDb');
  imageNotifier.value.clear();
  imageNotifier.value.addAll(imageDb.values);
  imageNotifier.notifyListeners();
}

Future<void> addImageToDb(ImageModel value) async {
  final imageDb = await Hive.openBox<ImageModel>('imageDb');
  final _id = await imageDb.add(value);
  value.id = _id;
}

Future<void> deleteImage(int id) async {
  final imageDb = await Hive.openBox<ImageModel>('imageDb');
  imageDb.deleteAt(id);
  getImageFromDb();
}
