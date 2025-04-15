class Access {
  final int? id;
  final int? user;
  final int? district;
  final int? hospital;
  final String name;

  Access({this.id, // primary key
            this.user,
            this.district,
            this.hospital,
            required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'user': user,
      'district': district,
      'hospital': hospital,
    };
  }

  factory Access.fromJson(Map<String, dynamic> json) => Access(
    id: json['pk'],
    name: json["fields"]['name'],
    user: json["fields"]['user'],
    district: json["fields"]['district'],
    hospital: json["fields"]['hospital'],
  );

  Map<String, dynamic> toJson() => {
    'model': "logistics.Access",
    'pk': id,
    'fields': {
      'hospital': hospital,
      'name': name,
      'user': user,
      'district': district,
    }
  };

  // for print
  @override
  String toString() {
    return 'Access{id: $id, name: $name, user: $user, district: $district, hospital: $hospital}';
  }

}