import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttermasktest/model/mask.dart';
import 'package:fluttermasktest/model/recent.dart';
import 'package:fluttermasktest/model/search.dart';
import 'package:fluttermasktest/ui/common/notification_item.dart';
import 'package:fluttermasktest/ui/screen/info_web_view_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '공적마스크 검색이',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.teal,
          accentColor: Colors.red),
      home: MyHomePage(title: '공적마스크 검색이'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var box;
  int pageIndex = 0;
  bool appPublishFlag = false;
  Mask resultList;
  List<Stores> stores;
  String userDay = "";
  TextEditingController latTextController = TextEditingController();
  TextEditingController lngTextController = TextEditingController();
  TextEditingController rangeTextController = TextEditingController();
  TextEditingController birthTextController = TextEditingController();

  Future<Mask> getMask(String lat, String lng, String range) async {
    var url =
        'https://8oi9s0nnth.apigw.ntruss.com/corona19-masks/v1/storesByGeo/json?lat=$lat&lng=$lng&m=$range';
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      Mask m = Mask.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      return m;
    } else {
      return null;
    }
  }

  Future<Recent> getSearchLog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lat = prefs.getString('recent_lat') ?? "";
    String lng = prefs.getString('recent_lng') ?? "";
    String range = prefs.getString('recent_range') ?? "";
    String dt = prefs.getString('recent_datetime') ?? "";
    Recent tmp = Recent(lat, lng, range, dt);
    return tmp;
  }

  Future<void> setSearchLog(String lat, String lng, String range) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('recent_lat', lat);
    await prefs.setString('recent_lng', lng);
    await prefs.setString('recent_range', range);
    await prefs.setString('recent_datetime', DateTime.now().toString());
  }

  Future<bool> getPublishState() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    final defaults = <String, dynamic>{'welcome': 'default welcome'};
    await remoteConfig.setDefaults(defaults);

    await remoteConfig.fetch(expiration: const Duration(hours: 5));
    await remoteConfig.activateFetched();
    print('welcome message: ' + remoteConfig.getString('welcome'));

    var tmp = remoteConfig.getString("publish");
    print(tmp);
    return tmp == "0" ? false : true;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPublishState().then((result) {
      print("return result : $result");
      if (result) {
        setState(() {
          appPublishFlag = true;
        });

        getSearchLog().then((r) {
          print(r);
          latTextController.text = r.lat;
          lngTextController.text = r.lng;
          rangeTextController.text = r.range;
          setState(() {});
        });
      } else {
        setState(() {
          appPublishFlag = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('마스크5부제 정보'),
              leading: Icon(Icons.info_outline),
            ),
            Divider(
              height: 0,
              thickness: 1.2,
            ),
            ListTile(
              title: Text('공적마스크 구매 안내'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => InformationWebViewPage(
                          url:
                              "http://ncov.mohw.go.kr/shBoardView.do?brdId=3&brdGubun=36&ncvContSeq=1092",
                          title: "공적마스크 구매 안내",
                        )));
              },
            ),
            ListTile(
                title: Text('마스크 사용 권고사항'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => InformationWebViewPage(
                            url:
                                "https://www.mfds.go.kr/brd/m_99/view.do?seq=43955",
                            title: "마스크 사용 권고사항",
                          )));
                }),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("설정"),
            ),
            Divider(
              height: 0,
              thickness: 1.2,
            ),
            ListTile(
              title: Text("태어난 년도 입력 및 수정"),
              subtitle: Text("마스크 5부제 요일 확인을 위한 정보입니다."),
              onTap: () {
                setState(() {
                  pageIndex = 2;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text('정보'),
              leading: Icon(Icons.info_outline),
            ),
            Divider(
              height: 0,
              thickness: 1.2,
            ),
            ExpansionTile(
              title: Text("개발자 정보"),
              children: <Widget>[
                ListTile(
                  title: Text("개발"),
                  subtitle: Text("박제창"),
                ),
                ListTile(
                  title: Text("이메일"),
                  subtitle: Text("aristojeff@gmail.com"),
                ),
                ListTile(
                  title: Text("레포지토리"),
                  subtitle: Text("https://github.com/JAICHANGPARK"),
                ),
              ],
            ),
            ListTile(
              title: Text('앱정보'),
              onTap: () {
                showAboutDialog(context: context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
      ),
      body: IndexedStack(
        index: pageIndex,
        children: <Widget>[
          !appPublishFlag
              ? NotificationItem()
              : SingleChildScrollView(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: <Widget>[
                      Card(
                        child: Container(
                          height: MediaQuery.of(context).size.height / 2.5,
                          padding: EdgeInsets.only(top: 16, left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("검색정보 입력"),
                              Expanded(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(flex: 2, child: Text('위도')),
                                    Expanded(
                                      flex: 8,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        controller: latTextController,
                                        decoration: InputDecoration(
                                            labelText: "위도",
                                            hintText: "37.xxx"),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(flex: 2, child: Text('경도')),
                                    Expanded(
                                      flex: 8,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        controller: lngTextController,
                                        decoration: InputDecoration(
                                            labelText: "경도",
                                            hintText: "127.xxx"),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(flex: 2, child: Text('검색 반경')),
                                    Expanded(
                                      flex: 8,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        controller: rangeTextController,
                                        decoration: InputDecoration(
                                            labelText: "반경(m)",
                                            hintText: "10m"),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              ButtonBar(
                                children: <Widget>[
                                  MaterialButton(
                                    child: Text('검색'),
                                    onPressed: () {
                                      String lat = latTextController.text;
                                      String lng = lngTextController.text;
                                      String r = rangeTextController.text;

                                      if (lat.length > 0 &&
                                          lng.length > 0 &&
                                          r.length > 0) {
                                        if (stores.length > 0) {
                                          stores.clear();
                                          getMask(lat, lng, r);
                                        }
                                        setSearchLog(lat, lng, r);
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  content:
                                                      Text("모든 조건을 입력해주세요"),
                                                ));
                                      }
                                    },
                                    color: Colors.teal,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height / 2.6,
                        width: MediaQuery.of(context).size.width,
                        child: FutureBuilder<Mask>(
                          future: getMask(latTextController.text,
                              lngTextController.text, rangeTextController.text),
                          builder: (context, snapshot) {
                            if (snapshot.data == null)
                              return Center(
                                child: Text("다시 시도해주세요 "),
                              );
                            if (snapshot.hasData) {
                              resultList = snapshot.data;
                              stores = resultList.stores;
                              return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: stores.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      color: stores[index].soldOut
                                          ? Colors.grey
                                          : Colors.white,
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 16),
                                        padding: EdgeInsets.only(
                                            left: 16, top: 16, bottom: 8),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                                "약국 이름: ${stores[index].name.substring(6)}"),
                                            Text(
                                              "주소 : ${stores[index].addr}",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                                "판매 수량 : ${stores[index].soldCnt.toString()}개"),
                                            stores[index].soldOut
                                                ? Text("재고여부 : 매진")
                                                : Text("재고여부 : 재고있음(확인필요)"),
                                            Text(
                                                "재고수량: ${stores[index].stockCnt.toString()}개")
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            } else {
                              return Center(
                                  child: Column(
                                children: <Widget>[
                                  CircularProgressIndicator(),
                                  Text("정보요청중...")
                                ],
                              ));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text("업데이트 예정"),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "태여난 년도",
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Card(
                    elevation: 4,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "출생연도를 입력해주세요",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          TextField(
                            keyboardType: TextInputType.number,
                            style: TextStyle(fontSize: 24),
                            maxLength: 4,
                            controller: birthTextController,
                            inputFormatters: [
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "출생연도 4자리",
                                hintText: "19xx",
                                suffix: Text("년")),
                          ),
                          ButtonBar(
                            children: <Widget>[
                              MaterialButton(
                                color: Colors.teal,
                                onPressed: () {
                                  int num =
                                      int.parse(birthTextController.text[3]);
                                  if (num == 1 && num == 6) {
                                    userDay = "월";
                                  } else if (num == 2 && num == 7) {
                                    userDay = "화";
                                  } else if (num == 3 && num == 8) {
                                    userDay = "수";
                                  } else if (num == 4 && num == 9) {
                                    userDay = "목";
                                  } else if (num == 5 && num == 0) {
                                    userDay = "금";
                                  }
                                  setState(() {});
                                },
                                child: Text('적용'),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    "구매가능요일",
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "평일에 구매하지 못하였다면 주말(토,일)에 구매가능합니다.",
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Card(
                    elevation: 4,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Text(
                              "매주",
                              style: GoogleFonts.roboto(fontSize: 48),
                            ),
                            Text(
                              userDay,
                              style: GoogleFonts.roboto(fontSize: 84),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: pageIndex,
          onTap: (newValue) {
            setState(() {
              pageIndex = newValue;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.search), title: Text("약국목록")),
            BottomNavigationBarItem(
                icon: Icon(Icons.list), title: Text("검색기록")),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), title: Text("구매 요일 확인")),
          ]),
      floatingActionButton: pageIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                if (appPublishFlag) {
                  setState(() {
                    if (stores != null) {
                      stores.clear();
                    }
                  });
                } else {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            content: Text("현재 이용할 수 없습니다."),
                          ));
                }
              },
              tooltip: 'Refresh',
              child: Icon(Icons.refresh),
            )
          : null, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Hive.close();
    super.dispose();
  }
}
