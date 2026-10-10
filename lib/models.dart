import 'dart:typed_data';
import 'package:flutter/material.dart';

enum PostVisibility { public, followers, private }

const List<Color> avatarColors = [
  Color(0xFF1E7BFF),
  Color(0xFF7C5CFF),
  Color(0xFF22C55E),
  Color(0xFFF59E0B),
  Color(0xFFF43F8E),
  Color(0xFF22D3EE),
];

class User {
  final String id;
  String name;
  String handle;
  bool verified;
  final int colorIndex;
  String bio;
  String link;
  String country;
  int followers;
  int following;
  final bool isMe;

  User({
    required this.id,
    required this.name,
    required this.handle,
    this.verified = false,
    this.colorIndex = 0,
    this.bio = '',
    this.link = '',
    this.country = '',
    this.followers = 0,
    this.following = 0,
    this.isMe = false,
  });
}

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

class Post {
  final String id;
  final String author;
  final bool anonymous;
  final String mood;
  final String text;
  final String time;
  final DateTime createdAt;
  final PostVisibility visibility;
  final List<String> tags;
  final String? groupName;
  int views;
  int likes;
  bool liked;
  int lifts;
  bool lifted;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.author,
    required this.anonymous,
    required this.mood,
    required this.text,
    required this.time,
    required this.createdAt,
    this.visibility = PostVisibility.public,
    this.tags = const [],
    this.groupName,
    this.views = 0,
    this.likes = 0,
    this.liked = false,
    this.lifts = 0,
    this.lifted = false,
    List<Comment>? comments,
  }) : comments = comments ?? [];

  String get name => anonymous ? 'Anjaan' : author;
  String get handle => anonymous ? '@anjaan' : '@${author.toLowerCase()}';
  bool get expired => DateTime.now().difference(createdAt).inDays >= 30;
  int get daysLeft => 30 - DateTime.now().difference(createdAt).inDays;
}

class Group {
  final String id;
  final String name;
  final String description;
  int members;
  bool joined;
  Group({required this.id, required this.name, required this.description, this.members = 0, this.joined = false});
}

class Topic {
  final String name;
  final int posts;
  Topic({required this.name, required this.posts});
}

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
  ['Stressed', 'My boss shouted at me in front of everyone again today. I came home and just stayed quiet. Who do I even tell?', '#work #stress'],
  ['Angry', 'Three years of hard work, and someone else got the promotion. I am furious and nobody sees it.', '#career #angry'],
  ['Happy', 'Today I did something just for myself for the first time. It is small, but it made me happy.', '#selfcare #happy'],
  ['Lonely', 'It is 2am and I cannot sleep. It feels really lonely in here.', '#lonely #night'],
  ['Grateful', 'Tasted my mom\'s cooking again and it hit me - some things never change, and that is a good thing.', '#family #grateful'],
  ['Sad', 'Results are out and they are below what I hoped. I do not want to tell anyone at home.', '#results #sad'],
  ['Stressed', 'Deadlines are piling up and I keep telling everyone I am fine. I am not fine.', '#work #burnout'],
  ['Angry', 'Someone took credit for my idea in the meeting today. I just sat there smiling.', '#office #angry'],
  ['Lonely', 'Everyone looks so busy with their lives. I feel like I am watching from outside.', '#lonely'],
  ['Happy', 'Small win today: I finally finished the thing I kept postponing for weeks.', '#wins #happy'],
  ['Grateful', 'A stranger helped me when I was lost. Restored a little faith today.', '#kindness'],
  ['Sad', 'I miss the person I used to be before all this.', '#sad #life'],
  ['Stressed', 'Cannot stop overthinking every message I send. Anyone else?', '#anxiety #stress'],
  ['Angry', 'Why is it so hard to just be heard once without being judged?', '#voice'],
];

/// In-memory demo store. Firebase (Auth + Firestore) will replace this later.
class AppState extends ChangeNotifier {
  final List<Post> posts = [];
  final List<AppNotification> notifications = [];
  final List<Post> myPosts = [];
  final List<Status> statuses = [];
  final List<Group> groups = [];
  final List<User> users = [];
  final Set<String> followingIds = {};
  final Map<String, int> interests = {};

  // settings
  bool notifyReplies = true;
  bool notifyLikes = true;
  bool publicByDefault = true;
  bool showAds = true;

  int _visible = 8;
  int streak = 5;

  late User me;

  AppState() {
    _seed();
  }

