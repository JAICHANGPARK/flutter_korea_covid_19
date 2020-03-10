class NaverGeo {
  Status status;
  List<Results> results;

  NaverGeo({this.status, this.results});

  NaverGeo.fromJson(Map<String, dynamic> json) {
    status =
    json['status'] != null ? new Status.fromJson(json['status']) : null;
    if (json['results'] != null) {
      results = new List<Results>();
      json['results'].forEach((v) {
        results.add(new Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.status != null) {
      data['status'] = this.status.toJson();
    }
    if (this.results != null) {
      data['results'] = this.results.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Status {
  int code;
  String name;
  String message;

  Status({this.code, this.name, this.message});

  Status.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['name'] = this.name;
    data['message'] = this.message;
    return data;
  }
}

class Results {
  String name;
  Code code;
  Region region;
  Land land;

  Results({this.name, this.code, this.region, this.land});

  Results.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'] != null ? new Code.fromJson(json['code']) : null;
    region =
    json['region'] != null ? new Region.fromJson(json['region']) : null;
    land = json['land'] != null ? new Land.fromJson(json['land']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.code != null) {
      data['code'] = this.code.toJson();
    }
    if (this.region != null) {
      data['region'] = this.region.toJson();
    }
    if (this.land != null) {
      data['land'] = this.land.toJson();
    }
    return data;
  }
}

class Code {
  String id;
  String type;
  String mappingId;

  Code({this.id, this.type, this.mappingId});

  Code.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    mappingId = json['mappingId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['mappingId'] = this.mappingId;
    return data;
  }
}

class Region {
  Area0 area0;
  Area1 area1;
  Area0 area2;
  Area0 area3;
  Area0 area4;

  Region({this.area0, this.area1, this.area2, this.area3, this.area4});

  Region.fromJson(Map<String, dynamic> json) {
    area0 = json['area0'] != null ? new Area0.fromJson(json['area0']) : null;
    area1 = json['area1'] != null ? new Area1.fromJson(json['area1']) : null;
    area2 = json['area2'] != null ? new Area0.fromJson(json['area2']) : null;
    area3 = json['area3'] != null ? new Area0.fromJson(json['area3']) : null;
    area4 = json['area4'] != null ? new Area0.fromJson(json['area4']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.area0 != null) {
      data['area0'] = this.area0.toJson();
    }
    if (this.area1 != null) {
      data['area1'] = this.area1.toJson();
    }
    if (this.area2 != null) {
      data['area2'] = this.area2.toJson();
    }
    if (this.area3 != null) {
      data['area3'] = this.area3.toJson();
    }
    if (this.area4 != null) {
      data['area4'] = this.area4.toJson();
    }
    return data;
  }
}

class Area0 {
  String name;
  Coords coords;

  Area0({this.name, this.coords});

  Area0.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    coords =
    json['coords'] != null ? new Coords.fromJson(json['coords']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.coords != null) {
      data['coords'] = this.coords.toJson();
    }
    return data;
  }
}

class Coords {
  Center center;

  Coords({this.center});

  Coords.fromJson(Map<String, dynamic> json) {
    center =
    json['center'] != null ? new Center.fromJson(json['center']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.center != null) {
      data['center'] = this.center.toJson();
    }
    return data;
  }
}

class Center {
  String crs;
  int x;
  int y;

  Center({this.crs, this.x, this.y});

  Center.fromJson(Map<String, dynamic> json) {
    crs = json['crs'];
    x = json['x'];
    y = json['y'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['crs'] = this.crs;
    data['x'] = this.x;
    data['y'] = this.y;
    return data;
  }
}

class Area1 {
  String name;
  Coords coords;
  String alias;

  Area1({this.name, this.coords, this.alias});

  Area1.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    coords =
    json['coords'] != null ? new Coords.fromJson(json['coords']) : null;
    alias = json['alias'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.coords != null) {
      data['coords'] = this.coords.toJson();
    }
    data['alias'] = this.alias;
    return data;
  }
}

class Land {
  String type;
  String number1;
  String number2;
  Addition0 addition0;
  Addition0 addition1;
  Addition0 addition2;
  Addition0 addition3;
  Addition0 addition4;
  Coords coords;
  String name;

  Land(
      {this.type,
        this.number1,
        this.number2,
        this.addition0,
        this.addition1,
        this.addition2,
        this.addition3,
        this.addition4,
        this.coords,
        this.name});

  Land.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    number1 = json['number1'];
    number2 = json['number2'];
    addition0 = json['addition0'] != null
        ? new Addition0.fromJson(json['addition0'])
        : null;
    addition1 = json['addition1'] != null
        ? new Addition0.fromJson(json['addition1'])
        : null;
    addition2 = json['addition2'] != null
        ? new Addition0.fromJson(json['addition2'])
        : null;
    addition3 = json['addition3'] != null
        ? new Addition0.fromJson(json['addition3'])
        : null;
    addition4 = json['addition4'] != null
        ? new Addition0.fromJson(json['addition4'])
        : null;
    coords =
    json['coords'] != null ? new Coords.fromJson(json['coords']) : null;
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['number1'] = this.number1;
    data['number2'] = this.number2;
    if (this.addition0 != null) {
      data['addition0'] = this.addition0.toJson();
    }
    if (this.addition1 != null) {
      data['addition1'] = this.addition1.toJson();
    }
    if (this.addition2 != null) {
      data['addition2'] = this.addition2.toJson();
    }
    if (this.addition3 != null) {
      data['addition3'] = this.addition3.toJson();
    }
    if (this.addition4 != null) {
      data['addition4'] = this.addition4.toJson();
    }
    if (this.coords != null) {
      data['coords'] = this.coords.toJson();
    }
    data['name'] = this.name;
    return data;
  }
}

class Addition0 {
  String type;
  String value;

  Addition0({this.type, this.value});

  Addition0.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['value'] = this.value;
    return data;
  }
}
