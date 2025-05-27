class ServiceCenter {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int totalReviews;
  final List<String> services;
  final String phone;
  final String? website;
  final String? imageUrl;
  final Map<String, String> operatingHours;
  final bool isOpen;
  final int? nextAvailableSlot; // Unix timestamp

  const ServiceCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.totalReviews,
    required this.services,
    required this.phone,
    this.website,
    this.imageUrl,
    required this.operatingHours,
    required this.isOpen,
    this.nextAvailableSlot,
  });

  factory ServiceCenter.fromJson(Map<String, dynamic> json) {
    return ServiceCenter(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      totalReviews: json['total_reviews'] as int,
      services: List<String>.from(json['services'] as List),
      phone: json['phone'] as String,
      website: json['website'] as String?,
      imageUrl: json['image_url'] as String?,
      operatingHours: Map<String, String>.from(json['operating_hours'] as Map),
      isOpen: json['is_open'] as bool,
      nextAvailableSlot: json['next_available_slot'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'total_reviews': totalReviews,
      'services': services,
      'phone': phone,
      'website': website,
      'image_url': imageUrl,
      'operating_hours': operatingHours,
      'is_open': isOpen,
      'next_available_slot': nextAvailableSlot,
    };
  }
}
