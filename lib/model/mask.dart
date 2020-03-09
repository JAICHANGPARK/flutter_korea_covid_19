class Mask {
  int count;
  List<Stores> stores;

  Mask({this.count, this.stores});

  Mask.fromJson(Map<String, dynamic> json) {
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
  int remainCnt;
  int soldCnt;
  bool soldOut;
  int stockCnt;
  String stockT;
  String type;

  String remainStat;

  Stores({
    this.addr,
    this.code,
    this.createdAt,
    this.lat,
    this.lng,
    this.name,
    this.remainCnt,
    this.soldCnt,
    this.soldOut,
    this.stockCnt,
    this.stockT,
    this.type,
    this.remainStat,
  });

  Stores.fromJson(Map<String, dynamic> json) {
    addr = json['addr'];
    code = json['code'];
    createdAt = json['created_at'];
    lat = json['lat'];
    lng = json['lng'];
    name = json['name'];
    remainCnt = json['remain_cnt'];
    soldCnt = json['sold_cnt'];
    soldOut = json['sold_out'];
    stockCnt = json['stock_cnt'];
    stockT = json['stock_t'];
    type = json['type'];
    remainStat = json['remain_stat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['addr'] = this.addr;
    data['code'] = this.code;
    data['created_at'] = this.createdAt;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['name'] = this.name;
    data['remain_cnt'] = this.remainCnt;
    data['sold_cnt'] = this.soldCnt;
    data['sold_out'] = this.soldOut;
    data['stock_cnt'] = this.stockCnt;
    data['stock_t'] = this.stockT;
    data['type'] = this.type;
    data['remain_stat'] = remainStat;
    return data;
  }
}
