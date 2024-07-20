class AutoCommissionModel {
  String? loraCommunication;
  double? batteryVlt;
  double? solarVlt;
  String? door1;
  String? door2;
  String? hexIntgValue;
  double? firmwareversion;
  String? siteName;
  String? nodeNo;
  String? mid;
  double? temp;
  double? ai1;
  double? ai2;
  AutoCommissionModel(
      {this.loraCommunication,
      this.batteryVlt,
      this.solarVlt,
      this.door1,
      this.door2,
      this.hexIntgValue,
      this.firmwareversion,
      this.siteName,
      this.nodeNo,
      this.mid,
      this.temp,
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

  void updateTemp(double? newTemp) {
    temp = newTemp;
  }

  void updateSiteName(String? newName) {
    siteName = newName;
  }

  void updateNodeNo(String? newNode) {
    nodeNo = newNode;
  }

  void updateLoraCommunication(String? newLoraCommunication) {
    loraCommunication = newLoraCommunication;
  }

  void updateFirmwareVersion(double? newFirmwareVersion) {
    firmwareversion = newFirmwareVersion;
  }

  void updateBatteryVlt(double? newBatteryVlt) {
    batteryVlt = newBatteryVlt;
  }

  void updateSolarVlt(double? newSolarVlt) {
    solarVlt = newSolarVlt;
  }

  void updateDoor1(String? newDoor1) {
    door1 = newDoor1;
  }

  void updateDoor2(String? newDoor2) {
    door2 = newDoor2;
  }

  void updateHexIntgValue(String? newhexValue) {
    hexIntgValue = newhexValue;
  }
}
