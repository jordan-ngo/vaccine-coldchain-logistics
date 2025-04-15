class ConflictLog {
  final int? id;
  final int log;

  ConflictLog({
    this.id, // primary key
    required this.log,
  });

  factory ConflictLog.fromJson(Map<String, dynamic> json) {
    return ConflictLog(
      id: json['pk'],
      log: json['fields']['log'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'log': log,
    };
  }
}