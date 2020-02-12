import 'dart:async';
import 'dart:math';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lotto/calcPanel.dart';
import 'package:lotto/history.dart';
import 'package:lotto/numberSelect.dart';

import 'core/coreLibrary.dart';
import 'core/widgets.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
   
  //FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId); //테스트용
  FirebaseAdMob.instance.initialize(appId: getAdmobAppId());
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: <String, WidgetBuilder>{
        '/CalcPanel': (BuildContext context) => new CalcPanel(),
        '/History': (BuildContext context) => new History(),
        '/NumberSelect': (BuildContext context) => new NumberSelect()
      },
      home: MyHomePage(title: '초기 화면'),
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void mainImageProcess() {
    //Navigator.of(context).pushNamed('/NumberSelect', arguments: "");
    Timer(Duration(seconds: 2), () {
      setState(() {
        isTrigger = true;
      });
      Timer(Duration(seconds: 2), () {
        isButtonVisible = true;
        Navigator.of(context).pushNamed('/NumberSelect', arguments: "");
      });
    });
  }

  String imagePath1 = "images/lottoMainImageBefore.jpg";
  String imagePath2 = "images/lottoMainImageAfter.jpg";

  Widget _crossFade(Widget first, Widget second, bool isExpanded) {
    //return AnimatedPositioned(child: first, duration: const Duration(milliseconds: 200));
    return AnimatedCrossFade(
      firstChild: first,
      secondChild: second,
      firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
      secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
      sizeCurve: Curves.fastOutSlowIn,
      crossFadeState:
          isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
    );
  }

  bool isTrigger = false;
  bool isButtonVisible = false;

  @override
  void initState() {
    mainImageProcess();
  }

  @override
  Widget build(BuildContext context) {
    Image image1 = Image.asset(
      imagePath1,
      height: 400,
    );
    Image image2 = Image.asset(
      imagePath2,
      height: 400,
    );

    return Scaffold(
        key: _scaffoldKey,
        // appBar: AppBar(
        //   backgroundColor: Colors.indigo[500],
        //   title: Text(widget.title),
        // ),
        body: Container(
          color: Colors.grey[100],
          child: Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 40),
                  child: _crossFade(image1, image2,
                      isTrigger) // Image.asset(imagePath1, height: 400,),
                  ),
              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(top: 100),
                child: Text("로또 맞을 확률", style: TextStyle(fontSize: 40),),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.only(bottom: 30),
                child: Visibility(
                  visible: isButtonVisible,
                  child: RaisedButton(
                      child: Text("확인"),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed('/NumberSelect', arguments: "");
                      }),
                ),
              )
            ],
          ),
        ));
  }
}
