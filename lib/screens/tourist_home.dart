import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/mock_repository.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'auth_screen.dart';
import 'provider_profile.dart';
import 'my_requests.dart';

/// Tourist home: map of nearby verified providers + searchable list.
class TouristHome extends StatefulWidget {
  const TouristHome({super.key});

  @override
  State<TouristHome> createState() => _TouristHomeState();
}

class _TouristHomeState extends State<TouristHome> {
  String _filter = 'All';
  // Tourist's assumed position: Nairobi CBD (prototype; production uses GPS).
  static const double _meLat = -1.2921;
  static const double _meLng = 36.8219;

  void _logout() {
    NativeGoRepo().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  void _openProfile(ProviderProfile p) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProviderProfileScreen(profile: p)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = NativeGoRepo();
    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final providers = repo.visibleProviders(serviceFilter: _filter);
        final markers = providers
            .map(
              (p) => Marker(
                point: LatLng(p.latitude, p.longitude),
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () => _openProfile(p),
                  child: const Icon(Icons.location_on,
                      color: Color(0xFF0E7C5B), size: 40),
                ),
              ),
            )
            .toList();
        return Scaffold(
          appBar: AppBar(
            title: const Text('Find a local'),
            backgroundColor: const Color(0xFF0E7C5B),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.receipt_long),
                tooltip: 'My requests',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const MyRequestsScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Log out',
                onPressed: _logout,
              ),
            ],
          ),
          body: Column(
            children: [
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  children: ['All', ...serviceCategories].map((s) {
                    final selected = _filter == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(s,
                            style: const TextStyle(fontSize: 12)),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _filter = s),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                flex: 5,
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(_meLat, _meLng),
                    initialZoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.nativego.app',
                    ),
                    MarkerLayer(markers: [
                      const Marker(
                        point: LatLng(_meLat, _meLng),
                        width: 44,
                        height: 44,
                        child: Icon(Icons.person_pin_circle,
                            color: Colors.blue, size: 40),
                      ),
                      ...markers,
                    ]),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: providers.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off,
                        message:
                            'No verified providers nearby for this service yet.',
                      )
                    : ListView.builder(
                        itemCount: providers.length,
                        itemBuilder: (context, i) {
                          final p = providers[i];
                          final user = repo.userById(p.userId);
                          final km = repo.kmBetween(
                              _meLat, _meLng, p.latitude, p.longitude);
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    const Color(0xFF0E7C5B),
                                child: Text(
                                  (user?.name ?? '?')
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(user?.name ?? 'Provider',
                                        style: const TextStyle(
                                            fontWeight:
                                                FontWeight.w600)),
                                  ),
                                  const VerificationChip(
                                      status:
                                          VerificationStatus.approved),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(p.services.join(' \u2022 '),
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      StarRating(
                                          rating: p.ratingAvg),
                                      Text(
                                          ' (${p.reviewCount})',
                                          style: TextStyle(
                                              color: Colors
                                                  .grey.shade600,
                                              fontSize: 12)),
                                      const SizedBox(width: 12),
                                      Icon(Icons.place,
                                          size: 14,
                                          color:
                                              Colors.grey.shade600),
                                      Text(
                                          ' ${km.toStringAsFixed(1)} km',
                                          style: TextStyle(
                                              color: Colors
                                                  .grey.shade600,
                                              fontSize: 12)),
                                      const Spacer(),
                                      Text(
                                        'Ksh ${p.hourlyRate.toStringAsFixed(0)}/hr',
                                        style: const TextStyle(
                                            fontWeight:
                                                FontWeight.w600,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () => _openProfile(p),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
