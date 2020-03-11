import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttermasktest/model/store_sale_result.dart';
import 'package:latlong/latlong.dart';

class ShopDetailPage extends StatefulWidget {
  final String apiKey;
  final String apiId;
  final double userLat;
  final double userLng;
  final Stores stores;

  ShopDetailPage(this.userLat, this.userLng, this.stores, this.apiId, this.apiKey);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<ShopDetailPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.userLng);
    print(widget.userLat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
//          Positioned(
//            left: 0,
//            top: 0,
//            bottom: 0,
//            right: 0,
//            child: FlutterMap(
//              options: MapOptions(
//                center: LatLng(widget.userLat, widget.userLng),
//                zoom: 15,
//                maxZoom: 19,
//              ),
//              layers: [
//                TileLayerOptions(
//                    urlTemplate:
//                        "https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png"),
//
//                MarkerLayerOptions(
//                    markers: [
//                      Marker(
//                          point: LatLng(widget.stores.lat, widget.stores.lng),
//                          builder: (ctx) => Icon(
//                            Icons.location_on,
//                            color: Colors.blue,
//                            size: 48.0,
//                          ),
//                          height: 60
//                      ),
////                      Marker(
////                          point: LatLng(widget.stores.lat, widget.stores.lng),
////                          builder: (ctx) => Icon(
////                            Icons.location_on,
////                            color: Colors.blue,
////                            size: 48.0,
////                          ),
////                          height: 60
////                      ),
//
//                    ]
//                ),
//
//              ],
//
//            ),
//          )
        ],
      ),
    );
  }
}
