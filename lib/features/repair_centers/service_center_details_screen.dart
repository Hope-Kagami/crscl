import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/repair_center.dart';

class ServiceCenterDetailsScreen extends StatelessWidget {
  const ServiceCenterDetailsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repairCenter =
        ModalRoute.of(context)!.settings.arguments as RepairCenter;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                repairCenter.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background:
                  repairCenter.imageUrl != null
                      ? Image.network(
                        repairCenter.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.car_repair, size: 64),
                            ),
                      )
                      : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.car_repair, size: 64),
                      ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 20,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${repairCenter.rating} (${repairCenter.reviewCount})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              repairCenter.isOpen
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          repairCenter.isOpen ? 'Open Now' : 'Closed',
                          style: TextStyle(
                            color:
                                repairCenter.isOpen
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Contact Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              () => _makePhoneCall(repairCenter.phoneNumber),
                          icon: const Icon(Icons.phone),
                          label: const Text('Call'),
                        ),
                      ),
                      if (repairCenter.email != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openEmail(repairCenter.email!),
                            icon: const Icon(Icons.email),
                            label: const Text('Email'),
                          ),
                        ),
                      ],
                      if (repairCenter.website != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _launchUrl(repairCenter.website!),
                            icon: const Icon(Icons.language),
                            label: const Text('Website'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                if (repairCenter.description != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'About',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(repairCenter.description!),
                  ),
                ],

                // Services
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Services',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        repairCenter.services.map((service) {
                          return Chip(label: Text(service));
                        }).toList(),
                  ),
                ),

                // Business Hours
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Business Hours',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children:
                        repairCenter.businessHours.map((hours) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  hours.dayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(hours.formattedHours),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),

                // Location Map
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Location',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(repairCenter.address),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: repairCenter.location,
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId(repairCenter.id),
                                position: repairCenter.location,
                                infoWindow: InfoWindow(
                                  title: repairCenter.name,
                                ),
                              ),
                            },
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/booking', arguments: repairCenter);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Book Appointment'),
          ),
        ),
      ),
    );
  }
}
