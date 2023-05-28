import 'package:hive_flutter/hive_flutter.dart';
part 'imagemodel.g.dart';

@HiveType(typeId: 1)
class ImageModel {
  @HiveField(0)
  int? id;

  @HiveField(1)
  final String image;

  ImageModel({required this.image, this.id});
}
