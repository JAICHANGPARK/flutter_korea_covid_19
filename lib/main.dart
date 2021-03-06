import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttermasktest/model/api_keys.dart';
import 'package:fluttermasktest/model/naver_reversegeocode.dart' as ng;

import 'package:fluttermasktest/model/recent.dart';

import 'package:fluttermasktest/model/store_sale_result.dart';
import 'package:fluttermasktest/provider/theme_provider.dart';
import 'package:fluttermasktest/ui/common/notification_item.dart';
import 'package:fluttermasktest/ui/common/under_construct_page.dart';

import 'package:fluttermasktest/ui/screen/info_web_view_page.dart';
import 'package:fluttermasktest/ui/screen/map_web_view_test_page.dart';
import 'package:fluttermasktest/ui/screen/test/map_test.dart';
import 'package:fluttermasktest/ui/screen/test/test_detail_page.dart';

import 'package:fluttermasktest/utils/app_string.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;

import 'package:line_icons/line_icons.dart';
import 'package:location/location.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

enum OnClickProcessState {
  beforeStart,
  start,
  success,
  failed,
}

void main() async {

//  runApp(ChangeNotifierProvider(
//    create: (_) {
//      return ThemeProvider(isLightTheme: true);
//    } ,
//    child: MyApp(),
//  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
//    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      debugShowCheckedModeBanner: false,
      title: '공적마스크 검색이',
      theme: ThemeData(primarySwatch: Colors.blue,
          primaryColor: Colors.teal,
          accentColor: Colors.red),
      darkTheme: ThemeData.dark().copyWith(textTheme: TextTheme()),
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
  StoreSaleResult resultList;
  List<Stores> stores;
  String userDay = "";
  String userBirth = "";
  String defaultRange = "1000";

  TextEditingController latTextController = TextEditingController();
  TextEditingController lngTextController = TextEditingController();
  TextEditingController rangeTextController = TextEditingController();
  TextEditingController birthTextController = TextEditingController();

  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  Map<String, double> currentLocation;
  StreamSubscription<LocationData> locationSubscription;
  String error;
  bool userServiceAgree = false;
  String version;

  OnClickProcessState onClickProcessState = OnClickProcessState.beforeStart;
  bool onClickCompleted = false;
  bool onClickStart = false;
  String onClickStateText = "";
  List<Stores> onClickStoreList = [];
  String onClickUserAddressText = "";

  String mapApiId = "";
  String mapApiKey = "";

  bool darkModeSwitch = false;

  Future<ApiKeys> getApiKeys(String path) async {
    String data = await DefaultAssetBundle.of(context).loadString(path);
    ApiKeys jsonResult = ApiKeys.fromJson(json.decode(data));
    print(jsonResult.toString());
    return jsonResult;
  }

  Future<StoreSaleResult> getMask(String lat, String lng, String range) async {
    var url = 'https://8oi9s0nnth.apigw.ntruss.com/corona19-masks/v1/storesByGeo/json?lat=$lat&lng=$lng&m=$range';
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      StoreSaleResult m = StoreSaleResult.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      return m;
    } else {
      throw Exception('접속량이 많아 다소 지연이 발생할 수 있습니다. 다시 시도해주세요. ');
      return null;
    }
  }

  Future<String> getUserAddress(String apiId, String apiKey, String lat, String lng) async {
    var url = 'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=${lng},${lat}&output=json';
    var response = await http.get(
      url,
      headers: {
        'X-NCP-APIGW-API-KEY-ID': apiId,
        'X-NCP-APIGW-API-KEY': apiKey,
      },
    );
    print('Response status: ${response.statusCode}');
    if (response.statusCode == HttpStatus.ok) {
      print('Response body: ${response.body}');
      ng.NaverGeo naverGeo = ng.NaverGeo.fromJson(json.decode(response.body));

      List<ng.Results> tmpResult = naverGeo.results;
      if (tmpResult.length > 0) {
        String userAddress =
            "${tmpResult[0].region.area1.name} ${tmpResult[0].region.area2.name} ${tmpResult[0].region.area3.name}";
        print(userAddress);
        return userAddress;
      } else {
        return "";
      }
    } else if (response.statusCode == HttpStatus.notFound) {
      return "404";
    } else {
      return "";
    }
  }

  Future<StoreSaleResult> getMaskFromAddress(String address) async {
    var url = 'https://8oi9s0nnth.apigw.ntruss.com/corona19-masks/v1/storesByAddr/json?address=$address';
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      StoreSaleResult m = StoreSaleResult.fromJson(json.decode(utf8.decode(response.bodyBytes)));
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

  Future<void> setUserBirth(String b, String d) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_birth', b);
    await prefs.setString('user_day', d);
  }

  Future<String> getUserBirth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String birth = prefs.getString('user_birth') ?? "";
    return birth;
  }

  Future<String> getUserDay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String day = prefs.getString('user_day') ?? "";
    return day;
  }

  Future<void> setUserServiceAgree(bool b) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('user_agree', b);
  }

  Future<bool> getUserServiceAgree() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool agree = prefs.getBool('user_agree') ?? false;
    return agree;
  }

  Future<bool> getPublishState() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    final defaults = <String, dynamic>{'welcome': 'default welcome'};
    await remoteConfig.setDefaults(defaults);
    await remoteConfig.fetch(expiration: const Duration(seconds: 10));
    await remoteConfig.activateFetched();
    var tmp = remoteConfig.getString("publish");
    return tmp == "0" ? false : true;
  }

  Future<bool> getAppVersion() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    await remoteConfig.fetch(expiration: const Duration(seconds: 10));
    await remoteConfig.activateFetched();
    var tmp = remoteConfig.getString("stable");
    print("엡 배포 버전 : $tmp");
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    print("version : $version   buildNumber : $buildNumber");
    if (int.parse(tmp) == int.parse(buildNumber)) {
      return false;
    } else if (int.parse(tmp) > int.parse(buildNumber)) {
      return true;
    } else {
      print("현재 버전이 더 높음");
      return false;
    }
  }

  Future<void> checkLocationServiceEnable() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
  }

  Future<bool> checkLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      print("원래 권한이 디나인");
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print("요청하고 위치 권한 허용 안함");
        return true;
      } else {
        print("요청하고 위치권한 허용함.");
        return false;
      }
    } else if (_permissionGranted == PermissionStatus.deniedForever) {
      print("영원히 거부 ");
      return false;
    } else {
      print("원래 권한 허용되어잇음.");
      return true;
    }
  }

  void initPlatformState() async {
    LocationData myLocation;
    try {
      myLocation = await location.getLocation();
      error = "";
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = "Permission Denied";
      } else if (e.code == "PERMISSION_DENIED_NEVER_ASK") {
        error = "Permission denied - please ask th user to enable ";
      }
      myLocation = null;
    }

    setState(() {
      _locationData = myLocation;
      print(_locationData.latitude);
      print(_locationData.longitude);
    });
  }

  void firebaseCloudMessagingListeners() {
    _firebaseMessaging.getToken().then((token) {
      print('token:' + token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("실시간 공지사항"),
            content: ListTile(
              title: Text(message["notification"]["title"]),
              subtitle: Text(message["notification"]["body"]),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        );
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    analytics.setCurrentScreen(screenName: "MainPage");
    firebaseCloudMessagingListeners();

    getApiKeys('assets/api_key.json').then((value) {
      mapApiId = value.mapApiKey.xNCPAPIGWAPIKEYID;
      mapApiKey = value.mapApiKey.xNCPAPIGWAPIKEY;
    });

    getUserServiceAgree().then((v) async {
      userServiceAgree = v;

      //사용자 서비스 이용 동의가 완료된 경우
      if (v) {
        checkLocationPermission().then((result) async {
          print(result);
          initPlatformState();
          if (result) {
            _locationData = await location.getLocation();
          }
        });

        locationSubscription = location.onLocationChanged.listen((result) {
          setState(() {
            _locationData = result;
          });
        });

        //오픈 상태인지 확인하기
        getPublishState().then((result) {
          //false: 아직 서비스 시작안함.
          //true : 현재 서비스 중
          if (result) {
            setState(() {
              appPublishFlag = true;
            });

            getSearchLog().then((r) {
              latTextController.text = r.lat;
              lngTextController.text = r.lng;
              print("저장된 거리값 : ${r.range}");
              if (r.range == "") {
                defaultRange = r.range;
                rangeTextController.text = "1000";
              } else {
                rangeTextController.text = r.range;
              }
              getAppVersion().then((b) async {
                if (b) {
                  _showVersionDialog(context);
                }
              });
            });
          }
          //아직 서비스 시작안할 떄
          else {
            getSearchLog().then((r) {
              latTextController.text = r.lat;
              lngTextController.text = r.lng;
              print("저장된 거리값 : ${r.range}");
              if (r.range == "") {
                defaultRange = r.range;
                rangeTextController.text = "1000";
              } else {
                rangeTextController.text = r.range;
              }
              getAppVersion().then((b) async {
                if (b) {
                  _showVersionDialog(context);
                }
              });
            });
//            getAppVersion().then((b) async {
//              if (b) {
//                _showVersionDialog(context);
//              }
//            });
            setState(() {
              appPublishFlag = false;
            });
          }
        });
      }

      //사용자 서비스 이용 동의가 완료된 경우
      //사용자 동의구하기
      else {
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return WillPopScope(
                onWillPop: () {},
                child: SimpleDialog(
                  contentPadding: EdgeInsets.all(16),
                  children: <Widget>[
                    Text("1. 제공되는 공적마스크 판매 정보 및 재고 정보는 실제와 5분이상 지연된 정보로 그 이상 차이가 발생할 수 있습니다."),
                    Text("2. 마스크 사용 지침 및 공적 마스크 관련 안내는 본 앱 왼쪽 상단 메뉴 및 [식약처 홈페이지]를 참고하세요."),
                    Text("3. 위치정보는 주변 약국을 검색하기 위해 사용됩니다."),
                    Text("4. 밤낮으로 전국의 약사분들도 힘껏 지원하고 계십니다. 따뜻한 응원의 메시지를 전하면 어떨까요?"),
                    Text("5. 위 내역을 확인하였고 동의하며 서비스를 이용하실 의향이 있으신 분만 동의하기를 눌러주세요 "),
                    SizedBox(
                      height: 16,
                    ),
                    ButtonBar(
                      children: <Widget>[
                        MaterialButton(
                          color: Colors.teal,
                          onPressed: () {
                            setState(() {
                              userServiceAgree = false;
                            });
                            setUserServiceAgree(userServiceAgree);
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "동의하지 않습니다.",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        MaterialButton(
                          color: Colors.teal,
                          onPressed: () {
                            setState(() {
                              userServiceAgree = true;
                            });
                            setUserServiceAgree(userServiceAgree);
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "동의합니다.",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                  title: Text("서비스 사용 동의"),
                ),
              );
            });

        print("동의완료 처리후 : $userServiceAgree");
        if (userServiceAgree) {
          checkLocationPermission().then((result) async {
            print(result);
            initPlatformState();
            if (result) {
              _locationData = await location.getLocation();
            }
          });

          locationSubscription = location.onLocationChanged.listen((result) {
            setState(() {
              _locationData = result;
            });
          });

          getPublishState().then((result) {
            if (result) {
              setState(() {
                appPublishFlag = true;
              });

              getSearchLog().then((r) {
                latTextController.text = r.lat;
                lngTextController.text = r.lng;
                if (r.range == "") {
                  defaultRange = r.range;
                  rangeTextController.text = "1000";
                } else {
                  rangeTextController.text = r.range;
                }
                getAppVersion().then((b) async {
                  if (b) {
                    _showVersionDialog(context);
                  }
                });
              });
            } else {
              getAppVersion().then((b) async {
                if (b) {
                  _showVersionDialog(context);
                }
              });
              setState(() {
                appPublishFlag = false;
              });
            }
          });
        } else {
          exit(0);
          SystemNavigator.pop();
        }
      }

      setState(() {});
    });

    super.initState();
  }

  String addressJSON = '';

  @override
  Widget build(BuildContext context) {
//    final themeProvider = Provider.of<ThemeProvider>(context);
    final Brightness brightnessValue = MediaQuery.of(context).platformBrightness;
    bool isDark = brightnessValue == Brightness.dark;

    print("다크모드? $isDark");
    return Scaffold(
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text('마스크5부제 관련 정보'),
                leading: Icon(Icons.info_outline),
              ),
              Divider(
                height: 0,
                thickness: 1.2,
              ),
              ListTile(
                title: Text('공적 마스크 구매 안내'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => InformationWebViewPage(
                            url: "http://blog.naver.com/kfdazzang/221839489769",
                            title: "공적마스크 구매 안내",
                          )));
                },
              ),
              ListTile(
                title: Text('공적 마스크 구입 요령'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => InformationWebViewPage(
                            url: "http://blog.naver.com/kfdazzang/221844817502",
                            title: "공적마스크 구입 요령",
                          )));
                },
              ),
              ListTile(
                  title: Text('마스크 사용 권고사항'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => InformationWebViewPage(
                              url: "https://www.mfds.go.kr/brd/m_99/view.do?seq=43955",
                              title: "마스크 사용 권고사항",
                            )));
                  }),
              ListTile(
                  title: Text('[카드뉴스] 마스크 사용 권고사항'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => InformationWebViewPage(
                              url: "http://blog.naver.com/kfdazzang/221837044802",
                              title: "[카드뉴스] 마스크 사용 권고사항",
                            )));
                  }),
              ListTile(
                  title: Text('공적마스크 관련 QnA'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => InformationWebViewPage(
                              url: "https://www.mfds.go.kr/brd/m_659/list.do",
                              title: "공적마스크 관련 QnA",
                            )));
                  }),
              ListTile(
                title: Text('정보'),
                leading: Icon(Icons.info_outline),
              ),
              Divider(
                height: 0,
                thickness: 1.2,
              ),
              SizedBox(
                height: 8,
              ),
              ListTile(
                title: Text("재고 색상 안내"),
                subtitle: Text(
                  "녹색(100개 이상)/노랑색(30~99개)/빨강색(2~29개)/회색(0~1개)",
                  style: TextStyle(fontSize: 12),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              ListTile(
                title: Text("유의사항"),
                subtitle: Text(
                  "제공되는 데이터는 5분-10분 정도 실제 재고와 차이가 있을 수 있습니다",
                  style: TextStyle(fontSize: 12),
                ),
              ),
              ListTile(
                title: Text("정보 제공 시간"),
                subtitle: Text(
                  "제공되는 데이터는 매일 오전8시부터 저녁11시까지 갱신되어 제공됩니다.",
                  style: TextStyle(fontSize: 12),
                ),
              ),
              ListTile(
                  title: Text("데이터 제공"),
                  subtitle: Text(
                    "공공데이터포털(건강보험심사평가원)",
                    style: TextStyle(fontSize: 12),
                  )),
              ListTile(
                title: Text(
                  "서비스 이용 동의",
                ),
                subtitle: userServiceAgree
                    ? Text(
                        "서비스 사용 동의 처리완료",
                        style: TextStyle(fontSize: 12),
                      )
                    : Text(
                        "서비스 사용 동의 미완료",
                        style: TextStyle(fontSize: 12),
                      ),
              ),
              ExpansionTile(
                title: Text("개발자 정보"),
                children: <Widget>[
                  ListTile(
                    title: Text("개발"),
                    subtitle: Text("박제창 (Dreamwalker)"),
                  ),
                  ListTile(
                    title: Text("이메일"),
                    subtitle: Text("aristojeff@gmail.com"),
                    onTap: () {
                      _launchEmail("aristojeff@gmail.com");
                    },
                  ),
                  ListTile(
                    title: Text("리포지토리"),
                    subtitle: Text("https://github.com/JAICHANGPARK"),
                  ),
                ],
              ),
              ExpansionTile(
                title: Text("기술지원 및 문의"),
                children: <Widget>[
                  ListTile(
                    onTap: () {
                      _launchEmail("aristojeff@gmail.com");
                    },
                    title: Text('기술 및 앱 관련문의'),
                    subtitle: Text("aristojeff@gmail.com"),
                  ),
                  ListTile(
                    title: Text("데이터 문의(한국정보화진흥원)"),
                    subtitle: Text("maskdata@nia.or.kr"),
                    onTap: () {
                      _launchEmail("maskdata@nia.or.kr");
                    },
                  )
                ],
              ),
              ListTile(
                title: Text('앱정보'),
                onTap: () {
                  showAboutDialog(
                      context: context,
                      applicationName: "공적마스크 검색이",
                      applicationVersion: version,
                      applicationIcon: Image.asset(
                        'assets/icon/icons2/playstore.png',
                        width: 64,
                        height: 64,
                      ));
                },
              ),
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
                subtitle: Text(
                  "마스크 5부제 요일 확인을 위한 정보입니다.",
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () {
                  setState(() {
                    pageIndex = 2;
                  });
                  Navigator.of(context).pop();
                },
              ),

            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: Text(
            widget.title,
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(LineIcons.map),
              onPressed: () {
                if (pageIndex == 0) {
                  if (onClickStoreList != null) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MapTest(
                              userLocation: _locationData,
                              storeItems: onClickStoreList,
                              analytics: analytics,
                            )));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MapTest(
                              userLocation: _locationData,
                              storeItems: [],
                              analytics: analytics,
                            )));
                  }
                } else if (pageIndex == 1) {
                  if (stores != null) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MapTest(
                              userLocation: _locationData,
                              storeItems: stores,
                              analytics: analytics,
                            )));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MapTest(
                              userLocation: _locationData,
                              storeItems: [],
                              analytics: analytics,
                            )));
                  }
                }
              },
            )
