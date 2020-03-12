import 'package:flutter/material.dart';

class UnderConstructPage extends StatelessWidget {
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
              "https://assets-ouch.icons8.com/thumb/89/66578613-b95f-46f4-b047-87cea9a478d8.png",
          width: MediaQuery.of(context).size.width / 1.5,),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text("개발 중...."),
            ),
          ),
        ],
      ),
    );
  }
}
