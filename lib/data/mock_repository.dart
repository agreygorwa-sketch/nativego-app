import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/models.dart';

/// In-memory data layer for the NativeGo prototype.
///
/// The public API of this class mirrors the Firestore-backed repository used
/// in production (collections: users, providerProfiles, serviceRequests,
/// messages, reviews, reports), so the UI code does not change when the
/// Firebase implementation is plugged in.
class NativeGoRepo extends ChangeNotifier {
  // Singleton: every screen talks to the same store.
  static final NativeGoRepo _instance = NativeGoRepo._internal();
  factory NativeGoRepo() => _instance;
  NativeGoRepo._internal() {
    _seed();
    // Seed reviews so provider profiles show review content.
    reviews.add(Review(
      id: 'rev_r_1',
      providerId: 'u_p1',
      touristId: 'u_tourist1',
      touristName: 'Alex Morgan',
      rating: 5,
      comment:
          'David knew all the shortcuts and made the walk great fun. Highly recommended!',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ));
    reviews.add(Review(
      id: 'rev_seed_grace',
      providerId: 'u_p2',
      touristId: 'u_tourist1',
      touristName: 'Alex Morgan',
      rating: 5,
      comment:
          'Grace is a wonderful storyteller. The Karen walk was the highlight of my trip.',
      timestamp: DateTime.now().subtract(const Duration(days: 6)),
    ));
  }

  AppUser? currentUser;

  final List<AppUser> users = [];
  final List<ProviderProfile> providers = [];
  final List<ServiceRequest> requests = [];
  final Map<String, List<ChatMessage>> messages = {};
  final List<Review> reviews = [];
  final List<Report> reports = [];

  int _idCounter = 100;

  String _nextId(String prefix) => '${prefix}_${_idCounter++}';

  // ------------------------------- seeding -------------------------------

