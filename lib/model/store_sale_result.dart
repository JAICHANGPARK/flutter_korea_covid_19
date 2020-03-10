class StoreSaleResult {
  int count;
  List<Stores> stores;

  StoreSaleResult({this.count, this.stores});

  StoreSaleResult.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['stores'] != null) {
      stores = new List<Stores>();
      json['stores'].forEach((v) {
        stores.add(new Stores.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    if (this.stores != null) {
      data['stores'] = this.stores.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Stores {
  String addr;
  String code;
  String createdAt;
  double lat;
  double lng;
  String name;
  String remainStat;
  String stockAt;
  String type;

  Stores(
      {this.addr,
        this.code,
        this.createdAt,
        this.lat,
        this.lng,
        this.name,
        this.remainStat,
        this.stockAt,
        this.type});

  Stores.fromJson(Map<String, dynamic> json) {
    addr = json['addr'];
    code = json['code'];
    createdAt = json['created_at'];
    lat = json['lat'];
    lng = json['lng'];
    name = json['name'];
    remainStat = json['remain_stat'];
    stockAt = json['stock_at'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['addr'] = this.addr;
    data['code'] = this.code;
    data['created_at'] = this.createdAt;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['name'] = this.name;
    data['remain_stat'] = this.remainStat;
    data['stock_at'] = this.stockAt;
    data['type'] = this.type;
    return data;
  }
}
