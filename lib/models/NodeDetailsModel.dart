class NodeDetailsModel {
  NodeDetailsModel({
    required this.omsId,
    required this.chakNo,
    required this.amsId,
    required this.amsNo,
    required this.rmsId,
    required this.rmsNo,
    required this.isChecking,
    required this.gateWayId,
    required this.gatewayNo,
    required this.gatewayName,
    required this.process1,
    required this.process2,
    required this.process3,
    required this.process4,
    required this.process5,
    required this.process6,
    required this.areaName,
    required this.description,
    required this.mechanical,
    required this.erection,
    required this.dryCommissioning,
    required this.wetCommissioning,
    required this.trenching,
    required this.pipeInatallation,
    required this.autoDryCommissioning,
    required this.autoWetCommissioning,
    required this.chainage,
    required this.coordinates,
    required this.networkType,
    required this.deviceType,
    required this.deviceId,
    required this.deviceNo,
    required this.deviceName,
    required this.firmwareVersion,
    required this.subChakQty,
    required this.macAddress,
    required this.timestamp,
  });

  final int? omsId;
  final String? chakNo;
  final int? amsId;
  final dynamic amsNo;
  final int? rmsId;
  final dynamic rmsNo;
  final int? isChecking;
  final int? gateWayId;
  final dynamic gatewayNo;
  final dynamic gatewayName;
  final dynamic process1;
  final dynamic process2;
  final dynamic process3;
  final dynamic process4;
  final dynamic process5;
  final dynamic process6;
  final dynamic areaName;
  final dynamic description;
  final String? mechanical;
  final String? erection;
  final dynamic dryCommissioning;
  final dynamic wetCommissioning;
  final dynamic trenching;
  final dynamic pipeInatallation;
  final dynamic autoDryCommissioning;
  final dynamic autoWetCommissioning;
  final int? chainage;
  final dynamic coordinates;
  final dynamic networkType;
  final dynamic deviceType;
  final int? deviceId;
  final dynamic deviceNo;
  final dynamic deviceName;
  final dynamic firmwareVersion;
  final int? subChakQty;
  final String? macAddress;
  final dynamic timestamp;

  factory NodeDetailsModel.fromJson(Map<String, dynamic> json) {
    return NodeDetailsModel(
      omsId: json["OmsId"],
      chakNo: json["ChakNo"],
      amsId: json["AmsId"],
      amsNo: json["AmsNo"],
      rmsId: json["RmsId"],
      rmsNo: json["RmsNo"],
      isChecking: json["IsChecking"],
      gateWayId: json["GateWayId"],
      gatewayNo: json["GatewayNo"],
      gatewayName: json["GatewayName"],
      process1: json["Process1"],
      process2: json["Process2"],
      process3: json["Process3"],
      process4: json["Process4"],
      process5: json["Process5"],
      process6: json["Process6"],
      areaName: json["AreaName"],
      description: json["Description"],
      mechanical: json["Mechanical"],
      erection: json["Erection"],
      dryCommissioning: json["DryCommissioning"],
      wetCommissioning: json["WetCommissioning"],
      trenching: json["Trenching"],
      pipeInatallation: json["PipeInatallation"],
      autoDryCommissioning: json["AutoDryCommissioning"],
      autoWetCommissioning: json["AutoWetCommissioning"],
      chainage: json["Chainage"],
      coordinates: json["Coordinates"],
      networkType: json["NetworkType"],
      deviceType: json["DeviceType"],
      deviceId: json["deviceId"],
      deviceNo: json["deviceNo"],
      deviceName: json["deviceName"],
      firmwareVersion: json["FirmwareVersion"],
      subChakQty: json["SubChakQty"],
      macAddress: json["MACAddress"],
      timestamp: json["Timestamp"],
    );
  }

  Map<String, dynamic> toJson() => {
        "OmsId": omsId,
        "ChakNo": chakNo,
        "AmsId": amsId,
        "AmsNo": amsNo,
        "RmsId": rmsId,
        "RmsNo": rmsNo,
        "IsChecking": isChecking,
        "GateWayId": gateWayId,
        "GatewayNo": gatewayNo,
        "GatewayName": gatewayName,
        "Process1": process1,
        "Process2": process2,
        "Process3": process3,
        "Process4": process4,
        "Process5": process5,
        "Process6": process6,
        "AreaName": areaName,
        "Description": description,
        "Mechanical": mechanical,
        "Erection": erection,
        "DryCommissioning": dryCommissioning,
        "WetCommissioning": wetCommissioning,
        "Trenching": trenching,
        "PipeInatallation": pipeInatallation,
        "AutoDryCommissioning": autoDryCommissioning,
        "AutoWetCommissioning": autoWetCommissioning,
        "Chainage": chainage,
        "Coordinates": coordinates,
        "NetworkType": networkType,
        "DeviceType": deviceType,
        "deviceId": deviceId,
        "deviceNo": deviceNo,
        "deviceName": deviceName,
        "FirmwareVersion": firmwareVersion,
        "SubChakQty": subChakQty,
        "MACAddress": macAddress,
        "Timestamp": timestamp,
      };
}
