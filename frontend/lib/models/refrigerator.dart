class Refrigerator {
  final int id;
  final String name;
  final String modelId;
  final String manufacturer;
  final bool tempMonitorInstalled;
  final String monitorType;
  final bool monitorWorking;
  final bool voltageRegulatorInstalled;
  final String regulatorType;
  final int vaccineCount;
  final int hospitalId;

  Refrigerator({
    required this.id,
    required this.name,
    required this.modelId,
    required this.manufacturer,
    required this.tempMonitorInstalled,
    required this.monitorType,
    required this.monitorWorking,
    required this.voltageRegulatorInstalled,
    required this.regulatorType,
    required this.vaccineCount,
    required this.hospitalId,
  });

  factory Refrigerator.fromJson(Map<String, dynamic> json) {
    return Refrigerator(
      id: json['id'],
      name: json['name'],
      modelId: json['model_id'],
      manufacturer: json['manufacturer'],
      tempMonitorInstalled: json['temp_monitor_installed'] == 1,
      monitorType: json['monitor_type'],
      monitorWorking: json['monitor_working'] == 1,
      voltageRegulatorInstalled: json['voltage_regulator_installed'] == 1,
      regulatorType: json['regulator_type'],
      vaccineCount: json['vaccine_count'],
      hospitalId: json['hospital_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'model_id': modelId,
      'manufacturer': manufacturer,
      'temp_monitor_installed': tempMonitorInstalled ? 1 : 0,
      'monitor_type': monitorType,
      'monitor_working': monitorWorking ? 1 : 0,
      'voltage_regulator_installed': voltageRegulatorInstalled ? 1 : 0,
      'regulator_type': regulatorType,
      'vaccine_count': vaccineCount,
      'hospital_id': hospitalId,
    };
  }
}
