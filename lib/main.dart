import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttermasktest/model/mask.dart';
import 'package:fluttermasktest/model/search.dart';
import 'package:hive/hive.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '공적마스크 검색'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Mask resultList;
  List<Stores> stores;
  TextEditingController latTextController = TextEditingController();
  TextEditingController lngTextController = TextEditingController();
  TextEditingController rangeTextController = TextEditingController();
  var box;

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

//    print(await http.read('https://example.com/foobar.txt'));
  }

  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
    var path = Directory.current.path;
    Hive..init(path);

//    Hive.openBox('testBox').then((r) => box = r);

//    getMask().then((r) {
//      setState(() {
//        resultList = r;
//      });
//    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
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
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Card(
              child: Container(
                height: MediaQuery.of(context).size.height / 2.5,
                padding: EdgeInsets.all(16),
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
                              controller: latTextController,
                              decoration: InputDecoration(
                                  labelText: "위도", hintText: "37.xxx"),
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
                              controller: lngTextController,
                              decoration: InputDecoration(
                                  labelText: "경도", hintText: "127.xxx"),
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
                              controller: rangeTextController,
                              decoration: InputDecoration(
                                  labelText: "반경(m)", hintText: "10m"),
                            ),
                          )
                        ],
                      ),
                    ),
                    ButtonBar(
                      children: <Widget>[
                        MaterialButton(
                          child: Text('검색'),
                          onPressed: ()  {
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

                              var person = Search()
                                ..lat = lat
                                ..lng = lng
                                ..range = r
                                ..datetime = DateTime.now().toString();
                              Hive.openBox('myBox').then((b) {
//                                var box = Hive.box('myBox');
                                b.put('search', person);
                                print(b.get('search')); // Dave: 22

                              });


                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        content: Text("모든 조건을 입력해주세요"),
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
              height: MediaQuery.of(context).size.height / 1.5,
              width: MediaQuery.of(context).size.width,
              child: FutureBuilder<Mask>(
                future: getMask(latTextController.text, lngTextController.text,
                    rangeTextController.text),
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
                              padding:
                                  EdgeInsets.only(left: 16, top: 16, bottom: 8),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
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
      )),
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon: Icon(Icons.search), title: Text("약국목록")),
        BottomNavigationBarItem(icon: Icon(Icons.list), title: Text("검색기록")),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (stores != null) {
              stores.clear();
            }
          });
        },
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
