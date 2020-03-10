import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopo/kopo.dart';

class SearchAddressPage extends StatefulWidget {
  @override
  _SearchAddressPageState createState() => _SearchAddressPageState();
}

class _SearchAddressPageState extends State<SearchAddressPage> {
  String address ="";
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            height: MediaQuery.of(context).size.height / 7,
            decoration: BoxDecoration(
              color: Colors.teal,
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16, top: 24,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("주소",style: Theme.of(context).textTheme.headline4,),
                          Text(address,style: Theme.of(context).textTheme.headline6,),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child:  MaterialButton(
                      color: Colors.teal,
                      onPressed: () async {
                        KopoModel model = await Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => Kopo(),
                          ),
                        );

                        print("모델 두 제이썬 : ${model.toJson()}");
                        setState(() {
                          address =
                          '${model.address} ${model.buildingName}${model.apartment == 'Y' ? '아파트' : ''} ${model.zonecode} ';
                        });

                        print(address);
                      },
                      child: Text(
                        "주소 찾기",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
