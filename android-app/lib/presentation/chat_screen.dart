import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/models/chat_message.dart';
import 'chat_state_notifier.dart';
import 'providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Check for pending prompt from other screens (e.g. PromptsScreen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pendingPrompt = ref.read(promptSelectedProvider);
      if (pendingPrompt != null && pendingPrompt.isNotEmpty) {
        _messageController.text = pendingPrompt;
        ref.read(promptSelectedProvider.notifier).clearPrompt();
        _sendMessage(pendingPrompt);
      } else {
        // Scroll to bottom if there are existing messages
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Small delay to ensure list is rendered
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        }
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    final chatState = ref.read(chatProvider);
    if (text.trim().isEmpty || chatState.isLoading) return;

    _messageController.clear();

    // Use the provider to send message
    final selectedStateAbbr = ref.read(selectedStateProvider);
    await ref.read(chatProvider.notifier).sendMessage(text, selectedStateAbbr);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Conversation?'),
        content: const Text(
            'This will remove all messages from the current session.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(chatProvider.notifier).clearChat();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _saveChat() {
    final chatState = ref.read(chatProvider);
    if (chatState.messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No conversation to save.')),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('Pocket Lawyer Conversation Log');
    buffer.writeln('Date: ${DateTime.now().toString()}\n');

    for (final msg in chatState.messages) {
      buffer.writeln(
          msg.isUser ? 'You: ${msg.content}' : 'Pocket Lawyer: ${msg.content}');
      if (!msg.isUser && msg.sources != null && msg.sources!.isNotEmpty) {
        buffer.writeln('Sources:');
        for (final source in msg.sources!) {
          buffer.writeln('- ${source.citation}');
        }
      }
      buffer.writeln('-' * 20);
    }

    Share.share(buffer.toString(), subject: 'Pocket Lawyer Conversation');
  }

  @override
  Widget build(BuildContext context) {
    final selectedStateAbbr = ref.watch(selectedStateProvider);
    final selectedStateName = abbrToStateName[selectedStateAbbr] ?? 'Colorado';
    final theme = Theme.of(context);

    // Watch the chat state
    final chatState = ref.watch(chatProvider);
    final messages = chatState.messages;
    final isLoading = chatState.isLoading;

    // Listen for selected prompts and auto-send them
    ref.listen<String?>(promptSelectedProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        _messageController.text = next;
        ref.read(promptSelectedProvider.notifier).clearPrompt();
        Future.delayed(const Duration(milliseconds: 100), () {
          _sendMessage(next);
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jeffrey - Pro', style: TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF5D5CDE),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Save Conversation',
            onPressed: _saveChat,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Chat',
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.indigo.shade50]),
              border: Border(bottom: BorderSide(color: Colors.blue.shade200)),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.blue.shade100),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: const Center(
                      child: Icon(Icons.account_balance,
                          size: 20, color: Color(0xFF5D5CDE))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildPulsingLiveIndicator(),
                          const SizedBox(width: 8),
                          Text('Direct Connection to Official Law Libraries',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                  fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                          'Jeffrey is online & connected to real-time legal sources to guide you.',
                          style: TextStyle(
                              color: Colors.blue.shade800, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.yellow.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Important: This provides legal information with source citations, not legal advice. All responses are encrypted end-to-end.',
                    style:
                        TextStyle(fontSize: 11, color: Colors.yellow.shade900),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.gavel,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                            'Ask Jeffrey anything about $selectedStateName law',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                              'I will search 8M+ court cases and 500K+ statutes to find your answer.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade500)),
                        ),
                        const SizedBox(height: 24),
                        Text('Or browse prompts for common questions',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && isLoading) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(messages[index], theme);
                    },
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2))
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask Jeffrey about $selectedStateName law...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                    enabled: !isLoading,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  heroTag: "chatSendFab",
                  onPressed: isLoading
                      ? null
                      : () => _sendMessage(_messageController.text),
                  backgroundColor:
                      isLoading ? Colors.grey : const Color(0xFF5D5CDE),
                  mini: true,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Icon(Icons.send, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingLiveIndicator() {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, double value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.shade400,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(1.0 - value),
                blurRadius: 4 + (value * 4),
                spreadRadius: value * 3,
              )
            ],
          ),
        );
      },
      onEnd: () {},
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypingDot(0),
            const SizedBox(width: 4),
            _buildTypingDot(1),
            const SizedBox(width: 4),
            _buildTypingDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, double value, child) {
        final animValue = (value - (index * 0.15)).clamp(0.0, 1.0);
        return Opacity(
          opacity: 0.3 + (animValue * 0.7),
          child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: Colors.grey.shade600, shape: BoxShape.circle)),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color(0xFF5D5CDE)
              : (theme.brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isUser)
              Text(message.content, style: const TextStyle(color: Colors.white))
            else
              MarkdownBody(
                data: message.content,
                styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87)),
              ),
            if (message.sources != null && message.sources!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text('Sources:',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: message.sources!
                    .map((source) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.indigo.shade100,
                              border: Border.all(color: Colors.indigo.shade300),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(source.citation,
                              style: TextStyle(
                                  fontSize: 10, color: Colors.indigo.shade900)),
                        ))
                    .toList(),
              ),
            ],
            if (message.confidence != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Confidence',
                      style: TextStyle(
                          fontSize: 11,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54)),
                  Text('${(message.confidence! * 100).round()}%',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: message.confidence,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      message.confidence! > 0.8
                          ? Colors.green
                          : (message.confidence! > 0.6
                              ? Colors.orange
                              : Colors.red)),
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
