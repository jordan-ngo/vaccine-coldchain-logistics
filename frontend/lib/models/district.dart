class District {
  final int? id;
  final String name;

  District({this.id, // primary key
           required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory District.fromJson(Map<String, dynamic> json) => District(
    id: json['pk'],
    name: json["fields"]['name'],
    );

  // for print
  @override
  String toString() {
    return 'District{id: $id, name: $name}';
  }
}