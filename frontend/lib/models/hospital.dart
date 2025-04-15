class Hospital {
  final int? id;
  final String name;
  final int district;

  Hospital(
      {this.id, // primary key
      required this.name,
      required this.district});

  factory Hospital.fromJson(Map<String, dynamic> json) => Hospital(
      id: json['pk'],
      name: json["fields"]['name'],
      district: json["fields"]['district']);

  Map<String, dynamic> toJson() => {
    'model': "logistics.Hospital",
    'pk': id,
    'fields': {
      'name': name,
      'district': district,
    }
  };

  // for print
  @override
  String toString() {
    return 'Hospital{id: $id, name: $name, district: $district}';
  }
}
