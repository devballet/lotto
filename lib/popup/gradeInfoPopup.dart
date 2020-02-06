import 'dart:convert';

import 'package:flutter/gestures.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:lotto/core/coreLibrary.dart';
import 'package:lotto/datatable/resultDataDTO.dart';
//import 'package:showpinghelper/core/coreLibrary.dart';

Widget GradeInfoPopup(BuildContext context, ResultData inputData) {
  ResultData resultData = new ResultData();

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
              Container(
                  child: Card(
                margin: EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[
                    DisplayLevel2TextControl(
                      title: '1등 : ',
                      value: '25,0000,0000 (25억)',
                    ),
                    DisplayLevel2TextControl(
                      title: '2등 : ',
                      value: '5000,0000 (5000만원)',
                    ),
                    DisplayLevel2TextControl(
                      title: '3등 : ',
                      value: '130,0000 (130만원)',
                    ),
                    DisplayLevel2TextControl(
                      title: '4등 : ',
                      value: '5,0000 (5만원)',
                    ),
                    DisplayLevel2TextControl(
                      title: '5등 : ',
                      value: '5000 (5천원)',
                    ),

                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    ),
  );
}
