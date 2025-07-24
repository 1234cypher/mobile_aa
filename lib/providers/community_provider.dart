import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/community_post.dart';

class CommunityProvider with ChangeNotifier {
  List<CommunityPost> _posts = [];
  bool _isLoading = false;

  List<CommunityPost> get posts => _posts;
  bool get isLoading => _isLoading;

  List<CommunityPost> getPostsByCategory(PostCategory category) {
    return _posts.where((post) => post.category == category).toList();
  }

  CommunityProvider() {
    _loadPostsFromStorage();
  }

  Future<void> _loadPostsFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final postsJson = prefs.getStringList('community_posts') ?? [];

      _posts = postsJson.map((postJson) {
        final postMap = json.decode(postJson);
        return CommunityPost.fromJson(postMap);
      }).toList();

      if (_posts.isEmpty) {
        _addDemoPosts();
      }

      _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading posts from storage: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _addDemoPosts() {
    final demoPosts = [
      CommunityPost(
        authorId: 'demo1',
        authorName: 'Marie L.',
        title: 'Comment j\'ai négocié mon augmentation',
        content: 'Après des mois d\'hésitation, j\'ai enfin demandé une augmentation. Voici ma stratégie qui a fonctionné...',
        category: PostCategory.career,
        tags: ['négociation', 'salaire', 'confiance'],
        likes: 24,
        comments: 8,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CommunityPost(
        authorId: 'demo2',
        authorName: 'Sophie M.',
        title: 'Syndrome de l\'imposteur : mes techniques',
        content: 'Je partage avec vous les techniques qui m\'ont aidée à surmonter le syndrome de l\'imposteur...',
        category: PostCategory.confidence,
        tags: ['imposteur', 'confiance', 'développement'],
        likes: 31,
        comments: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      CommunityPost(
        authorId: 'demo3',
        authorName: 'Anonyme',
        title: 'Équilibre vie pro/perso avec des enfants',
        content: 'Comment gérez-vous l\'équilibre entre votre carrière et votre vie de famille ?',
        category: PostCategory.workLifeBalance,
        tags: ['équilibre', 'famille', 'organisation'],
        likes: 18,
        comments: 15,
        isAnonymous: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];

    _posts.addAll(demoPosts);
    _savePostsToStorage();
  }

  Future<void> addPost(CommunityPost post) async {
    _posts.insert(0, post);
    await _savePostsToStorage();
    notifyListeners();
  }

  Future<void> likePost(String postId) async {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(
        likes: post.isLikedByUser ? post.likes - 1 : post.likes + 1,
        isLikedByUser: !post.isLikedByUser,
      );
      await _savePostsToStorage();
      notifyListeners();
    }
  }

  Future<void> deletePost(String postId) async {
    _posts.removeWhere((post) => post.id == postId);
    await _savePostsToStorage();
    notifyListeners();
  }

  List<CommunityPost> searchPosts(String query) {
    return _posts.where((post) =>
        post.title.toLowerCase().contains(query.toLowerCase()) ||
        post.content.toLowerCase().contains(query.toLowerCase()) ||
        post.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))).toList();
  }

  Future<void> _savePostsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = _posts.map((post) => json.encode(post.toJson())).toList();
    await prefs.setStringList('community_posts', postsJson);
  }
}