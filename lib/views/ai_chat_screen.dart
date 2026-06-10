import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chapter.dart';
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

  // Suggested prompts (Priority 4)
  final List<Map<String, String>> _suggestedPrompts = [
    {"label": "Explain simply", "query": "Explain simply"},
    {"label": "Moral lesson", "query": "Moral lesson"},
    {"label": "Explain in Bangla", "query": "Explain in Bangla"},
    {"label": "Character analysis", "query": "Character analysis"},
    {"label": "Modern life lesson", "query": "Modern life lesson"},
    {"label": "Research note", "query": "Research note"},
    {"label": "Child-friendly", "query": "Child-friendly explanation"},
  ];

  @override
  void initState() {
    super.initState();
    _resetWelcomeMessage();
  }

  @override
  void didUpdateWidget(covariant AiChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapter.id != widget.chapter.id) {
      // Clear chat logs and reset if the active chapter context changes!
      setState(() {
        _messages.clear();
        _resetWelcomeMessage();
      });
    }
  }

  void _resetWelcomeMessage() {
    _messages.add({
      'role': 'assistant',
      'text': 'Jai Shri Ram! I am your SITARAM AI research guide.\n\nI have loaded the context for **${widget.chapter.kanda} - ${widget.chapter.chapterTitleEnglish}**.\n\nYou can type a custom question below or tap any of the suggested research prompt buttons to explore!'
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
    final response = await aiService.askAi(widget.chapter, text);

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
              Text('Gemini API Settings', style: TextStyle(fontSize: 18, color: AppTheme.softCreamText)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your Gemini API key to enable live AI research queries. Keys are stored safely on your device.',
                style: TextStyle(fontSize: 12, color: AppTheme.textDimMaroon),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: keyController,
                obscureText: true,
                style: const TextStyle(color: AppTheme.softCreamText),
                decoration: InputDecoration(
                  hintText: 'Enter API Key...',
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
                  const SnackBar(content: Text('API Key deleted. Reset to simulation mode.')),
                );
              },
              child: const Text('Delete Key', style: TextStyle(color: Colors.redAccent)),
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
                    const SnackBar(content: Text('API Key saved successfully! Live AI activated.')),
                  );
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiKeyAsync = ref.watch(geminiApiKeyProvider);
    final hasKey = apiKeyAsync.maybeWhen(
      data: (key) => key != null && key.isNotEmpty,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: AppTheme.maroonBg,
      appBar: AppBar(
        title: const Text('AI Scripture Guide'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.vpn_key_rounded, 
              color: hasKey ? AppTheme.goldAccent : AppTheme.textDimMaroon
            ),
            onPressed: _showApiKeyDialog,
            tooltip: 'Configure Gemini API Key',
          )
        ],
      ),
      body: Column(
        children: [
          // 1. Mandatory safety disclaimer (Priority 4)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.orange.withOpacity(0.08),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.goldAccent, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'SITARAM AI Guide is for learning and reflection, not a religious authority.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.softCreamText.withOpacity(0.9)
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Active Chapter context banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.templeObsidian,
            child: Row(
              children: [
                const Icon(Icons.auto_stories_rounded, color: AppTheme.saffronPrimary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Context: ${widget.chapter.chapterTitleEnglish} (${widget.chapter.kanda})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.softCreamText),
                  ),
                ),
              ],
            ),
          ),

          // 3. Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return _buildMessageBubble(msg['text'] ?? '', isUser);
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

          // 4. Suggested Prompt Buttons (Priority 4)
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            color: AppTheme.templeObsidian,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _suggestedPrompts.length,
              itemBuilder: (context, index) {
                final prompt = _suggestedPrompts[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    backgroundColor: AppTheme.cardBgMaroon,
                    side: const BorderSide(color: AppTheme.goldAccent, width: 0.8),
                    label: Text(
                      prompt['label']!,
                      style: const TextStyle(fontSize: 11, color: AppTheme.goldAccent, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _isLoading ? null : () => _executeMessage(prompt['query']!),
                  ),
                );
              },
            ),
          ),

          // 5. Input panel
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
                      hintText: 'Ask custom research question...',
                      hintStyle: const TextStyle(color: AppTheme.textDimMaroon, fontSize: 13),
                      filled: true,
                      fillColor: AppTheme.maroonBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          )
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.saffronPrimary.withOpacity(0.12) : AppTheme.cardBgMaroon,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
          ),
          border: Border.all(
            color: isUser ? AppTheme.saffronPrimary.withOpacity(0.3) : AppTheme.goldAccent.withOpacity(0.25),
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
                  isUser ? 'Researcher' : 'SitaRam AI',
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
