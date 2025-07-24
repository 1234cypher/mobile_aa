import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../../providers/mood_provider.dart';
import '../../models/mood_entry.dart';
import '../../utils/theme.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Suivi de l\'humeur'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<MoodProvider>(
        builder: (context, moodProvider, child) {
          return SingleChildScrollView(
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
                    _buildTodayMoodCard(context, moodProvider),
                    const SizedBox(height: 24),
                    _buildWeeklyStats(context, moodProvider),
                    const SizedBox(height: 24),
                    _buildMoodHistory(context, moodProvider),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMoodDialog(context),
        backgroundColor: AppTheme.secondaryColor,
        child: const Icon(Iconsax.heart, color: Colors.white),
      ),
    );
  }

  Widget _buildTodayMoodCard(BuildContext context, MoodProvider moodProvider) {
    final todayMood = moodProvider.todayMood;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.secondaryColor, AppTheme.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Comment vous sentez-vous aujourd\'hui ?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 16),
          if (todayMood != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMoodIndicator('Humeur', todayMood.moodLevel, Iconsax.heart),
                _buildMoodIndicator('Motivation', todayMood.motivationLevel, Iconsax.flash),
                _buildMoodIndicator('Confiance', todayMood.confidenceLevel, Iconsax.star),
              ],
            ),
            if (todayMood.notes != null && todayMood.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  todayMood.notes!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ],
          ] else ...[
            Icon(
              Iconsax.heart,
              size: 48,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 12),
            Text(
              'Aucune entrée pour aujourd\'hui',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodIndicator(String label, int level, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          '$level/5',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyStats(BuildContext context, MoodProvider moodProvider) {
    final averageMood = moodProvider.averageMoodThisWeek;

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques de la semaine',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      averageMood.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor,
                          ),
                    ),
                    Text(
                      'Humeur moyenne',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.textSecondary.withOpacity(0.2),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${moodProvider.moodEntries.length}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    Text(
                      'Entrées totales',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodHistory(BuildContext context, MoodProvider moodProvider) {
    final entries = moodProvider.moodEntries.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique récent',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 16),
        if (entries.isEmpty)
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
                  Iconsax.heart,
                  size: 48,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucune entrée d\'humeur',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          )
        else
          ...entries.map((entry) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getMoodColor(entry.moodLevel).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        _getMoodIcon(entry.moodLevel),
                        color: _getMoodColor(entry.moodLevel),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE d MMMM', 'fr_FR').format(entry.date),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text('Humeur: ${entry.moodLevel}/5'),
                              const SizedBox(width: 16),
                              Text('Motivation: ${entry.motivationLevel}/5'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  Color _getMoodColor(int level) {
    switch (level) {
      case 1:
        return AppTheme.errorColor;
      case 2:
        return AppTheme.warningColor;
      case 3:
        return AppTheme.textSecondary;
      case 4:
        return AppTheme.primaryColor;
      case 5:
        return AppTheme.accentColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getMoodIcon(int level) {
    switch (level) {
      case 1:
        return Iconsax.emoji_sad;
      case 2:
        return Iconsax.emoji_normal;
      case 3:
        return Iconsax.emoji_normal;
      case 4:
        return Iconsax.emoji_happy;
      case 5:
        return Iconsax.heart;
      default:
        return Iconsax.emoji_normal;
    }
  }

  void _showAddMoodDialog(BuildContext context) {
    int moodLevel = 3;
    int motivationLevel = 3;
    int confidenceLevel = 3;
    final notesController = TextEditingController();
    List<String> selectedEmotions = [];
    List<String> selectedActivities = [];

    final emotions = ['Joyeuse', 'Calme', 'Énergique', 'Stressée', 'Fatiguée', 'Confiante', 'Anxieuse', 'Motivée'];
    final activities = ['Travail', 'Sport', 'Famille', 'Amis', 'Lecture', 'Méditation', 'Créativité', 'Repos'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Comment vous sentez-vous ?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMoodSlider('Humeur générale', moodLevel, (value) {
                  setState(() => moodLevel = value);
                }),
                const SizedBox(height: 16),
                _buildMoodSlider('Niveau de motivation', motivationLevel, (value) {
                  setState(() => motivationLevel = value);
                }),
                const SizedBox(height: 16),
                _buildMoodSlider('Confiance en soi', confidenceLevel, (value) {
                  setState(() => confidenceLevel = value);
                }),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optionnel)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('Émotions ressenties:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: emotions.map((emotion) => FilterChip(
                    label: Text(emotion),
                    selected: selectedEmotions.contains(emotion),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedEmotions.add(emotion);
                        } else {
                          selectedEmotions.remove(emotion);
                        }
                      });
                    },
                  )).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Activités du jour:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: activities.map((activity) => FilterChip(
                    label: Text(activity),
                    selected: selectedActivities.contains(activity),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedActivities.add(activity);
                        } else {
                          selectedActivities.remove(activity);
                        }
                      });
                    },
                  )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final entry = MoodEntry(
                  moodLevel: moodLevel,
                  motivationLevel: motivationLevel,
                  confidenceLevel: confidenceLevel,
                  notes: notesController.text.isNotEmpty ? notesController.text : null,
                  emotions: selectedEmotions,
                  activities: selectedActivities,
                );

                Provider.of<MoodProvider>(context, listen: false).addMoodEntry(entry);
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Entrée d\'humeur enregistrée ! 💝'),
                    backgroundColor: AppTheme.secondaryColor,
                  ),
                );
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSlider(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('1'),
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (newValue) => onChanged(newValue.round()),
              ),
            ),
            const Text('5'),
          ],
        ),
        Center(
          child: Text(
            '$value/5',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}