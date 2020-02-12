import 'package:flutter/material.dart';

import 'coreLibrary.dart';

class SimpleOutlineButton extends StatelessWidget {
  const SimpleOutlineButton({
    Key key,
    this.onPressed,
    @required this.buttonText,
    @required this.isTokenIconVisible,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String buttonText;
  //final Widget icon;
  final bool isTokenIconVisible;

  bool isIconExists() {
    if (isTokenIconVisible == true) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
        highlightedBorderColor: Colors.red,
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)),
        borderSide: BorderSide(color: HexColor("#344955"), width: 2),
        //splashColor: Colors.green[300],
        onPressed: onPressed,
        child: Row(
          children: <Widget>[
            Visibility(
              visible: isTokenIconVisible,
              child: Icon(Icons.confirmation_number, color: Colors.orange[600],),
            ),
            Visibility(
              visible: isTokenIconVisible,
              child: SizedBox(
                width: 10,
              ),
            ),
            Text(
              buttonText,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ));
  }
}