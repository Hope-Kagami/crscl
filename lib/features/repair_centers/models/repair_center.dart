import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RepairCenter {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final String? email;
  final String? website;
  final String? imageUrl;
  final String? description;
  final LatLng location;
  final List<String> services;
  final double rating;
  final int reviewCount;
  final List<BusinessHours> businessHours;
  final bool isOpen;

  RepairCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    this.email,
    this.website,
    this.imageUrl,
    this.description,
    required this.location,
    required this.services,
    required this.rating,
    required this.reviewCount,
    required this.businessHours,
    required this.isOpen,
  });

  factory RepairCenter.fromJson(Map<String, dynamic> json) {
    return RepairCenter(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      website: json['website'],
      imageUrl: json['image_url'],
      description: json['description'],
      location: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      services: List<String>.from(json['services'] ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      businessHours: json['business_hours'] != null
          ? List<BusinessHours>.from(
              (json['business_hours'] as List).map(
                (x) => BusinessHours.fromJson(x),
              ),
            )
          : [],
      isOpen: json['is_open'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone_number': phoneNumber,
      'email': email,
      'website': website,
      'image_url': imageUrl,
      'description': description,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'services': services,
      'rating': rating,
      'review_count': reviewCount,
      'business_hours': businessHours.map((x) => x.toJson()).toList(),
      'is_open': isOpen,
    };
  }
}

class BusinessHours {
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final TimeOfDay? openTime;
  final TimeOfDay? closeTime;
  final bool isClosed;

  BusinessHours({
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    this.isClosed = false,
  });

  factory BusinessHours.fromJson(Map<String, dynamic> json) {
    return BusinessHours(
      dayOfWeek: json['day_of_week'],
      openTime: json['open_time'] != null
          ? _timeFromString(json['open_time'])
          : null,
      closeTime: json['close_time'] != null
          ? _timeFromString(json['close_time'])
          : null,
      isClosed: json['is_closed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek,
      'open_time': openTime != null
          ? '${openTime!.hour.toString().padLeft(2, '0')}:${openTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'close_time': closeTime != null
          ? '${closeTime!.hour.toString().padLeft(2, '0')}:${closeTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'is_closed': isClosed,
    };
  }

  static TimeOfDay _timeFromString(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String get dayName {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String get formattedHours {
    if (isClosed) return 'Closed';
    if (openTime == null || closeTime == null) return 'Hours not available';

    String formatTime(TimeOfDay time) {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
    }

    return '${formatTime(openTime!)} - ${formatTime(closeTime!)}';
  }
}
