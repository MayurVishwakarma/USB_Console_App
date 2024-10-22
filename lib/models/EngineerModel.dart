// ignore_for_file: unnecessary_this

class EngineerNameModel {
  String? emailaddress;
  String? firstname;
  String? middlename;
  String? lastname;
  String? mobilenumber;
  String? userType;
  int? userid;

  EngineerNameModel(
      {this.emailaddress,
      this.firstname,
      this.middlename,
      this.lastname,
      this.mobilenumber,
      this.userType,
      this.userid});

  EngineerNameModel.fromJson(Map<String, dynamic> json) {
    emailaddress = json['emailaddress'];
    firstname = json['firstname'];
    middlename = json['middlename'];
    lastname = json['lastname'];
    mobilenumber = json['mobilenumber'];
    userType = json['User_Type'];
    userid = json['userid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['emailaddress'] = this.emailaddress;
    data['firstname'] = this.firstname;
    data['middlename'] = this.middlename;
    data['lastname'] = this.lastname;
    data['mobilenumber'] = this.mobilenumber;
    data['User_Type'] = this.userType;
    data['userid'] = this.userid;
    return data;
  }
}
