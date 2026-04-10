class VendorProfile {
  const VendorProfile({
    required this.uid,
    required this.ownerName,
    required this.phoneNumber,
    required this.shopName,
    required this.shopDescription,
    required this.locality,
    required this.shopAddress,
    this.deliveryRadiusKm,
    this.shopImageUrl,
  });

  final String uid;
  final String ownerName;
  final String phoneNumber;
  final String shopName;
  final String shopDescription;
  final String locality;
  final String shopAddress;
  final double? deliveryRadiusKm;
  final String? shopImageUrl;

  VendorProfile copyWith({
    String? uid,
    String? ownerName,
    String? phoneNumber,
    String? shopName,
    String? shopDescription,
    String? locality,
    String? shopAddress,
    double? deliveryRadiusKm,
    String? shopImageUrl,
  }) {
    return VendorProfile(
      uid: uid ?? this.uid,
      ownerName: ownerName ?? this.ownerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      shopName: shopName ?? this.shopName,
      shopDescription: shopDescription ?? this.shopDescription,
      locality: locality ?? this.locality,
      shopAddress: shopAddress ?? this.shopAddress,
      deliveryRadiusKm: deliveryRadiusKm ?? this.deliveryRadiusKm,
      shopImageUrl: shopImageUrl ?? this.shopImageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'ownerName': ownerName,
      'phoneNumber': phoneNumber,
      'shopName': shopName,
      'shopDescription': shopDescription,
      'locality': locality,
      'shopAddress': shopAddress,
      'deliveryRadiusKm': deliveryRadiusKm,
      'shopImageUrl': shopImageUrl,
    };
  }

  factory VendorProfile.fromMap(Map<String, dynamic> map) {
    return VendorProfile(
      uid: map['uid'] as String? ?? '',
      ownerName: map['ownerName'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      shopName: map['shopName'] as String? ?? '',
      shopDescription: map['shopDescription'] as String? ?? '',
      locality: map['locality'] as String? ?? '',
      shopAddress: map['shopAddress'] as String? ?? '',
      deliveryRadiusKm: (map['deliveryRadiusKm'] as num?)?.toDouble(),
      shopImageUrl: map['shopImageUrl'] as String?,
    );
  }
}
