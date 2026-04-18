import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../core/mixpanel_service.dart';
import '../domain/models/chat_message.dart';
import 'chat_state_notifier.dart';
import 'providers.dart';

// Avatar images
const String _avatarIdle = 'assets/images/jeffrey_05.png';
const String _avatarActive = 'assets/images/jeffrey_gold_06.png';

// Style icons mapping
const Map<ResponseStyle, IconData> _styleIcons = {
  ResponseStyle.standard: Icons.balance,
  ResponseStyle.quickCasual: Icons.flash_on,
  ResponseStyle.detailed: Icons.article,
  ResponseStyle.justFacts: Icons.fact_check,
  ResponseStyle.explainLikeFive: Icons.child_care,
};

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

    // Track search/query event
    MixpanelService.track('Search', {
      'search_query': text.trim(),
      'query_length': text.length,
    });

    _messageController.clear();

    final selectedStateAbbr = ref.read(selectedStateProvider);
    final selectedJurisdiction = ref.read(selectedJurisdictionProvider);
    final selectedCounty = ref.read(selectedCountyProvider);
    final selectedPlan = ref.read(selectedPlanProvider);
    final userName = ref.read(userNameProvider);
    final lawyerName = ref.read(lawyerNameProvider);
    final ageRange = ref.read(userAgeRangeProvider);
    final useCases = ref.read(userUseCasesProvider);
    await ref.read(chatProvider.notifier).sendMessage(
          text,
          selectedStateAbbr,
          jurisdiction: selectedJurisdiction,
          county: selectedCounty,
          plan: selectedPlan,
          userName: userName,
          lawyerName: lawyerName,
          ageRange: ageRange,
          useCases: useCases,
        );

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

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Answer copied.')),
    );
  }

  void _setFollowUpDraft() {
    _messageController.text =
        'Can you explain that more simply and tell me what I should do first?';
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: _messageController.text.length),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Follow-up question added to the input.')),
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

  void _showStyleSelector() {
    final currentStyle = ref.read(responseStyleProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How should Jeffrey respond?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StyleOption(
              label: 'Standard',
              description: 'Balanced - like a lawyer friend',
              style: ResponseStyle.standard,
              currentStyle: currentStyle,
            ),
            const Divider(height: 1),
            _StyleOption(
              label: 'Quick & Casual',
              description: 'Brief and conversational',
              style: ResponseStyle.quickCasual,
              currentStyle: currentStyle,
            ),
            const Divider(height: 1),
            _StyleOption(
              label: 'Detailed',
              description: 'Comprehensive deep dive',
              style: ResponseStyle.detailed,
              currentStyle: currentStyle,
            ),
            const Divider(height: 1),
            _StyleOption(
              label: 'Just the Facts',
              description: 'Objective and neutral',
              style: ResponseStyle.justFacts,
              currentStyle: currentStyle,
            ),
            const Divider(height: 1),
            _StyleOption(
              label: "Explain Like I'm 5",
              description: 'Simple analogies',
              style: ResponseStyle.explainLikeFive,
              currentStyle: currentStyle,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateSummary() async {
    final chatState = ref.read(chatProvider);
    final messages = chatState.messages;

    final userQuestions = <String>[];
    final aiResponses = <String>[];

    for (final msg in messages) {
      if (msg.isUser) {
        userQuestions.add(msg.content);
      } else {
        aiResponses.add(msg.content);
      }
    }

    if (userQuestions.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No conversation to summarize yet.')),
      );
      return;
    }

    // Show loading dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Summarizing...'),
          ],
        ),
      ),
    );

    try {
      final chatUseCase = ref.read(chatUseCaseProvider);
      final summary = await chatUseCase.generateConversationSummary(
        userQuestions,
        aiResponses,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Show summary dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Conversation Summary'),
          content: SingleChildScrollView(
            child: MarkdownBody(data: summary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: summary));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Summary copied to clipboard!')),
                );
              },
              child: const Text('Copy'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating summary: $e')),
      );
    }
  }

  void _quickActionSimplifier(ChatMessage message) {
    _messageController.text = 'Can you explain that in simpler terms?';
    _setFollowUpDraft();
  }

  void _quickActionPrioritize(ChatMessage message) {
    _messageController.text = 'What should I do first?';
    _setFollowUpDraft();
  }

  Future<void> _submitFeedback(ChatMessage message, bool isPositive) async {
    if (isPositive) {
      // Track positive feedback
      MixpanelService.track('Response Feedback', {
        'feedback_type': 'positive',
        'message_length': message.content.length,
        'has_sources': message.sources?.isNotEmpty ?? false,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanks for the feedback!'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    // For negative feedback, ask why
    if (!mounted) return;
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help us improve'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What was wrong with this response?'),
            const SizedBox(height: 16),
            _FeedbackOption(
              icon: Icons.error_outline,
              label: 'Inaccurate information',
              onTap: () => Navigator.of(context).pop('inaccurate'),
            ),
            _FeedbackOption(
              icon: Icons.text_snippet,
              label: 'Too complex/legalese',
              onTap: () => Navigator.of(context).pop('too_complex'),
            ),
            _FeedbackOption(
              icon: Icons.short_text,
              label: 'Not enough detail',
              onTap: () => Navigator.of(context).pop('not_enough_detail'),
            ),
            _FeedbackOption(
              icon: Icons.content_paste_off,
              label: 'Missing citations',
              onTap: () => Navigator.of(context).pop('no_citations'),
            ),
            _FeedbackOption(
              icon: Icons.help_outline,
              label: 'Other',
              onTap: () => Navigator.of(context).pop('other'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (reason != null) {
      // Track negative feedback with reason
      MixpanelService.track('Response Feedback', {
        'feedback_type': 'negative',
        'reason': reason,
        'message_length': message.content.length,
        'has_sources': message.sources?.isNotEmpty ?? false,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanks for your feedback! We\'ll work on improving.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedStateAbbr = ref.watch(selectedStateProvider);
    final selectedStateName = abbrToStateName[selectedStateAbbr] ?? 'Colorado';
    final selectedJurisdiction = ref.watch(selectedJurisdictionProvider);
    final selectedCounty = ref.watch(selectedCountyProvider);
    final selectedPlan = ref.watch(selectedPlanProvider);
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

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.gavel,
                            size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: 14),
                        Text(
                            'Ask Jeffrey anything about $selectedStateName law',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Text(
                            'Plain-English answers pulled from real legal sources.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade500)),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _QuickPromptChip(
                              label: 'Can my landlord keep my deposit?',
                              onTap: () => _sendMessage(
                                  'Can my landlord keep my security deposit in $selectedStateName? Explain it in plain English.'),
                            ),
                            _QuickPromptChip(
                              label: 'What happens if I miss court?',
                              onTap: () => _sendMessage(
                                  'What happens if I miss a court date in $selectedStateName? Keep it simple and practical.'),
                            ),
                            _QuickPromptChip(
                              label: 'Can my boss fire me for this?',
                              onTap: () => _sendMessage(
                                  'Can my employer fire me for reporting a problem in $selectedStateName? Explain my options simply.'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Not legal advice • Info with source citations',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade400)),
                      ],
                    ),
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
          ),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              if (messages.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      size: 20, color: Colors.grey.shade500),
                  onPressed: _clearChat,
                  tooltip: 'Clear chat',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              // Response style toggle
              if (messages.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.tune, size: 20, color: Colors.grey.shade500),
                  onPressed: _showStyleSelector,
                  tooltip: 'Response style',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              // Summary button (only for long conversations)
              if (messages.length >= 10)
                IconButton(
                  icon: Icon(Icons.summarize, size: 20, color: Colors.grey.shade500),
                  onPressed: _generateSummary,
                  tooltip: 'Summarize conversation',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Ask about $selectedStateName law...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _sendMessage,
                  enabled: !isLoading,
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                heroTag: 'chatSendFab',
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
    final agentState = ref.watch(agentStateProvider);
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(18)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with pulse effect
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                _avatarActive,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStateDot('Researching', agentState == AgentState.researching),
                    const SizedBox(width: 6),
                    _buildStateDot('Analyzing', agentState == AgentState.analyzing),
                    const SizedBox(width: 6),
                    _buildStateDot('Answering', agentState == AgentState.answering),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getStateLabel(agentState),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStateLabel(AgentState state) {
    switch (state) {
      case AgentState.researching:
        return 'Looking up the law...';
      case AgentState.analyzing:
        return 'Making sense of it...';
      case AgentState.answering:
        return 'Almost there...';
      default:
        return 'Thinking...';
    }
  }

  Widget _buildStateDot(String label, bool isActive) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(label + isActive.toString()),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? const Color(0xFF5D5CDE).withOpacity(0.3 + (value * 0.7))
                : Colors.grey.shade300,
          ),
        );
      },
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
    final lawyerName = ref.watch(lawyerNameProvider);

    if (message.isUser) {
      // User message - keep original style
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: const BoxDecoration(
            color: Color(0xFF5D5CDE),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            message.content,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Jeffrey's message with avatar
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              _avatarIdle,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header badge
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                        theme.brightness == Brightness.dark ? 0.08 : 0.55,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$lawyerName\'s answer',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                  // Message content
                  MarkdownBody(
                    data: message.content,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                        height: 1.45,
                      ),
                    ),
                  ),
                  // Sources
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
                                constraints: const BoxConstraints(maxWidth: 260),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.grey.shade700
                                      : Colors.white,
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.menu_book, size: 14),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        source.citation,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: theme.brightness == Brightness.dark
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  // Confidence score
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (message.confidence! > 0.8
                                    ? Colors.green
                                    : (message.confidence! > 0.6
                                        ? Colors.orange
                                        : Colors.red))
                                .withOpacity(0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('${(message.confidence! * 100).round()}%',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: message.confidence! > 0.8
                                      ? Colors.green.shade800
                                      : (message.confidence! > 0.6
                                          ? Colors.orange.shade800
                                          : Colors.red.shade800))),
                        ),
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
                  // Action buttons
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _copyMessage(message.content),
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _setFollowUpDraft,
                        icon: const Icon(Icons.reply, size: 16),
                        label: const Text('Ask follow-up'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _quickActionSimplifier(message),
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: const Text('Simpler'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _quickActionPrioritize(message),
                        icon: const Icon(Icons.flag, size: 16),
                        label: const Text('First step?'),
                      ),
                    ],
                  ),
                  // Feedback thumbs up/down
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Was this helpful?',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white60
                              : Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _submitFeedback(message, true),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.thumb_up, size: 14, color: Colors.green.shade700),
                              const SizedBox(width: 4),
                              Text(
                                'Good',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _submitFeedback(message, false),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.thumb_down, size: 14, color: Colors.red.shade700),
                              const SizedBox(width: 4),
                              Text(
                                'Not helpful',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Follow-up suggestion chips
                  if (message.followUpSuggestions != null &&
                      message.followUpSuggestions!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                          theme.brightness == Brightness.dark ? 0.08 : 0.55,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Suggested follow-ups:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: theme.brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: message.followUpSuggestions!.take(3).map((suggestion) {
                        return InkWell(
                          onTap: () => _sendMessage(suggestion),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF5D5CDE).withOpacity(0.12),
                                  const Color(0xFF7878F2).withOpacity(0.08),
                                ],
                              ),
                              border: Border.all(
                                color: const Color(0xFF5D5CDE).withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_forward,
                                  size: 14,
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white70
                                      : const Color(0xFF5D5CDE),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    suggestion,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickPromptChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickPromptChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      avatar:
          Icon(Icons.auto_awesome, size: 16, color: theme.colorScheme.primary),
      label: Text(label, style: TextStyle(color: theme.colorScheme.onSurface)),
      onPressed: onTap,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
      side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.18)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _StyleOption extends StatelessWidget {
  final String label;
  final String description;
  final ResponseStyle style;
  final ResponseStyle currentStyle;

  const _StyleOption({
    required this.label,
    required this.description,
    required this.style,
    required this.currentStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentStyle == style;
    final ref = ProviderScope.containerOf(context);

    return InkWell(
      onTap: () {
        ref.read(responseStyleProvider.notifier).state = style;
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected
            ? const Color(0xFF5D5CDE).withOpacity(0.08)
            : Colors.transparent,
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF5D5CDE) : Colors.grey.shade400,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF5D5CDE) : null,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeedbackOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(
            theme.brightness == Brightness.dark ? 0.08 : 0.55,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: theme.colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
