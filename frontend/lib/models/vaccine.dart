class Vaccine {
  final int? id;
  final String name;
  final String producer;
  final String type;
  int amount;
  final String hospital;
  int? refrigeratorId;
  String refrigerator;
  String other;

  Vaccine({this.id, // primary key
           required this.name,
           required this.producer,
           required this.type,
           required this.amount,
           required this.hospital,
           this.refrigeratorId, // not sure if required is required
           required this.refrigerator,
           required this.other,});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'producer': producer,
      'type': type,
      'amount': amount,
      'hospital': hospital,
      'refrigerator_id': refrigeratorId,
      'refrigerator': refrigerator,
      'other': other,
    };
  }

  factory Vaccine.fromMap(Map<String, dynamic> map) => Vaccine(
    id: map['id'],
    name: map['name'],
    producer: map['producer'],
    type: map['type'],
    amount: map['amount'],
    hospital: map['hospital'],
    refrigeratorId: map['refrigerator_id'],
    refrigerator: map['refrigerator'],
    other: map['other'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'producer': producer,
    'type': type,
    'amount': amount,
    'hospital': hospital,
    'refrigerator_id': refrigeratorId,
    'refrigerator': refrigerator,
    'other': other,
  };

  factory Vaccine.fromJson(Map<String, dynamic> json) => Vaccine(
    id: json['id'],
    name: json['name'],
    producer: json['producer'],
    type: json['type'],
    amount: json['amount'],
    hospital: json['hospital'],
    refrigeratorId: json['refrigerator_id'],
    refrigerator: json['refrigerator'],
    other: json['other'],
    );

  // for print
  @override
  String toString() {
    return 'Vaccine{id: $id, name: $name, producer: $producer, type: $type, amount: $amount, hospital: $hospital, refrigerator_id: $refrigeratorId, refrigerator: $refrigerator, other: $other}';
  }
}