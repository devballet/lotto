import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/gestures.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:lotto/core/coreLibrary.dart';
import 'package:lotto/datatable/resultDataDTO.dart';

import 'dart:math' as math;
//import 'package:showpinghelper/core/coreLibrary.dart';

Widget FastCalcPopup(BuildContext context, ResultData inputData) {
  ResultData resultData = new ResultData();

  String ordrcnt = "";

  return SafeArea(
    top: false,
    bottom: false,
    child: Form(
      // key: _formKey,
      //autovalidate: _autovalidate,
      //onWillPop: _warnUserAboutInvalidData,
      child: Scrollbar(
        child: SingleChildScrollView(
          dragStartBehavior: prefix0.DragStartBehavior.down,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Card(
                  margin: EdgeInsets.all(5),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 20,
                          ),
                          Icon(
                            Icons.check_circle,
                            color: Colors.teal,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '개수 선택',
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        //initialValue: 10000,
                        keyboardType: TextInputType.number,
                        initialValue: ordrcnt.toString(),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '개수',

                          //prefixText: '\$',
                          suffixText: '개',
                          suffixStyle: TextStyle(color: Colors.green),
                        ),
                        onChanged: (String value) {
                          ordrcnt = value;
                        },
                        maxLines: 1,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          RaisedButton(
                            child: Text("계산하기"),
                            onPressed: () {
                              if (ordrcnt == null || ordrcnt.length == 0) {
                                ShowMessageBox(context, "확인", "개수를 입력해 주세요");
                                return;
                              }

                              if ( double.parse(ordrcnt) > 1000000) //100만 보다 크면
                              {
                                ShowMessageBox(context, "확인", "100만 보다 작은수로 입력해 주세요.");
                                return;
                              }

                              resultData.resultState = ResultState.yes;
                              resultData.resultString = "resultCount";
                              resultData.resultObject = ordrcnt;
                              Navigator.pop<ResultData>(
                                  context, resultData); //close the popup
                            },
                          ),
                        ],
                      )
                    ],
                  )),
              Card(
                  margin: EdgeInsets.all(5),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 20,
                          ),
                          Icon(
                            Icons.check_circle,
                            color: Colors.teal,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '결과 바로계산',
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          RaisedButton(
                            child: Text("3등 결과보기"),
                            onPressed: () {
                              resultData.resultState = ResultState.yes;
                              resultData.resultString = "resultGrade";
                              resultData.resultObject = "3";
                              Navigator.pop<ResultData>(
                                  context, resultData); //close the popup
                            },
                          ),
                          RaisedButton(
                            child: Text("2등 결과보기"),
                            onPressed: () {
                              resultData.resultState = ResultState.yes;
                              resultData.resultString = "resultGrade";
                              resultData.resultObject = "2";
                              Navigator.pop<ResultData>(
                                  context, resultData); //close the popup
                            },
                          ),
                          RaisedButton(
                            child: Text("1등 결과보기"),
                            onPressed: () {
                              resultData.resultState = ResultState.yes;
                              resultData.resultString = "resultGrade";
                              resultData.resultObject = "1";
                              Navigator.pop<ResultData>(
                                  context, resultData); //close the popup
                            },
                          ),
                        ],
                      )
                    ],
                  )),
              
            ],
          ),
        ),
      ),
    ),
  );
}

class _CustomThumbShape extends SliderComponentShape {
  static const double _thumbSize = 4.0;
  static const double _disabledThumbSize = 3.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return isEnabled
        ? const Size.fromRadius(_thumbSize)
        : const Size.fromRadius(_disabledThumbSize);
  }

  static final Animatable<double> sizeTween = Tween<double>(
    begin: _disabledThumbSize,
    end: _thumbSize,
  );

  @override
  void paint(
    PaintingContext context,
    Offset thumbCenter, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
  }) {
    final Canvas canvas = context.canvas;
    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );
    final double size = _thumbSize * sizeTween.evaluate(enableAnimation);
    final Path thumbPath = _downTriangle(size, thumbCenter);
    canvas.drawPath(
        thumbPath, Paint()..color = colorTween.evaluate(enableAnimation));
  }
}

class _CustomValueIndicatorShape extends SliderComponentShape {
  static const double _indicatorSize = 4.0;
  static const double _disabledIndicatorSize = 3.0;
  static const double _slideUpHeight = 40.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(isEnabled ? _indicatorSize : _disabledIndicatorSize);
  }

  static final Animatable<double> sizeTween = Tween<double>(
    begin: _disabledIndicatorSize,
    end: _indicatorSize,
  );

  @override
  void paint(
    PaintingContext context,
    Offset thumbCenter, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
  }) {
    final Canvas canvas = context.canvas;
    final ColorTween enableColor = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.valueIndicatorColor,
    );
    final Tween<double> slideUpTween = Tween<double>(
      begin: 0.0,
      end: _slideUpHeight,
    );
    final double size = _indicatorSize * sizeTween.evaluate(enableAnimation);
    final Offset slideUpOffset =
        Offset(0.0, -slideUpTween.evaluate(activationAnimation));
    final Path thumbPath = _upTriangle(size, thumbCenter + slideUpOffset);
    final Color paintColor = enableColor
        .evaluate(enableAnimation)
        .withAlpha((255.0 * activationAnimation.value).round());
    canvas.drawPath(
      thumbPath,
      Paint()..color = paintColor,
    );
    canvas.drawLine(
        thumbCenter,
        thumbCenter + slideUpOffset,
        Paint()
          ..color = paintColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0);
    labelPainter.paint(
        canvas,
        thumbCenter +
            slideUpOffset +
            Offset(-labelPainter.width / 2.0, -labelPainter.height - 4.0));
  }
}

Path _upTriangle(double size, Offset thumbCenter) =>
    _downTriangle(size, thumbCenter, invert: true);

Path _downTriangle(double size, Offset thumbCenter, {bool invert = false}) {
  final Path thumbPath = Path();
  final double height = math.sqrt(3.0) / 2.0;
  final double centerHeight = size * height / 3.0;
  final double halfSize = size / 2.0;
  final double sign = invert ? -1.0 : 1.0;
  thumbPath.moveTo(
      thumbCenter.dx - halfSize, thumbCenter.dy + sign * centerHeight);
  thumbPath.lineTo(thumbCenter.dx, thumbCenter.dy - 2.0 * sign * centerHeight);
  thumbPath.lineTo(
      thumbCenter.dx + halfSize, thumbCenter.dy + sign * centerHeight);
  thumbPath.close();
  return thumbPath;
}
