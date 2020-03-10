import 'package:flutter/material.dart';
import 'package:fluttermasktest/ui/screen/info_web_view_page.dart';


class AppDrawerItem extends StatefulWidget {
  final bool userAgreeState;
  int pageIndex;
  final String appVersion;

  AppDrawerItem({this.userAgreeState, this.pageIndex, this.appVersion});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawerItem> {
  @override
  Widget build(BuildContext context) {
    return ListView(
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
                  url:
                  "http://ncov.mohw.go.kr/shBoardView.do?brdId=3&brdGubun=36&ncvContSeq=1092",
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
                    url:
                    "https://www.mfds.go.kr/brd/m_99/view.do?seq=43955",
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
              widget.pageIndex = 3;
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
              subtitle: Text("박제창 (Dreamwalker)"),
            ),
            ListTile(
              title: Text("이메일 (문의하기)"),
              subtitle: Text("aristojeff@gmail.com"),
            ),
            ListTile(
              title: Text("리포지토리"),
              subtitle: Text("https://github.com/JAICHANGPARK"),
            ),
          ],
        ),
        ListTile(
          title: Text('앱정보'),
          onTap: () {
            showAboutDialog(
                context: context,
                applicationName: "공적마스크 검색이",
                applicationVersion: widget.appVersion,
                applicationIcon: Image.asset(
                  'assets/icon/icons2/playstore.png',
                  width: 64,
                  height: 64,
                ));
          },
        ),
        ListTile(
          title: Text("유의사항"),
          subtitle: Text(
            "5분 이상 전의 데이터로 실제 재고와 차이가 있을 수 있습니다",
            style: TextStyle(fontSize: 12),
          ),
        ),
        ListTile(
            title: Text("정보 제공"),
            subtitle: Text(
              "공공데이터포털(건강보험심사평가원)",
              style: TextStyle(fontSize: 12),
            )),
        ListTile(
          title: Text(
            "서비스 이용 동의",
          ),
          subtitle: widget.userAgreeState
              ? Text(
            "서비스 사용 동의 처리완료",
            style: TextStyle(fontSize: 12),
          )
              : Text(
            "서비스 사용 동의 미완료",
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
