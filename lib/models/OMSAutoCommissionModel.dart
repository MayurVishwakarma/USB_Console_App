class OmsAutoCommissionModel {
  String? siteName;
  String? mid;
  double? firmwareversion;
  double? batteryBefore;
  double? batteryAfter;
  double? solarVlt;
  String? doorstatus;
  String? nodeNo;
  double? ai1;
  double? ai2;
  OmsAutoCommissionModel(
      {this.siteName,
      this.mid,
      this.firmwareversion,
      this.batteryBefore,
      this.batteryAfter,
      this.solarVlt,
      this.doorstatus,
      this.nodeNo,
      this.ai1,
      this.ai2});

  void updateMid(String? newMid) {
    mid = newMid;
  }

  void updateAi1(double? newAi1) {
    ai1 = newAi1;
  }

  void updateAi2(double? newAi2) {
    ai2 = newAi2;
  }

  void updateSiteName(String? newName) {
    siteName = newName;
  }

  void updateNodeNo(String? newNode) {
    nodeNo = newNode;
  }

  void updateFirmwareVersion(double? newFirmwareVersion) {
    firmwareversion = newFirmwareVersion;
  }

  void updateBatteryVltBefore(double? newBatteryVlt) {
    batteryBefore = newBatteryVlt;
  }

  void updateBatteryVltAfter(double? newBatteryVlt) {
    batteryAfter = newBatteryVlt;
  }

  void updateSolarVlt(double? newSolarVlt) {
    solarVlt = newSolarVlt;
  }

  void updateDoorStatus(String? newDoor1) {
    doorstatus = newDoor1;
  }
}
