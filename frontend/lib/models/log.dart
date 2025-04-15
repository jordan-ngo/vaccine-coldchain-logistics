import 'dart:convert';

class Log {
  final int? id;
  final int user;
  final int district;
  final int hospital;
  final int? refrigerator;
  final Map<String, dynamic> previousValue;
  final Map<String, dynamic> newValue;
  final DateTime timestamp;

  Log({
    this.id, // primary key
    required this.user,
    required this.district,
    required this.hospital,
    this.refrigerator,
    required this.previousValue,
    required this.newValue,
    required this.timestamp,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      id: json['id'],
      user: json['user'],
      district: json['district'],
      hospital: json['hospital'],
      refrigerator: json['refrigerator'],
      previousValue: jsonDecode(json['previous_value']),
      newValue: jsonDecode(json['new_value']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'district': district,
      'hospital': hospital,
      'refrigerator': refrigerator,
      'previous_value': jsonEncode(previousValue),
      'new_value': jsonEncode(newValue),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}