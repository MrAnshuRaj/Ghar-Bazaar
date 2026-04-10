class Address {
  const Address({required this.locality, required this.line1, this.landmark});

  final String locality;
  final String line1;
  final String? landmark;

  Address copyWith({String? locality, String? line1, String? landmark}) {
    return Address(
      locality: locality ?? this.locality,
      line1: line1 ?? this.line1,
      landmark: landmark ?? this.landmark,
    );
  }

  Map<String, dynamic> toMap() {
    return {'locality': locality, 'line1': line1, 'landmark': landmark};
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      locality: map['locality'] as String? ?? '',
      line1: map['line1'] as String? ?? '',
      landmark: map['landmark'] as String?,
    );
  }
}
