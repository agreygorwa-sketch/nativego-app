import 'package:flutter/material.dart';
import '../data/mock_repository.dart';
import '../models/models.dart';

/// Per-request chat between tourist and provider.
class ChatScreen extends StatefulWidget {
  final ServiceRequest request;
  const ChatScreen({super.key, required this.request});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final repo = NativeGoRepo();
    final me = repo.currentUser;
    if (me == null) return;
    repo.sendMessage(widget.request.id, me.id, _ctrl.text);
    _ctrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = NativeGoRepo();
    final otherUser = repo.userById(widget.request.providerId);
    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final me = repo.currentUser;
        final msgs = repo.messagesFor(widget.request.id);
        return Scaffold(
          appBar: AppBar(
            title: Text(otherUser?.name ?? 'Chat'),
            backgroundColor: const Color(0xFF0E7C5B),
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              Expanded(
                child: msgs.isEmpty
                    ? const Center(
                        child: Text(
                          'No messages yet. Say hello!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(12),
                        itemCount: msgs.length,
                        itemBuilder: (context, i) {
                          final m = msgs[i];
                          final mine =
                              me != null && m.senderId == me.id;
                          return Align(
                            alignment: mine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(bottom: 8),
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context)
                                            .size
                                            .width *
                                        0.75,
                              ),
                              decoration: BoxDecoration(
                                color: mine
                                    ? const Color(0xFF0E7C5B)
                                    : Colors.grey.shade200,
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                              child: Text(
                                m.text,
                                style: TextStyle(
                                  color: mine
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _send,
                        icon: const Icon(Icons.send),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF0E7C5B),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
