import 'package:flutter/material.dart';

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
  'Gussa',
  'Udaas',
  'Stress',
  'Khushi',
  'Akela',
  'Shukriya',
];

const Map<String, Color> moodColors = {
  'Gussa': Color(0xFFE5484D),
  'Udaas': Color(0xFF6B7A90),
  'Stress': Color(0xFFF79009),
  'Khushi': Color(0xFF12B76A),
  'Akela': Color(0xFF7C5CFF),
  'Shukriya': Color(0xFF1D9BF0),
};

/// In-memory demo store. Firebase (Auth + Firestore) will replace this later;
/// the UI only talks to [AppState], so the swap stays contained.
class AppState extends ChangeNotifier {
  final List<Post> posts = [];
  final List<AppNotification> notifications = [];
  final List<Post> myPosts = [];

  int streak = 5;
  int followers = 128;
  int following = 74;
  final List<String> badges = ['First post', '7-day streak', 'Helpful'];
  String username = 'Anjaan';
  String bio = 'Yahan dil ki baat likhta hoon. Anjaan rehna pasand hai.';
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
        mood: 'Stress',
        text: 'Aaj office mein boss ne phir sabke saamne daanta. Ghar aakar chup reh gaya, kisi ko kya bataun.',
        time: '12m',
        likes: 34,
        reposts: 6,
        comments: [
          Comment(author: 'Anjaan', text: 'Bhai tu akela nahi hai. Kal behtar hoga.', time: '5m'),
          Comment(author: 'Riya', text: 'Same boat. Stay strong.', time: '2m'),
        ],
      ),
      Post(
        id: 'p2',
        author: 'Anjaan',
        anonymous: true,
        mood: 'Gussa',
        text: '3 saal ki mehnat, promotion phir bhi kisi aur ko mili. Andar se gussa aa raha hai.',
        time: '48m',
        likes: 61,
        reposts: 12,
        comments: [
          Comment(author: 'Anjaan', text: 'Bilkul galat hua yaar.', time: '30m'),
        ],
      ),
      Post(
        id: 'p3',
        author: 'Neha',
        anonymous: false,
        mood: 'Khushi',
        text: 'Aaj pehli baar apne liye kuch kiya. Chhoti si baat hai, par dil khush hai.',
        time: '2h',
        likes: 88,
        reposts: 9,
      ),
      Post(
        id: 'p4',
        author: 'Anjaan',
        anonymous: true,
        mood: 'Akela',
        text: 'Raat ke 2 baje, neend nahi aa rahi. Bahut akela lag raha hai.',
        time: '4h',
        likes: 42,
        reposts: 3,
        comments: [
          Comment(author: 'Anjaan', text: 'Hum yahan hain. Baat kar le.', time: '3h'),
        ],
      ),
      Post(
        id: 'p5',
        author: 'Arjun',
        anonymous: false,
        mood: 'Shukriya',
        text: 'Mummy ke haath ka khana kha ke yaad aaya - kuch cheezein kabhi nahi badalti.',
        time: '6h',
        likes: 120,
        reposts: 21,
      ),
      Post(
        id: 'p6',
        author: 'Anjaan',
        anonymous: true,
        mood: 'Udaas',
        text: 'Result aa gaya, expectations se kam. Ghar mein batane ka mann nahi kar raha.',
        time: '9h',
        likes: 27,
        reposts: 2,
      ),
    ]);

    notifications.addAll([
      AppNotification(text: 'Kisi ne tumhare post ko repost kiya.', time: '8m', icon: Icons.repeat),
      AppNotification(text: 'Kisi ne tumhare post par like kiya.', time: '10m', icon: Icons.favorite),
      AppNotification(text: 'Naya comment: "Main bhi same boat mein hoon."', time: '35m', icon: Icons.mode_comment),
      AppNotification(text: 'Aaj ka prompt: Aaj tumhara mood kaisa hai?', time: '3h', icon: Icons.lightbulb_outline),
      AppNotification(text: 'Tumhari 7-din ki streak ban gayi. Shabaash!', time: '1d', icon: Icons.local_fire_department),
    ]);

    // Demo: the anonymous posts are treated as this user's, so the
    // Instagram-style grid on the profile has something to show.
    myPosts.addAll(posts.where((x) => x.anonymous));
  }

  void addPost(String text, String mood, bool anonymous) {
    final post = Post(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      author: username,
      anonymous: anonymous,
      mood: mood,
      text: text,
      time: 'abhi',
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
    post.comments.add(Comment(author: username, text: text, time: 'abhi'));
    notifyListeners();
  }

  List<Post> get trending {
    final list = [...posts];
    list.sort((a, b) => (b.likes + b.reposts).compareTo(a.likes + a.reposts));
    return list;
  }
}

final AppState appState = AppState();
