// Data models for the NativeGo platform.
// These mirror the class diagram in Chapter 4 and map 1:1 onto the
// Firestore collections used by the production backend
// (users, providerProfiles, serviceRequests, messages, reviews, reports).

enum Role { tourist, provider, admin }

enum RequestStatus { pending, accepted, inProgress, completed, cancelled }

enum VerificationStatus { pending, approved, rejected }

String requestStatusLabel(RequestStatus s) {
  switch (s) {
    case RequestStatus.pending:
      return 'Pending';
    case RequestStatus.accepted:
      return 'Accepted';
    case RequestStatus.inProgress:
      return 'In progress';
    case RequestStatus.completed:
      return 'Completed';
    case RequestStatus.cancelled:
      return 'Cancelled';
  }
}

String verificationLabel(VerificationStatus s) {
  switch (s) {
    case VerificationStatus.pending:
      return 'Pending verification';
    case VerificationStatus.approved:
      return 'Verified';
    case VerificationStatus.rejected:
      return 'Rejected';
  }
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final String password; // demo only: production uses Firebase Auth
  final String phone;
  final Role role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
  });
}

class ProviderProfile {
  final String providerId;
  final String userId;
  String bio;
  List<String> languages;
  List<String> services;
  double hourlyRate;
  double latitude;
  double longitude;
  bool available;
  VerificationStatus verificationStatus;
  bool documentsSubmitted;
  double ratingAvg;
  int reviewCount;

  ProviderProfile({
    required this.providerId,
    required this.userId,
    required this.bio,
    required this.languages,
    required this.services,
    required this.hourlyRate,
    required this.latitude,
    required this.longitude,
    this.available = true,
    this.verificationStatus = VerificationStatus.pending,
    this.documentsSubmitted = false,
    this.ratingAvg = 0.0,
    this.reviewCount = 0,
  });
}

class ServiceRequest {
  final String id;
  final String touristId;
  final String providerId;
  final String serviceType;
  final String description;
  final double latitude;
  final double longitude;
  RequestStatus status;
  final DateTime createdAt;

  ServiceRequest({
    required this.id,
    required this.touristId,
    required this.providerId,
    required this.serviceType,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.status = RequestStatus.pending,
    required this.createdAt,
  });
}

class ChatMessage {
  final String id;
  final String requestId;
  final String senderId;
  final String text;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.requestId,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });
}

class Review {
  final String id;
  final String providerId;
  final String touristId;
  final String touristName;
  final int rating; // 1..5
  final String comment;
  final DateTime timestamp;

  const Review({
    required this.id,
    required this.providerId,
    required this.touristId,
    required this.touristName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });
}

class Report {
  final String id;
  final String reporterId;
  final String reporterName;
  final String reportedUserId;
  final String reportedUserName;
  final String reason;
  bool resolved;
  final DateTime timestamp;

  Report({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.reason,
    this.resolved = false,
    required this.timestamp,
  });
}

/// Fixed list of service categories offered on the platform.
const List<String> serviceCategories = [
  'Navigation assistance',
  'Cultural information',
  'Local recommendations',
  'Translation assistance',
  'Local experiences',
  'Activity assistance',
];
