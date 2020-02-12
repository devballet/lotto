import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:lotto/datatable/historyDTO.dart';
import 'package:lotto/popup/fastCalcPopup.dart';
import 'package:lotto/popup/gradeInfoPopup.dart';
import 'package:firebase_admob/firebase_admob.dart';

import 'core/coreLibrary.dart';
import 'core/firebaseAdmobManager.dart';
import 'core/widgets.dart';
import 'datatable/resultDataDTO.dart';

class CalcPanel extends StatefulWidget {
  @override
  _CalcPanelState createState() => _CalcPanelState();
}

class _CalcPanelState extends State<CalcPanel> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<int> selectedNumbers = new List<int>();
  ProgressBarHandler _handler;

  String displaySelectedNumber = "";
  String targetDisplaySelectedNumber = "";
  StringBuffer strLog = new StringBuffer();
  final Set<int> targetNums = <int>{};
  int targetAddNum = 0;

  ////타켓 번호를 랜덤으로 선택한다.
  void targetNumberRandomSelect() {
    targetNums.clear();
    targetAddNum = 0;

    var ran = new Random();

    for (int i = 0; i < 7; i++) {
      bool isNumSelected = false;
      int intRan = 0;
      while (isNumSelected == false) {
        intRan = ran.nextInt(45);
        if (intRan > 45 || intRan < 1) {
          continue;
        }

        if (targetNums.contains(intRan) == true) {
          continue;
        }

        isNumSelected = true;
      }

      if (targetNums.length <= 5) {
        targetNums.add(intRan);
      } else if (targetNums.length == 6) {
        targetAddNum = intRan; //추가번호 (2등 추첨용)
      }
    }
  }

  List<int> hitNumbers = new List<int>();
  String hitNumberText = "";
  int grade = 0;

  int grade1Count = 0;
  int grade2Count = 0;
  int grade3Count = 0;
  int grade4Count = 0;
  int grade5Count = 0;

  double grade1Per = 0;
  double grade2Per = 0;
  double grade3Per = 0;
  double grade4Per = 0;
  double grade5Per = 0;

  int grade1PerPerson = 0;
  int grade2PerPerson = 0;
  int grade3PerPerson = 0;
  int grade4PerPerson = 0;
  int grade5PerPerson = 0;

  int lottoCount = 0;
  int lottoHitCount = 0;
  double money_in = 0;
  double money_out = 0;
  double money_sum = 0;

  String money_in_display = "";
  String money_out_display = "";
  String money_sum_display = "";

  bool isGradeHit = false;
  ////점수 계산
  void scoreCalc({int in_grade = 0}) {
    //selectedNumbers
    //targetNums
    this.hitNumbers.clear();
    this.hitNumberText = "";
    this.grade = 0;
    this.isGradeHit = false;

    for (int i = 0; i < selectedNumbers.length; i++) {
      int hitCount = 0;
      String hitNumText = "";
      int selectedNum = selectedNumbers.elementAt(i);

      for (int j = 0; j < targetNums.length; j++) {
        int targetNum = targetNums.elementAt(j);

        if (selectedNum == targetNum) {
          hitCount++;
          hitNumbers.add(selectedNum);
        }
      }
    }

    if (lottoCount == null) {
      lottoCount = 0;
    }
    lottoCount++;
    double tempAddMoney = 0;
    if (hitNumbers != null && hitNumbers.length > 0) {
      //등수 계산
      if (hitNumbers.length == 3) //5등
      {
        grade = 5;
        grade5Count++;
        lottoHitCount++;
        tempAddMoney = 0.5;

        grade5Per = grade5Count / lottoCount * 100;
        grade5PerPerson = (100 / grade5Per).round();
      } else if (hitNumbers.length == 4) // 4등
      {
        grade = 4;
        grade4Count++;
        lottoHitCount++;
        tempAddMoney = 5;

        grade4Per = grade4Count / lottoCount * 100;
        grade4PerPerson = (100 / grade4Per).round();
      } else if (hitNumbers.length == 5) {
        if (selectedNumbers.contains(targetAddNum) == true) {
          //2등
          grade = 2;
          grade2Count++;
          lottoHitCount++;
          tempAddMoney = 5000;
          grade2Per = grade2Count / lottoCount * 100;
          grade2PerPerson = (100 / grade2Per).round();

          if (in_grade == 2) {
            isGradeHit = true;
          }
        } else {
          //3등
          grade = 3;
          grade3Count++;
          lottoHitCount++;
          tempAddMoney = 130;
          grade3Per = grade3Count / lottoCount * 100;
          grade3PerPerson = (100 / grade3Per).round();

          if (in_grade == 3) {
            isGradeHit = true;
          }
        }
      } else if (hitNumbers.length == 6) {
        //1등
        grade = 1;
        grade1Count++;
        lottoHitCount++;
        tempAddMoney = 250000;
        grade1Per = grade1Count / lottoCount * 100;
        grade1PerPerson = (100 / grade1Per).round();

        if (in_grade == 1) {
          isGradeHit = true;
        }
      }

      for (int i = 0; i < hitNumbers.length; i++) {
        int hitNum = hitNumbers.elementAt(i);
        if (hitNumberText == "") {
          hitNumberText = hitNum.toString();
        } else {
          hitNumberText = hitNumberText + ", " + hitNum.toString();
        }
      }
    }

    //돈 계산
    this.money_out = money_out - 0.1;
    this.money_in = money_in + tempAddMoney;
    this.money_sum = money_in + money_out;
  }

  ////로그를 쌓는다.
  void SetLog(String logText) {
    strLog.write('\r\n');
    strLog.write(logText);
  }

  Timer timer;

  //계산로직 비동기처리
  Future calcAsync(int needCount, bool isBackGround, {int grade = 0}) async {
    calc(needCount, isBackGround, grade: grade);
  }

  ///계산 로직
  void calc(int needCount, bool isBackGround, {int grade = 0}) {
    int count = 0;

    // _handler.show();
    // _handler.dismiss();
    if (isBackGround == false) {
      if (timer != null && timer.isActive == true) return;

      timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        if (timer.isActive == true) {}

        targetNumberRandomSelect(); //추첨 랜덤번호 선택
        scoreCalc(); //점수계산

        setTargetDisplaySelectedNumber(false); //추첨번호 text표시

        count++;
        if (count >= needCount) {
          timer.cancel();
        }
      });
    } else {
      _handler.show();

      if (grade != null && grade > 0) {
        // 특정 등수까지 돌리기
        bool isHit = false;
        int whileCount = 0;
        while (isHit == false) {
          targetNumberRandomSelect(); //추첨 랜덤번호 선택
          scoreCalc(in_grade: grade); //점수계산
          setTargetDisplaySelectedNumber(true); //추첨번호 text표시
          if (isGradeHit == true) {
            isHit = true;
          }
          whileCount++;
          if (whileCount > 3999999) {
            isHit = true;
            final snackBar = SnackBar(
                content: Text('시간이 너무 오래걸려 중지합니다. ㅠㅠ 토큰은 다시 회복됩니다.'),
                duration: Duration(milliseconds: 3000));
            _scaffoldKey.currentState.showSnackBar(snackBar);
            CoreLibrary.tokenCount = CoreLibrary.tokenCount + 1;
          }
        }
      } else {
        // 넘어온 카운트 만큼 돌리기
        for (int i = 0; i < needCount; i++) {
          targetNumberRandomSelect(); //추첨 랜덤번호 선택
          scoreCalc(in_grade: grade); //점수계산
          setTargetDisplaySelectedNumber(true); //추첨번호 text표시
        }
      }

      _handler.dismiss();

      // 빠른 계산 결과 끝난후 로그 처리
      setState(() {
        SetLog("빠른 계산은 3등 이상에 대해서만 로그를 보여줍니다.");

        final f = new NumberFormat("#,####.#");
        money_in_display = f.format(money_in);
        money_out_display = f.format(money_out);
        money_sum_display = f.format(money_sum);

        if (grade1Count > 0) {
          this.grade1Display = gradeDislpay(grade1Count.toString(),
              grade1Per.toString(), grade1PerPerson.toString());
        }
        if (grade2Count > 0) {
          this.grade2Display = gradeDislpay(grade2Count.toString(),
              grade2Per.toString(), grade2PerPerson.toString());
        }
        if (grade3Count > 0) {
          this.grade3Display = gradeDislpay(grade3Count.toString(),
              grade3Per.toString(), grade3PerPerson.toString());
        }
        if (grade4Count > 0) {
          this.grade4Display = gradeDislpay(grade4Count.toString(),
              grade4Per.toString(), grade4PerPerson.toString());
        }
        if (grade5Count > 0) {
          this.grade5Display = gradeDislpay(grade5Count.toString(),
              grade5Per.toString(), grade5PerPerson.toString());
        }
      });
    }

    // Timer(Duration(seconds: 1), () {
    //   for (int i = 0; i < 5; i++) {

    //   }
    // });

    // setState(() {
    //   for (int i = 0; i < count; i++) {
    //     targetNumberRandomSelect();

    //     for (int j = 0; j < selectedNumbers.length; i++) {
    //       // _selectedNums.contains()
    //       // selectedNumbers.elementAt(j)
    //     }
    //   }
    // });
  }

  ////선택된 숫자에 대한 display text생성
  void SetDisplaySelectedNumber() {
    displaySelectedNumber = "";

    setState(() {
      for (int i = 0; i < selectedNumbers.length; i++) {
        String value = selectedNumbers.elementAt(i).toString();

        if (displaySelectedNumber == "") {
          displaySelectedNumber = value;
        } else {
          displaySelectedNumber = displaySelectedNumber + ", " + value;
        }
      }
    });
  }

  String grade1Display = "";
  String grade2Display = "";
  String grade3Display = "";
  String grade4Display = "";
  String grade5Display = "";

  //// 등수별 결과 display 리턴
  String gradeDislpay(String count, String gradePer, String gradePerson) {
    String gradeDisplay = count +
        "개 당첨 (" +
        gradePerson +
        "개 중1)(" +
        gradePer.substring(0, 15) +
        ")";
    return gradeDisplay;
  }

  ////히스토리 화면을 연다.
  void popupHistory() {
    Navigator.of(context).pushNamed('/History', arguments: selectedNumbers);
  }

  void readResult() {
    //저장된 데이터 읽기
    CoreLibrary core = new CoreLibrary();

    core.HistoryRead().then((value) {
      List<HistoryDTO> orderList = new List<HistoryDTO>();
      String result = value.toString();
      try {
        if (result != null && result.length > 0 && result.toString() != "0") {
          Map decodeResult = json.decode(result);
          if (decodeResult.containsKey("ListData")) {
            Map orders = decodeResult["ListData"][0];
            List list = decodeResult["ListData"];
            if (list != null && list.length > 0) {
              for (int i = 0; i < list.length; i++) {
                Map order = list.elementAt(i);
                HistoryDTO newDTO = HistoryDTO.fromJson(order);
                if (newDTO != null) {
                  orderList.add(newDTO);
                }
              }
            }
          }
        }

        if (orderList.length > 0) {}
      } catch (e) {}
    });
  }

  //// 결과를 저장한다.
  void saveResult() {
    if (this.tokenCheck() == false) {
      //토큰체크
      return;
    }

    CoreLibrary core = new CoreLibrary();

    core.HistoryRead().then((value) {
      List<HistoryDTO> orderList = new List<HistoryDTO>();
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
                  orderList.add(newDTO);
                }
              }
            }
          }
        }

        //기존 데이터 불러오기 완료

        HistoryDTO newDTO = makeHistoryDTO();
        orderList.add(newDTO);

        List listBody = List();

        orderList.map((item) => listBody.add(item.toMap())).toList();

        var body = json.encode({"ListData": listBody});

        CoreLibrary core = new CoreLibrary();
        core.HistoryhWrite(body);

        final snackBar = SnackBar(
            content: Text('저장하였습니다.'), duration: Duration(milliseconds: 1000));
        _scaffoldKey.currentState.showSnackBar(snackBar);

        tokenUse();
      } catch (e) {}
    });
  }

  ////토큰 사용 이벤트에서 토큰체크 전처리
  bool tokenCheck() {
    if (CoreLibrary.tokenCount == 0) {
      final snackBar = SnackBar(
          content: Text('토큰이 없습니다. 토큰얻기 버튼을 통해 추가 가능합니다.'),
          duration: Duration(milliseconds: 1000));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      return false;
    }

    return true;
  }

  ////토큰을 사용하는 경우에 대한 처리
  void tokenUse() {
    CoreLibrary.tokenCount = CoreLibrary.tokenCount - 1;
  }

  ////빠른계산 클릭시
  void fastCalcClick() {
    if (this.tokenCheck() == false) {
      //토큰체크
      return;
    }

    ResultData inputData = new ResultData();
    Widget itemPopup = FastCalcPopup(context, inputData);
    showPopup(context, itemPopup, "빠른계산").then<void>((Object value) {
      if (value != null) {
        ResultData resultData = value as ResultData;
        String resultString = resultData.resultString;
        var resultObject = resultData.resultObject;
        if (resultData.resultState == ResultState.yes) {
          if (resultString != null &&
              resultString != "" &&
              resultObject.toString() != null &&
              resultObject.toString() != "") {
            //결과 바로계산
            if (resultString == "resultGrade") {
              int grade = int.parse(resultObject);
              if (grade > 0) {
                //calcAsync(0, true, grade: grade);

                void click() async {
                  var a = await calcAsync(0, true, grade: grade);
                }

                click();
              }
            } else if (resultString == "resultCount") //개수 선택
            {
              int count = int.parse(resultObject);
              //calcAsync(count, true);

              void click() async {
                var a = await calcAsync(count, true);
              }

              click();
            }
          }

          tokenUse();
        }
      }
    });
  }

  ////현재 결과를 저장하기 위한 DTO 생성
  HistoryDTO makeHistoryDTO() {
    HistoryDTO newDTO = new HistoryDTO();
    newDTO.displaySelectedNumber = this.displaySelectedNumber;
    newDTO.grade1Count = this.grade1Count;
    newDTO.grade2Count = this.grade2Count;
    newDTO.grade1Count = grade1Count;
    newDTO.grade2Count = grade2Count;
    newDTO.grade3Count = grade3Count;
    newDTO.grade4Count = grade4Count;
    newDTO.grade5Count = grade5Count;

    newDTO.grade1Per = grade1Per;
    newDTO.grade2Per = grade2Per;
    newDTO.grade3Per = grade3Per;
    newDTO.grade4Per = grade4Per;
    newDTO.grade5Per = grade5Per;

    newDTO.grade1PerPerson = grade1PerPerson;
    newDTO.grade2PerPerson = grade2PerPerson;
    newDTO.grade3PerPerson = grade3PerPerson;
    newDTO.grade4PerPerson = grade4PerPerson;
    newDTO.grade5PerPerson = grade5PerPerson;

    newDTO.lottoCount = lottoCount;

    newDTO.moneyIn = money_in;
    //newDTO.moneyInDisplay = money_in_display;
    newDTO.moneyOut = money_out;
    //newDTO.moneyOutDisplay = money_out_display;
    newDTO.moneySum = money_sum;
    //newDTO.moneySumDisplay = money_sum_display;
    return newDTO;
  }

  ////선택된 숫자에 대한 display text생성(추첨 숫자용)
  void setTargetDisplaySelectedNumber(bool isBackGround) {
    this.targetDisplaySelectedNumber = "";

    if (isBackGround == true) {
      if (grade != null && (grade == 1 || grade == 2 || grade == 3)) {
        //PASS
      } else {
        return;
      }
    }

    setState(() {
      for (int i = 0; i < targetNums.length; i++) {
        String value = targetNums.elementAt(i).toString();

        if (targetDisplaySelectedNumber == "") {
          targetDisplaySelectedNumber = value;
        } else {
          targetDisplaySelectedNumber =
              targetDisplaySelectedNumber + ", " + value;
        }
      }

      targetDisplaySelectedNumber =
          targetDisplaySelectedNumber + " [" + targetAddNum.toString() + "]";

      if (this.hitNumbers != null && hitNumbers.length > 0) {
        this.targetDisplaySelectedNumber = targetDisplaySelectedNumber +
            " (hit :" +
            hitNumbers.length.toString() +
            ")";
      }
    });

    SetLog("추첨번호 => " + targetDisplaySelectedNumber);

    if (grade != null && grade > 0) {
      SetLog("       " + grade.toString() + "등에 당첨되었습니다!!!!!");

      if (grade == 1) {
        this.grade1Display = gradeDislpay(grade1Count.toString(),
            grade1Per.toString(), grade1PerPerson.toString());
      } else if (grade == 2) {
        this.grade2Display = gradeDislpay(grade2Count.toString(),
            grade2Per.toString(), grade2PerPerson.toString());
      } else if (grade == 3) {
        this.grade3Display = gradeDislpay(grade3Count.toString(),
            grade3Per.toString(), grade3PerPerson.toString());
      } else if (grade == 4) {
        this.grade4Display = gradeDislpay(grade4Count.toString(),
            grade4Per.toString(), grade4PerPerson.toString());
      } else if (grade == 5) {
        this.grade5Display = gradeDislpay(grade5Count.toString(),
            grade5Per.toString(), grade5PerPerson.toString());
      }
    }

    // if (isBackGround == false) {
    // } else {
    //   if (grade != null && (grade == 1 || grade == 2 || grade == 3)) {
    //     setState(() {
    //       for (int i = 0; i < targetNums.length; i++) {
    //         String value = targetNums.elementAt(i).toString();

    //         if (targetDisplaySelectedNumber == "") {
    //           targetDisplaySelectedNumber = value;
    //         } else {
    //           targetDisplaySelectedNumber =
    //               targetDisplaySelectedNumber + ", " + value;
    //         }
    //       }

    //       if (this.hitNumbers != null && hitNumbers.length > 0) {
    //         this.targetDisplaySelectedNumber = targetDisplaySelectedNumber +
    //             " (hit :" +
    //             hitNumbers.length.toString() +
    //             ")";
    //       }
    //     });
    //     SetLog("추첨번호 => " + targetDisplaySelectedNumber);
    //     SetLog("       " + grade.toString() + "등에 당첨되었습니다!!!!!");

    //     if (grade == 1) {
    //       this.grade1Display = grade1Count.toString() +
    //           "개 당첨 (" +
    //           this.grade1Per.toString() +
    //           ")";
    //     } else if (grade == 2) {
    //       this.grade2Display = grade2Count.toString() +
    //           "개 당첨 (" +
    //           this.grade2Per.toString() +
    //           ")";
    //     } else if (grade == 3) {
    //       this.grade3Display = grade3Count.toString() +
    //           "개 당첨 (" +
    //           this.grade3Per.toString() +
    //           ")";
    //     }
    //   }
    // }

    //money_in_display = money_in.toStringAsFixed(1);

    if (isBackGround == false) {
      final f = new NumberFormat("#,####.#");
      money_in_display = f.format(money_in);
      money_out_display = f.format(money_out);
      money_sum_display = f.format(money_sum);
    }
  }

  AdmobReward rewardAd = AdmobReward(
    adUnitId: getRewardAdUnitId(),
    listener: (AdmobAdEvent event, Map<String, dynamic> args) {
      if (event == AdmobAdEvent.rewarded) {
        print('User was rewarded!');
        print('Reward type: ${args['type']}');
        print('Reward amount: ${args['amount']}');
      }
    },
  );

  ////애드몹 광고 처리
  void admobRewardAds() async {
    if (loadRewardedVideoAd == true) {
      fMan.showRewardedVideoAd();
      //fMan.loadRewardedVideoAd();
    } else {
      fMan.loadRewardedVideoAd();
      loadRewardedVideoAd = true;
    }

    //RewardedVideoAd.instance.show();
  }

  //int tokenCount = 0;

  FirebaseAdmobManager fMan = FirebaseAdmobManager();
  bool loadInterstitialAd = false;
  bool loadRewardedVideoAd = false;
  int rewardCount = 0;

  void interstitialAdListener(MobileAdEvent event) {
    print("************ event: $event");
    switch (event) {
      case MobileAdEvent.loaded:
        setState(() {
          loadInterstitialAd = true;
        });
        break;
      case MobileAdEvent.failedToLoad:
        break;
      case MobileAdEvent.clicked:
        break;
      case MobileAdEvent.impression:
        break;
      case MobileAdEvent.opened:
        setState(() {
          loadInterstitialAd = false;
        });
        break;
      case MobileAdEvent.leftApplication:
        break;
      case MobileAdEvent.closed:
        break;
    }
  }

  void rewardedVideoListner(RewardedVideoAdEvent event,
      {String rewardType, int rewardAmount}) {
    print("************ event: $event");
    switch (event) {
      case RewardedVideoAdEvent.loaded:
        setState(() {
          loadRewardedVideoAd = true;
        });
        break;
      case RewardedVideoAdEvent.failedToLoad:
        break;
      case RewardedVideoAdEvent.opened:
        setState(() {
          loadRewardedVideoAd = false;
        });
        break;
      case RewardedVideoAdEvent.leftApplication:
        break;
      case RewardedVideoAdEvent.closed:
        if (loadRewardedVideoAd == false) {
          fMan.loadRewardedVideoAd();
          //loadRewardedVideoAd = true;
        }
        break;
      case RewardedVideoAdEvent.rewarded:
        setState(() {
          rewardCount += rewardAmount;
          //토큰 추가!!!!!!!!!!!!!!
          CoreLibrary.tokenCount = CoreLibrary.tokenCount + 5;
        });
        break;
      case RewardedVideoAdEvent.started:
        break;
      case RewardedVideoAdEvent.completed:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    //rewardAd.load();

    if (adMopInit == false) {
      fMan.init(
          interstitialAdListener: interstitialAdListener,
          rewardedVideoListner: rewardedVideoListner);
      adMopInit = true;
    }

    fMan.loadRewardedVideoAd();

    // RewardedVideoAd.instance.load(getRewardAdUnitId(), targetingInfo);

    // RewardedVideoAd.instance.listener =
    //     (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
    //   if (event == RewardedVideoAdEvent.rewarded) {
    //     setState(() {
    //       print(rewardAmount);
    //     });
    //   }
    // };
  }

  @override
  void dispose() {
    //fMan.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<int> argu = ModalRoute.of(context).settings.arguments;
    selectedNumbers = argu;
    SetDisplaySelectedNumber();

    var progressBar = ModalRoundedProgressBar(
      //getting the handler
      handleCallback: (handler) {
        _handler = handler;
      },
    );

    //_handler.dismiss();

    var scaffold = Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
          backgroundColor: Colors.indigo[500],
          title: new Container(
            child: Row(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text("계산 시작"),
                ),
                SizedBox(
                  width: 20,
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.confirmation_number,
                        size: 20,
                        color: Colors.orange[600],
                      ),
                      new SizedBox(
                        width: 5.0,
                      )
                    ],
                  ),
                ),
                Text(
                  "내 토큰(",
                  style: TextStyle(fontSize: 15),
                ),
                Text(CoreLibrary.tokenCount.toString(),
                    style: TextStyle(fontSize: 15)),
                Text("개)", style: TextStyle(fontSize: 15)),
                SizedBox(
                  width: 10,
                ),
                OutlineButton(
                  splashColor: Colors.green[300],
                  onPressed: () {
                    setState(() {
                      admobRewardAds();
                    });
                  },
                  child: Text(
                    "토큰얻기",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ) //new Text("계산 시작"),
          ),
      body: new Container(
        child: new Center(
          child: new Column(
            children: <Widget>[
              CommonDisplayText(title: "내 번호", value: displaySelectedNumber),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // RaisedButton(
                  //   child: Text("100개 계산하기"),
                  //   onPressed: () {
                  //     calc(100, false);
                  //   },
                  // ),
                  SimpleOutlineButton(
                    buttonText: "100개 계산하기",
                    isTokenIconVisible: false,
                    onPressed: () {
                      calc(100, false);
                    },
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  SimpleOutlineButton(
                    buttonText: "빠른계산",
                    isTokenIconVisible: true,
                    onPressed: () {
                      fastCalcClick();
                    },
                  ),

                  // RaisedButton(
                  //   child: Row(
                  //     children: <Widget>[
                  //       Icon(Icons.confirmation_number),
                  //       SizedBox(
                  //         width: 10,
                  //       ),
                  //       Text("빠른계산")
                  //     ],
                  //   ),
                  //   onPressed: () {
                  //     //calc(1000000, true);
                  //   },
                  // ),
                ],
              ),
              CommonDisplayText(
                  title: "추첨 번호", value: targetDisplaySelectedNumber),
              Expanded(
                child: LogControl(strLog: strLog),
              ),
              Card(
                  margin: EdgeInsets.all(5),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 20,
                          ),
                          Icon(
                            Icons.check_circle,
                            color: Colors.orange.shade800,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '결과',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            child: Icon(Icons.info_outline,
                                color: Colors.black54, size: 20),
                            onTap: () {
                              ResultData inputData = new ResultData();
                              Widget itemPopup =
                                  GradeInfoPopup(context, inputData);
                              showPopup(context, itemPopup, "당첨금")
                                  .then<void>((Object value) {
                                if (value != null) {
                                  ResultData resultData = value as ResultData;
                                  String resultString = resultData.resultString;
                                  // if (resultString != null &&
                                  //     resultString != "") {
                                  //   setState(() {
                                  //     CoreLibrary.userId = resultString;
                                  //     CoreLibrary core = new CoreLibrary();
                                  //     core.AuthWrite(CoreLibrary.userId);
                                  //   });
                                  // }

                                }
                              });
                            },
                          ),
                          Expanded(
                              child: Container(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                SimpleOutlineButton(
                                  buttonText: "결과저장",
                                  isTokenIconVisible: true,
                                  onPressed: () {
                                    saveResult();
                                  },
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                SimpleOutlineButton(
                                  buttonText: "히스토리",
                                  isTokenIconVisible: false,
                                  onPressed: () {
                                    popupHistory();
                                  },
                                ),
                                // FlatButton(
                                //     onPressed: () {},
                                //     child: Text(
                                //       "히스토리",
                                //       style: TextStyle(color: Colors.blue[800]),
                                //     ))
                              ],
                            ),
                          )),

                          // RaisedButton(
                          //   onPressed: () {
                          //     saveResult();
                          //   },
                          //   child: Text("저장"),
                          // ),
                          // RaisedButton(
                          //   onPressed: () {
                          //     readResult();
                          //   },
                          //   child: Text("불러오기"),
                          // ),
                          // RaisedButton(
                          //   onPressed: () {
                          //     popupHistory();
                          //   },
                          //   child: Text("히스토리"),
                          // ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
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
                              value: lottoCount.toString(),
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
                    ],
                  ))
            ],
          ),
        ),
      ),
    );

    return Stack(
      children: <Widget>[
        scaffold,
        progressBar,
      ],
    );
  }
}

