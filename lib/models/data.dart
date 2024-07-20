// ignore_for_file: non_constant_identifier_names

class Data {
  String? InletButton;
  String? OutletButton;

  double? filterInlet;
  double? filterOutlet;

  String? PFCMD1;
  String? PFCMD2;
  String? PFCMD3;
  String? PFCMD4;
  String? PFCMD5;
  String? PFCMD6;

  String? sov1;
  String? sov2;
  String? sov3;
  String? sov4;
  String? sov5;
  String? sov6;

  String? pos1;
  String? pos2;
  String? pos3;
  String? pos4;
  String? pos5;
  String? pos6;

  String? pt1Smode;
  String? pt2Smode;
  String? pt3Smode;
  String? pt4Smode;
  String? pt5Smode;
  String? pt6Smode;

  String? pt1Omode;
  String? pt2Omode;
  String? pt3Omode;
  String? pt4Omode;
  String? pt5Omode;
  String? pt6Omode;

  double? posval1;
  double? posval2;
  double? posval3;
  double? posval4;
  double? posval5;
  double? posval6;

  double? outlet_1_actual_count_controller;
  double? outlet_2_actual_count_controller;
  double? outlet_3_actual_count_controller;
  double? outlet_4_actual_count_controller;
  double? outlet_6_actual_count_controller;
  double? outlet_5_actual_count_controller;

  bool? openvalpos1;
  bool? openvalpos2;
  bool? openvalpos3;
  bool? openvalpos4;
  bool? openvalpos5;
  bool? openvalpos6;

  bool? closevalpos1;
  bool? closevalpos2;
  bool? closevalpos3;
  bool? closevalpos4;
  bool? closevalpos5;
  bool? closevalpos6;

  Data({
    this.PFCMD1,
    this.PFCMD2,
    this.PFCMD3,
    this.PFCMD4,
    this.PFCMD5,
    this.PFCMD6,
    this.InletButton,
    this.OutletButton,
    this.filterInlet,
    this.filterOutlet,
    this.pos1,
    this.pos2,
    this.pos3,
    this.pos4,
    this.pos5,
    this.pos6,
    this.pt1Smode,
    this.pt2Smode,
    this.pt3Smode,
    this.pt4Smode,
    this.pt5Smode,
    this.pt6Smode,
    this.pt1Omode,
    this.pt2Omode,
    this.pt3Omode,
    this.pt4Omode,
    this.pt5Omode,
    this.pt6Omode,
    this.posval1,
    this.posval2,
    this.posval3,
    this.posval4,
    this.posval5,
    this.posval6,
    this.sov1,
    this.sov2,
    this.sov3,
    this.sov4,
    this.sov5,
    this.sov6,
    this.outlet_1_actual_count_controller,
    this.outlet_2_actual_count_controller,
    this.outlet_3_actual_count_controller,
    this.outlet_4_actual_count_controller,
    this.outlet_5_actual_count_controller,
    this.outlet_6_actual_count_controller,
    this.closevalpos1,
    this.closevalpos2,
    this.closevalpos3,
    this.closevalpos4,
    this.closevalpos5,
    this.closevalpos6,
    this.openvalpos1,
    this.openvalpos2,
    this.openvalpos3,
    this.openvalpos4,
    this.openvalpos5,
    this.openvalpos6,
  });

