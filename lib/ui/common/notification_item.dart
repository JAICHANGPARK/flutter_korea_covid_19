import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 7,
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "우리나라 모든 약사님들께 감사의 인사를 드립니다.",
                  style: GoogleFonts.nanumPenScript(fontSize: 28),
                ),
                Image.network(
                  "https://assets-ouch.icons8.com/thumb/676/f10310c4-3d7d-4e98-8541-1ea864393a04.png",
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes
                            : null,
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("☕️  ️현재 서비스 준비중 및 시범운영 (베타테스트) 기간(-3/15) 입니다.", textAlign: TextAlign.start,),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "🛠 내부적으로 오픈 일정이 결정되기 전까지 서비스 이용을 잠시 제한합니다.",
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "🛠 1차 서비스 시작은 3월 11일 오전 8시 오픈 예정입니다.",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
