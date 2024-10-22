class LoginMasterModel {

  int? userid;
  String? mobMessage;
  String? token;
  String? userType;
  String? fName;
  String? lName;
  String? pwd;

  LoginMasterModel(
      {this.userid,
      this.mobMessage,
      this.token,
      this.userType,
      this.fName,
      this.lName,
      this.pwd});

  LoginMasterModel.fromJson(Map<String, dynamic> json) {
    userid = json['userid'];
    mobMessage = json['MobMessage'];
    token = json['Token'];
    userType = json['userType'];
    fName = json['FName'];
    lName = json['LName'];
    pwd = json['pwd'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userid'] = userid;
    data['MobMessage'] = mobMessage;
    data['Token'] = token;
    data['userType'] = userType;
    data['FName'] = fName;
    data['LName'] = lName;
    data['pwd'] = pwd;
    return data;
  }
}
