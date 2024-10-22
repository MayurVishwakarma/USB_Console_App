class ProjectModel {
  int? id;
  String? projectName;
  String? state;
  int? totalArea;
  String? description;
  String? project;
  String? clientLogo;
  String? contractorLogo;
  String? userType;
  String? hostIp;
  String? userName;
  String? password;
  String? eCString;
  String? rCString;
  String? dRString;
  String? allowDeviceTypeString;

  ProjectModel(
      {this.id,
      this.projectName,
      this.state,
      this.totalArea,
      this.description,
      this.project,
      this.clientLogo,
      this.contractorLogo,
      this.userType,
      this.hostIp,
      this.userName,
      this.password,
      this.eCString,
      this.rCString,
      this.dRString,
      this.allowDeviceTypeString});

  ProjectModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    projectName = json['ProjectName'];
    state = json['State'];
    totalArea = json['TotalArea'];
    description = json['Description'];
    project = json['project'];
    clientLogo = json['clientLogo'];
    contractorLogo = json['contractorLogo'];
    userType = json['User_Type'];
    hostIp = json['HostIp'];
    userName = json['userName'];
    password = json['Password'];
    eCString = json['ECString'];
    rCString = json['RCString'];
    dRString = json['DRString'];
    allowDeviceTypeString = json['AllowDeviceTypeString'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ProjectName'] = projectName;
    data['State'] = state;
    data['TotalArea'] = totalArea;
    data['Description'] = description;
    data['project'] = project;
    data['clientLogo'] = clientLogo;
    data['contractorLogo'] = contractorLogo;
    data['User_Type'] = userType;
    data['HostIp'] = hostIp;
    data['userName'] = userName;
    data['Password'] = password;
    data['ECString'] = eCString;
    data['RCString'] = rCString;
    data['DRString'] = dRString;
    data['AllowDeviceTypeString'] = allowDeviceTypeString;
    return data;
  }
}
