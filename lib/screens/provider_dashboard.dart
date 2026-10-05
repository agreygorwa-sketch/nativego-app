import 'package:flutter/material.dart';
import '../data/mock_repository.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'auth_screen.dart';
import 'provider_setup.dart';
import 'chat_screen.dart';

/// Provider home: availability toggle, incoming requests, profile setup.
class ProviderDashboard extends StatelessWidget {
  const ProviderDashboard({super.key});

  void _logout(BuildContext context) {
    NativeGoRepo().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = NativeGoRepo();
    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final me = repo.currentUser;
        if (me == null) return const Scaffold();
        final profile = repo.profileOf(me.id);
        final incoming = repo.requestsForProvider(me.id);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Provider dashboard'),
            backgroundColor: const Color(0xFF0E7C5B),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                tooltip: 'My provider profile',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            const ProviderSetupScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Log out',
                onPressed: () => _logout(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profile != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Hello, ${me.name}',
                                        style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight:
                                                FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    VerificationChip(
                                        status: profile
                                            .verificationStatus),
                                  ],
                                ),
                              ),
                              if (profile.verificationStatus ==
                                  VerificationStatus.approved)
                                Column(
                                  children: [
                                    const Text('Available',
                                        style: TextStyle(
                                            fontSize: 12)),
                                    Switch(
                                      value: profile.available,
                                      onChanged: (v) =>
                                          repo.setAvailability(
                                              profile.providerId,
                                              v),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          if (profile.verificationStatus !=
                              VerificationStatus.approved)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Text(
                                profile.documentsSubmitted
                                    ? 'Your verification documents are under review. You will appear in tourist searches once approved.'
                                    : 'Complete your provider profile and submit verification documents to start receiving requests.',
                                style: TextStyle(
                                    color:
                                        Colors.orange.shade900,
                                    fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text('Incoming requests',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (incoming.isEmpty)
                  const EmptyState(
                    icon: Icons.inbox,
                    message:
                        'No requests yet. New requests from tourists will appear here.',
                  )
                else
                  ...incoming.map((r) {
                    final tourist = repo.userById(r.touristId);
                    return Card(
                      margin:
                          const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(r.serviceType,
                                      style: const TextStyle(
                                          fontWeight:
                                              FontWeight.w600,
                                          fontSize: 15)),
                                ),
                                StatusChip(status: r.status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                                '${tourist?.name ?? 'Tourist'}: ${r.description}'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (r.status ==
                                    RequestStatus.pending) ...[
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => repo
                                          .updateRequestStatus(
                                              r.id,
                                              RequestStatus
                                                  .accepted),
                                      style: ElevatedButton
                                          .styleFrom(
                                        backgroundColor:
                                            const Color(
                                                0xFF0E7C5B),
                                        foregroundColor:
                                            Colors.white,
                                      ),
                                      child:
                                          const Text('Accept'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => repo
                                          .updateRequestStatus(
                                              r.id,
                                              RequestStatus
                                                  .cancelled),
                                      child:
                                          const Text('Decline'),
                                    ),
                                  ),
                                ] else ...[
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ChatScreen(
                                                    request:
                                                        r),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                          Icons.chat_bubble_outline),
                                      label:
                                          const Text('Chat'),
                                    ),
                                  ),
                                  if (r.status ==
                                      RequestStatus
                                          .accepted) ...[
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => repo
                                            .updateRequestStatus(
                                                r.id,
                                                RequestStatus
                                                    .inProgress),
                                        style: ElevatedButton
                                            .styleFrom(
                                          backgroundColor:
                                              const Color(
                                                  0xFF0E7C5B),
                                          foregroundColor:
                                              Colors.white,
                                        ),
                                        child: const Text(
                                            'Start'),
                                      ),
                                    ),
                                  ],
                                  if (r.status ==
                                      RequestStatus
                                          .inProgress) ...[
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => repo
                                            .updateRequestStatus(
                                                r.id,
                                                RequestStatus
                                                    .completed),
                                        style: ElevatedButton
                                            .styleFrom(
                                          backgroundColor:
                                              Colors.green
                                                  .shade700,
                                          foregroundColor:
                                              Colors.white,
                                        ),
                                        child: const Text(
                                            'Complete'),
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}