// class SimpleOutlineButton extends StatelessWidget {
//   const SimpleOutlineButton({
//     Key key,
//     this.onPressed,
//     @required this.buttonText,
//     @required this.isTokenIconVisible,
//   }) : super(key: key);

//   final VoidCallback onPressed;
//   final String buttonText;
//   //final Widget icon;
//   final bool isTokenIconVisible;

//   bool isIconExists() {
//     if (isTokenIconVisible == true) {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return OutlineButton(
//         highlightedBorderColor: Colors.red,
//         shape: new RoundedRectangleBorder(
//             borderRadius: new BorderRadius.circular(30.0)),
//         borderSide: BorderSide(color: HexColor("#344955"), width: 2),
//         //splashColor: Colors.green[300],
//         onPressed: onPressed,
//         child: Row(
//           children: <Widget>[
//             Visibility(
//               visible: isTokenIconVisible,
//               child: Icon(Icons.confirmation_number, color: Colors.orange[600],),
//             ),
//             Visibility(
//               visible: isTokenIconVisible,
//               child: SizedBox(
//                 width: 10,
//               ),
//             ),
//             Text(
//               buttonText,
//               style: TextStyle(color: Colors.black),
//             ),
//           ],
//         ));
//   }
// }

class LogControl extends StatelessWidget {
  const LogControl({
    Key key,
    @required this.strLog,
  }) : super(key: key);

  final StringBuffer strLog;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(5),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: 20,
                ),
                Icon(
                  Icons.check_circle,
                  color: Colors.orange.shade800,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '로그',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                height: 120,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    SingleChildScrollView(
                        reverse: true, child: Text(strLog.toString())),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class CommonDisplayText extends StatelessWidget {
  const CommonDisplayText({
    Key key,
    @required this.title,
    @required this.value,
  }) : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Container(
          margin: EdgeInsets.only(left: 5, bottom: 5),
          alignment: Alignment.centerLeft,
          child: RaisedButton(
            onPressed: () {},
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            elevation: 4.0,
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.check_circle,
                  color: Colors.orange.shade800,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Container(
                    width: 250,
                    //margin: EdgeInsets.only(left: 10, bottom: 5),
                    child: Html(data: value)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
