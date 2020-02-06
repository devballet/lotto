import 'package:flutter/material.dart';
import 'package:lotto/core/popup.dart';
import 'package:lotto/core/popup_content.dart';

//int tokenCount = 0;

class CoreLibrary{
  static int tokenCount = 0;
}

Future<Object> showPopup(BuildContext context, Widget widget, String title,
    {BuildContext popupContext}) async {
  final result = await Navigator.push(
    context,
    PopupLayout(
      top: 30,
      left: 30,
      right: 30,
      bottom: 50,
      child: PopupContent(
        content: Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.green[300],
            leading: new Builder(builder: (context) {
              return IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  try {
                    Navigator.pop(context, "test"); //close the popup
                  } catch (e) {}
                },
              );
            }),
            brightness: Brightness.light,
          ),
          resizeToAvoidBottomPadding: false,
          body: widget,
        ),
      ),
    ),
  );

  return result;
}


/*--------------------------
  // name : ShowMessageBox
  // title : 메시지 박스를 호출한다.
  // desc : 
  ---------------------------*/
Future<void> ShowMessageBox(
    BuildContext context, String title, String message) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


class DisplayLevel2TextControl extends StatelessWidget {
  const DisplayLevel2TextControl({
    Key key,
    @required this.title,
    @required this.value,
    this.lastString = "",
  }) : super(key: key);

  final String title;
  final String value;
  final String lastString;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 10),
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(
                color: Colors.blueAccent, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 10),
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(color: Colors.black),
          ),
        ),
        Visibility(
          visible: lastString == null ? false : true,
          child: Container(
            margin: EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
            child: Text(
              lastString,
              style: TextStyle(color: Colors.green),
            ),
          ),
        ),
      ],
    );
  }
}



class ModalRoundedProgressBar extends StatefulWidget {
  final double _opacity;
  final String _textMessage; // optional message to show
   final Function _handlerCallback; // callback that will give a handler object to change widget state.

  ModalRoundedProgressBar({
    @required Function handleCallback(ProgressBarHandler handler),
    String message = "", // some text to show if needed...
    double opacity = 0.7, // opacity default value
  })  : _textMessage = message,
        _opacity = opacity,
        _handlerCallback = handleCallback;

  @override
  State createState() => _ModalRoundedProgressBarState();
}
//StateClass ...
class _ModalRoundedProgressBarState extends State<ModalRoundedProgressBar> {
  bool _isShowing = false; // member that control if a rounded progressBar will be showing or not

  @override
  void initState() {
    super.initState();
    /* Here we create a handle object that will be sent for a widget that creates a ModalRounded      ProgressBar.*/
    ProgressBarHandler handler = ProgressBarHandler();

   handler.show = this.show; // handler show member holds a show() method
    handler.dismiss = this.dismiss; // handler dismiss member holds a dismiss method
    widget._handlerCallback(handler); //callback to send handler object
  }

  @override
  Widget build(BuildContext context) {
    //return a simple stack if we don't wanna show a roundedProgressBar...
    if (!_isShowing) return Stack(); 

   // here we return a layout structre that show a roundedProgressBar with a simple text message
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: widget._opacity,
            //ModalBarried used to make a modal effect on screen
            child: ModalBarrier( 
              dismissible: false,
              color: Colors.black54,
            ),
          ),

          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                Text(widget._textMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // method do change state and show our CircularProgressBar
  void show() {
    setState(() => _isShowing = true);
  }

 // method to change state and hide our CIrcularProgressBar
  void dismiss() {
    setState(() => _isShowing = false);
  }
}

// handler class
class ProgressBarHandler {
  Function show; //show is the name of member..can be what you want...
  Function dismiss;
}