  Data copyWith({
    String? InletButton,
    String? OutletButton,
    double? filterInlet,
    double? filterOutlet,
    String? PFCMD1,
    String? PFCMD2,
    String? PFCMD3,
    String? PFCMD4,
    String? PFCMD5,
    String? PFCMD6,
    String? sov1,
    String? sov2,
    String? sov3,
    String? sov4,
    String? sov5,
    String? sov6,
    String? pos1,
    String? pos2,
    String? pos3,
    String? pos4,
    String? pos5,
    String? pos6,
    String? pt1Smode,
    String? pt2Smode,
    String? pt3Smode,
    String? pt4Smode,
    String? pt5Smode,
    String? pt6Smode,
    double? posval1,
    double? posval2,
    double? posval3,
    double? posval4,
    double? posval5,
    double? posval6,
    double? outlet_1_actual_count_controller,
    double? outlet_2_actual_count_controller,
    double? outlet_3_actual_count_controller,
    double? outlet_4_actual_count_controller,
    double? outlet_6_actual_count_controller,
    double? outlet_5_actual_count_controller,
    bool? openvalpos1,
    bool? openvalpos2,
    bool? openvalpos3,
    bool? openvalpos4,
    bool? openvalpos5,
    bool? openvalpos6,
    bool? closevalpos1,
    bool? closevalpos2,
    bool? closevalpos3,
    bool? closevalpos4,
    bool? closevalpos5,
    bool? closevalpos6,
  }) {
    return Data(
      InletButton: InletButton ?? this.InletButton,
      OutletButton: OutletButton ?? this.OutletButton,
      filterInlet: filterInlet ?? this.filterInlet,
      filterOutlet: filterOutlet ?? this.filterOutlet,
      PFCMD1: PFCMD1 ?? this.PFCMD1,
      PFCMD2: PFCMD2 ?? this.PFCMD2,
      PFCMD3: PFCMD3 ?? this.PFCMD3,
      PFCMD4: PFCMD4 ?? this.PFCMD4,
      PFCMD5: PFCMD5 ?? this.PFCMD5,
      PFCMD6: PFCMD6 ?? this.PFCMD6,
      sov1: sov1 ?? this.sov1,
      sov2: sov2 ?? this.sov2,
      sov3: sov3 ?? this.sov3,
      sov4: sov4 ?? this.sov4,
      sov5: sov5 ?? this.sov5,
      sov6: sov6 ?? this.sov6,
      pos1: pos1 ?? this.pos1,
      pos2: pos2 ?? this.pos2,
      pos3: pos3 ?? this.pos3,
      pos4: pos4 ?? this.pos4,
      pos5: pos5 ?? this.pos5,
      pos6: pos6 ?? this.pos6,
      pt1Smode: pt1Smode ?? this.pt1Smode,
      pt2Smode: pt2Smode ?? this.pt2Smode,
      pt3Smode: pt3Smode ?? this.pt3Smode,
      pt4Smode: pt4Smode ?? this.pt4Smode,
      pt5Smode: pt5Smode ?? this.pt5Smode,
      pt6Smode: pt6Smode ?? this.pt6Smode,
      posval1: posval1 ?? this.posval1,
      posval2: posval2 ?? this.posval2,
      posval3: posval3 ?? this.posval3,
      posval4: posval4 ?? this.posval4,
      posval5: posval5 ?? this.posval5,
      posval6: posval6 ?? this.posval6,
      outlet_1_actual_count_controller: outlet_1_actual_count_controller ??
          this.outlet_1_actual_count_controller,
      outlet_2_actual_count_controller: outlet_2_actual_count_controller ??
          this.outlet_2_actual_count_controller,
      outlet_3_actual_count_controller: outlet_3_actual_count_controller ??
          this.outlet_3_actual_count_controller,
      outlet_4_actual_count_controller: outlet_4_actual_count_controller ??
          this.outlet_4_actual_count_controller,
      outlet_5_actual_count_controller: outlet_5_actual_count_controller ??
          this.outlet_5_actual_count_controller,
      outlet_6_actual_count_controller: outlet_6_actual_count_controller ??
          this.outlet_6_actual_count_controller,
      closevalpos1: closevalpos1 ?? this.closevalpos1,
      closevalpos2: closevalpos2 ?? this.closevalpos2,
      closevalpos3: closevalpos3 ?? this.closevalpos3,
      closevalpos4: closevalpos4 ?? this.closevalpos4,
      closevalpos5: closevalpos5 ?? this.closevalpos5,
      closevalpos6: closevalpos6 ?? this.closevalpos6,
      openvalpos1: openvalpos1 ?? this.openvalpos1,
      openvalpos2: openvalpos1 ?? this.openvalpos2,
      openvalpos3: openvalpos3 ?? this.openvalpos3,
      openvalpos4: openvalpos4 ?? this.openvalpos4,
      openvalpos5: openvalpos5 ?? this.openvalpos5,
      openvalpos6: openvalpos6 ?? this.openvalpos6,
    );
  }
}
