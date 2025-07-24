import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../utils/theme.dart';
import 'dashboard_screen.dart';
import 'tasks_screen.dart';
import 'success_screen.dart';
import 'profile_screen.dart';
import 'projects_screen.dart';
import 'mood_screen.dart';
import 'challenges_screen.dart';
import 'community_screen.dart';
import 'learning_screen.dart';
import 'analytics_screen.dart';
import 'calendar_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TasksScreen(),
    const ProjectsScreen(),
    const SuccessScreen(),
    const MoodScreen(),
    const ChallengesScreen(),
    const CommunityScreen(),
    const LearningScreen(),
    const AnalyticsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      drawer: _buildDrawer(context),
      bottomNavigationBar: _currentIndex < 4 ? Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(0, Iconsax.home, 'Accueil'),
                _buildBottomNavItem(1, Iconsax.task_square, 'Tâches'),
                _buildBottomNavItem(2, Iconsax.folder, 'Projets'),
                _buildBottomNavItem(3, Iconsax.star, 'Succès'),
              ],
            ),
          ),
        ),
      ) : null,
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.psychology,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  'ConfidenceBoost',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Votre compagnon de développement',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(4, Iconsax.heart, 'Suivi humeur', () => _navigateToPage(4)),
          _buildDrawerItem(5, Iconsax.flash, 'Défis quotidiens', () => _navigateToPage(5)),
          _buildDrawerItem(6, Iconsax.people, 'Communauté', () => _navigateToPage(6)),
          _buildDrawerItem(7, Iconsax.book, 'Apprentissage', () => _navigateToPage(7)),
          _buildDrawerItem(8, Iconsax.chart, 'Statistiques', () => _navigateToPage(8)),
          const Divider(),
          _buildDrawerItem(9, Iconsax.profile_circle, 'Mon Profil', () => _navigateToPage(9)),
          _buildDrawerItem(-1, Iconsax.calendar, 'Calendrier', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalendarScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String title, VoidCallback onTap) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _navigateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}