//          IconButton(
//            icon: Icon(Icons.search),
//            onPressed: () {
//              Navigator.of(context).push(MaterialPageRoute(
//                  builder: (context) => WebViewTest(
//                        userLat: _locationData.latitude.toString(),
//                        userLng: _locationData.longitude.toString(),
//                        apiId: mapApiId,
//                        apiKey: mapApiKey,
//                      )));
//            },
//          )
          ],
        ),
        body: IndexedStack(
          index: pageIndex,
          children: <Widget>[
            !appPublishFlag
                ? UnderConstructPage()
                :
                // 원클릭 검색 원래 // 두번째 페이지
                Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: onClickCompleted
                          ? onClickStoreList.length > 0
                              ? Column(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  "검색 결과",
                                                  style: Theme.of(context).textTheme.headline6.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                ),
                                                Text("근처의 총 ${onClickStoreList.length}개 판매처를 찾았어요."),
                                              ],
                                            ),
                                            Spacer(),
                                            Text("재검색"),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  onClickStoreList.clear();
                                                  onClickCompleted = false;
                                                  onClickStart = false;
                                                  onClickStateText = "";
                                                });
                                              },
                                              icon: Icon(Icons.refresh),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 10,
                                      child: ListView.builder(
                                        physics: BouncingScrollPhysics(),
                                        itemCount: onClickStoreList.length,
                                        itemBuilder: (context, index) {
                                          Color stockColor;
                                          Color stockTextColor;
                                          String stockText = "알수없음";
                                          String remain = onClickStoreList[index].remainStat;
                                          String type = onClickStoreList[index].type;
                                          String typeText;
                                          if (type == "01") {
                                            typeText = "약국";
                                          } else if (type == "02") {
                                            typeText = "우체국";
                                          } else if (type == "03") {
                                            typeText = "농협";
                                          } else {
                                            typeText = "정보없음";
                                          }

                                          if (remain == "plenty") {
                                            stockColor = Colors.lightGreen;
                                            stockText = "100개 이상😆";
                                            stockTextColor = Colors.white;
                                          } else if (remain == "some") {
                                            stockColor = Colors.yellow;
                                            stockText = "30개이상~\n100개미만😀";
                                            stockTextColor = Colors.black;
                                          } else if (remain == "few") {
                                            stockColor = Colors.red;
                                            stockText = "30개 미만🤔";
                                            stockTextColor = Colors.white;
                                          } else if (remain == "empty") {
                                            stockColor = Colors.grey[300];
                                            stockText = "재고없음😢";
                                            stockTextColor = Colors.black;
                                          } else if (remain == "break") {
                                            stockColor = Colors.grey[300];
                                            stockText = "판매중지 🙅‍♂️";
                                            stockTextColor = Colors.black;
                                          } else {
                                            stockColor = Colors.grey[300];
                                            stockText = "정보없음😢";
                                            stockTextColor = Colors.white;
                                          }

                                          return Container(
                                            margin: EdgeInsets.only(bottom: 16, left: 8, right: 8),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context).cardColor,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(38),
                                                  bottomRight: Radius.circular(38),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.black.withOpacity(0.2),
                                                      blurRadius: 2,
                                                      spreadRadius: 1,
                                                      offset: Offset(2, 2))
                                                ]),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                                                        decoration: BoxDecoration(
                                                            color: Theme.of(context).cardColor,
                                                            borderRadius: BorderRadius.only(
                                                              topLeft: Radius.circular(20),
                                                              bottomRight: Radius.circular(20),
                                                            ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                  color: Colors.black.withOpacity(0.1),
                                                                  blurRadius: 3,
                                                                  spreadRadius: 2,
                                                                  offset: Offset(2, 2)),
                                                              BoxShadow(
                                                                  color: Colors.black.withOpacity(0.05),
                                                                  blurRadius: 1,
                                                                  spreadRadius: 1,
                                                                  offset: Offset(-2, -2)),
                                                            ]),
                                                        child: Center(
                                                            child: Text(
                                                          typeText,
                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                        )),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: <Widget>[
                                                          onClickStoreList[index].stockAt != null
                                                              ? Text(
                                                                  "입고시간: ${onClickStoreList[index].stockAt}",
                                                                  style: TextStyle(fontSize: 12),
                                                                )
                                                              : Text(
                                                                  "입고시간: 정보없음",
                                                                  style: TextStyle(fontSize: 12),
                                                                ),
                                                          onClickStoreList[index].createdAt != null
                                                              ? Text(
                                                                  "생성일: ${onClickStoreList[index].createdAt}",
                                                                  style: TextStyle(fontSize: 12),
                                                                )
                                                              : Text(
                                                                  "생성일: 정보없음",
                                                                  style: TextStyle(fontSize: 12),
                                                                )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 16,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 6,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            onClickStoreList[index].name != null
                                                                ? Text(
                                                                    "판매처: ${onClickStoreList[index].name}",
                                                                    style: TextStyle(fontSize: 16),
                                                                  )
                                                                : Text(
                                                                    "판매처: 정보없음",
                                                                    style: TextStyle(fontSize: 16),
                                                                  ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(right: 48),
                                                              child: onClickStoreList[index].addr != null
                                                                  ? SelectableText(
                                                                      "${onClickStoreList[index].addr}",
                                                                      style: TextStyle(fontSize: 12),
                                                                    )
                                                                  : Text(
                                                                      "주소 정보없음",
                                                                      style: TextStyle(fontSize: 12),
                                                                    ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                          flex: 3,
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              analytics.logEvent(name: "ClickToMap");
//                                                              _launchURL(
//                                                                  "geo:${onClickStoreList[index].lat},${onClickStoreList[index].lng}?q=${onClickStoreList[index].name}");
                                                            },
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.only(
                                                                    bottomRight: Radius.circular(24),
                                                                    topLeft: Radius.circular(24),
                                                                  ),
                                                                  color: stockColor),
                                                              child: Center(
                                                                child: Text(
                                                                  stockText,
                                                                  style: TextStyle(
                                                                      color: stockTextColor,
                                                                      fontWeight: FontWeight.bold),
                                                                ),
                                                              ),
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('근처 판매점이 존재하지 않아요😫'),
                                    ),
                                    MaterialButton(
                                      color: Colors.teal,
                                      padding: EdgeInsets.all(8),
                                      onPressed: () {
                                        setState(() {
                                          onClickStart = false;
                                          onClickCompleted = false;
                                          onClickStoreList.clear();
                                          onClickStateText = "";
                                        });
                                      },
                                      child: Text(
                                        '다시시도',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                )
                          : onClickStart
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    CircularProgressIndicator(),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(onClickStateText),
                                    )
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image.network(
                                      "https://assets-ouch.icons8.com/thumb/918/5a740b73-921a-448e-a681-a03c20dcea66.png",
                                      height: MediaQuery.of(context).size.height / 3.5,
                                      width: MediaQuery.of(context).size.width / 2,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        _permissionGranted = await location.hasPermission();
                                        if (_permissionGranted == PermissionStatus.denied) {
                                          print("원래 권한이 디나인");
                                          _permissionGranted = await location.requestPermission();
                                          if (_permissionGranted != PermissionStatus.granted) {
                                            print("요청하고 위치 권한 허용 안함");
                                          } else {
                                            print("요청하고 위치권한 허용함.");
                                          }
                                        } else {
                                          print("위치 권한 허용 유저");
                                          if (_locationData != null) {
                                            print(_locationData.latitude.toString());
                                            setState(() {
                                              onClickStart = true;
                                              onClickStateText = "주소 정보 가져오는 중...";
                                            });
                                            getUserAddress(mapApiId, mapApiKey, _locationData.latitude.toString(),
                                                    _locationData.longitude.toString())
                                                .then((value) {
                                              print(value);
                                              if (value != "" && value != "404") {
                                                onClickUserAddressText = value;
                                                setState(() {
                                                  onClickStateText = "주소 정보 가져오기 성공!! 😍\n"
                                                      "$value 주변의 공적마스크 판매처를 검색중입니다..."
                                                      "잠시만 기다려주세요";
                                                });
                                                getMaskFromAddress(value).then((result) {
                                                  if (result != null) {
                                                    List<Stores> tmpStores = result.stores;

                                                    tmpStores.forEach((element) {
                                                      print(element.name);
                                                    });

                                                    // 리스트 정렬
                                                    onClickStoreList.addAll(
                                                        tmpStores.where((f) => f.remainStat == "plenty").toList());
                                                    onClickStoreList.addAll(
                                                        tmpStores.where((f) => f.remainStat == "some").toList());
                                                    onClickStoreList
                                                        .addAll(tmpStores.where((f) => f.remainStat == "few").toList());
                                                    onClickStoreList.addAll(
                                                        tmpStores.where((f) => f.remainStat == "empty").toList());
                                                    onClickStoreList
                                                        .addAll(tmpStores.where((f) => f.remainStat == null).toList());

//                                                  tmpStores.where((f) => f.stockAt =="empty").toList();
                                                    setState(() {
//                                                    onClickStoreList =
//                                                        tmpStores;
                                                      onClickCompleted = true;
                                                      onClickStart = true;
                                                      onClickStateText = "주변 ${result.count}곳의 장소를 찾았습니다.";
                                                    });
                                                  }
                                                }).timeout(Duration(seconds: 10), onTimeout: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: Text('알림'),
                                                          content: Text("시간초과 (잠시후 다시 시도 해주시거나 인터넷 연결을 확인해주세요)"),
                                                          actions: <Widget>[
                                                            ButtonBar(
                                                              children: <Widget>[
                                                                FlatButton(
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                  child: Text("확인"),
                                                                )
                                                              ],
                                                            )
                                                          ],
                                                        );
                                                      });
                                                  setState(() {
                                                    onClickStoreList.clear();
                                                    onClickCompleted = false;
                                                    onClickStart = false;
                                                    onClickStateText = "";
                                                  });
                                                });
//                                        setState(() {
//                                          onClickStateText ="$value 주변의 공적마스크 판매처를 검색중입니다...";
//                                        });
                                              } else {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Text('알림'),
                                                        content: Text("알수 없는 오류 (잠시후 다시 시도 해주시거나 인터넷 연결을 확인해주세요)"),
                                                        actions: <Widget>[
                                                          ButtonBar(
                                                            children: <Widget>[
                                                              FlatButton(
                                                                onPressed: () {
                                                                  Navigator.of(context).pop();
                                                                },
                                                                child: Text("확인"),
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      );
                                                    });
                                                setState(() {
                                                  onClickStoreList.clear();
                                                  onClickCompleted = false;
                                                  onClickStart = false;
                                                  onClickStateText = "";
                                                });
                                              }
                                            });
                                          } else {
                                            _locationData = await location.getLocation();
                                          }
                                        }
                                      },
                                      child: AvatarGlow(
                                        startDelay: Duration(milliseconds: 500),
                                        glowColor: isDark ? Theme.of(context).accentColor : Colors.red,
                                        endRadius: 120.0,
                                        duration: Duration(milliseconds: 1200),
                                        repeat: true,
                                        showTwoGlows: true,
                                        repeatPauseDuration: Duration(milliseconds: 50),
                                        child: Material(
                                          elevation: 8.0,
                                          shape: CircleBorder(),
                                          child: CircleAvatar(
                                            backgroundColor: Theme.of(context).cardColor,
                                            child: Icon(
                                              LineIcons.play,
                                              size: 58,
                                              color: isDark ? Theme.of(context).accentColor : Colors.red,
                                            ),
                                            radius: 60.0,
                                          ),
                                        ),
                                        shape: BoxShape.circle,
                                        animate: true,
                                        curve: Curves.fastOutSlowIn,
                                      ),
                                    ),
                                    Text(
                                      "원클릭 검색하기",
                                      style:
                                          Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                    ),
                  ),

            //원래 첫번쨰 페이지 범위기반 검색
            !appPublishFlag
                ? NotificationItem()
                : SingleChildScrollView(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: <Widget>[
                        Card(
                          elevation: 6,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "검색 반경 설정",
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                Text(
                                  "현재 위치를 기반으로 검색 반경을 지정할 수 있습니다. (기본 1000 [m] / 1 [km])",
                                  style: Theme.of(context).textTheme.caption,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 8,
                                        child: TextField(
                                          autofocus: false,
                                          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                          keyboardType: TextInputType.number,
                                          controller: rangeTextController,
                                          decoration: InputDecoration(
                                              suffix: Text("m"),
                                              border: OutlineInputBorder(),
                                              labelText: "반경(m)",
                                              hintText: "100m(최대 5000m)"),
                                          onChanged: (value) {},
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: ButtonBar(
                                          children: <Widget>[
                                            MaterialButton(
                                              child: Text('검색'),
                                              onPressed: () {
                                                if (int.parse(rangeTextController.text) > 5000) {
                                                  rangeTextController.text = "5000";
                                                }
//                                              FocusScope.of(context).unfocus();
//                              String lat = latTextController.text;
//                              String lng = lngTextController.text;
                                                String r = rangeTextController.text;

                                                if (
//                              lat.length > 0 &&
//                                  lng.length > 0 &&
                                                    _locationData != null && r.length > 0) {
                                                  print("latitude : ${_locationData.latitude.toString()}");
                                                  print("longitude : ${_locationData.longitude.toString()}");
                                                  if (stores.length > 0 && stores != null) {
                                                    stores.clear();
                                                    getMask(_locationData.latitude.toString(),
                                                            _locationData.longitude.toString(), r)
                                                        .timeout(Duration(seconds: 10), onTimeout: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: Text("안내"),
                                                              content: Text("접속량이 많아 다소 지연이 발생할 수 있습니다. 다시 시도해주세요"),
                                                              actions: <Widget>[
                                                                ButtonBar(
                                                                  children: <Widget>[
                                                                    FlatButton(
                                                                      child: Text("확인"),
                                                                      onPressed: () {
                                                                        Navigator.of(context).pop();
                                                                      },
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            );
                                                          });
                                                      return null;
                                                    });
                                                  }
                                                  setSearchLog(_locationData.latitude.toString(),
                                                      _locationData.longitude.toString(), r);
                                                }
                                                // 입력창이 비어있다면
                                                else {
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
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height / 1.8,
                          width: MediaQuery.of(context).size.width,
                          child: _locationData != null
                              ? FutureBuilder<StoreSaleResult>(
                                  future: getMask(_locationData.latitude.toString(), _locationData.longitude.toString(),
                                      rangeTextController.text),
                                  builder: (context, snapshot) {
//                            if (snapshot.data == null)
//                              return Center(
//                                child: Text("다시 시도해주세요 "),
//                              );
                                    if (snapshot.hasData) {
                                      resultList = snapshot.data;

                                      stores = resultList.stores;

                                      if (stores.length > 0) {
//                                      filterStores.addAll(stores.where((e) => e.remainStat == "plenty").toList());
//                                      filterStores.addAll(stores.where((e) => e.remainStat == "some").toList());
//                                      filterStores.addAll(stores.where((e) => e.remainStat == "few").toList());
//                                      filterStores.addAll(stores.where((e) => e.remainStat == "empty").toList());
//                                      filterStores.addAll(stores.where((e) => e.remainStat == "null").toList());
//
//
//                                      stores.addAll(resultList.stores.where((e) => e.remainStat == "plenty").toList());
//                                      stores.addAll(resultList.stores.where((e) => e.remainStat == "some").toList());
//                                      stores.addAll(resultList.stores.where((e) => e.remainStat == "few").toList());
//                                      stores.addAll(resultList.stores.where((e) => e.remainStat == "empty").toList());
//                                      stores.addAll(resultList.stores.where((e) => e.remainStat == "null").toList());
//                                      stores.addAll(resultList.stores.where((e) => e.remainStat == null).toList());

                                        return Padding(
                                          padding: const EdgeInsets.only(top: 16),
                                          child: ListView.builder(
                                            physics: BouncingScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: stores.length,
                                            itemBuilder: (context, index) {
                                              Color stockColor;
                                              Color stockTextColor;
                                              String stockText = "알수없음";
                                              String remain = stores[index].remainStat;
                                              String type = stores[index].type;
                                              String typeText;
                                              if (type == "01") {
                                                typeText = "약국";
                                              } else if (type == "02") {
                                                typeText = "우체국";
                                              } else if (type == "03") {
                                                typeText = "농협";
                                              } else {
                                                typeText = "정보없음";
                                              }

                                              if (remain == "plenty") {
                                                stockColor = Colors.lightGreen;
                                                stockText = "100개 이상😆";
                                                stockTextColor = Colors.white;
                                              } else if (remain == "some") {
                                                stockColor = Colors.yellow;
                                                stockText = "30개이상~\n100개미만😀";
                                                stockTextColor = Colors.black;
                                              } else if (remain == "few") {
                                                stockColor = Colors.red;
                                                stockText = "30개 미만🤔";
                                                stockTextColor = Colors.white;
                                              } else if (remain == "empty") {
                                                stockColor = Colors.grey[300];
                                                stockText = "재고없음😢";
                                                stockTextColor = Colors.black;
                                              } else if (remain == "break") {
                                                stockColor = Colors.grey[300];
                                                stockText = "판매중지 🙅‍♂️";
                                                stockTextColor = Colors.black;
                                              } else {
                                                stockColor = Colors.grey[300];
                                                stockText = "정보없음😢";
                                                stockTextColor = Colors.white;
                                              }

                                              return Container(
                                                margin: EdgeInsets.only(bottom: 16, left: 8, right: 8),
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context).cardColor,
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(38),
                                                      bottomRight: Radius.circular(38),
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Colors.black.withOpacity(0.2),
                                                          blurRadius: 2,
                                                          spreadRadius: 1,
                                                          offset: Offset(2, 2))
                                                    ]),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(16),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          Container(
                                                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                                                            decoration: BoxDecoration(
                                                                color: Theme.of(context).cardColor,
                                                                borderRadius: BorderRadius.only(
                                                                  topLeft: Radius.circular(20),
                                                                  bottomRight: Radius.circular(20),
                                                                ),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors.black.withOpacity(0.1),
                                                                      blurRadius: 3,
                                                                      spreadRadius: 2,
                                                                      offset: Offset(2, 2)),
                                                                  BoxShadow(
                                                                      color: Colors.black.withOpacity(0.05),
                                                                      blurRadius: 1,
                                                                      spreadRadius: 1,
                                                                      offset: Offset(-2, -2)),
                                                                ]),
                                                            child: Center(
                                                              child: Text(typeText,
                                                                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                                        fontWeight: FontWeight.bold,
                                                                      )),
                                                            ),
                                                          ),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: <Widget>[
                                                              stores[index].stockAt != null
                                                                  ? Text(
                                                                      "입고시간: ${stores[index].stockAt}",
                                                                      style: TextStyle(fontSize: 12),
                                                                    )
                                                                  : Text(
                                                                      "입고시간: 정보없음",
                                                                      style: TextStyle(fontSize: 12),
                                                                    ),
                                                              stores[index].createdAt != null
                                                                  ? Text(
                                                                      "생성일: ${stores[index].createdAt}",
                                                                      style: TextStyle(fontSize: 12),
                                                                    )
                                                                  : Text(
                                                                      "생성일: 정보없음",
                                                                      style: TextStyle(fontSize: 12),
                                                                    )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 16,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          Expanded(
                                                            flex: 6,
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: <Widget>[
                                                                stores[index].name != null
                                                                    ? Text(
                                                                        "판매처: ${stores[index].name}",
                                                                        style: TextStyle(fontSize: 16),
                                                                      )
                                                                    : Text(
                                                                        "판매처: 정보없음",
                                                                        style: TextStyle(fontSize: 16),
                                                                      ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 48),
                                                                  child: stores[index].addr != null
                                                                      ? SelectableText(
                                                                          "${stores[index].addr}",
                                                                          style: TextStyle(fontSize: 12),
                                                                        )
                                                                      : Text(
                                                                          "주소 정보없음",
                                                                          style: TextStyle(fontSize: 12),
                                                                        ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                              flex: 3,
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.only(
                                                                      bottomRight: Radius.circular(24),
                                                                      topLeft: Radius.circular(24),
                                                                    ),
                                                                    color: stockColor),
                                                                child: Center(
                                                                  child: Text(
                                                                    stockText,
                                                                    style: TextStyle(
                                                                        color: stockTextColor,
                                                                        fontWeight: FontWeight.bold),
                                                                  ),
                                                                ),
                                                              )),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      } else if (stores.length == 0) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Image.network(
                                              "https://assets-ouch.icons8.com/thumb/100/17018717-ad19-4c5b-9a9b-f31a1270ed1f.png",
                                              height: MediaQuery.of(context).size.height / 3.8,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                "검색결과 근처에 판패처가 없어요. \n검색 반경을 늘려보거나 왼쪽 상단의 지도를 이용해보세요.",
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          ],
                                        );
                                      }
                                      //응답받은 결과의 길이가 0이 아닐떄
                                      else {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            CircularProgressIndicator(),
                                            Text("잠시만 기다려주세요..."),
                                            Text("접속량이 많아 다소 지연이 될수 있습니다."),
                                            Text("권장: 네트워크 환경이 원할한 곳에서 사용해주세요."),
                                          ],
                                        );
                                      }
                                    } else {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[CircularProgressIndicator(), Text("정보요청중...")],
                                      );
                                    }
                                  },
                                )
                              : Center(child: Text("위치정보 받아오는 중...")),
                        ),
                      ],
                    ),
                  ),

