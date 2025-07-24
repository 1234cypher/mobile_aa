import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/learning_provider.dart';
import '../../models/learning_content.dart';
import '../../utils/theme.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: ContentCategory.values.length + 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Apprentissage'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: [
            const Tab(text: 'Tous'),
            ...ContentCategory.values.map((category) => Tab(text: _getCategoryName(category))),
          ],
        ),
      ),
      body: Consumer<LearningProvider>(
        builder: (context, learningProvider, child) {
          return Column(
            children: [
              _buildProgressHeader(context, learningProvider),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildContentGrid(learningProvider.contents),
                    ...ContentCategory.values.map((category) =>
                        _buildContentGrid(learningProvider.getContentsByCategory(category))),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, LearningProvider learningProvider) {
    final totalContents = learningProvider.contents.length;
    final completedContents = learningProvider.completedContents.length;
    final progressPercentage = totalContents > 0 ? (completedContents / totalContents * 100) : 0;

    return Container(
      margin: const EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Votre progression',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${progressPercentage.toInt()}%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progressPercentage / 100,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedContents/$totalContents contenus terminés',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
              ),
              Icon(
                Iconsax.book,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentGrid(List<LearningContent> contents) {
    if (contents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.book,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun contenu disponible',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: contents.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 400),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildContentCard(contents[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentCard(LearningContent content) {
    return Container(
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
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: _getTypeColor(content.type).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Icon(
                _getTypeIcon(content.type),
                size: 40,
                color: _getTypeColor(content.type),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Iconsax.timer,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${content.duration} min',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const Spacer(),
                      if (content.isCompleted)
                        Icon(
                          Iconsax.tick_circle,
                          size: 16,
                          color: AppTheme.accentColor,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (content.rating > 0)
                    Row(
                      children: List.generate(5, (index) => Icon(
                        index < content.rating ? Iconsax.star5 : Iconsax.star,
                        size: 12,
                        color: index < content.rating 
                            ? AppTheme.warningColor 
                            : AppTheme.textSecondary.withOpacity(0.3),
                      )),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _openContent(content),
                style: ElevatedButton.styleFrom(
                  backgroundColor: content.isCompleted 
                      ? AppTheme.accentColor 
                      : _getTypeColor(content.type),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(
                  content.isCompleted ? 'Terminé' : 'Commencer',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(ContentCategory category) {
    switch (category) {
      case ContentCategory.leadership:
        return 'Leadership';
      case ContentCategory.confidence:
        return 'Confiance';
      case ContentCategory.productivity:
        return 'Productivité';
      case ContentCategory.networking:
        return 'Réseau';
      case ContentCategory.negotiation:
        return 'Négociation';
      case ContentCategory.interview:
        return 'Entretiens';
      case ContentCategory.career:
        return 'Carrière';
      case ContentCategory.wellness:
        return 'Bien-être';
    }
  }

  Color _getTypeColor(ContentType type) {
    switch (type) {
      case ContentType.article:
        return AppTheme.primaryColor;
      case ContentType.video:
        return AppTheme.errorColor;
      case ContentType.podcast:
        return AppTheme.secondaryColor;
      case ContentType.webinar:
        return AppTheme.accentColor;
      case ContentType.ebook:
        return AppTheme.warningColor;
      case ContentType.exercise:
        return AppTheme.textPrimary;
    }
  }

  IconData _getTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.article:
        return Iconsax.document_text;
      case ContentType.video:
        return Iconsax.video_play;
      case ContentType.podcast:
        return Iconsax.microphone;
      case ContentType.webinar:
        return Iconsax.video;
      case ContentType.ebook:
        return Iconsax.book;
      case ContentType.exercise:
        return Iconsax.activity;
    }
  }

  void _openContent(LearningContent content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(content.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content.description),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(_getTypeIcon(content.type), color: _getTypeColor(content.type)),
                const SizedBox(width: 8),
                Text('${content.duration} minutes'),
              ],
            ),
            if (!content.isCompleted) ...[
              const SizedBox(height: 16),
              const Text('Marquer comme terminé une fois que vous avez fini ?'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          if (!content.isCompleted)
            ElevatedButton(
              onPressed: () {
                Provider.of<LearningProvider>(context, listen: false)
                    .markAsCompleted(content.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contenu marqué comme terminé ! 🎉'),
                    backgroundColor: AppTheme.accentColor,
                  ),
                );
              },
              child: const Text('Marquer terminé'),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}