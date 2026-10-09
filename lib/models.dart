import 'package:flutter/material.dart';
import 'theme.dart';

class Comment {
  final String author;
  final String text;
  final String time;
  Comment({required this.author, required this.text, required this.time});
}

class Post {
  final String id;
  final String author;
  final bool anonymous;
  final String mood;
  final String text;
  final String time;
  int likes;
  bool liked;
  int reposts;
  bool reposted;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.author,
    required this.anonymous,
    required this.mood,
    required this.text,
    required this.time,
    this.likes = 0,
    this.liked = false,
    this.reposts = 0,
    this.reposted = false,
    List<Comment>? comments,
  }) : comments = comments ?? [];

  String get name => anonymous ? 'Anjaan' : author;

  String get handle => anonymous ? '@anjaan' : '@${author.toLowerCase()}';
}

class AppNotification {
  final String text;
  final String time;
  final IconData icon;
  AppNotification({required this.text, required this.time, required this.icon});
}

const List<String> moodList = [
  'Angry',
  'Sad',
  'Stressed',
  'Happy',
  'Lonely',
  'Grateful',
];

const Map<String, Color> moodColors = {
  'Angry': Color(0xFFEF4444),
  'Sad': Color(0xFF6B7A90),
  'Stressed': Color(0xFFF59E0B),
  'Happy': Color(0xFF22C55E),
  'Lonely': Color(0xFF7C5CFF),
  'Grateful': Color(0xFF22D3EE),
};

/// In-memory demo store. Firebase (Auth + Firestore) will replace this later;
/// the UI only talks to [AppState], so the swap stays contained.
class AppState extends ChangeNotifier {
  final List<Post> posts = [];
  final List<AppNotification> notifications = [];
  final List<Post> myPosts = [];

  int streak = 5;
  int followers = 1284;
  int following = 316;
  final List<String> badges = ['First post', '7-day streak', 'Helpful'];
  String username = 'Anjaan';
  String handle = '@anjaan';
  String bio = 'Writing what is on my mind. Staying anonymous.';
  bool anonymousByDefault = true;

  AppState() {
    _seed();
  }

  void _seed() {
    posts.addAll([
      Post(
        id: 'p1',
        author: 'Anjaan',
        anonymous: true,
        mood: 'Stressed',
        text: 'My boss shouted at me in front of everyone again today. I came home and just stayed quiet. Who do I even tell?',
        time: '12m',
        likes: 342,
        reposts: 58,
        comments: [
          Comment(author: 'Anjaan', text: 'You are not alone in this. Tomorrow will be better.', time: '5m'),
          Comment(author: 'Riya', text: 'Same boat. Stay strong.', time: '2m'),
        ],
      ),
      Post(
        id: 'p2',
        author: 'Anjaan',
        anonymous: true,
        mood: 'Angry',
        text: 'Three years of hard work, and someone else got the promotion. I am furious and nobody sees it.',
        time: '48m',
        likes: 611,
        reposts: 124,
        comments: [
          Comment(author: 'Anjaan', text: 'That is genuinely unfair.', time: '30m'),
        ],
      ),
      Post(
        id: 'p3',
        author: 'Neha',
        anonymous: false,
        mood: 'Happy',
        text: 'Today I did something just for myself for the first time. It is small, but it made me happy.',
        time: '2h',
        likes: 888,
        reposts: 96,
      ),
      Post(
        id: 'p4',
        author: 'Anjaan',
        anonymous: true,
        mood: 'Lonely',
        text: 'It is 2am and I cannot sleep. It feels really lonely in here.',
        time: '4h',
        likes: 421,
        reposts: 33,
        comments: [
          Comment(author: 'Anjaan', text: 'We are here. Talk to us.', time: '3h'),
        ],
      ),
      Post(
        id: 'p5',
        author: 'Arjun',
        anonymous: false,
        mood: 'Grateful',
        text: 'Tasted my mom\'s cooking again and it hit me - some things never change, and that is a good thing.',
        time: '6h',
        likes: 1204,
        reposts: 211,
      ),
      Post(
        id: 'p6',
        author: 'Anjaan',
        anonymous: true,
        mood: 'Sad',
        text: 'Results are out and they are below what I hoped. I do not want to tell anyone at home.',
        time: '9h',
        likes: 271,
        reposts: 22,
      ),
    ]);

    notifications.addAll([
      AppNotification(text: 'Someone reposted your post.', time: '8m', icon: Icons.repeat),
      AppNotification(text: 'Someone liked your post.', time: '10m', icon: Icons.favorite),
      AppNotification(text: 'New comment: "I am in the same boat."', time: '35m', icon: Icons.mode_comment),
      AppNotification(text: 'Today\'s prompt: How are you feeling right now?', time: '3h', icon: Icons.auto_awesome),
      AppNotification(text: 'You hit a 7-day streak. Nice.', time: '1d', icon: Icons.local_fire_department),
    ]);

    myPosts.addAll(posts.where((x) => x.anonymous));
  }

  void addPost(String text, String mood, bool anonymous) {
    final post = Post(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      author: username,
      anonymous: anonymous,
      mood: mood,
      text: text,
      time: 'now',
    );
    posts.insert(0, post);
    myPosts.insert(0, post);
    notifyListeners();
  }

  void toggleLike(Post post) {
    post.liked = !post.liked;
    post.likes += post.liked ? 1 : -1;
    notifyListeners();
  }

  void toggleRepost(Post post) {
    post.reposted = !post.reposted;
    post.reposts += post.reposted ? 1 : -1;
    notifyListeners();
  }

  void addComment(Post post, String text) {
    post.comments.add(Comment(author: username, text: text, time: 'now'));
    notifyListeners();
  }

  /// Lightweight on-device ranking - what "the algorithm" surfaces.
  double _score(Post p) =>
      p.likes * 1.0 + p.reposts * 2.5 + p.comments.length * 4.0;

  List<Post> get forYou {
    final list = [...posts];
    list.sort((a, b) => _score(b).compareTo(_score(a)));
    return list;
  }

  List<Post> get trending {
    final list = [...posts];
    list.sort((a, b) => (b.likes + b.reposts).compareTo(a.likes + a.reposts));
    return list;
  }

  List<Post> byMood(String mood) => posts.where((p) => p.mood == mood).toList();
}

final AppState appState = AppState();
