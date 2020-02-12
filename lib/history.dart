import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lotto/core/coreLibrary.dart';
import 'package:lotto/datatable/historyDTO.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<DemoItem<dynamic>> _demoItems = <DemoItem<dynamic>>[];
  CoreLibrary core = new CoreLibrary();

//타이틀 정보를 설정한다.
  DemoItem<String> TitleControlInit(HistoryDTO dto) {
    return DemoItem<String>(
      name: dto.index,
      value: dto.displaySelectedNumber,
      hint: dto.displaySelectedNumber,
      showDt: "showDt",
      ordrInfo: "ordrInfo",
      stodNo: "stodNo",
      valueToString: (String value) => value,
      builder: (DemoItem<String> item) {
        void close() {
          setState(() {
            item.isExpanded = false;
          });
        }

        String grade1Display = "";
        String grade2Display = "";
        String grade3Display = "";
        String grade4Display = "";
        String grade5Display = "";

        final f = new NumberFormat("#,####.#");
        String money_in_display = f.format(dto.moneyIn);
        String money_out_display = f.format(dto.moneyOut);
        String money_sum_display = f.format(dto.moneySum);

        if (dto.grade1Count > 0) {
          grade1Display = core.gradeDislpay(dto.grade1Count.toString(),
              dto.grade1Per.toString(), dto.grade1PerPerson.toString());
        }
        if (dto.grade2Count > 0) {
          grade2Display = core.gradeDislpay(dto.grade2Count.toString(),
              dto.grade2Per.toString(), dto.grade2PerPerson.toString());
        }
        if (dto.grade3Count > 0) {
          grade3Display = core.gradeDislpay(dto.grade3Count.toString(),
              dto.grade3Per.toString(), dto.grade3PerPerson.toString());
        }
        if (dto.grade4Count > 0) {
          grade4Display = core.gradeDislpay(dto.grade4Count.toString(),
              dto.grade4Per.toString(), dto.grade4PerPerson.toString());
        }
        if (dto.grade5Count > 0) {
          grade5Display = core.gradeDislpay(dto.grade5Count.toString(),
              dto.grade5Per.toString(), dto.grade5PerPerson.toString());
        }

        return Form(
          child: Builder(
            builder: (BuildContext context) {
              return CollapsibleBody(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                onSave: () {
                  // Form.of(context).save();
                  // widget.onResearch(item.stodNo);
                  // close();
                },
                onCancel: () {
                  Form.of(context).reset();
                  //ShowMessageBox(context, "확인", "정말 삭제하시겠습니까?");
                  //String titlNm = title.titlNm;
                  ShowMessageBoxWithConfirm(context, "삭제", "정말 삭제하시겠습니까?")
                      .then((ConfirmAction onValue) {
                    if (onValue == ConfirmAction.ACCEPT) {
                      //타이틀 삭제

                      this.orderList.remove(dto);
                      this.saveResult();
                    } else if (onValue == ConfirmAction.CANCEL) {
                      //PASS
                    }
                  });

                  // close();
                },
                //455
                child: Container(
                  height: 200,
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      DisplayLevel2TextControl(
                          title: '1등 : ', value: grade1Display),
                      DisplayLevel2TextControl(
                          title: '2등 : ', value: grade2Display),
                      DisplayLevel2TextControl(
                          title: '3등 : ', value: grade3Display),
                      DisplayLevel2TextControl(
                          title: '4등 : ', value: grade4Display),
                      DisplayLevel2TextControl(
                          title: '5등 : ', value: grade5Display),
                      DisplayLevel2TextControl(
                        title: '복권개수 : ',
                        value: dto.lottoCount.toString(),
                        lastString: "개",
                      ),
                      DisplayLevel2TextControl(
                        title: '지출 : ',
                        value: money_out_display,
                        lastString: "만원",
                      ),
                      DisplayLevel2TextControl(
                          title: '수입 : ',
                          value: money_in_display,
                          lastString: "만원"),
                      DisplayLevel2TextControl(
                          title: '총 금액 : ',
                          value: money_sum_display,
                          lastString: "만원"),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<HistoryDTO> orderList = new List<HistoryDTO>();

  void readResult() {
    //저장된 데이터 읽기
    this._demoItems = <DemoItem<dynamic>>[];
    orderList = new List<HistoryDTO>();
    CoreLibrary core = new CoreLibrary();

    core.HistoryRead().then((value) {
      //List<HistoryDTO> orderList = new List<HistoryDTO>();
      String result = value.toString();
      try {
        if (result != null && result.length > 0 && result.toString() != "0") {
          Map decodeResult = json.decode(result);
          if (decodeResult.containsKey("ListData")) {
            //Map orders = decodeResult["ListData"][0];
            List list = decodeResult["ListData"];
            if (list != null && list.length > 0) {
              for (int i = 0; i < list.length; i++) {
                Map order = list.elementAt(i);
                HistoryDTO newDTO = HistoryDTO.fromJson(order);
                if (newDTO != null) {
                  setState(() {
                    orderList.add(newDTO);
                  });
                }
              }
            }
          }
        }

        if (orderList.length > 0) {
          this._demoItems = <DemoItem<dynamic>>[];
          if (orderList != null && orderList.length > 0) {
            for (int i = 0; i < orderList.length; i++) {
              orderList[i].index = (i + 1).toString();
              DemoItem item = TitleControlInit(orderList[i]);
              this._demoItems.add(item);
            }
          }
        }
      } catch (e) {}
    });
  }

  //// 결과를 저장한다.
  void saveResult() {
    CoreLibrary core = new CoreLibrary();

    List listBody = List();

    this.orderList.map((item) => listBody.add(item.toMap())).toList();

    var body = json.encode({"ListData": listBody});

    core.HistoryhWrite(body);

    setState(() {
      readResult();
    });
  }

  @override
  void initState() {
    readResult();
  }

  @override
  Widget build(BuildContext context) {
    //super.build(context);
    // return StreamBuilder(
    //     stream: thrdBloc.getTitleList,
    //     builder: (BuildContext context, AsyncSnapshot<List<TitleDTO>> snapshot) {
    //       return snapshot.hasData ? Text(snapshot.data.toString()) : Text('nodata');
    //     });

    bool isDataExists = false;
    if (_demoItems.length > 0) {
      isDataExists = true;
    }

    return Scaffold(
      appBar: new AppBar(
          backgroundColor: Colors.indigo[500],
          title: new Container(
            child: Row(
              children: <Widget>[
                Text("히스토리"),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ShowMessageBoxWithConfirm(
                              context, "삭제", "모든 데이터를 삭제합니다.\r\n정말 삭제하시겠습니까?")
                          .then((ConfirmAction resultValue) {
                        if (resultValue == ConfirmAction.ACCEPT) {
                          this.orderList.clear();
                          this.saveResult();
                        }
                      });
                    },
                    child: Container(
                      alignment: Alignment.centerRight,
                      //color: Colors.red,
                      child: Icon(Icons.delete_sweep),
                    ),
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
              ],
            ),
          ) //new Text("계산 시작"),
          ),
      body: isDataExists
          ? Column(
              children: <Widget>[
                // Container(
                //   height: 30,
                //   child: Row(
                //     children: <Widget>[
                //       RaisedButton(
                //         child: Container(
                //           child: Icon(Icons.delete_sweep),
                //         ),
                //         onPressed: () {},
                //       )
                //     ],
                //   ),
                // ),
                Expanded(
                  child: SingleChildScrollView(
                    child: SafeArea(
                      top: false,
                      bottom: false,
                      child: Container(
                        margin: const EdgeInsets.all(24.0),
                        child: ExpansionPanelList(
                          expansionCallback: (int index, bool isExpanded) {
                            setState(() {
                              _demoItems[index].isExpanded = !isExpanded;
                            });
                          },
                          children: _demoItems
                              .map<ExpansionPanel>((DemoItem<dynamic> item) {
                            return ExpansionPanel(
                              isExpanded: item.isExpanded,
                              headerBuilder: item.headerBuilder,
                              body: item.build(),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Container(
              child: Center(
                child: Text(
                  "데이터가 존재하지 않습니다.",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
    );
  }
}

typedef DemoItemBodyBuilder<T> = Widget Function(DemoItem<T> item);
typedef ValueToString<T> = String Function(T value);

enum Location { Barbados, Bahamas, Bermuda }

class CollapsibleBody extends StatelessWidget {
  const CollapsibleBody({
    this.margin = EdgeInsets.zero,
    this.child,
    this.onSave,
    this.onCancel,
  });

  final EdgeInsets margin;
  final Widget child;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    //thrdBloc.SelectTitleList(CoreLibrary.userId);
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                bottom: 24.0,
              ) -
              margin,
          child: Center(
            child: DefaultTextStyle(
              style: textTheme.caption.copyWith(fontSize: 15.0),
              child: child,
            ),
          ),
        ),
        const Divider(height: 1.0),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: FlatButton(
                  onPressed: onCancel,
                  child: const Text('삭제',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                      )),
                ),
              ),
              // Container(
              //   margin: const EdgeInsets.only(right: 8.0),
              //   child: FlatButton(
              //     onPressed: onSave,
              //     textTheme: ButtonTextTheme.accent,
              //     child: const Text('재조회'),
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}

class DualHeaderWithHint extends StatelessWidget {
  const DualHeaderWithHint({
    this.name,
    this.value,
    this.hint,
    this.showHint,
  });

  final String name;
  final String value;
  final String hint;
  final bool showHint;

  Widget _crossFade(Widget first, Widget second, bool isExpanded) {
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Container(
            //color: Colors.red,
            margin: const EdgeInsets.only(left: 24.0),
            child: Container(
              //fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                name,
                style: textTheme.body1.copyWith(fontSize: 15.0),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            //color: Colors.blue,
            margin: const EdgeInsets.only(left: 24.0),
            child: _crossFade(
              Text(hint, style: textTheme.caption.copyWith(fontSize: 15.0)),
              Text(hint, style: textTheme.caption.copyWith(fontSize: 15.0)),
              showHint,
            ),
          ),
        ),
      ],
    );
  }
}

class DemoItem<T> {
  DemoItem(
      {this.name,
      this.value,
      this.hint,
      this.builder,
      this.valueToString,
      this.showDt,
      this.ordrInfo,
      this.stodNo})
      : textController = TextEditingController(text: valueToString(value));

  final String name;
  final String hint;

  final String showDt; //쇼핑일자
  String ordrInfo = ""; //쇼핑정보
  String stodNo = ""; //

  String getOrdrInfo() {
    if (ordrInfo != null) {
      return ordrInfo;
    } else
      return "";
  }

  final TextEditingController textController;
  final DemoItemBodyBuilder<T> builder;
  final ValueToString<T> valueToString;
  T value;
  bool isExpanded = false;

  ExpansionPanelHeaderBuilder get headerBuilder {
    return (BuildContext context, bool isExpanded) {
      return DualHeaderWithHint(
        name: name,
        value: valueToString(value),
        hint: hint,
        showHint: isExpanded,
      );
    };
  }

  Widget build() => builder(this);
}
