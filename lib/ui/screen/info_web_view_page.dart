import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InformationWebViewPage extends StatefulWidget {
  final String url;
  final String title;

  InformationWebViewPage({@required this.url, this.title});

  @override
  _InformationWebViewPageState createState() => _InformationWebViewPageState();
}

class _InformationWebViewPageState extends State<InformationWebViewPage> {
  bool pageState = true;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          pageState ? Center(child: CircularProgressIndicator()) : Container()
        ],
      ),
      body: WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
        javascriptChannels: <JavascriptChannel>[
          _toasterJavascriptChannel(context),
        ].toSet(),
//        navigationDelegate: (NavigationRequest request) {
//          if (request.url.startsWith('https://www.youtube.com/')) {
//            print('blocking navigation to $request}');
//            return NavigationDecision.prevent;
//          }
//          print('allowing navigation to $request');
//          return NavigationDecision.navigate;
//        },
        onPageStarted: (String url) {
          setState(() {
            pageState = true;
          });
          print('Page started loading: $url');
        },
        onPageFinished: (String url) {
          print('Page finished loading: $url');
          setState(() {
            pageState = false;
          });
        },
        gestureNavigationEnabled: true,
      ),
    );
  }
}

JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
  return JavascriptChannel(
      name: 'Toaster',
      onMessageReceived: (JavascriptMessage message) {
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      });
}