  void _seed() {
    // Admin (seeded account)
    users.add(const AppUser(
      id: 'u_admin',
      name: 'System Administrator',
      email: 'admin@nativego.co.ke',
      password: 'admin123',
      phone: '+254700000000',
      role: Role.admin,
    ));
    // Demo tourist
    users.add(const AppUser(
      id: 'u_tourist1',
      name: 'Alex Morgan',
      email: 'tourist@demo.co.ke',
      password: 'demo123',
      phone: '+254711111111',
      role: Role.tourist,
    ));
    // Demo providers (users + profiles)
    _addSeedProvider(
      id: 'u_p1',
      name: 'David Mwangi',
      email: 'david@demo.co.ke',
      phone: '+254722222222',
      bio: 'Born and raised in Nairobi. I know every shortcut in Westlands and '
          'love showing visitors the real city beyond the guidebooks.',
      languages: const ['English', 'Swahili'],
      services: const ['Navigation assistance', 'Local recommendations'],
      rate: 800,
      lat: -1.2635,
      lng: 36.8028,
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.8,
      reviewCount: 24,
    );
    _addSeedProvider(
      id: 'u_p2',
      name: 'Grace Achieng',
      email: 'grace@demo.co.ke',
      phone: '+254733333333',
      bio: 'Cultural guide based in Karen. I offer storytelling walks, translation '
          'in English, Swahili and French, and introductions to local crafts.',
      languages: const ['English', 'Swahili', 'French'],
      services: const ['Cultural information', 'Translation assistance', 'Local experiences'],
      rate: 1200,
      lat: -1.3318,
      lng: 36.7086,
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.9,
      reviewCount: 41,
    );
    _addSeedProvider(
      id: 'u_p3',
      name: 'Peter Otieno',
      email: 'peter@demo.co.ke',
      phone: '+254744444444',
      bio: 'CBD navigator. I help visitors move safely through downtown Nairobi, '
          'find the best local eateries and avoid the tourist traps.',
      languages: const ['English', 'Swahili'],
      services: const ['Navigation assistance', 'Local recommendations'],
      rate: 600,
      lat: -1.2921,
      lng: 36.8219,
      verificationStatus: VerificationStatus.pending,
      documentsSubmitted: true,
      ratingAvg: 0.0,
      reviewCount: 0,
    );
    _addSeedProvider(
      id: 'u_p4',
      name: 'Faith Wanjiru',
      email: 'faith@demo.co.ke',
      phone: '+254755555555',
      bio: 'Food lover from Kilimani. Join me for nyama choma trails, market '
          'visits and home-style cooking experiences.',
      languages: const ['English', 'Swahili', 'Kikuyu'],
      services: const ['Local experiences', 'Translation assistance'],
      rate: 1000,
      lat: -1.2970,
      lng: 36.7820,
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.7,
      reviewCount: 18,
    );
    _addSeedProvider(
      id: 'u_p5',
      name: 'John Kamau',
      email: 'john@demo.co.ke',
      phone: '+254766666666',
      bio: 'Eastleigh shopping guide. I know the malls, the markets and where to '
          'get the best prices. Somali and Swahili translation available.',
      languages: const ['English', 'Swahili', 'Somali'],
      services: const ['Local recommendations', 'Translation assistance', 'Activity assistance'],
      rate: 700,
      lat: -1.2775,
      lng: 36.8522,
      verificationStatus: VerificationStatus.approved,
      ratingAvg: 4.6,
      reviewCount: 12,
    );
    _addSeedProvider(
      id: 'u_p6',
      name: 'Mary Njeri',
      email: 'mary@demo.co.ke',
      phone: '+254777777777',
      bio: 'Nature walk leader in Lavington and Karura. I do morning bird walks '
          'and photography strolls for small groups.',
      languages: const ['English', 'Swahili'],
      services: const ['Activity assistance', 'Local experiences'],
      rate: 900,
      lat: -1.2800,
      lng: 36.7700,
      verificationStatus: VerificationStatus.pending,
      documentsSubmitted: true,
      ratingAvg: 0.0,
      reviewCount: 0,
    );

    // A completed request (for the review flow demo)
    final completed = ServiceRequest(
      id: 'r_1',
      touristId: 'u_tourist1',
      providerId: 'u_p1',
      serviceType: 'Navigation assistance',
      description: 'Half-day walk through Westlands, ending at Sarit Centre.',
      latitude: -1.2635,
      longitude: 36.8028,
      status: RequestStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    );
    requests.add(completed);
    messages[completed.id] = [
      ChatMessage(
        id: 'm_1',
        requestId: completed.id,
        senderId: 'u_tourist1',
        text: 'Hi David, are you free Saturday morning?',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ChatMessage(
        id: 'm_2',
        requestId: completed.id,
        senderId: 'u_p1',
        text: 'Karibu! Yes, Saturday 9am works. Meet at the Westlands roundabout?',
        timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
      ),
    ];

    // An in-progress request with chat history
    final active = ServiceRequest(
      id: 'r_2',
      touristId: 'u_tourist1',
      providerId: 'u_p2',
      serviceType: 'Cultural information',
      description: 'Karen Blixen area cultural walk, about 3 hours.',
      latitude: -1.3318,
      longitude: 36.7086,
      status: RequestStatus.accepted,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    );
    requests.add(active);
    messages[active.id] = [
      ChatMessage(
        id: 'm_3',
        requestId: active.id,
        senderId: 'u_tourist1',
        text: 'Hi Grace! Looking forward to the cultural walk.',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      ChatMessage(
        id: 'm_4',
        requestId: active.id,
        senderId: 'u_p2',
        text: 'Welcome! I will meet you at the Karen Blixen Museum gate at 10am.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];

    // A pending request (for the provider dashboard demo)
    requests.add(ServiceRequest(
      id: 'r_3',
      touristId: 'u_tourist1',
      providerId: 'u_p4',
      serviceType: 'Local experiences',
      description: 'Evening nyama choma trail for two people.',
      latitude: -1.2970,
      longitude: 36.7820,
      status: RequestStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ));
  }

  void _addSeedProvider({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String bio,
    required List<String> languages,
    required List<String> services,
    required double rate,
    required double lat,
    required double lng,
    required VerificationStatus verificationStatus,
    bool documentsSubmitted = false,
    double ratingAvg = 0.0,
    int reviewCount = 0,
  }) {
    users.add(AppUser(
      id: id,
      name: name,
      email: email,
      password: 'demo123',
      phone: phone,
      role: Role.provider,
    ));
    providers.add(ProviderProfile(
      providerId: 'pp_$id',
      userId: id,
      bio: bio,
      languages: List.of(languages),
      services: List.of(services),
      hourlyRate: rate,
      latitude: lat,
      longitude: lng,
      verificationStatus: verificationStatus,
      documentsSubmitted: documentsSubmitted,
      ratingAvg: ratingAvg,
      reviewCount: reviewCount,
    ));
  }

  // ------------------------------ auth ------------------------------

  AppUser? login(String email, String password) {
    for (final u in users) {
      if (u.email.toLowerCase() == email.trim().toLowerCase() &&
          u.password == password) {
        currentUser = u;
        notifyListeners();
        return u;
      }
    }
    return null;
  }

  AppUser register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required Role role,
  }) {
    final user = AppUser(
      id: _nextId('u'),
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: role,
    );
    users.add(user);
    if (role == Role.provider) {
      providers.add(ProviderProfile(
        providerId: _nextId('pp'),
        userId: user.id,
        bio: '',
        languages: const [],
        services: const [],
        hourlyRate: 0,
        latitude: -1.2921,
        longitude: 36.8219,
      ));
    }
    currentUser = user;
    notifyListeners();
    return user;
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  // ---------------------------- providers ----------------------------

  AppUser? userById(String id) {
    for (final u in users) {
      if (u.id == id) return u;
    }
    return null;
  }

  ProviderProfile? profileOf(String userId) {
    for (final p in providers) {
      if (p.userId == userId) return p;
    }
    return null;
  }

  ProviderProfile? profileById(String providerId) {
    for (final p in providers) {
      if (p.providerId == providerId) return p;
    }
    return null;
  }

  /// Providers visible to tourists: verified and marked available.
  List<ProviderProfile> visibleProviders({String? serviceFilter}) {
    return providers.where((p) {
      if (p.verificationStatus != VerificationStatus.approved) return false;
      if (!p.available) return false;
      if (serviceFilter != null &&
          serviceFilter != 'All' &&
          !p.services.contains(serviceFilter)) {
        return false;
      }
      return true;
    }).toList();
  }

  List<ProviderProfile> pendingVerifications() {
    return providers
        .where((p) => p.verificationStatus == VerificationStatus.pending)
        .toList();
  }

  void setAvailability(String providerId, bool available) {
    profileById(providerId)?.available = available;
    notifyListeners();
  }

  void updateProviderProfile(
    String providerId, {
    String? bio,
    List<String>? languages,
    List<String>? services,
    double? hourlyRate,
    double? latitude,
    double? longitude,
  }) {
    final p = profileById(providerId);
    if (p == null) return;
    if (bio != null) p.bio = bio;
    if (languages != null) p.languages = languages;
    if (services != null) p.services = services;
    if (hourlyRate != null) p.hourlyRate = hourlyRate;
    if (latitude != null) p.latitude = latitude;
    if (longitude != null) p.longitude = longitude;
    notifyListeners();
  }

  void submitVerificationDocuments(String providerId) {
    final p = profileById(providerId);
    if (p == null) return;
    p.documentsSubmitted = true;
    p.verificationStatus = VerificationStatus.pending;
    notifyListeners();
  }

  void approveProvider(String providerId) {
    profileById(providerId)?.verificationStatus = VerificationStatus.approved;
    notifyListeners();
  }

  void rejectProvider(String providerId) {
    profileById(providerId)?.verificationStatus = VerificationStatus.rejected;
    notifyListeners();
  }

  // ---------------------------- requests ----------------------------

  ServiceRequest createRequest({
    required String touristId,
    required String providerId,
    required String serviceType,
    required String description,
    required double latitude,
    required double longitude,
  }) {
    final r = ServiceRequest(
      id: _nextId('r'),
      touristId: touristId,
      providerId: providerId,
      serviceType: serviceType,
      description: description,
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now(),
    );
    requests.add(r);
    messages[r.id] = [];
    notifyListeners();
    return r;
  }

  void updateRequestStatus(String requestId, RequestStatus status) {
    for (final r in requests) {
      if (r.id == requestId) {
        r.status = status;
        notifyListeners();
        return;
      }
    }
  }

  List<ServiceRequest> requestsForTourist(String touristId) =>
      requests.where((r) => r.touristId == touristId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<ServiceRequest> requestsForProvider(String providerUserId) =>
      requests.where((r) => r.providerId == providerUserId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  ServiceRequest? requestById(String id) {
    for (final r in requests) {
      if (r.id == id) return r;
    }
    return null;
  }

  // ---------------------------- messaging ----------------------------

  List<ChatMessage> messagesFor(String requestId) =>
      List.unmodifiable(messages[requestId] ?? const []);

  void sendMessage(String requestId, String senderId, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final list = messages.putIfAbsent(requestId, () => []);
    list.add(ChatMessage(
      id: _nextId('m'),
      requestId: requestId,
      senderId: senderId,
      text: trimmed,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  // ---------------------------- reviews ----------------------------

  List<Review> reviewsForProvider(String providerUserId) =>
      reviews.where((r) => r.providerId == providerUserId).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  bool hasReviewed(String requestId) =>
      reviews.any((r) => r.id == 'rev_$requestId');

  void submitReview({
    required String requestId,
    required String providerId,
    required String touristId,
    required String touristName,
    required int rating,
    required String comment,
  }) {
    reviews.add(Review(
      id: 'rev_$requestId',
      providerId: providerId,
      touristId: touristId,
      touristName: touristName,
      rating: rating,
      comment: comment,
      timestamp: DateTime.now(),
    ));
    // Update the provider's aggregate rating.
    final rated = reviews.where((r) => r.providerId == providerId).toList();
    final p = profileOf(providerId);
    if (p != null && rated.isNotEmpty) {
      final sum = rated.fold<int>(0, (s, r) => s + r.rating);
      p.ratingAvg = sum / rated.length;
      p.reviewCount = rated.length;
    }
    notifyListeners();
  }

  // ---------------------------- reports ----------------------------

  void submitReport({
    required String reporterId,
    required String reporterName,
    required String reportedUserId,
    required String reportedUserName,
    required String reason,
  }) {
    reports.add(Report(
      id: _nextId('rep'),
      reporterId: reporterId,
      reporterName: reporterName,
      reportedUserId: reportedUserId,
      reportedUserName: reportedUserName,
      reason: reason,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void resolveReport(String reportId) {
    for (final r in reports) {
      if (r.id == reportId) {
        r.resolved = true;
        notifyListeners();
        return;
      }
    }
  }

  // ---------------------------- helpers ----------------------------

  double kmBetween(double lat1, double lng1, double lat2, double lng2) {
    const d = Distance();
    return d.as(
      LengthUnit.Kilometer,
      LatLng(lat1, lng1),
      LatLng(lat2, lng2),
    );
  }
}
