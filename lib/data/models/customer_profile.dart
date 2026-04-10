class CustomerProfile {
  const CustomerProfile({
    required this.uid,
    required this.fullName,
    required this.phoneNumber,
    required this.locality,
    required this.addressLine,
    this.landmark,
  });

  final String uid;
  final String fullName;
  final String phoneNumber;
  final String locality;
  final String addressLine;
  final String? landmark;

  CustomerProfile copyWith({
    String? uid,
    String? fullName,
    String? phoneNumber,
    String? locality,
    String? addressLine,
    String? landmark,
  }) {
    return CustomerProfile(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      locality: locality ?? this.locality,
      addressLine: addressLine ?? this.addressLine,
      landmark: landmark ?? this.landmark,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'locality': locality,
      'addressLine': addressLine,
      'landmark': landmark,
    };
  }

  factory CustomerProfile.fromMap(Map<String, dynamic> map) {
    return CustomerProfile(
      uid: map['uid'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      locality: map['locality'] as String? ?? '',
      addressLine: map['addressLine'] as String? ?? '',
      landmark: map['landmark'] as String?,
    );
  }
}
