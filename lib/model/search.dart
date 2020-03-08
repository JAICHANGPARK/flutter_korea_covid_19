import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Search{
  @HiveField(0)
  String lat;
  @HiveField(1)
  String lng;
  @HiveField(2)
  String range;
  @HiveField(3)
  String datetime;

  Search(this.lat, this.lng, this.range, this.datetime);

}