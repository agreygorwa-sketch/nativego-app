import 'package:flutter/material.dart';
import '../models/models.dart';

/// Shared building blocks used across NativeGo screens.

class StatusChip extends StatelessWidget {
  final RequestStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case RequestStatus.pending:
        bg = Colors.amber.shade100;
        fg = Colors.amber.shade900;
        break;
      case RequestStatus.accepted:
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade900;
        break;
      case RequestStatus.inProgress:
        bg = Colors.purple.shade100;
        fg = Colors.purple.shade900;
        break;
      case RequestStatus.completed:
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        break;
      case RequestStatus.cancelled:
        bg = Colors.red.shade100;
        fg = Colors.red.shade900;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        requestStatusLabel(status),
        style: TextStyle(
            color: fg, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class VerificationChip extends StatelessWidget {
  final VerificationStatus status;
  const VerificationChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final verified = status == VerificationStatus.approved;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: verified ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.verified : Icons.hourglass_empty,
            size: 14,
            color: verified
                ? Colors.green.shade900
                : Colors.orange.shade900,
          ),
          const SizedBox(width: 4),
          Text(
            verificationLabel(status),
            style: TextStyle(
              color: verified
                  ? Colors.green.shade900
                  : Colors.orange.shade900,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  const StarRating({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: Colors.amber.shade700, size: size),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: size - 2),
        ),
      ],
    );
  }
}

/// Interactive 1-5 star picker used on the review screen.
class StarPicker extends StatefulWidget {
  final int initial;
  final ValueChanged<int> onChanged;
  const StarPicker({super.key, this.initial = 5, required this.onChanged});

  @override
  State<StarPicker> createState() => _StarPickerState();
}

class _StarPickerState extends State<StarPicker> {
  late int _value;
  @override
  void initState() {
    super.initState();
    _value = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = i < _value;
        return IconButton(
          icon: Icon(
            filled ? Icons.star : Icons.star_border,
            color: Colors.amber.shade700,
            size: 36,
          ),
          onPressed: () {
            setState(() => _value = i + 1);
            widget.onChanged(_value);
          },
        );
      }),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
