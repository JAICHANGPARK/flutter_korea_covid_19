import 'package:hive/hive.dart';

part 'search.g.dart';

@HiveType(typeId: 0)
class Search{
  @HiveField(0)
  final String lat;
  @HiveField(1)
  final String lng;
  @HiveField(2)
  final String range;
  @HiveField(3)
  final  String datetime;

  Search(this.lat, this.lng, this.range, this.datetime);

}