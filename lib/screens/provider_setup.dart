import 'package:flutter/material.dart';
import '../data/mock_repository.dart';
import '../models/models.dart';
import '../widgets/common.dart';

/// Provider sets up their public profile and submits verification documents.
class ProviderSetupScreen extends StatefulWidget {
  const ProviderSetupScreen({super.key});

  @override
  State<ProviderSetupScreen> createState() => _ProviderSetupScreenState();
}

class _ProviderSetupScreenState extends State<ProviderSetupScreen> {
  late TextEditingController _bioCtrl;
  late TextEditingController _rateCtrl;
  late TextEditingController _langsCtrl;
  late Set<String> _services;
  bool _docsSubmitted = false;

  @override
  void initState() {
    super.initState();
    final repo = NativeGoRepo();
    final profile = repo.profileOf(repo.currentUser!.id);
    _bioCtrl = TextEditingController(text: profile?.bio ?? '');
    _rateCtrl = TextEditingController(
        text: (profile?.hourlyRate ?? 0).toStringAsFixed(0));
    _langsCtrl = TextEditingController(
        text: (profile?.languages ?? []).join(', '));
    _services = Set.of(profile?.services ?? []);
    _docsSubmitted = profile?.documentsSubmitted ?? false;
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _rateCtrl.dispose();
    _langsCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final repo = NativeGoRepo();
    final me = repo.currentUser;
    if (me == null) return;
    final profile = repo.profileOf(me.id);
    if (profile == null) return;
    repo.updateProviderProfile(
      profile.providerId,
      bio: _bioCtrl.text.trim(),
      languages: _langsCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      services: _services.toList(),
      hourlyRate: double.tryParse(_rateCtrl.text.trim()) ?? 0,
    );
    showSnack(context, 'Profile saved.');
    Navigator.of(context).pop();
  }

  void _submitDocs() {
    final repo = NativeGoRepo();
    final me = repo.currentUser;
    if (me == null) return;
    final profile = repo.profileOf(me.id);
    if (profile == null) return;
    // Prototype: document upload is simulated; production stores the files
    // in Firebase Storage and records their URLs on the provider profile.
    repo.submitVerificationDocuments(profile.providerId);
    setState(() => _docsSubmitted = true);
    showSnack(context,
        'Documents submitted for verification. An administrator will review them.');
  }

  @override
  Widget build(BuildContext context) {
    final repo = NativeGoRepo();
    final profile = repo.profileOf(repo.currentUser!.id);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My provider profile'),
        backgroundColor: const Color(0xFF0E7C5B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (profile != null) ...[
              Row(
                children: [
                  const Text('Verification: ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  VerificationChip(
                      status: profile.verificationStatus),
                ],
              ),
              const SizedBox(height: 16),
            ],
            const Text('About you',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _bioCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'Tell tourists who you are and what you offer...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Services you offer',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: serviceCategories.map((s) {
                final selected = _services.contains(s);
                return FilterChip(
                  label: Text(s),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _services.add(s);
                    } else {
                      _services.remove(s);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Languages (comma separated)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _langsCtrl,
              decoration: const InputDecoration(
                hintText: 'English, Swahili',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Hourly rate (Ksh)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _rateCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixText: 'Ksh ',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E7C5B),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Save profile',
                  style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
            const Text('Identity verification',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'Upload a national ID and any tour-guide licence. An administrator reviews every submission before your profile becomes visible to tourists.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _docsSubmitted ? null : _submitDocs,
              icon: const Icon(Icons.upload_file),
              label: Text(_docsSubmitted
                  ? 'Documents submitted'
                  : 'Submit verification documents'),
            ),
          ],
        ),
      ),
    );
  }
}
