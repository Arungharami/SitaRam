import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../l10n/app_localizations.dart';
import '../models/chapter.dart';
import '../services/content_service.dart';
import '../theme.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final Chapter chapter;
  const ReaderScreen({super.key, required this.chapter});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _fontSize = 16.0;

  // Audio player parameters
  late AudioPlayer _audioPlayer;
  bool _isAudioPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String _audioLanguage = 'en'; // default English
  bool _isAudioLoading = false;
  String? _audioError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _audioPlayer = AudioPlayer();

    // Stream listeners
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isAudioPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _position = Duration.zero;
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.pause();
          }
        });
      }
    });

    _audioPlayer.durationStream.listen((d) {
      if (mounted && d != null) {
        setState(() {
          _duration = d;
        });
      }
    });

    _audioPlayer.positionStream.listen((p) {
      if (mounted) {
        setState(() {
          _position = p;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.stop(); // Safe release
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initAndPlayAudio() async {
    final audioDetail = _audioLanguage == 'en' ? widget.chapter.audioEnglish : widget.chapter.audioBangla;

    setState(() {
      _isAudioLoading = true;
      _audioError = null;
    });

    try {
      await _audioPlayer.setAsset(audioDetail.audioFile);
      await _audioPlayer.play();
    } catch (e) {
      setState(() {
        _audioError = "Audio file not found locally. To test, upload an MP3 file to '${audioDetail.audioFile}' inside the project assets folder.";
        _isAudioLoading = false;
      });
      debugPrint("Error loading asset audio: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isAudioLoading = false;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_isAudioPlaying) {
      _audioPlayer.pause();
    } else {
      if (_duration == Duration.zero) {
        _initAndPlayAudio();
      } else {
        _audioPlayer.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final meta = widget.chapter.sourceMetadata;

    return Scaffold(
      backgroundColor: AppTheme.maroonBg,
      appBar: AppBar(
        title: Text('${widget.chapter.kanda} - Chapter ${widget.chapter.chapterNumber}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Text scaling button
          IconButton(
            icon: const Icon(Icons.format_size, size: 18),
            onPressed: () {
              setState(() {
                _fontSize = _fontSize == 16.0 ? 20.0 : (_fontSize == 20.0 ? 24.0 : 16.0);
              });
            },
          ),
          // AI context sync button
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, size: 18, color: AppTheme.goldAccent),
            onPressed: () {
              ref.read(activeChapterProvider.notifier).state = widget.chapter;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.saffronPrimary,
                  content: Text(l10n.readerAiSnackbar),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.saffronPrimary,
          labelColor: AppTheme.saffronPrimary,
          unselectedLabelColor: AppTheme.textDimMaroon,
          tabs: [
            Tab(text: l10n.readerTabEnglish),
            Tab(text: l10n.readerTabBangla),
            Tab(text: l10n.readerTabSpanish),
            Tab(text: l10n.readerTabInsights),
            Tab(text: l10n.readerTabAudio),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEnglishTab(meta),
          _buildBanglaTab(meta),
          _buildSpanishTab(l10n, meta),
          _buildInsightsTab(l10n, meta),
          _buildAudioTab(l10n),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.saffronPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.auto_awesome_rounded),
        label: Text(l10n.readerAskAiGuide),
        onPressed: () {
          ref.read(activeChapterProvider.notifier).state = widget.chapter;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppTheme.saffronPrimary,
              content: Text(l10n.readerAiSnackbar),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnglishTab(SourceMetadata meta) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.chapter.chapterTitleEnglish,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.softCreamText),
          ),
          const SizedBox(height: 16),
          Text(
            widget.chapter.englishText,
            style: TextStyle(fontSize: _fontSize, height: 1.6, color: AppTheme.softCreamText),
          ),
          const SizedBox(height: 40),
          _buildSourceCard(meta, isBangla: false),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSpanishTab(AppLocalizations l10n, SourceMetadata meta) {
    if (widget.chapter.spanishText.isEmpty) {
      return Center(child: Text(l10n.readerSpanishNotLoaded, style: const TextStyle(color: AppTheme.textDimMaroon)));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.chapter.chapterTitleSpanish.isNotEmpty
                ? widget.chapter.chapterTitleSpanish
                : widget.chapter.chapterTitleEnglish,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.devotionalCardDecoration(),
            child: Text(
              widget.chapter.spanishText,
              style: TextStyle(fontSize: _fontSize, height: 1.6, color: AppTheme.softCreamText),
            ),
          ),
          const SizedBox(height: 40),
          _buildSourceCard(meta, isBangla: false),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBanglaTab(SourceMetadata meta) {
    if (widget.chapter.chapterTitleBangla.isEmpty) {
      return const Center(child: Text('Bangla translation not loaded.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.chapter.chapterTitleBangla,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.devotionalCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'অনুবাদ ও ব্যাখ্যা (Translation & Explanation):',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.saffronPrimary, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.chapter.banglaText,
                  style: TextStyle(fontSize: _fontSize, height: 1.6, color: AppTheme.softCreamText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildSourceCard(meta, isBangla: true),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(AppLocalizations l10n, SourceMetadata meta) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // English Summary Card
          _buildInsightSection(
            title: l10n.readerEnglishSummary,
            icon: Icons.summarize_rounded,
            color: AppTheme.saffronPrimary,
            content: widget.chapter.shortSummaryEnglish,
          ),
          const SizedBox(height: 16),

          // Bangla Summary Card
          if (widget.chapter.shortSummaryBangla.isNotEmpty) ...[
            _buildInsightSection(
              title: 'সারসংক্ষেপ (Bangla Summary)',
              icon: Icons.short_text_rounded,
              color: AppTheme.goldAccent,
              content: widget.chapter.shortSummaryBangla,
            ),
            const SizedBox(height: 16),
          ],

          // Moral Lesson Card
          _buildInsightSection(
            title: l10n.readerMoralLesson,
            icon: Icons.workspace_premium_rounded,
            color: AppTheme.goldAccent,
            content: widget.chapter.moralLessonEnglish,
          ),
          const SizedBox(height: 16),

          if (widget.chapter.moralLessonBangla.isNotEmpty) ...[
            _buildInsightSection(
              title: 'নৈতিক শিক্ষা (Bangla Moral)',
              icon: Icons.star_border_purple500_rounded,
              color: AppTheme.saffronPrimary,
              content: widget.chapter.moralLessonBangla,
            ),
            const SizedBox(height: 24),
          ],

          // Characters
          Text(l10n.readerCharactersPresent, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.softCreamText)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.chapter.characters.map((c) {
              return Chip(
                avatar: CircleAvatar(
                  backgroundColor: AppTheme.goldAccent.withValues(alpha: 0.2),
                  child: Text(c[0], style: const TextStyle(fontSize: 10, color: AppTheme.goldAccent)),
                ),
                label: Text(c),
                backgroundColor: AppTheme.cardBgMaroon,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Themes
          Text(l10n.readerThemesPrinciples, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.softCreamText)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.chapter.themes.map((t) {
              return Chip(
                label: Text('#$t'),
                backgroundColor: Colors.teal.withValues(alpha: 0.12),
                labelStyle: const TextStyle(color: Colors.tealAccent),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          _buildSourceCard(meta, isBangla: false),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildInsightSection({required String title, required IconData icon, required Color color, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.devotionalCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
            ],
          ),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(color: AppTheme.softCreamText, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSourceCard(SourceMetadata meta, {required bool isBangla}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBgMaroon,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBangla ? 'উৎস ও তথ্য নিরাপত্তা (Source & Review Info)' : 'Source Safety & Verification Info',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDimMaroon),
          ),
          const SizedBox(height: 10),
          _buildSourceText('Source Book:', widget.chapter.sourceTitle),
          _buildSourceText('Translator:', meta.authorTranslator),
          _buildSourceText('Publication Year:', meta.publicationYear?.toString() ?? '1891'),
          _buildSourceText('Copyright Status:', widget.chapter.sourceStatus),
          _buildSourceText('Review Status:', widget.chapter.reviewStatus),
          _buildSourceText('Approved By:', meta.reviewerName ?? 'SitaRam Team'),
          _buildSourceText('Approval Date:', meta.approvalDate ?? '2026-06-10'),
        ],
      ),
    );
  }

  Widget _buildSourceText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.textDimMaroon)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 11, color: AppTheme.softCreamText))),
        ],
      ),
    );
  }

  Widget _buildAudioTab(AppLocalizations l10n) {
    final audioDetail = _audioLanguage == 'en' ? widget.chapter.audioEnglish : widget.chapter.audioBangla;
    final isPlaceholder = audioDetail.status == 'placeholder';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.saffronPrimary.withValues(alpha: 0.12),
              border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3), width: 2),
            ),
            child: Icon(
              Icons.audiotrack_rounded,
              size: 70,
              color: _isAudioPlaying ? AppTheme.goldAccent : AppTheme.textDimMaroon,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            _audioLanguage == 'en' ? widget.chapter.chapterTitleEnglish : widget.chapter.chapterTitleBangla,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.softCreamText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Type: ${audioDetail.voiceType}',
            style: const TextStyle(fontSize: 13, color: AppTheme.textDimMaroon),
          ),
          const SizedBox(height: 24),

          // Lang selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.readerAudioTrack, style: const TextStyle(color: AppTheme.textDimMaroon)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _audioLanguage,
                dropdownColor: AppTheme.cardBgMaroon,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English narration')),
                  DropdownMenuItem(value: 'bn', child: Text('Bangla explanation')),
                ],
                onChanged: (lang) {
                  if (lang != null) {
                    setState(() {
                      _audioLanguage = lang;
                      _audioPlayer.stop();
                      _duration = Duration.zero;
                      _position = Duration.zero;
                      _audioError = null;
                    });
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 20),

          // Safe placeholder banner (Priority 1 & 8)
          if (isPlaceholder)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.goldAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.goldAccent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Audiobook MP3 file is currently missing. To test, upload an MP3 to "${audioDetail.audioFile}".',
                      style: const TextStyle(fontSize: 11, color: AppTheme.softCreamText),
                    ),
                  ),
                ],
              ),
            ),

          if (_audioError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                _audioError!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),

          // Scrubber
          Slider(
            activeColor: AppTheme.saffronPrimary,
            inactiveColor: Colors.white10,
            value: _position.inSeconds.toDouble(),
            max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 100.0,
            onChanged: (val) {
              _audioPlayer.seek(Duration(seconds: val.toInt()));
            },
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position), style: const TextStyle(fontSize: 12, color: AppTheme.textDimMaroon)),
                Text(_formatDuration(_duration), style: const TextStyle(fontSize: 12, color: AppTheme.textDimMaroon)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Player Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.speed_rounded, color: AppTheme.textDimMaroon),
                onPressed: () {
                  final currentSpeed = _audioPlayer.speed;
                  final nextSpeed = currentSpeed == 1.0 ? 1.25 : (currentSpeed == 1.25 ? 1.5 : (currentSpeed == 1.5 ? 0.75 : 1.0));
                  _audioPlayer.setSpeed(nextSpeed);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      backgroundColor: AppTheme.cardBgMaroon,
                      content: Text('Speed: ${nextSpeed}x'),
                    ),
                  );
                },
              ),
              const SizedBox(width: 20),
              
              GestureDetector(
                onTap: _isAudioLoading ? null : _togglePlayPause,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.saffronGoldGradient,
                  ),
                  child: _isAudioLoading
                      ? const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : Icon(
                          _isAudioPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 34,
                          color: Colors.white,
                        ),
                ),
              ),
              const SizedBox(width: 20),

              IconButton(
                icon: const Icon(Icons.replay_rounded, color: AppTheme.textDimMaroon),
                onPressed: () {
                  _audioPlayer.seek(Duration.zero);
                  _audioPlayer.pause();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
