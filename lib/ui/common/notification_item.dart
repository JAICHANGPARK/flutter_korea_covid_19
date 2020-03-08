import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Card(
        elevation: 7,
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("밤낮으로 고생하시는 우리나라 모든 약사님들께 감사의 인사를 드립니다."),
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
              Text("현재 서비스 준비중 및 테스트 기간 입니다."),
              Text(
                "내부적으로 오픈일정이 결정되기 전까지 서비스 이용을 제한합니다.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
