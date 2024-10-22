class OTPMasterModel {
  int? userid;
  String? mobNo;
  String? mobMessage;
  String? code;
  String? codeTime;
  String? token;
  String? userType;

  OTPMasterModel(
      {this.userid,
      this.mobNo,
      this.mobMessage,
      this.code,
      this.codeTime,
      this.token,
      this.userType});

  OTPMasterModel.fromJson(Map<String, dynamic> json) {
    userid = json['userid'];
    mobNo = json['MobNo'];
    mobMessage = json['MobMessage'];
    code = json['Code'];
    codeTime = json['CodeTime'];
    token = json['Token'];
    userType = json['userType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userid'] = userid;
    data['MobNo'] = mobNo;
    data['MobMessage'] = mobMessage;
    data['Code'] = code;
    data['CodeTime'] = codeTime;
    data['Token'] = token;
    data['userType'] = userType;
    return data;
  }
}
