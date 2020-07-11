import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class UnderConstructPage extends StatefulWidget {
  @override
  _UnderConstructPageState createState() => _UnderConstructPageState();
}

class _UnderConstructPageState extends State<UnderConstructPage> {
  Future<String> getTextFromRemoteConfig() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    final defaults = <String, dynamic>{'welcome': 'default welcome'};
    await remoteConfig.setDefaults(defaults);
    await remoteConfig.fetch(expiration: const Duration(seconds: 10));
    await remoteConfig.activateFetched();
    var tmp = remoteConfig.getString("under_construct_text");
//    return tmp == "0" ? false : true;
    return tmp;
  }

  String _text;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTextFromRemoteConfig().then((value) {

      setState(() {
        _text = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.network(

//            "https://assets-ouch.icons8.com/thumb/89/66578613-b95f-46f4-b047-87cea9a478d8.png",
            "https://ouch-cdn.icons8.com/preview/836/7d198965-5de4-4bd4-8268-89f409b6a406.png",
            width: MediaQuery.of(context).size.width / 1.5,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(_text ?? "...잠시만 기다려주세요..."),
            ),
          ),
        ],
      ),
    );
  }
}
