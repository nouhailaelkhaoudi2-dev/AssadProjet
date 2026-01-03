import 'package:equatable/equatable.dart';

/// Entité représentant une fanzone
class FanZone extends Equatable {
  final String id;
  final String name;
  final String city;
  final String address;
  final double latitude;
  final double longitude;
  final String? capacity;
  final String? openingHours;
  final String? description;
  final String? imageUrl;
  final List<String> amenities;

  const FanZone({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.capacity,
    this.openingHours,
    this.description,
    this.imageUrl,
    this.amenities = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        city,
        address,
        latitude,
        longitude,
        capacity,
        openingHours,
        description,
        imageUrl,
        amenities,
      ];

  /// URL Google Maps
  String get googleMapsUrl {
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }

  FanZone copyWith({
    String? id,
    String? name,
    String? city,
    String? address,
    double? latitude,
    double? longitude,
    String? capacity,
    String? openingHours,
    String? description,
    String? imageUrl,
    List<String>? amenities,
  }) {
    return FanZone(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capacity: capacity ?? this.capacity,
      openingHours: openingHours ?? this.openingHours,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      amenities: amenities ?? this.amenities,
    );
  }
}

/// Fanzones officielles CAN 2025 (données statiques)
class AfconFanZones {
  AfconFanZones._();

  static const List<FanZone> fanzones = [
    FanZone(
      id: '1',
      name: 'Fan Zone Casablanca',
      city: 'Casablanca',
      address: 'Place Mohammed V, Casablanca',
      latitude: 33.5731,
      longitude: -7.5898,
      capacity: '50 000',
      openingHours: '14h00 - 00h00',
      description: 'La plus grande fan zone de la CAN 2025, située au cœur de Casablanca.',
      amenities: ['Écran géant', 'Restauration', 'Animation', 'Sécurité 24h/24'],
    ),
    FanZone(
      id: '2',
      name: 'Fan Zone Rabat',
      city: 'Rabat',
      address: 'Esplanade du Bouregreg, Rabat',
      latitude: 34.0209,
      longitude: -6.8416,
      capacity: '30 000',
      openingHours: '14h00 - 00h00',
      description: 'Fan zone avec vue sur le fleuve Bouregreg.',
      amenities: ['Écran géant', 'Restauration', 'Zone VIP'],
    ),
    FanZone(
      id: '3',
      name: 'Fan Zone Marrakech',
      city: 'Marrakech',
      address: 'Place Jemaa el-Fna, Marrakech',
      latitude: 31.6295,
      longitude: -7.9811,
      capacity: '40 000',
      openingHours: '15h00 - 01h00',
      description: 'Ambiance unique sur la célèbre place Jemaa el-Fna.',
      amenities: ['Écran géant', 'Restauration traditionnelle', 'Spectacles'],
    ),
    FanZone(
      id: '4',
      name: 'Fan Zone Tanger',
      city: 'Tanger',
      address: 'Corniche de Tanger',
      latitude: 35.7595,
      longitude: -5.8340,
      capacity: '25 000',
      openingHours: '14h00 - 00h00',
      description: 'Fan zone face à la mer Méditerranée.',
      amenities: ['Écran géant', 'Restauration', 'Plage'],
    ),
    FanZone(
      id: '5',
      name: 'Fan Zone Fès',
      city: 'Fès',
      address: 'Place Boujloud, Fès',
      latitude: 34.0331,
      longitude: -5.0003,
      capacity: '20 000',
      openingHours: '14h00 - 23h00',
      description: 'Fan zone aux portes de la médina historique.',
      amenities: ['Écran géant', 'Restauration', 'Artisanat'],
    ),
    FanZone(
      id: '6',
      name: 'Fan Zone Agadir',
      city: 'Agadir',
      address: 'Marina d\'Agadir',
      latitude: 30.4278,
      longitude: -9.5981,
      capacity: '20 000',
      openingHours: '15h00 - 00h00',
      description: 'Fan zone au bord de l\'océan Atlantique.',
      amenities: ['Écran géant', 'Restauration', 'Activités nautiques'],
    ),
  ];

  static FanZone? getFanZoneById(String id) {
    try {
      return fanzones.firstWhere((fz) => fz.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<FanZone> getFanZonesByCity(String city) {
    return fanzones.where((fz) => fz.city.toLowerCase() == city.toLowerCase()).toList();
  }
}
