enum ResultState {
  confirm,
  cancel,
  yes,
  no,
}


class ResultData{
  String _resultString;
  Object _resultObject;
  ResultState _resultState;

  String get resultString => _resultString;

  set resultString(String resultString) {
    _resultString = resultString;
  }

  Object get resultObject => _resultObject;

  set resultObject(Object resultObject) {
    _resultObject = resultObject;
  }

  ResultState get resultState => _resultState;

  set resultState(ResultState resultState) {
    _resultState = resultState;
  }


}