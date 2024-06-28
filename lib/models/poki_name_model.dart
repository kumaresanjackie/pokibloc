import 'package:hive/hive.dart';

part 'poki_name_model.g.dart';

@HiveType(typeId: 0)
class PokiNameModel {
  @HiveField(0)
  String? name;
  @HiveField(1)
  String? imageUrl;

  PokiNameModel({this.name, this.imageUrl});

  PokiNameModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    imageUrl = json['url']; // Adjust based on your JSON structure
  }
}
