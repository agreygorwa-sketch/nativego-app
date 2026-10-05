import 'package:flutter/material.dart';
import '../data/mock_repository.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'auth_screen.dart';

/// Administrator: verification queue, users, reports, statistics.
class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _tab = 0;

  void _logout() {
    NativeGoRepo().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = NativeGoRepo();
    final tabs = ['Verification', 'Users', 'Reports', 'Stats'];
    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Admin panel'),
          backgroundColor: const Color(0xFF0E7C5B),
          foregroundColor: Colors.white,
          actions: [
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
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                itemCount: tabs.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tabs[i]),
                    selected: _tab == i,
                    onSelected: (_) =>
                        setState(() => _tab = i),
                  ),
                ),
              ),
            ),
            Expanded(
              child: [
                _verificationTab(repo),
                _usersTab(repo),
                _reportsTab(repo),
                _statsTab(repo),
              ][_tab],
            ),
          ],
        ),
      ),
    );
  }

  Widget _verificationTab(NativeGoRepo repo) {
    final pending = repo.pendingVerifications();
    if (pending.isEmpty) {
      return const EmptyState(
        icon: Icons.verified,
        message: 'No providers waiting for verification.',
      );
    }
    return ListView.builder(
      itemCount: pending.length,
      itemBuilder: (context, i) {
        final p = pending[i];
        final user = repo.userById(p.userId);
        return Card(
          margin:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.name ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
                const SizedBox(height: 4),
                Text('Email: ${user?.email ?? ''}'),
                Text('Phone: ${user?.phone ?? ''}'),
                Text(
                    'Documents: ${p.documentsSubmitted ? 'submitted' : 'not submitted'}'),
                Text('Services: ${p.services.join(', ')}'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          repo.approveProvider(p.providerId);
                          showSnack(context,
                              '${user?.name} verified and now visible to tourists.');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF0E7C5B),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Approve'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          repo.rejectProvider(p.providerId);
                          showSnack(context,
                              '${user?.name} verification rejected.');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _usersTab(NativeGoRepo repo) {
    return ListView.builder(
      itemCount: repo.users.length,
      itemBuilder: (context, i) {
        final u = repo.users[i];
        final isProvider = u.role == Role.provider;
        final profile =
            isProvider ? repo.profileOf(u.id) : null;
        return Card(
          margin:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: u.role == Role.admin
                  ? Colors.purple
                  : const Color(0xFF0E7C5B),
              child: Text(u.name.substring(0, 1).toUpperCase(),
                  style:
                      const TextStyle(color: Colors.white)),
            ),
            title: Text(u.name),
            subtitle: Text(
                '${u.email}\nRole: ${u.role.name}${profile != null ? ' \u2022 ${verificationLabel(profile.verificationStatus)}' : ''}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _reportsTab(NativeGoRepo repo) {
    final open =
        repo.reports.where((r) => !r.resolved).toList();
    if (open.isEmpty) {
      return const EmptyState(
        icon: Icons.flag,
        message: 'No open reports. All clear.',
      );
    }
    return ListView.builder(
      itemCount: open.length,
      itemBuilder: (context, i) {
        final r = open[i];
        return Card(
          margin:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reported: ${r.reportedUserName}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600)),
                Text('By: ${r.reporterName}',
                    style:
                        TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 6),
                Text(r.reason),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      repo.resolveReport(r.id);
                      showSnack(
                          context, 'Report marked as resolved.');
                    },
                    child: const Text('Mark resolved'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statsTab(NativeGoRepo repo) {
    final verified = repo.providers
        .where((p) =>
            p.verificationStatus ==
            VerificationStatus.approved)
        .length;
    final stats = [
      ('Registered users', repo.users.length, Icons.people),
      ('Verified providers', verified, Icons.verified),
      ('Service requests', repo.requests.length, Icons.receipt_long),
      ('Reviews submitted', repo.reviews.length, Icons.star),
      ('Open reports',
          repo.reports.where((r) => !r.resolved).length, Icons.flag),
    ];
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: stats
          .map((s) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(s.$3,
                          size: 32,
                          color:
                              const Color(0xFF0E7C5B)),
                      const SizedBox(height: 8),
                      Text('${s.$2}',
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold)),
                      Text(s.$1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}
