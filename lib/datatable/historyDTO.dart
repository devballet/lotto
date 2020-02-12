class HistoryDTO {
  String displaySelectedNumber;

  String index;
  // String grade1Display = "";
  // String grade2Display = "";
  // String grade3Display = "";
  // String grade4Display = "";
  // String grade5Display = "";

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

  double moneyIn = 0;
  double moneyOut = 0;
  double moneySum = 0;

  int lottoCount = 0;

  String moneyInDisplay = "";
  String moneyOutDisplay = "";
  String moneySumDisplay = "";

  HistoryDTO({
    // this.grade1Display,
    // this.grade2Display,
    // this.grade3Display,
    // this.grade4Display,
    // this.grade5Display,
    this.displaySelectedNumber,
    this.grade1Count,
    this.grade2Count,
    this.grade3Count,
    this.grade4Count,
    this.grade5Count,
    this.grade1Per,
    this.grade2Per,
    this.grade3Per,
    this.grade4Per,
    this.grade5Per,
    this.grade1PerPerson,
    this.grade2PerPerson,
    this.grade3PerPerson,
    this.grade4PerPerson,
    this.grade5PerPerson,
    this.lottoCount,
    this.moneyIn,
    this.moneyOut,
    this.moneySum,
    // this.moneyInDisplay,
    // this.moneyOutDisplay,
    // this.moneySumDisplay,
  });

  factory HistoryDTO.fromJson(Map<String, dynamic> json) {
    return HistoryDTO(
      displaySelectedNumber: json['displaySelectedNumber'],
      grade1Count: json['grade1Count'],
      grade2Count: json['grade2Count'],
      grade3Count: json['grade3Count'],
      grade4Count: json['grade4Count'],
      grade5Count: json['grade5Count'],
      grade1Per: json['grade1Per'],
      grade2Per: json['grade2Per'],
      grade3Per: json['grade3Per'],
      grade4Per: json['grade4Per'],
      grade5Per: json['grade5Per'],
      grade1PerPerson: json['grade1PerPerson'],
      grade2PerPerson: json['grade2PerPerson'],
      grade3PerPerson: json['grade3PerPerson'],
      grade4PerPerson: json['grade4PerPerson'],
      grade5PerPerson: json['grade5PerPerson'],
      lottoCount: json["lottoCount"],
      moneyIn: json['moneyIn'],
      moneyOut: json['moneyOut'],
      moneySum: json['moneySum'],
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["displaySelectedNumber"] = displaySelectedNumber;
    map["grade1Count"] = grade1Count ?? "";
    map["grade2Count"] = grade2Count ?? "";

    map["grade3Count"] = grade3Count ?? "";
    map["grade4Count"] = grade4Count ?? "";
    map["grade5Count"] = grade5Count ?? "";
    map["grade1Per"] = grade1Per ?? "";
    map["grade2Per"] = grade2Per ?? "";
    map["grade3Per"] = grade3Per ?? "";
    map["grade4Per"] = grade4Per ?? "";
    map["grade5Per"] = grade5Per ?? "";
    map["grade1PerPerson"] = grade1PerPerson ?? "";
    map["grade2PerPerson"] = grade2PerPerson ?? "";
    map["grade3PerPerson"] = grade3PerPerson ?? "";

    map["grade4PerPerson"] = grade4PerPerson ?? "";
    map["grade5PerPerson"] = grade5PerPerson ?? "";
    map["lottoCount"] = lottoCount ?? "";
    map["moneyIn"] = moneyIn ?? "";
    map["moneyOut"] = moneyOut ?? "";
    map["moneySum"] = moneySum ?? "";

    return map;
  }
}