//          SearchAddressPage(),

//          SingleChildScrollView(
//            child: Container(
//              height: MediaQuery.of(context).size.height - 140,
//              child: Column(
//                children: <Widget>[
//                  Expanded(
//                    flex: 2,
//                    child: Padding(
//                      padding: const EdgeInsets.all(16.0),
//                      child: Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                        crossAxisAlignment: CrossAxisAlignment.center,
//                        children: <Widget>[
//                          Flexible(
//                            child: Column(
//                              mainAxisAlignment: MainAxisAlignment.center,
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              children: <Widget>[
//                                Text(
//                                  "주소",
//                                  style: TextStyle(fontSize: 16),
//                                ),
//                                Text(
//                                  addressJSON,
//                                  style: TextStyle(fontSize: 12),
//                                )
//                              ],
//                            ),
//                          ),
//                          MaterialButton(
//                            color: Colors.teal,
//                            onPressed: () async {
//                              KopoModel model = await Navigator.push(
//                                context,
//                                CupertinoPageRoute(
//                                  builder: (context) => Kopo(),
//                                ),
//                              );
//
//                              print("모델 두 제이썬 : ${model.toJson()}");
//                              setState(() {
//                                addressJSON =
//                                    '${model.address} ${model.buildingName}${model.apartment == 'Y' ? '아파트' : ''} ${model.zonecode} ';
//                              });
//
//                              print(addressJSON);
//                            },
//                            child: Text(
//                              "주소검색",
//                              style: TextStyle(color: Colors.white),
//                            ),
//                          ),
//                        ],
//                      ),
//                    ),
//                  ),
//                  Expanded(
//                    flex: 10,
//                    child: Placeholder(),
//                  ),
//                ],
//              ),
//            ),
//          ),

//            //세번째 페이지
//            Container(
//              height: MediaQuery.of(context).size.height,
//              width: MediaQuery.of(context).size.width,
//              color: Theme.of(context).scaffoldBackgroundColor,
//              child: Column(
//                crossAxisAlignment: CrossAxisAlignment.center,
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  Image.network("https://assets-ouch.icons8.com/thumb/866/7387d6d9-81eb-405c-854f-d73b00b8e789.png"),
//                  Center(
//                    child: Text("개발중...업데이트 예정"),
//                  ),
//                ],
//              ),
//            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: MediaQuery.of(context).size.height - 80,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "태어난 연도",
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
                                      autofocus: false,
                                      maxLength: 4,
                                      controller: birthTextController,
                                      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
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
                                            if (birthTextController.text.length > 0 &&
                                                birthTextController.text.length == 4) {
//                                            FocusScope.of(context).unfocus();

                                              int num = int.parse(birthTextController.text[3]);

                                              if (num == 1 || num == 6) {
                                                userDay = "월";
                                              } else if (num == 2 || num == 7) {
                                                userDay = "화";
                                              } else if (num == 3 || num == 8) {
                                                userDay = "수";
                                              } else if (num == 4 || num == 9) {
                                                userDay = "목";
                                              } else if (num == 5 || num == 0) {
                                                userDay = "금";
                                              }

                                              setUserBirth(birthTextController.text, userDay);

                                              setState(() {});
                                            } else {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                        content: Text("4자리 출생연도를 입력해주세요"),
                                                      ));
                                            }
                                          },
                                          child: Text('적용'),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
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
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 12,
            currentIndex: pageIndex,
            selectedItemColor: Colors.indigo,
            onTap: (newValue) {
              if (newValue == 2) {
                getUserBirth().then((value) {
                  birthTextController.text = value;
                  getUserDay().then((v) {
                    setState(() {
                      userDay = v;
                    });
                  });
                });
              }
              setState(() {
                pageIndex = newValue;
              });
            },
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.plus_one), title: Text("원클릭검색")),
              BottomNavigationBarItem(icon: Icon(Icons.my_location), title: Text("내위치주변")),
