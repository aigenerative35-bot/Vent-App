import 'dart:typed_data';

import 'package:flutter/material.dart';

class Comment {
  final String author;
  final String text;
  final String time;
  int likes;
  bool liked;
  final List<Comment> replies;

  Comment({
    required this.author,
    required this.text,
    required this.time,
    this.likes = 0,
    this.liked = false,
    List<Comment>? replies,
  }) : replies = replies ?? [];
}

class Person {
  final String name;
  final String mutual;
  bool friend;
  Person({required this.name, required this.mutual, this.friend = false});
}

class Post {
  final String id;
  final String author;
  final bool anonymous;
  final String mood;
  final String text;
  final String time;
  int views;
  int likes;
  bool liked;
  int lifts; // reposts
  bool lifted;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.author,
    required this.anonymous,
    required this.mood,
    required this.text,
    required this.time,
    this.views = 0,
    this.likes = 0,
    this.liked = false,
    this.lifts = 0,
    this.lifted = false,
    List<Comment>? comments,
  }) : comments = comments ?? [];

  String get name => anonymous ? 'Anjaan' : author;
  String get handle => anonymous ? '@anjaan' : '@${author.toLowerCase()}';
}

/// A photo status that disappears 24 hours after it is posted.
class Status {
  final String id;
  final String author;
  final Uint8List? imageBytes;
  final int gradientIndex;
  final String caption;
  final DateTime createdAt;

  Status({
    required this.id,
    required this.author,
    this.imageBytes,
    this.gradientIndex = 0,
    required this.caption,
    required this.createdAt,
  });

  DateTime get expiresAt => createdAt.add(const Duration(hours: 24));
  bool get expired => DateTime.now().isAfter(expiresAt);
  Duration get remaining => expiresAt.difference(DateTime.now());
}

class AppNotification {
  final String text;
  final String time;
  final IconData icon;
  AppNotification({required this.text, required this.time, required this.icon});
}

const List<String> moodList = ['Angry', 'Sad', 'Stressed', 'Happy', 'Lonely', 'Grateful'];

const Map<String, Color> moodColors = {
  'Angry': Color(0xFFEF4444),
  'Sad': Color(0xFF6B7A90),
  'Stressed': Color(0xFFF59E0B),
  'Happy': Color(0xFF22C55E),
  'Lonely': Color(0xFF7C5CFF),
  'Grateful': Color(0xFF1E7BFF),
};

const List<List<Color>> statusGradients = [
  [Color(0xFF1E7BFF), Color(0xFF4DA3FF)],
  [Color(0xFF7C5CFF), Color(0xFF22D3EE)],
  [Color(0xFFEF4444), Color(0xFFF59E0B)],
  [Color(0xFF22C55E), Color(0xFF22D3EE)],
  [Color(0xFFF43F8E), Color(0xFF7C5CFF)],
];

const List<List<String>> _templates = [
  ['Stressed', 'My boss shouted at me in front of everyone again today. I came home and just stayed quiet. Who do I even tell?'],
  ['Angry', 'Three years of hard work, and someone else got the promotion. I am furious and nobody sees it.'],
  ['Happy', 'Today I did something just for myself for the first time. It is small, but it made me happy.'],
  ['Lonely', 'It is 2am and I cannot sleep. It feels really lonely in here.'],
  ['Grateful', 'Tasted my mom\'s cooking again and it hit me - some things never change, and that is a good thing.'],
  ['Sad', 'Results are out and they are below what I hoped. I do not want to tell anyone at home.'],
  ['Stressed', 'Deadlines are piling up and I keep telling everyone I am fine. I am not fine.'],
  ['Angry', 'Someone took credit for my idea in the meeting today. I just sat there smiling.'],
  ['Lonely', 'Everyone looks so busy with their lives. I feel like I am watching from outside.'],
  ['Happy', 'Small win today: I finally finished the thing I kept postponing for weeks.'],
  ['Grateful', 'A stranger helped me when I was lost. Restored a little faith today.'],
  ['Sad', 'I miss the person I used to be before all this.'],
  ['Stressed', 'Cannot stop overthinking every message I send. Anyone else?'],
  ['Angry', 'Why is it so hard to just be heard once without being judged?'],
];

/// In-memory demo store. Firebase (Auth + Firestore) will replace this later.
class AppState extends ChangeNotifier {
  final List<Post> posts = [];
  final List<AppNotification> notifications = [];
  final List<Post> myPosts = [];
  final List<Person> people = [];
  final List<Status> statuses = [];

  int _visible = 8;

