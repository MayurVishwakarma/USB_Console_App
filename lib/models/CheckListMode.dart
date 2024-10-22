// ignore_for_file: unnecessary_new

import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class CheckListItem {
  int? checkListId;
  int? subProcessId;
  int? processId;
  String? description;
  int? seqNo;
  String? inputType;
  String? inputText;
  String? value;
  String? subProcessName;
  String? processName;
  int? approvedStatus;
  int? workedBy;
  String? workedOn;
  int? approvedBy;
  String? approvedOn;
  String? tempDT;
  String? remark;
  String? approvalRemark;
  Uint8List? imageByteArray;
  int? isMultiValue;
  int? subChakQty;
  String? deviceType;
  String? downlink;
  String? macAddress;
  String? subscribeTopicName;
  String? parameterName;
  String? comment;
  String? coordinate;
  String? dataType;
  String? source;
  int? deviceId;
  String? conString;
  int? userId;
  String? siteTeamEngineer;
  bool? issiteTeamEngineer;
  XFile? image;
  String? issaved;
  bool? isChecked;

  CheckListItem(
      {this.checkListId,
      this.subProcessId,
      this.processId,
      this.description,
      this.seqNo,
      this.inputType,
      this.inputText,
      this.value,
      this.subProcessName,
      this.processName,
      this.approvedStatus,
      this.workedBy,
      this.workedOn,
      this.approvedBy,
      this.approvedOn,
      this.tempDT,
      this.remark,
      this.approvalRemark,
      this.imageByteArray,
      this.isMultiValue,
      this.subChakQty,
      this.deviceType,
      this.downlink,
      this.macAddress,
      this.subscribeTopicName,
      this.parameterName,
      this.comment,
      this.coordinate,
      this.dataType,
      this.source,
      this.deviceId,
      this.conString,
      this.userId,
      this.siteTeamEngineer,
      this.image,
      this.issaved,
      this.issiteTeamEngineer,
      this.isChecked});

  CheckListItem.fromJson(Map<String, dynamic> json) {
    checkListId = json['CheckListId'];
    subProcessId = json['SubProcessId'];
    processId = json['ProcessId'];
    description = json['Description'];
    seqNo = json['SeqNo'];
    inputType = json['InputType'];
    inputText = json['InputText'];
    value = json['Value'];
    subProcessName = json['SubProcessName'];
    processName = json['ProcessName'];
    approvedStatus = json['ApprovedStatus'];
    workedBy = json['WorkedBy'];
    workedOn = json['WorkedOn'];
    approvedBy = json['ApprovedBy'];
    approvedOn = json['ApprovedOn'];
    tempDT = json['TempDT'];
    remark = json['Remark'];
    approvalRemark = json['ApprovalRemark'];
    if (json['imageByteArray'] != null) {
      imageByteArray = base64.decode(json['imageByteArray']);
    }
    isMultiValue = json['IsMultiValue'];
    subChakQty = json['SubChakQty'];
    deviceType = json['DeviceType'];
    downlink = json['Downlink'];
    macAddress = json['MacAddress'];
    subscribeTopicName = json['SubscribeTopicName'];
    parameterName = json['ParameterName'];
    comment = json['Comment'];
    coordinate = json['Coordinate'];
    dataType = json['DataType'];
    source = json['Source'];
    deviceId = json['DeviceId'];
    conString = json['conString'];
    userId = json['UserId'];
    issaved = json['issaved'];
    siteTeamEngineer = json['SiteTeamEngineer'];
    image = json['image'];
    issiteTeamEngineer = json['issiteTeamEngineer'];
    isChecked = json['IsChecked'];
    // if (inputType == 'image') {
    //   if (value!.length != 0)
    //     image = XFile.fromData(base64.decode(value!));
    //   else
    //     image = XFile(
    //         "imageupload.png"); //yeh code check kar lena i dont know ki static image kese feed karte XFile me
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CheckListId'] = checkListId;
    data['SubProcessId'] = subProcessId;
    data['ProcessId'] = processId;
    data['Description'] = description;
    data['SeqNo'] = seqNo;
    data['InputType'] = inputType;
    data['InputText'] = inputText;
    data['Value'] = value;
    data['SubProcessName'] = subProcessName;
    data['ProcessName'] = processName;
    data['ApprovedStatus'] = approvedStatus;
    data['WorkedBy'] = workedBy;
    data['WorkedOn'] = workedOn;
    data['ApprovedBy'] = approvedBy;
    data['ApprovedOn'] = approvedOn;
    data['TempDT'] = tempDT;
    data['Remark'] = remark;
    data['ApprovalRemark'] = approvalRemark;
    data['imageByteArray'] = imageByteArray;
    data['IsMultiValue'] = isMultiValue;
    data['SubChakQty'] = subChakQty;
    data['DeviceType'] = deviceType;
    data['Downlink'] = downlink;
    data['MacAddress'] = macAddress;
    data['SubscribeTopicName'] = subscribeTopicName;
    data['ParameterName'] = parameterName;
    data['Comment'] = comment;
    data['Coordinate'] = coordinate;
    data['DataType'] = dataType;
    data['Source'] = source;
    data['DeviceId'] = deviceId;
    data['conString'] = conString;
    data['UserId'] = userId;
    data['issaved'] = issaved;
    data['SiteTeamEngineer'] = siteTeamEngineer;
    data['image'] = image;
    data['issiteTeamEngineer'] = issiteTeamEngineer;
    data['IsChecked'] = isChecked;
    return data;
  }
}
