import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'repository.dart';
import 'translate.dart';

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
  Uint8List? avatarBytes;
  Uint8List? bannerBytes;

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

class Poll {
  final List<String> options;
  final List<int> votes;
  int? myVote;

  Poll({required this.options, List<int>? votes, this.myVote})
      : votes = votes ?? List.filled(options.length, 0);

  int get total => votes.fold(0, (s, v) => s + v);

  void vote(int i) {
    if (myVote == i) return;
    if (myVote != null) votes[myVote!] -= 1;
    myVote = i;
    votes[i] += 1;
  }
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
  final Poll? poll;
  Uint8List? imageBytes;
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
    this.poll,
    this.imageBytes,
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

/// An unfinished post the user saved for later.
class Draft {
  String text;
  String mood;
  bool anonymous;
  List<String> tags;
  Uint8List? imageBytes;
  DateTime savedAt;
  Draft({
    this.text = '',
    this.mood = 'Happy',
    this.anonymous = true,
    this.tags = const [],
    this.imageBytes,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now();
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

  // social
  final Set<String> bookmarkedIds = {};
  final Set<String> blockedIds = {};
  final Set<String> mutedIds = {};
  final Set<String> reportedIds = {};
  final List<Draft> drafts = [];
  String lang = 'en';

  // settings
  bool notifyReplies = true;
  bool notifyLikes = true;
  bool publicByDefault = true;
  bool showAds = true;

  int _visible = 8;
  int streak = 5;

  late User me;

  /// Storage boundary — swap for a FirestoreRepository later; nothing else changes.
  final DataRepository repo;

  Timer? _saveTimer;
  bool _loaded = false;

  AppState({DataRepository? repository}) : repo = repository ?? LocalRepository() {
    _seed();
  }

  /// Load previously saved data (called once at startup).
  Future<void> init() async {
    final data = await repo.load();
    if (data != null) {
      try {
        applyJson(data);
      } catch (_) {}
    }
    _loaded = true;
    super.notifyListeners();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (!_loaded) return;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 700), () {
      repo.save(toJson());
    });
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
          poll: i == 0
              ? Poll(options: ['Yes, a lot', 'Sometimes', 'Not really'], votes: [42, 27, 11])
              : null,
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
      Group(id: 'g2', name: 'Office Life', description: 'Talk about work, safely.', members: 840),
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
    return posts.where((p) => p.anonymous || !_hiddenAuthor(p.author)).take(_visible).toList();
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

  void addPost(String text, String mood, bool anonymous, PostVisibility visibility, List<String> tags, {Poll? poll, Uint8List? imageBytes}) {
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
      poll: poll,
      imageBytes: imageBytes,
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

  void votePoll(Post post, int index) {
    post.poll?.vote(index);
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
    final list = posts.where((p) => p.anonymous || !_hiddenAuthor(p.author)).toList();
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

  // ---- bookmarks ----
  bool isBookmarked(Post p) => bookmarkedIds.contains(p.id);
  void toggleBookmark(Post p) {
    if (!bookmarkedIds.add(p.id)) bookmarkedIds.remove(p.id);
    notifyListeners();
  }
  List<Post> get bookmarkedPosts => posts.where((p) => bookmarkedIds.contains(p.id)).toList();

  // ---- block / mute / report ----
  bool isBlocked(User u) => blockedIds.contains(u.id);
  bool isMuted(User u) => mutedIds.contains(u.id);
  void toggleBlock(User u) {
    if (u.isMe) return;
    if (!blockedIds.add(u.id)) blockedIds.remove(u.id);
    notifyListeners();
  }
  void toggleMute(User u) {
    if (u.isMe) return;
    if (!mutedIds.add(u.id)) mutedIds.remove(u.id);
    notifyListeners();
  }
  List<User> get blockedUsers => users.where((u) => blockedIds.contains(u.id)).toList();
  List<User> get mutedUsers => users.where((u) => mutedIds.contains(u.id)).toList();
  void reportPost(Post p) {
    reportedIds.add(p.id);
    posts.remove(p);
    myPosts.remove(p);
    notifyListeners();
  }
  bool _hiddenAuthor(String name) {
    final u = users.firstWhere(
      (x) => x.name.toLowerCase() == name.toLowerCase(),
      orElse: () => me,
    );
    return blockedIds.contains(u.id) || mutedIds.contains(u.id);
  }

  // ---- drafts ----
  void addDraft(String text, String mood, bool anonymous, List<String> tags, {Uint8List? imageBytes}) {
    drafts.insert(0, Draft(text: text, mood: mood, anonymous: anonymous, tags: tags, imageBytes: imageBytes));
    notifyListeners();
  }
  void removeDraft(Draft d) {
    drafts.remove(d);
    notifyListeners();
  }

  // ---- edit post ----
  void editPost(Post p, String text, List<String> tags, {Uint8List? imageBytes}) {
    final updated = Post(
      id: p.id,
      author: p.author,
      anonymous: p.anonymous,
      mood: p.mood,
      text: text,
      time: p.time,
      createdAt: p.createdAt,
      visibility: p.visibility,
      tags: tags,
      groupName: p.groupName,
      poll: p.poll,
      imageBytes: imageBytes ?? p.imageBytes,
      views: p.views,
      likes: p.likes,
      liked: p.liked,
      lifts: p.lifts,
      lifted: p.lifted,
      comments: p.comments,
    );
    final i = posts.indexOf(p);
    if (i >= 0) posts[i] = updated;
    final idx = myPosts.indexOf(p);
    if (idx >= 0) myPosts[idx] = updated;
    notifyListeners();
  }

  // ---- followers / following ----
  List<User> get followingList => users.where((u) => followingIds.contains(u.id)).toList();
  List<User> get followersList =>
      users.where((u) => !u.isMe && !followingIds.contains(u.id)).take(8).toList();

  // ---- search ----
  List<User> searchUsers(String q) {
    final s = q.toLowerCase().replaceAll('@', '').trim();
    if (s.isEmpty) return [];
    return users
        .where((u) =>
            u.name.toLowerCase().contains(s) ||
            u.handle.toLowerCase().contains(s) ||
            u.bio.toLowerCase().contains(s))
        .toList();
  }
  List<Post> searchPosts(String q) {
    final s = q.toLowerCase().trim();
    if (s.isEmpty) return [];
    return posts.where((p) => p.text.toLowerCase().contains(s)).toList();
  }
  List<String> searchTags(String q) {
    final s = q.toLowerCase().replaceAll('#', '').trim();
    final set = <String>{};
    for (final p in posts) {
      for (final t in p.tags) {
        final tag = t.replaceAll('#', '');
        if (tag.isEmpty) continue;
        if (s.isEmpty || tag.toLowerCase().contains(s)) set.add(tag);
      }
    }
    final list = set.toList()..sort();
    return list;
  }

  // ---- language ----
  void setLang(String l) {
    lang = l;
    notifyListeners();
  }

  // ---- translation (X-style "Translate post") ----
  final Map<String, String> translations = {};
  final Set<String> showTranslated = {};
  final Set<String> translating = {};
  final Map<String, String> translateErrors = {};

  bool isTranslating(Post p) => translating.contains(p.id);

  /// Translate a post into the user's current app language (or English).
  /// Never throws — a failure is stored in [translateErrors] for the UI to
  /// show with a retry, so a bad network can never crash the app.
  Future<void> translatePost(Post p) async {
    if (translations.containsKey(p.id)) {
      toggleTranslation(p);
      return;
    }
    if (translating.contains(p.id)) return; // already in flight
    translating.add(p.id);
    translateErrors.remove(p.id);
    notifyListeners();

    final target = lang == 'hi' ? 'hi' : 'en';
    final res = await TranslateService.translate(p.text, target);

    translating.remove(p.id);
    if (res.ok && res.text != null && res.text != p.text) {
      translations[p.id] = res.text!;
      showTranslated.add(p.id);
    } else if (!res.ok) {
      translateErrors[p.id] = res.error ?? 'Translation failed';
    }
    notifyListeners();
  }

  void toggleTranslation(Post p) {
    if (!showTranslated.add(p.id)) showTranslated.remove(p.id);
    notifyListeners();
  }

  // ---- persistence (the only place that knows the storage format) ----
  Map<String, dynamic> toJson() => {
        'me': _userJson(me),
        'users': users.map(_userJson).toList(),
        'posts': posts.map(_postJson).toList(),
        'myPosts': myPosts.map((p) => p.id).toList(),
        'following': followingIds.toList(),
        'bookmarks': bookmarkedIds.toList(),
        'blocked': blockedIds.toList(),
        'muted': mutedIds.toList(),
        'drafts': drafts
            .map((d) => {
                  'text': d.text,
                  'mood': d.mood,
                  'anonymous': d.anonymous,
                  'tags': d.tags,
                  'image': _b64(d.imageBytes),
                  'savedAt': d.savedAt.millisecondsSinceEpoch,
                })
            .toList(),
        'groups': groups
            .map((g) => {'id': g.id, 'name': g.name, 'description': g.description, 'members': g.members, 'joined': g.joined})
            .toList(),
        'statuses': statuses
            .map((s) => {'id': s.id, 'author': s.author, 'caption': s.caption, 'gradientIndex': s.gradientIndex, 'image': _b64(s.imageBytes), 'createdAt': s.createdAt.millisecondsSinceEpoch})
            .toList(),
        'interests': interests,
        'lang': lang,
        'settings': {
          'notifyReplies': notifyReplies,
          'notifyLikes': notifyLikes,
          'publicByDefault': publicByDefault,
          'showAds': showAds,
        },
      };

  void applyJson(Map<String, dynamic> j) {
    if (j['me'] is Map) me = _userFrom(j['me'] as Map, isMe: true);
    if (j['users'] is List) {
      users
        ..clear()
        ..addAll((j['users'] as List).map((e) => _userFrom(e as Map)));
      if (!users.any((u) => u.isMe)) users.insert(0, me);
    }
    if (j['posts'] is List) {
      posts
        ..clear()
        ..addAll((j['posts'] as List).map((e) => _postFrom(e as Map)));
    }
    if (j['myPosts'] is List) {
      final ids = (j['myPosts'] as List).cast<String>().toSet();
      myPosts
        ..clear()
        ..addAll(posts.where((p) => ids.contains(p.id)));
    }
    followingIds
      ..clear()
      ..addAll(((j['following'] as List?) ?? []).cast<String>());
    bookmarkedIds
      ..clear()
      ..addAll(((j['bookmarks'] as List?) ?? []).cast<String>());
    blockedIds
      ..clear()
      ..addAll(((j['blocked'] as List?) ?? []).cast<String>());
    mutedIds
      ..clear()
      ..addAll(((j['muted'] as List?) ?? []).cast<String>());
    if (j['drafts'] is List) {
      drafts
        ..clear()
        ..addAll((j['drafts'] as List).map((e) {
          final m = e as Map;
          return Draft(
            text: '${m['text'] ?? ''}',
            mood: '${m['mood'] ?? 'Happy'}',
            anonymous: m['anonymous'] == true,
            tags: ((m['tags'] as List?) ?? []).cast<String>(),
            imageBytes: _unb64(m['image']),
            savedAt: DateTime.fromMillisecondsSinceEpoch(
                (m['savedAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch),
          );
        }));
    }
    if (j['groups'] is List) {
      groups
        ..clear()
        ..addAll((j['groups'] as List).map((e) {
          final m = e as Map;
          return Group(
            id: '${m['id']}',
            name: '${m['name']}',
            description: '${m['description'] ?? ''}',
            members: (m['members'] as int?) ?? 0,
            joined: m['joined'] == true,
          );
        }));
    }
    if (j['statuses'] is List) {
      statuses
        ..clear()
        ..addAll((j['statuses'] as List).map((e) {
          final m = e as Map;
          return Status(
            id: '${m['id']}',
            author: '${m['author']}',
            caption: '${m['caption'] ?? ''}',
            gradientIndex: (m['gradientIndex'] as int?) ?? 0,
            imageBytes: _unb64(m['image']),
            createdAt: DateTime.fromMillisecondsSinceEpoch(
                (m['createdAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch),
          );
        }));
    }
    if (j['interests'] is Map) {
      interests
        ..clear()
        ..addAll((j['interests'] as Map).map((k, v) => MapEntry('$k', (v as num).toInt())));
    }
    if (j['lang'] is String) lang = j['lang'] as String;
    final st = j['settings'];
    if (st is Map) {
      notifyReplies = st['notifyReplies'] != false;
      notifyLikes = st['notifyLikes'] != false;
      publicByDefault = st['publicByDefault'] != false;
      showAds = st['showAds'] != false;
    }
  }

  // ---- (de)serialization helpers ----
  static String? _b64(Uint8List? b) => b == null ? null : base64Encode(b);
  static Uint8List? _unb64(dynamic s) => (s is String && s.isNotEmpty) ? base64Decode(s) : null;

  static Map<String, dynamic> _userJson(User u) => {
        'id': u.id,
        'name': u.name,
        'handle': u.handle,
        'verified': u.verified,
        'colorIndex': u.colorIndex,
        'bio': u.bio,
        'link': u.link,
        'country': u.country,
        'followers': u.followers,
        'following': u.following,
        'isMe': u.isMe,
        'avatar': _b64(u.avatarBytes),
        'banner': _b64(u.bannerBytes),
      };
  static User _userFrom(Map m, {bool isMe = false}) => User(
        id: '${m['id']}',
        name: '${m['name'] ?? 'User'}',
        handle: '${m['handle'] ?? ''}',
        verified: m['verified'] == true,
        colorIndex: (m['colorIndex'] as int?) ?? 0,
        bio: '${m['bio'] ?? ''}',
        link: '${m['link'] ?? ''}',
        country: '${m['country'] ?? ''}',
        followers: (m['followers'] as int?) ?? 0,
        following: (m['following'] as int?) ?? 0,
        isMe: isMe || m['isMe'] == true,
      )
        ..avatarBytes = _unb64(m['avatar'])
        ..bannerBytes = _unb64(m['banner']);

  static Map<String, dynamic> _postJson(Post p) => {
        'id': p.id,
        'author': p.author,
        'anonymous': p.anonymous,
        'mood': p.mood,
        'text': p.text,
        'time': p.time,
        'createdAt': p.createdAt.millisecondsSinceEpoch,
        'visibility': p.visibility.index,
        'tags': p.tags,
        'groupName': p.groupName,
        'image': _b64(p.imageBytes),
        'views': p.views,
        'likes': p.likes,
        'liked': p.liked,
        'lifts': p.lifts,
        'lifted': p.lifted,
        'poll': p.poll == null
            ? null
            : {'options': p.poll!.options, 'votes': p.poll!.votes, 'myVote': p.poll!.myVote},
        'comments': p.comments.map(_commentJson).toList(),
      };
  static Post _postFrom(Map m) => Post(
        id: '${m['id']}',
        author: '${m['author']}',
        anonymous: m['anonymous'] == true,
        mood: '${m['mood'] ?? 'Happy'}',
        text: '${m['text'] ?? ''}',
        time: '${m['time'] ?? ''}',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            (m['createdAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch),
        visibility: PostVisibility.values[(m['visibility'] as int?) ?? 0],
        tags: ((m['tags'] as List?) ?? []).cast<String>(),
        groupName: m['groupName'] as String?,
        imageBytes: _unb64(m['image']),
        views: (m['views'] as int?) ?? 0,
        likes: (m['likes'] as int?) ?? 0,
        liked: m['liked'] == true,
        lifts: (m['lifts'] as int?) ?? 0,
        lifted: m['lifted'] == true,
        poll: m['poll'] == null
            ? null
            : Poll(
                options: ((m['poll'] as Map)['options'] as List).cast<String>(),
                votes: ((m['poll'] as Map)['votes'] as List).cast<int>(),
                myVote: (m['poll'] as Map)['myVote'] as int?,
              ),
        comments: ((m['comments'] as List?) ?? []).map((e) => _commentFrom(e as Map)).toList(),
      );
  static Map<String, dynamic> _commentJson(Comment c) => {
        'author': c.author,
        'text': c.text,
        'time': c.time,
        'likes': c.likes,
        'liked': c.liked,
        'replies': c.replies.map(_commentJson).toList(),
      };
  static Comment _commentFrom(Map m) => Comment(
        author: '${m['author']}',
        text: '${m['text'] ?? ''}',
        time: '${m['time'] ?? ''}',
        likes: (m['likes'] as int?) ?? 0,
        liked: m['liked'] == true,
        replies: ((m['replies'] as List?) ?? []).map((e) => _commentFrom(e as Map)).toList(),
      );
}

final AppState appState = AppState();
