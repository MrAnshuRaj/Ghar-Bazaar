class Shop {
  const Shop({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.coverImageUrl,
    required this.locality,
    required this.address,
    required this.deliveryEstimate,
    required this.contactNumber,
    this.openingHours,
    this.rating = 4.5,
    this.categories = const [],
  });

  final String id;
  final String vendorId;
  final String name;
  final String description;
  final String imageUrl;
  final String? coverImageUrl;
  final String locality;
  final String address;
  final String deliveryEstimate;
  final String contactNumber;
  final String? openingHours;
  final double rating;
  final List<String> categories;

  Shop copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? description,
    String? imageUrl,
    String? coverImageUrl,
    String? locality,
    String? address,
    String? deliveryEstimate,
    String? contactNumber,
    String? openingHours,
    double? rating,
    List<String>? categories,
  }) {
    return Shop(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      locality: locality ?? this.locality,
      address: address ?? this.address,
      deliveryEstimate: deliveryEstimate ?? this.deliveryEstimate,
      contactNumber: contactNumber ?? this.contactNumber,
      openingHours: openingHours ?? this.openingHours,
      rating: rating ?? this.rating,
      categories: categories ?? this.categories,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'coverImageUrl': coverImageUrl,
      'locality': locality,
      'address': address,
      'deliveryEstimate': deliveryEstimate,
      'contactNumber': contactNumber,
      'openingHours': openingHours,
      'rating': rating,
      'categories': categories,
    };
  }

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      id: map['id'] as String? ?? '',
      vendorId: map['vendorId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      coverImageUrl: map['coverImageUrl'] as String?,
      locality: map['locality'] as String? ?? '',
      address: map['address'] as String? ?? '',
      deliveryEstimate: map['deliveryEstimate'] as String? ?? '',
      contactNumber: map['contactNumber'] as String? ?? '',
      openingHours: map['openingHours'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      categories: List<String>.from(map['categories'] as List? ?? const []),
    );
  }
}
