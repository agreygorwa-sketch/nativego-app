import 'package:flutter/material.dart';
import '../data/mock_repository.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'chat_screen.dart';
import 'review_screen.dart';

/// Tourist's list of service requests with status tracking.
class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = NativeGoRepo();
    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final me = repo.currentUser;
        if (me == null) return const Scaffold();
        final list = repo.requestsForTourist(me.id);
        return Scaffold(
          appBar: AppBar(
            title: const Text('My requests'),
            backgroundColor: const Color(0xFF0E7C5B),
            foregroundColor: Colors.white,
          ),
          body: list.isEmpty
              ? const EmptyState(
                  icon: Icons.receipt_long,
                  message:
                      'No requests yet. Find a local provider and send your first request.',
                )
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final r = list[i];
                    final providerUser = repo.userById(r.providerId);
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(r.serviceType,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                                '${providerUser?.name ?? 'Provider'} \u2022 ${r.description}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            StatusChip(status: r.status),
                          ],
                        ),
                        trailing:
                            const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  RequestDetailScreen(request: r),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

/// Detail of one request: status timeline, actions, chat entry, review entry.
class RequestDetailScreen extends StatelessWidget {
  final ServiceRequest request;
  const RequestDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final repo = NativeGoRepo();
    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final r = repo.requestById(request.id) ?? request;
        final providerUser = repo.userById(r.providerId);
        final profile = repo.profileOf(r.providerId);
        final me = repo.currentUser;
        final canReview = r.status == RequestStatus.completed &&
            me != null &&
            !repo.hasReviewed(r.id);
        return Scaffold(
          appBar: AppBar(
            title: Text(r.serviceType),
            backgroundColor: const Color(0xFF0E7C5B),
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF0E7C5B),
                      child: Text(
                        (providerUser?.name ?? '?')
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(providerUser?.name ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)),
                          if (profile != null)
                            StarRating(
                                rating: profile.ratingAvg),
                        ],
                      ),
                    ),
                    StatusChip(status: r.status),
                  ],
                ),
                const SizedBox(height: 16),
                Text(r.description,
                    style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 16),
                const Text('Progress',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                _timeline(r.status),
                const SizedBox(height: 20),
                if (r.status == RequestStatus.accepted ||
                    r.status == RequestStatus.inProgress)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        repo.updateRequestStatus(
                            r.id, RequestStatus.inProgress);
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start service'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF0E7C5B),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (r.status == RequestStatus.inProgress)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        repo.updateRequestStatus(
                            r.id, RequestStatus.completed);
                        showSnack(context,
                            'Service marked complete. Please leave a review!');
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Mark as complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (canReview)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReviewScreen(
                                request: r),
                          ),
                        );
                      },
                      icon: const Icon(Icons.star_border),
                      label: const Text('Write a review'),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ChatScreen(request: r),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Chat with provider'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _timeline(RequestStatus status) {
    const steps = [
      (RequestStatus.pending, 'Sent'),
      (RequestStatus.accepted, 'Accepted'),
      (RequestStatus.inProgress, 'In progress'),
      (RequestStatus.completed, 'Completed'),
    ];
    final order = RequestStatus.values;
    final currentIdx = order.indexOf(status);
    return Column(
      children: steps.map((s) {
        final idx = order.indexOf(s.$1);
        final done = idx <= currentIdx &&
            status != RequestStatus.cancelled;
        return Row(
          children: [
            Icon(
              done ? Icons.check_circle : Icons.circle_outlined,
              color: done
                  ? const Color(0xFF0E7C5B)
                  : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(s.$2,
                style: TextStyle(
                    color: done
                        ? Colors.black87
                        : Colors.grey.shade500,
                    fontWeight:
                        done ? FontWeight.w600 : null)),
          ],
        );
      }).toList(),
    );
  }
}
