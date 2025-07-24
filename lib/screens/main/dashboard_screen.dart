import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/success_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/mood_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/pomodoro_timer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh data
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 400),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildQuickStats(context),
                    const SizedBox(height: 24),
                    _buildTodayAffirmation(context),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildTodayTasks(context),
                    const SizedBox(height: 24),
                    _buildRecentSuccesses(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final firstName = user?.name.split(' ').first ?? 'Utilisateur';
        final timeOfDay = _getTimeOfDay();
        
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$timeOfDay $firstName !',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(DateTime.now()),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Iconsax.profile_circle,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer5<TaskProvider, SuccessProvider, UserProvider, ChallengeProvider, MoodProvider>(
      builder: (context, taskProvider, successProvider, userProvider, challengeProvider, moodProvider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Tâches du jour',
                '${taskProvider.todayTasks.length}',
                Iconsax.task_square,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Succès enregistrés',
                '${successProvider.successes.length}',
                Iconsax.star,
                AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Défis terminés',
                '${challengeProvider.completedChallenges.length}',
                Iconsax.flash,
                AppTheme.warningColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAffirmation(BuildContext context) {
    return Consumer2<UserProvider, ChallengeProvider>(
      builder: (context, userProvider, challengeProvider, child) {
        final todayChallenge = challengeProvider.todayChallenge;
        final affirmations = userProvider.defaultAffirmations;
        final todayAffirmation = affirmations[DateTime.now().day % affirmations.length];
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(
                Iconsax.flash,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                todayChallenge != null ? 'Défi du jour' : 'Affirmation du jour',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                todayChallenge?.title ?? todayAffirmation,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              if (todayChallenge != null) ...[
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to challenges screen
                    Scaffold.of(context).openDrawer();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Voir le défi'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Nouvelle tâche',
                Iconsax.add_circle,
                AppTheme.primaryColor,
                () => _showAddTaskDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                'Nouveau succès',
                Iconsax.star,
                AppTheme.secondaryColor,
                () => _showAddSuccessDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                'Timer Pomodoro',
                Iconsax.timer,
                AppTheme.accentColor,
                () => _showPomodoroTimer(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTasks(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final todayTasks = taskProvider.todayTasks.take(3).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tâches d\'aujourd\'hui',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (todayTasks.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // Navigate to tasks screen
                    },
                    child: const Text('Voir tout'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (todayTasks.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Iconsax.task_square,
                      size: 48,
                      color: AppTheme.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aucune tâche pour aujourd\'hui',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...todayTasks.map((task) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: task.status.index == 2 ? AppTheme.accentColor : Colors.transparent,
                        border: Border.all(
                          color: task.status.index == 2 ? AppTheme.accentColor : AppTheme.textSecondary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: task.status.index == 2 
                          ? const Icon(Icons.check, color: Colors.white, size: 12)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        task.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: task.status.index == 2 ? TextDecoration.lineThrough : null,
                          color: task.status.index == 2 ? AppTheme.textSecondary : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task.priority).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getPriorityText(task.priority),
                        style: TextStyle(
                          color: _getPriorityColor(task.priority),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          ],
        );
      },
    );
  }

  Widget _buildRecentSuccesses(BuildContext context) {
    return Consumer<SuccessProvider>(
      builder: (context, successProvider, child) {
        final recentSuccesses = successProvider.recentSuccesses.take(2).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Succès récents',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (recentSuccesses.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // Navigate to success screen
                    },
                    child: const Text('Voir tout'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentSuccesses.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Iconsax.star,
                      size: 48,
                      color: AppTheme.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Commencez à enregistrer vos succès !',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...recentSuccesses.map((success) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Iconsax.star,
                        color: AppTheme.secondaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            success.title,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d MMM yyyy').format(success.date),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(
                        success.confidenceImpact,
                        (index) => Icon(
                          Iconsax.star5,
                          size: 16,
                          color: AppTheme.warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          ],
        );
      },
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 17) return 'Bon après-midi';
    return 'Bonsoir';
  }

  Color _getPriorityColor(priority) {
    switch (priority.index) {
      case 0: return AppTheme.accentColor;
      case 1: return AppTheme.warningColor;
      case 2: return AppTheme.secondaryColor;
      case 3: return AppTheme.errorColor;
      default: return AppTheme.textSecondary;
    }
  }

  String _getPriorityText(priority) {
    switch (priority.index) {
      case 0: return 'Faible';
      case 1: return 'Moyenne';
      case 2: return 'Haute';
      case 3: return 'Urgente';
      default: return 'Normale';
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    // TODO: Implement add task dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité à venir')),
    );
  }

  void _showAddSuccessDialog(BuildContext context) {
    // TODO: Implement add success dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité à venir')),
    );
  }

  void _showPomodoroTimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PomodoroTimer(),
    );
  }
}