import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/chat_message.dart';
import '../domain/models/legal_source.dart';
import 'providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    setState(() {
      _messages.add(
          ChatMessage(content: text, isUser: true, timestamp: DateTime.now()));
      _isLoading = true;
      _messageController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      final ragRepository = ref.read(ragRepositoryProvider);
      final selectedStateAbbr = ref.read(selectedStateProvider);
      final response =
          await ragRepository.performRAGQuery(text, selectedStateAbbr);

      setState(() {
        _messages.add(ChatMessage(
          content: response['content'] as String,
          isUser: false,
          timestamp: DateTime.now(),
          sources: (response['sources'] as List?)
              ?.map((s) => LegalSource.fromJson(s as Map<String, dynamic>))
              .toList(),
          confidence: response['confidence'] as double?,
        ));
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

      // Track successful chat for review prompt (after 3 successful chats)
      final viralService = ref.read(viralGrowthServiceProvider);
      viralService.requestReview();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          content:
              'Error: ${e.toString()}\n\nCheck API credentials or rephrase.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedStateAbbr = ref.watch(selectedStateProvider);
    final selectedStateName = abbrToStateName[selectedStateAbbr] ?? 'Colorado';
    final theme = Theme.of(context);

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
              height: 40,
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pocket Lawyer Pro', style: TextStyle(fontSize: 18)),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF5D5CDE),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.purple.shade50]),
              border: Border(bottom: BorderSide(color: Colors.blue.shade200)),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.blue.shade500, Colors.purple.shade600]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                      child: Text('🧠', style: TextStyle(fontSize: 16))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Advanced Legal RAG System',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                              fontSize: 13)),
                      Text(
                          'Powered by GPT-4o-mini with real-time legal database access',
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
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('Ask me anything about $selectedStateName law',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Text('Or browse prompts for common questions',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(_messages[index], theme);
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
                      hintText: 'Ask about $selectedStateName law...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  heroTag: "chatSendFab",
                  onPressed: _isLoading
                      ? null
                      : () => _sendMessage(_messageController.text),
                  backgroundColor:
                      _isLoading ? Colors.grey : const Color(0xFF5D5CDE),
                  mini: true,
                  child: _isLoading
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
