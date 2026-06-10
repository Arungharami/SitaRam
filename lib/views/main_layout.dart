import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/content_service.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'research_dashboard.dart';
import 'ai_chat_screen.dart';
import 'donation_screen.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Preload chapters and set default active chapter
    ref.read(chaptersListProvider.future).then((chapters) {
      if (chapters.isNotEmpty && ref.read(activeChapterProvider) == null) {
        ref.read(activeChapterProvider.notifier).state = chapters.first;
      }
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeChapter = ref.watch(activeChapterProvider);

    final List<Widget> tabs = [
      const HomeScreen(),
      const ResearchDashboard(),
      activeChapter != null
          ? AiChatScreen(chapter: activeChapter)
          : const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.saffronPrimary),
              ),
            ),
      const DonationScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.templeObsidian,
        selectedItemColor: AppTheme.saffronPrimary,
        unselectedItemColor: AppTheme.textDimMaroon,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chrome_reader_mode_outlined),
            activeIcon: Icon(Icons.chrome_reader_mode_rounded),
            label: 'Kandas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore_rounded),
            label: 'Research',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome_rounded),
            label: 'AI Guide',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline_rounded),
            activeIcon: Icon(Icons.favorite_rounded),
            label: 'Support',
          ),
        ],
      ),
    );
  }
}
