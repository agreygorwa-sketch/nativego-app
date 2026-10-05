import 'package:flutter/material.dart';
import '../data/mock_repository.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'my_requests.dart';

/// Form for a tourist to request a service from a provider.
class RequestFormScreen extends StatefulWidget {
  final ProviderProfile profile;
  const RequestFormScreen({super.key, required this.profile});

  @override
  State<RequestFormScreen> createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  late String _serviceType;
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _serviceType = widget.profile.services.isNotEmpty
        ? widget.profile.services.first
        : serviceCategories.first;
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final repo = NativeGoRepo();
    final me = repo.currentUser;
    if (me == null) return;
    if (_descCtrl.text.trim().isEmpty) {
      showSnack(context, 'Please describe what you need.');
      return;
    }
    repo.createRequest(
      touristId: me.id,
      providerId: widget.profile.userId,
      serviceType: _serviceType,
      description: _descCtrl.text.trim(),
      latitude: widget.profile.latitude,
      longitude: widget.profile.longitude,
    );
    showSnack(context, 'Request sent! The provider will respond soon.');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MyRequestsScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerUser =
        NativeGoRepo().userById(widget.profile.userId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request service'),
        backgroundColor: const Color(0xFF0E7C5B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Requesting: ${providerUser?.name ?? 'Provider'}',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Text('Service needed',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _serviceType,
              decoration:
                  const InputDecoration(border: OutlineInputBorder()),
              items: widget.profile.services
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _serviceType = v ?? _serviceType),
            ),
            const SizedBox(height: 16),
            const Text('Describe what you need',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'e.g. I need help finding the Maasai Market and bargaining for souvenirs, about 2 hours.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on,
                      color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your current location will be shared with the provider once they accept.',
                      style: TextStyle(
                          color: Colors.blue.shade900, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E7C5B),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Send request',
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
