import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scroll = ScrollController();
  String _otherUid = '';
  String _otherName = 'Chat';

  @override
  void initState() {
    super.initState();
    // Parse conversationId to get other user
    final parts = widget.conversationId.split('_');
    final myUid = ref.read(currentUserProvider).valueOrNull?.uid ?? '';
    _otherUid = parts.firstWhere((p) => p != myUid, orElse: () => parts.last);
    _otherName = 'User';
  }

  @override
  void dispose() { _msgCtrl.dispose(); _scroll.dispose(); super.dispose(); }

  Future<void> _send() async {
    final msg = _msgCtrl.text.trim();
    if (msg.isEmpty) return;
    _msgCtrl.clear();
    await ref.read(chatNotifierProvider.notifier).sendMessage(
      conversationId: widget.conversationId, toUid: _otherUid, message: msg,
    );
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider(widget.conversationId)).valueOrNull ?? [];
    final myUid = ref.watch(currentUserProvider).valueOrNull?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(radius: 16, backgroundColor: AppColors.primary.withOpacity(0.1), child: Text(AppUtils.getInitials(_otherName), style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_otherName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const Text('Online', style: TextStyle(fontSize: 11, color: AppColors.success)),
          ]),
        ]),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: Column(children: [
        Expanded(
          child: messages.isEmpty
              ? const AppEmptyState(icon: Icons.chat_bubble_outline_rounded, title: 'No messages yet', subtitle: 'Start the conversation!')
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final m = messages[i];
                    final isMe = m.fromUid == myUid;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe) ...[
                            CircleAvatar(radius: 14, backgroundColor: AppColors.primary.withOpacity(0.1), child: Text(AppUtils.getInitials(m.fromName), style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600))),
                            const SizedBox(width: 8),
                          ],
                          Flexible(child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primary : AppColors.card,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isMe ? 16 : 4), bottomRight: Radius.circular(isMe ? 4 : 16),
                              ),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                              if (!isMe) Text(m.fromName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                              Text(m.message, style: TextStyle(fontSize: 14, color: isMe ? Colors.white : AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text(AppUtils.timeAgo(m.sentAt), style: TextStyle(fontSize: 10, color: isMe ? Colors.white60 : AppColors.textSecondary)),
                            ]),
                          )),
                          if (isMe) ...[
                            const SizedBox(width: 8),
                            Icon(m.isRead ? Icons.done_all_rounded : Icons.done_rounded, size: 14, color: m.isRead ? AppColors.primary : AppColors.textSecondary),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 8),
          decoration: BoxDecoration(color: AppColors.card, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))]),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _msgCtrl,
              decoration: InputDecoration(hintText: 'Type a message...', contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), filled: true, fillColor: AppColors.inputFill),
              onSubmitted: (_) => _send(),
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(width: 44, height: 44, decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle), child: const Icon(Icons.send_rounded, color: Colors.white, size: 20)),
            ),
          ]),
        ),
      ]),
    );
  }
}