  int streak = 5;
  int friends = 842;
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
    for (var i = 0; i < 26; i++) {
      final t = _templates[i % _templates.length];
      final anon = i % 3 != 1;
      posts.add(
        Post(
          id: 'p$i',
          author: anon ? 'Anjaan' : ['Neha', 'Arjun', 'Priya'][i % 3],
          anonymous: anon,
          mood: t[0],
          text: t[1],
          time: '${(i + 1) * 7}m',
          views: 800 + i * 137,
          likes: 20 + (i * 53) % 900,
          lifts: 3 + (i * 11) % 180,
          comments: [
            Comment(
              author: 'Anjaan',
              text: 'You are not alone in this.',
              time: '${(i + 1) * 3}m',
              likes: 4 + i,
              replies: [
                Comment(author: 'Riya', text: 'Exactly. We are here.', time: '2m', likes: 2),
              ],
            ),
            Comment(author: 'Kabir', text: 'Same boat. Stay strong.', time: '1m', likes: 3),
          ],
        ),
      );
    }

    notifications.addAll([
      AppNotification(text: 'Someone lifted your post.', time: '8m', icon: Icons.repeat),
      AppNotification(text: 'Someone liked your post.', time: '10m', icon: Icons.favorite),
      AppNotification(text: 'New comment: "I am in the same boat."', time: '35m', icon: Icons.mode_comment_outlined),
      AppNotification(text: 'Today\'s prompt: How are you feeling right now?', time: '3h', icon: Icons.auto_awesome),
      AppNotification(text: 'You hit a 7-day streak. Nice.', time: '1d', icon: Icons.local_fire_department),
    ]);

    people.addAll([
      Person(name: 'Riya Sharma', mutual: '12 mutual friends'),
      Person(name: 'Arjun Mehta', mutual: '8 mutual friends', friend: true),
      Person(name: 'Neha Verma', mutual: '23 mutual friends'),
      Person(name: 'Kabir Singh', mutual: '5 mutual friends'),
      Person(name: 'Priya Nair', mutual: '17 mutual friends', friend: true),
    ]);

    statuses.addAll([
      Status(
        id: 's1',
        author: 'Riya',
        gradientIndex: 1,
        caption: 'Good morning from the hills',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Status(
        id: 's2',
        author: 'Arjun',
        gradientIndex: 2,
        caption: 'Late night thoughts',
        createdAt: DateTime.now().subtract(const Duration(hours: 9)),
      ),
      Status(
        id: 's3',
        author: 'Neha',
        gradientIndex: 3,
        caption: 'Coffee and calm',
        createdAt: DateTime.now().subtract(const Duration(hours: 20)),
      ),
    ]);

    myPosts.addAll(posts.where((x) => x.anonymous).take(6));
  }

  // ---- feed with scroll pagination ----
  List<Post> get feed => posts.take(_visible).toList();
  List<Post> get forYouFeed => forYou.take(_visible).toList();
  List<Post> get hotFeed => trending.take(_visible).toList();
  bool get hasMore => _visible < posts.length;
  void loadMore() {
    if (!hasMore) return;
    _visible += 6;
    notifyListeners();
  }

  void addPost(String text, String mood, bool anonymous) {
    final post = Post(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      author: username,
      anonymous: anonymous,
      mood: mood,
      text: text,
      time: 'now',
      views: 1,
    );
    posts.insert(0, post);
    myPosts.insert(0, post);
    _visible += 1;
    notifyListeners();
  }

  void toggleLike(Post post) {
    post.liked = !post.liked;
    post.likes += post.liked ? 1 : -1;
    notifyListeners();
  }

  void toggleLift(Post post) {
    post.lifted = !post.lifted;
    post.lifts += post.lifted ? 1 : -1;
    notifyListeners();
  }

  void addComment(Post post, String text) {
    post.comments.insert(0, Comment(author: username, text: text, time: 'now'));
    notifyListeners();
  }

  void addReply(Comment parent, String text) {
    parent.replies.insert(0, Comment(author: username, text: text, time: 'now'));
    notifyListeners();
  }

  void toggleCommentLike(Comment c) {
    c.liked = !c.liked;
    c.likes += c.liked ? 1 : -1;
    notifyListeners();
  }

  void toggleFriend(Person person) {
    person.friend = !person.friend;
    notifyListeners();
  }

  // ---- statuses (24h) ----
  List<Status> get activeStatuses {
    statuses.removeWhere((s) => s.expired);
    return statuses;
  }

  void addStatus({Uint8List? imageBytes, String caption = '', int gradientIndex = 0}) {
    statuses.insert(
      0,
      Status(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        author: username,
        imageBytes: imageBytes,
        caption: caption,
        gradientIndex: gradientIndex,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void removeStatus(Status s) {
    statuses.remove(s);
    notifyListeners();
  }

  // ---- ranking ----
  double _score(Post p) => p.views * 0.05 + p.likes * 1.0 + p.lifts * 2.5 + p.comments.length * 4.0;

  List<Post> get forYou {
    final list = [...posts];
    list.sort((a, b) => _score(b).compareTo(_score(a)));
    return list;
  }

  List<Post> get trending {
    final list = [...posts];
    list.sort((a, b) => (b.likes + b.lifts).compareTo(a.likes + a.lifts));
    return list;
  }

  List<Post> byMood(String mood) => posts.where((p) => p.mood == mood).toList();
}

final AppState appState = AppState();
