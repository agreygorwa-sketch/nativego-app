import 'package:flutter/material.dart';
import '../data/mock_repository.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'request_form.dart';

/// Full provider profile: bio, services, languages, reviews, request button.
class ProviderProfileScreen extends StatefulWidget {
  final ProviderProfile profile;
  const ProviderProfileScreen({super.key, required this.profile});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  void _report() {
    final repo = NativeGoRepo();
    final me = repo.currentUser;
    final providerUser = repo.userById(widget.profile.userId);
    if (me == null || providerUser == null) return;
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Report this provider'),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Describe the problem...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonCtrl.text.trim().isEmpty) return;
              repo.submitReport(
                reporterId: me.id,
                reporterName: me.name,
                reportedUserId: providerUser.id,
                reportedUserName: providerUser.name,
                reason: reasonCtrl.text.trim(),
              );
              Navigator.of(context).pop();
              showSnack(context,
                  'Report submitted. An administrator will review it.');
            },
            child: const Text('Submit report'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = NativeGoRepo();
    final p = widget.profile;
    final user = repo.userById(p.userId);
    final reviews = repo.reviewsForProvider(p.userId);
    return Scaffold(
      appBar: AppBar(
        title: Text(user?.name ?? 'Provider'),
        backgroundColor: const Color(0xFF0E7C5B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Report',
            onPressed: _report,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: repo,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFF0E7C5B),
                    child: Text(
                      (user?.name ?? '?').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? '',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        VerificationChip(
                            status: p.verificationStatus),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            StarRating(
                                rating: p.ratingAvg, size: 18),
                            Text('  ${p.reviewCount} reviews',
                                style: TextStyle(
                                    color: Colors.grey.shade600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(p.bio, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 16),
              const Text('Services',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: p.services
                    .map((s) => Chip(label: Text(s)))
                    .toList(),
              ),
              const SizedBox(height: 12),
              const Text('Languages',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: p.languages
                    .map((l) => Chip(
                          label: Text(l),
                          backgroundColor: Colors.blue.shade50,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.payments_outlined),
                  const SizedBox(width: 8),
                  Text(
                    'Ksh ${p.hourlyRate.toStringAsFixed(0)} per hour',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Reviews',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              if (reviews.isEmpty)
                Text('No reviews yet.',
                    style: TextStyle(color: Colors.grey.shade600))
              else
                ...reviews.map((r) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(
                                child: Text(r.touristName,
                                    style: const TextStyle(
                                        fontWeight:
                                            FontWeight.w600))),
                            StarRating(rating: r.rating.toDouble()),
                          ],
                        ),
                        subtitle: Text(r.comment),
                      ),
                    )),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => RequestFormScreen(profile: p)),
          );
        },
        backgroundColor: const Color(0xFF0E7C5B),
        icon: const Icon(Icons.send, color: Colors.white),
        label: const Text('Request service',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
