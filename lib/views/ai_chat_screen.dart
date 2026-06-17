import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/chapter.dart';
import '../providers/locale_provider.dart';
import '../services/ai_service.dart';
import '../theme.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  final Chapter chapter;
  const AiChatScreen({super.key, required this.chapter});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  List<Map<String, String>> _getSuggestedPrompts(AppLocalizations l10n) => [
    {"label": l10n.aiGuidePrompt1, "query": l10n.aiGuidePrompt1},
    {"label": l10n.aiGuidePrompt2, "query": l10n.aiGuidePrompt2},
    {"label": l10n.aiGuidePrompt3, "query": l10n.aiGuidePrompt3},
    {"label": l10n.aiGuidePrompt4, "query": l10n.aiGuidePrompt4},
    {"label": l10n.aiGuidePrompt5, "query": l10n.aiGuidePrompt5},
    {"label": l10n.aiGuidePrompt6, "query": l10n.aiGuidePrompt6},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _resetWelcomeMessage();
    });
  }

  @override
  void didUpdateWidget(covariant AiChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapter.id != widget.chapter.id) {
      setState(() {
        _messages.clear();
        _resetWelcomeMessage();
      });
    }
  }

  void _resetWelcomeMessage() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _messages.clear();
      _messages.add({
        'role': 'assistant',
        'text': l10n.aiGuideWelcome(
          widget.chapter.kanda,
          widget.chapter.chapterTitleEnglish,
        ),
      });
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendCustomMessage() async {
    final text = _questionController.text.trim();
    if (text.isEmpty) return;
    _questionController.clear();
    await _executeMessage(text);
  }

  Future<void> _executeMessage(String text) async {
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });
    _scrollToBottom();

    final aiService = ref.read(aiServiceProvider);
    final langCode = ref.read(localeProvider).languageCode;
    final response = await aiService.askAi(widget.chapter, text, languageCode: langCode);

    if (mounted) {
      setState(() {
        _messages.add({'role': 'assistant', 'text': response});
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _showApiKeyDialog() async {
    final aiService = ref.read(aiServiceProvider);
    final currentKey = await aiService.getApiKey() ?? '';
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final keyController = TextEditingController(text: currentKey);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBgMaroon,
          title: const Row(
            children: [
              Icon(Icons.vpn_key_rounded, color: AppTheme.goldAccent),
              SizedBox(width: 10),
              Flexible(
                child: Text('Gemini API Settings',
                    style: TextStyle(fontSize: 18, color: AppTheme.softCreamText)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.aiGuideApiKeyInfo,
                style: const TextStyle(fontSize: 12, color: AppTheme.textDimMaroon),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: keyController,
                obscureText: true,
                style: const TextStyle(color: AppTheme.softCreamText),
                decoration: InputDecoration(
                  hintText: l10n.aiGuideApiKeyHint,
                  hintStyle: const TextStyle(color: AppTheme.textDimMaroon),
                  filled: true,
                  fillColor: AppTheme.templeObsidian,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                aiService.deleteApiKey();
                ref.invalidate(geminiApiKeyProvider);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.aiGuideApiKeyDeleted)),
                );
              },
              child: Text(l10n.aiGuideApiKeyDelete, style: const TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.saffronPrimary),
              onPressed: () {
                final key = keyController.text.trim();
                if (key.isNotEmpty) {
                  aiService.saveApiKey(key);
                  ref.invalidate(geminiApiKeyProvider);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.aiGuideApiKeySaved)),
                  );
                }
              },
              child: Text(l10n.aiGuideApiKeySave, style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final apiKeyAsync = ref.watch(geminiApiKeyProvider);
    final hasKey = apiKeyAsync.maybeWhen(
      data: (key) => key != null && key.isNotEmpty,
      orElse: () => false,
    );
    final prompts = _getSuggestedPrompts(l10n);

    return Scaffold(
      backgroundColor: AppTheme.maroonBg,
      appBar: AppBar(
        title: Text(l10n.aiGuideTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.vpn_key_rounded,
                color: hasKey ? AppTheme.goldAccent : AppTheme.textDimMaroon),
            onPressed: _showApiKeyDialog,
            tooltip: 'Gemini API Key',
          )
        ],
      ),
      body: Column(
        children: [
          // Safety disclaimer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.orange.withValues(alpha: 0.08),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.goldAccent, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.aiGuideDisclaimer,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.softCreamText.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active chapter context banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.templeObsidian,
            child: Row(
              children: [
                const Icon(Icons.auto_stories_rounded, color: AppTheme.saffronPrimary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.aiGuideContextLabel(
                      widget.chapter.chapterTitleEnglish,
                      widget.chapter.kanda,
                    ),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.softCreamText),
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return _buildMessageBubble(l10n, msg['text'] ?? '', isUser);
              },
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: AppTheme.saffronPrimary, strokeWidth: 2),
                ),
              ),
            ),

          // Suggested prompts
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            color: AppTheme.templeObsidian,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: prompts.length,
              itemBuilder: (context, index) {
                final prompt = prompts[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    backgroundColor: AppTheme.cardBgMaroon,
                    side: const BorderSide(color: AppTheme.goldAccent, width: 0.8),
                    label: Text(
                      prompt['label']!,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.goldAccent, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _isLoading ? null : () => _executeMessage(prompt['query']!),
                  ),
                );
              },
            ),
          ),

          // Input panel
          Container(
            padding: const EdgeInsets.all(12),
            color: AppTheme.templeObsidian,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    style: const TextStyle(color: AppTheme.softCreamText),
                    decoration: InputDecoration(
                      hintText: l10n.aiGuideInputHint,
                      hintStyle: const TextStyle(color: AppTheme.textDimMaroon, fontSize: 13),
                      filled: true,
                      fillColor: AppTheme.maroonBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendCustomMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.saffronPrimary,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                    onPressed: _isLoading ? null : _sendCustomMessage,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AppLocalizations l10n, String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: isUser
              ? AppTheme.saffronPrimary.withValues(alpha: 0.12)
              : AppTheme.cardBgMaroon,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
          ),
          border: Border.all(
            color: isUser
                ? AppTheme.saffronPrimary.withValues(alpha: 0.3)
                : AppTheme.goldAccent.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUser ? Icons.person_outline : Icons.auto_awesome_rounded,
                  size: 11,
                  color: isUser ? AppTheme.saffronPrimary : AppTheme.goldAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  isUser ? l10n.aiGuideResearcher : l10n.aiGuideBotName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isUser ? AppTheme.saffronPrimary : AppTheme.goldAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.softCreamText),
            ),
          ],
        ),
      ),
    );
  }
}
