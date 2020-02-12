import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lotto/calcPanel.dart';
import 'package:lotto/history.dart';

import 'core/widgets.dart';


class NumberSelect extends StatefulWidget {
  NumberSelect({Key key, this.title}) : super(key: key);
  final String title;

  @override
  NumberSelectState createState() => NumberSelectState();
}

class NumberSelectState extends State<NumberSelect> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  bool _showElevation = true;

  List<Widget> buildCards() {
    const List<double> elevations = <double>[
      0.0,
      1.0,
      2.0,
      3.0,
      4.0,
      5.0,
      8.0,
      16.0,
      24.0,
    ];

    return elevations.map<Widget>((double elevation) {
      return Center(
        child: Card(
          margin: const EdgeInsets.all(20.0),
          elevation: _showElevation ? elevation : 0.0,
          child: SizedBox(
            height: 50.0,
            width: 50.0,
            child: Center(
              child: Text('${elevation.toStringAsFixed(0)} pt'),
            ),
          ),
        ),
      );
    }).toList();
  }

  // const List<String> itemList = <String>[
  //   "test"

  // ];
  final Set<String> _selectedTools = <String>{};
  //final Set<int> selectedNumbers = <int>{};

  List<String> lottoNumbers = <String>[
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31',
    '32',
    '33',
    '34',
    '35',
    '36',
    '37',
    '38',
    '39',
    '40',
    '41',
    '42',
    '43',
    '44',
    '45',
  ];

  String selectedValue = "";
  List<int> selectedNumbers = List<int>();

  ////번호 자동생성
  void numberRandomSelect() {
    _selectedTools.clear();

    var ran = new Random();

    for (int i = 0; i < 6; i++) {
      bool isNumSelected = false;
      int intRan = 0;
      while (isNumSelected == false) {
        intRan = ran.nextInt(45);
        if (intRan > 45 || intRan < 1) {
          continue;
        }

        if (_selectedTools.contains(intRan.toString()) == true) {
          continue;
        }

        isNumSelected = true;
      }

      if (_selectedTools.length <= 5) {
        _selectedTools.add(intRan.toString());
      }
    }

    numberSelected();
  }

  ///// 번호 선택후 처리
  void numberSelected() {
    selectedValue = "";

    this.selectedNumbers = List<int>();

    for (int i = 1; i <= 45; i++) {
      if (_selectedTools.contains(i.toString()) == true) {
        selectedNumbers.add(i);
      }
    }

    setState(() {
      for (int i = 0; i < selectedNumbers.length; i++) {
        String value = selectedNumbers.elementAt(i).toString();

        if (selectedValue == "") {
          selectedValue = value;
        } else {
          selectedValue = selectedValue + ", " + value;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.indigo[500],
        title: Text("번호선택"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
                child: Scrollbar(
              child: Container(

                  // child: RaisedButton(),
                  child: Column(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Stack(
                      children: <Widget>[
                        // Container(
                        //   margin: EdgeInsets.only(left: 10, top: 20),
                        //   child: RaisedButton(
                        //     child: Text('자동'),
                        //     color: Colors.grey[300],
                        //     onPressed: (){

                        //     },
                        //   ),
                        // ),
                        Container(
                          //color: Colors.indigo[50],
                          height: 100,
                          child: Center(
                              child: Text(
                            selectedValue,
                            style: TextStyle(fontSize: 27),
                          )),
                        ),
                      ],
                      //color: Colors.red,
                    ),
                  ),
                  Flexible(
                    flex: 5,
                    child: GridView.count(
                        addAutomaticKeepAlives: true,
                        childAspectRatio: 1.6,
                        crossAxisCount: 6,
                        children: lottoNumbers.map<Widget>((String number) {
                          return FilterChip(
                            key: ValueKey<String>(number),
                            label: Text(
                              number,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            selectedColor: Colors.amber[800],
                            backgroundColor: Colors.indigo[300],
                            selected: _selectedTools.contains(number),
                            onSelected: (bool value) {
                              setState(() {
                                if (value == true) {
                                  if (_selectedTools.length <= 5) {
                                    _selectedTools.add(number);
                                  }
                                } else {
                                  _selectedTools.remove(number);
                                }
                                numberSelected();
                              });
                            },
                          );
                        }).toList()),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[


                          SimpleOutlineButton(
                            buttonText: "초기화",
                            isTokenIconVisible: false,
                            onPressed: () {
                              setState(() {
                                _selectedTools.clear();
                                numberSelected();
                              });
                            },
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          SimpleOutlineButton(
                            buttonText: "자동생성",
                            isTokenIconVisible: false,
                            onPressed: () {
                              setState(() {
                                numberRandomSelect();
                              });
                            },
                          ),
                          // simpleOutlineButton(
                          //   buttonText: "자동생성",
                          //   onPressed: () {
                          //     setState(() {
                          //       numberRandomSelect();
                          //     });
                          //   },
                          // ),
                          SizedBox(
                            width: 20,
                          ),
                          SimpleOutlineButton(
                            buttonText: "확인",
                            isTokenIconVisible: false,
                            onPressed: () {
                              if (selectedNumbers == null) {
                                final snackBar = SnackBar(
                                    content: Text('번호를 선택해야 합니다.'),
                                    duration: Duration(milliseconds: 1000));
                                //Scaffold.of(context).showSnackBar(snackBar);
                                _scaffoldKey.currentState
                                    .showSnackBar(snackBar);
                                return;
                              }

                              if (selectedNumbers.length != 6) {
                                final snackBar = SnackBar(
                                    content: Text('6개의 번호를 선택해 주세요.'),
                                    duration: Duration(milliseconds: 1000));
                                // Scaffold.of(context).showSnackBar(snackBar);

                                //ShowSnackBar(context, '6개의 번호를 선택해 주세요.');
                                _scaffoldKey.currentState
                                    .showSnackBar(snackBar);
                                return;
                              }

                              Navigator.of(context).pushNamed('/CalcPanel',
                                  arguments: selectedNumbers);
                            },
                          ),
                          // simpleOutlineButton(
                          //   buttonText: "확인",
                          //   onPressed: () {
                          //     // if ("1" == "1") {
                          //     //   print("test");
                          //     // }

                              
                          //   },
                          // ),
                        ],
                      ),
                    ),
                  )
                ],
              )),
            ))
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class simpleOutlineButton extends StatelessWidget {
  const simpleOutlineButton({
    Key key,
    this.onPressed,
    @required this.buttonText,
  }) : super(key: key);

  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      highlightedBorderColor: Colors.green,
      //highlightColor: Colors.red,
      color: Colors.white,
      splashColor: Colors.green[300],
      child: Text(
        buttonText,
        style: GoogleFonts.padauk(textStyle: TextStyle(fontSize: 20)),
        //style: TextStyle(fontSize: 20),
      ),

      onPressed: onPressed,
    );
  }
}

void ShowSnackBar(BuildContext buildContext, String message) {
  if (buildContext != null) {
    final snackBar = SnackBar(
        duration: Duration(milliseconds: 1000), content: Text(message));
    Scaffold.of(buildContext).showSnackBar(snackBar);
  }
}
