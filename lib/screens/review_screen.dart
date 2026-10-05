import 'package:flutter/material.dart';
import '../data/mock_repository.dart';
import '../models/models.dart';
import '../widgets/common.dart';

/// Tourist rates the provider after a completed service.
class ReviewScreen extends StatefulWidget {
  final ServiceRequest request;
  const ReviewScreen({super.key, required this.request});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final repo = NativeGoRepo();
    final me = repo.currentUser;
    if (me == null) return;
    repo.submitReview(
      requestId: widget.request.id,
      providerId: widget.request.providerId,
      touristId: me.id,
      touristName: me.name,
      rating: _rating,
      comment: _commentCtrl.text.trim(),
    );
    showSnack(context, 'Thank you! Your review was submitted.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final providerUser =
        NativeGoRepo().userById(widget.request.providerId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write a review'),
        backgroundColor: const Color(0xFF0E7C5B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How was your experience with ${providerUser?.name ?? 'the provider'}?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            StarPicker(
              initial: _rating,
              onChanged: (v) => setState(() => _rating = v),
            ),
            const SizedBox(height: 8),
            Text(
              '$_rating out of 5',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Your review (optional)',
                hintText:
                    'What did you enjoy? Would you recommend them?',
                border: OutlineInputBorder(),
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
              child: const Text('Submit review',
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