//              BottomNavigationBarItem(icon: Icon(Icons.list), title: Text("검색기록")),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), title: Text("구매 요일 확인")),
            ]),
        floatingActionButton: _buildFloatingActionButton(pageIndex)
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  Widget _buildFloatingActionButton(int index) {
    if (index == 0) {
      if (onClickStoreList.length > 0) {
        return FloatingActionButton(
          tooltip: "open map",
          child: Icon(Icons.map),
          onPressed: () async {
            analytics.logEvent(name: "ClickToMap");
            if (onClickStoreList != null) {
              List<Stores> tmp = onClickStoreList;
              onClickStoreList = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MapTest(
                        userLocation: _locationData,
                        storeItems: onClickStoreList,
                        analytics: analytics,
                      )));

              print("returned");
              if (onClickStoreList == null) {
                setState(() {
                  onClickCompleted = false;
                  onClickStart = false;
//                  onClickStoreList = tmp;
                });
              } else {
                if (onClickStoreList.length == 0) {
                  setState(() {
                    onClickCompleted = false;
                    onClickStart = false;
//                  onClickStoreList = tmp;
                  });
                }
              }

//              setState(() {});
            } else {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MapTest(
                        userLocation: _locationData,
                        storeItems: [],
                        analytics: analytics,
                      )));
            }
          },
        );
      } else {
        return null;
      }
    } else if (index == 1) {
      return FloatingActionButton(
        onPressed: () {
          analytics.logEvent(name: "userRefresh");
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
//                setState(() {
//                  if (stores != null) {
//                    stores.clear();
//                  }
//                });
        },
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      );
    } else {
      return null;
    }
  }

  _buildOnClickWidget(OnClickProcessState onClickProcessState) {
    switch (onClickProcessState) {
      case OnClickProcessState.beforeStart:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              "https://assets-ouch.icons8.com/thumb/918/5a740b73-921a-448e-a681-a03c20dcea66.png",
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width / 2,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                        : null,
                  ),
                );
              },
            ),
            GestureDetector(
              onTap: () async {
                analytics.logEvent(name: "onClickTouch");
                _permissionGranted = await location.hasPermission();
                if (_permissionGranted == PermissionStatus.denied) {
                  print("원래 권한이 디나인");
                  _permissionGranted = await location.requestPermission();
                  if (_permissionGranted != PermissionStatus.granted) {
                    print("요청하고 위치 권한 허용 안함");
                  } else {
                    print("요청하고 위치권한 허용함.");
                  }
                } else {
                  print("위치 권한 허용 유저");
                  if (_locationData != null) {
                    print(_locationData.latitude.toString());
                    setState(() {
                      onClickProcessState = OnClickProcessState.start;
                    });
                    getUserAddress(
                        mapApiId, mapApiKey, _locationData.latitude.toString(), _locationData.longitude.toString());
                  } else {
                    _locationData = await location.getLocation();
                  }
                }
              },
              child: AvatarGlow(
                startDelay: Duration(milliseconds: 500),
                glowColor: Colors.red,
                endRadius: 140.0,
                duration: Duration(milliseconds: 1000),
                repeat: true,
                showTwoGlows: true,
                repeatPauseDuration: Duration(milliseconds: 80),
                child: Material(
                  elevation: 8.0,
                  shape: CircleBorder(),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[100],
                    child: Icon(
                      LineIcons.play,
                      size: 58,
                      color: Colors.red,
                    ),
                    radius: 60.0,
                  ),
                ),
                shape: BoxShape.circle,
                animate: true,
                curve: Curves.fastOutSlowIn,
              ),
            ),
            Text(
              "원클릭 검색하기",
              style: Theme.of(context).textTheme.headline5.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        );
        break;
      case OnClickProcessState.start:
        return Column();
        break;
      default:
        return null;
        break;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
//    Hive.close();
    locationSubscription.cancel();
    super.dispose();
  }

  _showVersionDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "새로운 버전 출시";
        String message = "지금보다 개선된 새로운 버전이 출시되었어요! 보다 나은 서비스 이용을 위해서 최신버전을 유지하는것을 추천드립니다. 업데이트하시겠어요?";
        String btnLabel = "지금 업데이트";
        String btnLabelCancel = "나중에";
        return new AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text(btnLabel),
              onPressed: () => _launchURL(PLAY_STORE_URL),
            ),
            FlatButton(
              child: Text(btnLabelCancel),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchEmail(String email) async {
    if (await canLaunch("mailto:$email")) {
      await launch("mailto:$email");
    } else {
      throw 'Could not launch';
    }
  }

  @override
  void didUpdateWidget(MyHomePage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    print("didUpdateWidget!!!!");
  }

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  _fetchData() {
    return this._memoizer.runOnce(() async {
      await Future.delayed(Duration(seconds: 2));
      return 'REMOTE DATA';
    });
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults

    if (query.length < 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Search term must be longer than two letters.",
            ),
          )
        ],
      );
    }
    return Column();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return Column();
  }
}