  void _seed() {
    me = User(
      id: 'me',
      name: 'Anjaan',
      handle: '@anjaan',
      bio: 'Writing what is on my mind. Staying anonymous.',
      followers: 1284,
      following: 316,
      colorIndex: 0,
      isMe: true,
    );
    users.addAll([
      me,
      User(id: 'u1', name: 'Riya', handle: '@riya', verified: true, colorIndex: 1, bio: 'Designer. Tea person.', followers: 8200, following: 210),
      User(id: 'u2', name: 'Arjun', handle: '@arjun', colorIndex: 2, bio: 'Runner. Reader.', followers: 540, following: 180),
      User(id: 'u3', name: 'Neha', handle: '@neha', verified: true, colorIndex: 3, bio: 'Writer.', followers: 12400, following: 90),
      User(id: 'u4', name: 'Kabir', handle: '@kabir', colorIndex: 4, bio: 'Just here.', followers: 210, following: 320),
      User(id: 'u5', name: 'Priya', handle: '@priya', colorIndex: 5, bio: 'Music and moods.', followers: 3300, following: 410),
    ]);
    followingIds.addAll(['u1', 'u3']);

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
          createdAt: DateTime.now().subtract(Duration(hours: (i + 1) * 7)),
          tags: t[2].split(' '),
          groupName: ['Exam Stress', 'Office Life', 'Night Owls'][i % 3],
          views: 800 + i * 137,
          likes: 20 + (i * 53) % 900,
          lifts: 3 + (i * 11) % 180,
          comments: [
            Comment(
              author: 'Anjaan',
              text: 'You are not alone in this.',
              time: '${(i + 1) * 3}m',
              likes: 4 + i,
              replies: [Comment(author: 'Riya', text: 'Exactly. We are here.', time: '2m', likes: 2)],
            ),
            Comment(author: 'Kabir', text: 'Same boat. Stay strong.', time: '1m', likes: 3),
          ],
        ),
      );
    }

    notifications.addAll([
      AppNotification(text: 'Riya followed you.', time: '6m', icon: Icons.person_add_alt),
      AppNotification(text: 'Someone lifted your post.', time: '8m', icon: Icons.repeat),
      AppNotification(text: 'Someone liked your post.', time: '10m', icon: Icons.favorite),
      AppNotification(text: 'New comment: "I am in the same boat."', time: '35m', icon: Icons.mode_comment_outlined),
      AppNotification(text: 'You hit a 7-day streak. Nice.', time: '1d', icon: Icons.local_fire_department),
    ]);

    groups.addAll([
      Group(id: 'g1', name: 'Exam Stress', description: 'For anyone fighting exams right now.', members: 1200, joined: true),
      Group(id: 'g2', name: 'Office Life', description: 'Vent about work, safely.', members: 840),
      Group(id: 'g3', name: 'Night Owls', description: 'For the 2am thoughts.', members: 430, joined: true),
    ]);

    statuses.addAll([
      Status(id: 's1', author: 'Riya', gradientIndex: 1, caption: 'Good morning from the hills', createdAt: DateTime.now().subtract(const Duration(hours: 3))),
      Status(id: 's2', author: 'Arjun', gradientIndex: 2, caption: 'Late night thoughts', createdAt: DateTime.now().subtract(const Duration(hours: 9))),
    ]);

    interests.addAll({'Stressed': 4, 'Lonely': 3, 'Happy': 2});

    myPosts.addAll(posts.where((x) => x.anonymous).take(6));
  }

  User userFor(String name) {
    return users.firstWhere(
      (u) => u.name.toLowerCase() == name.toLowerCase(),
      orElse: () => me,
    );
  }

  bool isFollowing(User u) => followingIds.contains(u.id);

  void toggleFollow(User u) {
    if (u.isMe) return;
    if (followingIds.contains(u.id)) {
      followingIds.remove(u.id);
      u.followers -= 1;
    } else {
      followingIds.add(u.id);
      u.followers += 1;
    }
    notifyListeners();
  }

  // ---- posts (with 1-month auto delete) ----
  void purgeExpired() {
    posts.removeWhere((p) => p.expired);
    myPosts.removeWhere((p) => p.expired);
  }

  List<Post> get feed {
    purgeExpired();
    return posts.take(_visible).toList();
  }

  bool get hasMore => _visible < posts.length;
  void loadMore() {
    if (!hasMore) return;
    _visible += 6;
    notifyListeners();
  }

  /// ~70% of the feed matches the moods this user engages with most.
  List<Post> get interestFeed {
    purgeExpired();
    final top = interests.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final wanted = top.take(3).map((e) => e.key).toSet();
    final match = posts.where((p) => wanted.contains(p.mood)).toList();
    final other = posts.where((p) => !wanted.contains(p.mood)).toList();
    final out = <Post>[];
    final mCount = (_visible * 0.7).round();
    out.addAll(match.take(mCount));
    out.addAll(other.take(_visible - out.length));
    if (out.length < _visible) out.addAll(match.skip(mCount).take(_visible - out.length));
    return out;
  }

  void addPost(String text, String mood, bool anonymous, PostVisibility visibility, List<String> tags) {
    final post = Post(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      author: me.name,
      anonymous: anonymous,
      mood: mood,
      text: text,
      time: 'now',
      createdAt: DateTime.now(),
      visibility: visibility,
      tags: tags,
      views: 1,
    );
    posts.insert(0, post);
    myPosts.insert(0, post);
    _visible += 1;
    notifyListeners();
  }

  void deletePost(Post post) {
    posts.remove(post);
    myPosts.remove(post);
    notifyListeners();
  }

  void toggleLike(Post post) {
    post.liked = !post.liked;
    post.likes += post.liked ? 1 : -1;
    if (post.liked) interests[post.mood] = (interests[post.mood] ?? 0) + 1;
    notifyListeners();
  }

  void toggleLift(Post post) {
    post.lifted = !post.lifted;
    post.lifts += post.lifted ? 1 : -1;
    notifyListeners();
  }

  void addComment(Post post, String text) {
    post.comments.insert(0, Comment(author: me.name, text: text, time: 'now'));
    notifyListeners();
  }

  void addReply(Comment parent, String text) {
    parent.replies.insert(0, Comment(author: me.name, text: text, time: 'now'));
    notifyListeners();
  }

  void toggleCommentLike(Comment c) {
    c.liked = !c.liked;
    c.likes += c.liked ? 1 : -1;
    notifyListeners();
  }

  // ---- groups ----
  void toggleGroup(Group g) {
    g.joined = !g.joined;
    g.members += g.joined ? 1 : -1;
    notifyListeners();
  }

  void addGroup(String name, String description) {
    groups.insert(0, Group(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name, description: description, members: 1, joined: true));
    notifyListeners();
  }

  // ---- sharing ----
  void share(Post post, {String? toGroup}) {
    post.lifts += 1;
    post.lifted = true;
    notifyListeners();
  }

  // ---- statuses ----
  List<Status> get activeStatuses {
    statuses.removeWhere((s) => s.expired);
    return statuses;
  }

  void addStatus({Uint8List? imageBytes, String caption = '', int gradientIndex = 0}) {
    statuses.insert(0, Status(id: DateTime.now().microsecondsSinceEpoch.toString(), author: me.name, imageBytes: imageBytes, caption: caption, gradientIndex: gradientIndex, createdAt: DateTime.now()));
    notifyListeners();
  }

  // ---- topics ----
  List<Topic> get trendingTopics {
    final map = <String, int>{};
    for (final p in posts) {
      for (final t in p.tags) {
        final tag = t.replaceAll('#', '');
        if (tag.isEmpty) continue;
        map[tag] = (map[tag] ?? 0) + 1;
      }
    }
    final list = map.entries.map((e) => Topic(name: e.key, posts: e.value * 137 + 40)).toList();
    list.sort((a, b) => b.posts.compareTo(a.posts));
    return list.take(8).toList();
  }

  List<Post> postsWithTag(String tag) =>
      posts.where((p) => p.tags.any((t) => t.replaceAll('#', '') == tag)).toList();

  // ---- analytics (demo) ----
  int get totalViews => myPosts.fold(0, (s, p) => s + p.views);
  int get totalLikes => myPosts.fold(0, (s, p) => s + p.likes);
  int get totalComments => myPosts.fold(0, (s, p) => s + p.comments.length);
  List<int> get viewsByDay => [12, 28, 19, 41, 33, 52, 47];

  // ---- ranking ----
  double _score(Post p) => p.views * 0.05 + p.likes * 1.0 + p.lifts * 2.5 + p.comments.length * 4.0;

  List<Post> get forYou {
    purgeExpired();
    final list = [...posts];
    list.sort((a, b) => _score(b).compareTo(_score(a)));
    return list;
  }

  List<Post> get trending {
    purgeExpired();
    final list = [...posts];
    list.sort((a, b) => (b.likes + b.lifts).compareTo(a.likes + a.lifts));
    return list;
  }

  List<Post> get forYouFeed => forYou.take(_visible).toList();
  List<Post> get hotFeed => trending.take(_visible).toList();

  Set<String> get joinedGroupNames =>
      groups.where((g) => g.joined).map((g) => g.name).toSet();

  /// Feed of posts from the groups this user has joined.
  List<Post> get groupFeed {
    purgeExpired();
    final joined = joinedGroupNames;
    return posts.where((p) => p.groupName != null && joined.contains(p.groupName)).toList();
  }

  // ---- username generator ----
  String suggestUsername(String name) {
    final base = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final n = 100 + DateTime.now().millisecond % 900;
    return '@${base.isEmpty ? 'user' : base}$n';
  }
}

final AppState appState = AppState();
