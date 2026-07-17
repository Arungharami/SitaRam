import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/chapter.dart';
import '../models/ai_response.dart';
import '../models/citation.dart';
import '../providers/locale_provider.dart';
import '../services/ai_service.dart';
import '../theme.dart';
import 'reader_screen.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  final Chapter chapter;
  const AiChatScreen({super.key, required this.chapter});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class ChatMessage {
  final String role;
  final String text;
  final List<Citation> citations;
  final String interpretationLabel;
  final List<String> limitations;

  ChatMessage({
    required this.role,
    required this.text,
    this.citations = const [],
    this.interpretationLabel = '',
    this.limitations = const [],
  });
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  
  // RAG Mode: student vs research
  String _ragMode = 'student'; 

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
      _messages.add(ChatMessage(
        role: 'assistant',
        text: l10n.aiGuideWelcome(
          widget.chapter.kanda,
          widget.chapter.chapterTitleEnglish,
        ),
      ));
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
      _messages.add(ChatMessage(role: 'user', text: text));
      _isLoading = true;
    });
    _scrollToBottom();

    final aiService = ref.read(aiServiceProvider);
    final langCode = ref.read(localeProvider).languageCode;
    
    try {
      final aiResponse = await aiService.askRAG(
        question: text,
        languageCode: langCode,
        mode: _ragMode,
        kandaId: widget.chapter.kandaId,
      );

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            role: 'assistant',
            text: aiResponse.answer,
            citations: aiResponse.citations,
            interpretationLabel: aiResponse.interpretationLabel,
            limitations: aiResponse.limitations,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            role: 'assistant',
            text: "Failed to receive response from backend: $e",
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  // Feedback modal
  void _showFeedbackDialog(ChatMessage msg) {
    String selectedReason = 'citation_correct';
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBgMaroon,
          title: const Row(
            children: [
              Icon(Icons.feedback_rounded, color: AppTheme.goldAccent),
              SizedBox(width: 8),
              Text('Submit Feedback', style: TextStyle(color: AppTheme.softCreamText, fontSize: 18)),
            ],
          ),
          content: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Help us improve the RAG safety and accuracy guardrails:',
                    style: TextStyle(color: AppTheme.textDimMaroon, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<String>(
                    dropdownColor: AppTheme.cardBgMaroon,
                    value: selectedReason,
                    isExpanded: true,
                    style: const TextStyle(color: AppTheme.softCreamText),
                    items: const [
                      DropdownMenuItem(value: 'citation_correct', child: Text('Accurate citation')),
                      DropdownMenuItem(value: 'incorrect_citation', child: Text('Incorrect Kanda/Sarga citation')),
                      DropdownMenuItem(value: 'translation_problem', child: Text('Translation wording issue')),
                      DropdownMenuItem(value: 'safety_concern', child: Text('Disrespectful / ungrounded claim')),
                      DropdownMenuItem(value: 'too_complicated', child: Text('Response too complicated')),
                      DropdownMenuItem(value: 'too_simple', child: Text('Response too simple')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedReason = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    maxLines: 2,
                    style: const TextStyle(color: AppTheme.softCreamText),
                    decoration: InputDecoration(
                      hintText: 'Additional comments (optional)',
                      hintStyle: const TextStyle(color: AppTheme.textDimMaroon),
                      fillColor: AppTheme.templeObsidian,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textDimMaroon)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.saffronPrimary),
              onPressed: () async {
                final aiService = ref.read(aiServiceProvider);
                await aiService.submitFeedback(
                  feedbackId: DateTime.now().millisecondsSinceEpoch.toString(),
                  questionId: 'q_id',
                  answerId: 'a_id',
                  rating: selectedReason == 'citation_correct' ? 'helpful' : 'unhelpful',
                  reason: selectedReason,
                  comment: commentController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppTheme.saffronPrimary,
                      content: Text('Feedback successfully submitted. Thank you!'),
                    ),
                  );
                }
              },
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prompts = _getSuggestedPrompts(l10n);

    return Scaffold(
      backgroundColor: AppTheme.maroonBg,
      appBar: AppBar(
        title: Text(l10n.aiGuideTitle),
        actions: [
          // Study Mode selector (Student vs Research)
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: DropdownButton<String>(
              value: _ragMode,
              dropdownColor: AppTheme.cardBgMaroon,
              underline: const SizedBox(),
              style: const TextStyle(color: AppTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 13),
              icon: const Icon(Icons.psychology_outlined, color: AppTheme.goldAccent, size: 18),
              items: const [
                DropdownMenuItem(value: 'student', child: Text('Student ')),
                DropdownMenuItem(value: 'research', child: Text('Research ')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _ragMode = val;
                  });
                }
              },
            ),
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

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.role == 'user';
                return _buildMessageBubble(l10n, msg, isUser);
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

  Widget _buildMessageBubble(AppLocalizations l10n, ChatMessage msg, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.86),
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
              mainAxisAlignment: MainAxisAlignment.between,
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
                // Render label if present
                if (!isUser && msg.interpretationLabel.isNotEmpty)
                  Text(
                    msg.interpretationLabel,
                    style: const TextStyle(fontSize: 8, color: AppTheme.textDimMaroon, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              msg.text,
              style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.softCreamText),
            ),
            
            // Citation Cards (Tappable cards)
            if (!isUser && msg.citations.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white10),
              const Text(
                'EVIDENCE & CITATIONS:',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.goldAccent),
              ),
              const SizedBox(height: 6),
              ...msg.citations.map((citation) {
                return InkWell(
                  onTap: () {
                    // Navigate to ReaderScreen directly using the active list
                    final chapters = ref.read(chaptersListProvider).value;
                    if (chapters != null) {
                      final targetChapter = chapters.firstWhere(
                        (ch) => ch.chapterNumber == citation.sarga && ch.kandaId.toLowerCase() == citation.kanda.toLowerCase().replaceFirst(' ', '_'),
                        orElse: () => chapters.first,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReaderScreen(chapter: targetChapter)),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.templeObsidian,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bookmark_added_rounded, color: AppTheme.goldAccent, size: 12),
                            const SizedBox(width: 6),
                            Text(
                              '${citation.kanda} · Sarga ${citation.sarga}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          citation.quotedText,
                          style: const TextStyle(fontSize: 10, color: AppTheme.textDimMaroon, fontStyle: FontStyle.italic),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],

            // Feedback and limitations buttons
            if (!isUser && msg.text.startsWith('Jai') == false) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.thumb_up_alt_outlined, size: 14, color: AppTheme.textDimMaroon),
                    onPressed: () => _showFeedbackDialog(msg),
                    tooltip: 'Helpful',
                  ),
                  IconButton(
                    icon: const Icon(Icons.thumb_down_alt_outlined, size: 14, color: AppTheme.textDimMaroon),
                    onPressed: () => _showFeedbackDialog(msg),
                    tooltip: 'Report issue / feedback',
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}
