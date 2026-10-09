import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';
import 'widgets.dart';

void openPost(BuildContext context, Post post) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
  );
}

// ---------------------------------------------------------------- HOME

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vent'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
          const SizedBox(width: 4),
        ],
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const PromptBanner(),
              ...appState.posts.map(
                (post) => TweetCard(post: post, onTap: () => openPost(context, post)),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

class PromptBanner extends StatelessWidget {
  const PromptBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.border))),
      child: Row(
        children: [
          const AvatarCircle(label: 'A', size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aaj tumhara mood kaisa hai?',
              style: TextStyle(color: p.secondary, fontSize: 15),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            ),
            onPressed: () {},
            child: const Text('Likho'),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- EXPLORE

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search posts, moods, log...',
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                child: Text('Trending',
                    style: TextStyle(color: p.text, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              ...appState.trending.map(
                (post) => TweetCard(post: post, onTap: () => openPost(context, post)),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------- CREATE

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _controller = TextEditingController();
  String _mood = moodList.first;
  late bool _anonymous = appState.anonymousByDefault;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kuch likho pehle')),
      );
      return;
    }
    appState.addPost(text, _mood, _anonymous);
    _controller.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post ho gaya')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Naya post')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Mood chuno',
              style: TextStyle(fontWeight: FontWeight.w700, color: p.text)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: moodList.map((m) {
              final selected = m == _mood;
              final c = moodColors[m]!;
              return ChoiceChip(
                label: Text(m),
                selected: selected,
                onSelected: (_) => setState(() => _mood = m),
                selectedColor: c.withValues(alpha: 0.18),
                labelStyle: TextStyle(
                  color: selected ? c : p.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
                side: BorderSide(color: selected ? c : p.border),
                backgroundColor: p.bg,
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 6,
            maxLength: 300,
            decoration: const InputDecoration(hintText: 'Dil ki baat likho... (max 300)'),
          ),
          const SizedBox(height: 4),
          SwitchListTile(
            value: _anonymous,
            onChanged: (v) => setState(() => _anonymous = v),
            title: Text('Anjaan rehna (anonymous)',
                style: TextStyle(fontSize: 14, color: p.text)),
            subtitle: Text('Tumhara naam kisi ko nahi dikhega',
                style: TextStyle(fontSize: 12, color: p.secondary)),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Post karo'),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------- DETAIL

class PostDetailScreen extends StatefulWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final t = _controller.text.trim();
    if (t.isEmpty) return;
    appState.addComment(widget.post, t);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final post = widget.post;
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: p.border))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AvatarCircle(label: post.anonymous ? 'A' : post.author),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(post.name,
                                        style: TextStyle(
                                            color: p.text,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14.5)),
                                    Text(post.handle,
                                        style: TextStyle(color: p.secondary, fontSize: 13)),
                                  ],
                                ),
                              ),
                              MoodChip(mood: post.mood),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(post.text,
                              style: TextStyle(color: p.text, fontSize: 17, height: 1.4)),
                          const SizedBox(height: 10),
                          Text(post.time, style: TextStyle(color: p.secondary, fontSize: 13)),
                          const SizedBox(height: 10),
                          ActionRow(post: post, onComment: () {}),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                      child: Text('Replies (${post.comments.length})',
                          style: TextStyle(
                              color: p.text, fontSize: 15, fontWeight: FontWeight.w800)),
                    ),
                    if (post.comments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('Pehla reply tum karo.',
                            style: TextStyle(color: p.secondary)),
                      ),
                    ...post.comments.map(
                      (c) => Container(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: p.border))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AvatarCircle(label: c.author, size: 38, color: p.secondary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(c.author,
                                          style: TextStyle(
                                              color: p.text,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13.5)),
                                      Text('  · ${c.time}',
                                          style: TextStyle(color: p.secondary, fontSize: 12.5)),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(c.text,
                                      style: TextStyle(
                                          color: p.text, fontSize: 14.5, height: 1.35)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  decoration: BoxDecoration(
                    color: p.bg,
                    border: Border(top: BorderSide(color: p.border)),
                  ),
                  child: Row(
                    children: [
                      const AvatarCircle(label: 'A', size: 36),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(hintText: 'Reply likho...'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(onPressed: _send, icon: const Icon(Icons.send_rounded, size: 18)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------- NOTIFICATIONS

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: appState.notifications.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: p.border),
            itemBuilder: (context, i) {
              final n = appState.notifications[i];
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: p.chipBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(n.icon, size: 19, color: AppColors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.text,
                              style: TextStyle(color: p.text, fontSize: 14, height: 1.3)),
                          const SizedBox(height: 3),
                          Text(n.time,
                              style: TextStyle(color: p.secondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------- PROFILE
// Instagram-style: big avatar + stats row, bio, buttons, then a 3-column grid.

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _stat(BuildContext context, String value, String label) {
    final p = Palette.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(color: p.text, fontSize: 16.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: p.secondary, fontSize: 12.5)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(appState.username),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
          const SizedBox(width: 4),
        ],
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final myPosts = appState.myPosts;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Row(
                  children: [
                    const AvatarCircle(label: 'A', size: 84),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Row(
                        children: [
                          _stat(context, '${myPosts.length}', 'Posts'),
                          _stat(context, '${appState.followers}', 'Followers'),
                          _stat(context, '${appState.following}', 'Following'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appState.username,
                        style: TextStyle(
                            color: p.text, fontSize: 14.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(appState.bio, style: TextStyle(color: p.text, fontSize: 13.5, height: 1.35)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _pill(context, Icons.local_fire_department,
                            '${appState.streak} din streak'),
                        ...appState.badges.map((b) => _pill(context, Icons.verified, b)),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text('Edit profile'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Share profile'),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: p.border),
              if (myPosts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  child: Column(
                    children: [
                      Icon(Icons.grid_on, size: 40, color: p.secondary),
                      const SizedBox(height: 10),
                      Text('Abhi tak koi post nahi. "Post" tab se likho.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: p.secondary)),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(2),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemCount: myPosts.length,
                  itemBuilder: (context, i) {
                    final post = myPosts[i];
                    final c = moodColors[post.mood] ?? AppColors.blue;
                    return GestureDetector(
                      onTap: () => openPost(context, post),
                      child: Container(
                        decoration: BoxDecoration(
                          color: c.withValues(alpha: 0.16),
                          border: Border.all(color: p.border, width: 0.5),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MoodChip(mood: post.mood),
                            const SizedBox(height: 6),
                            Expanded(
                              child: Text(
                                post.text,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: p.text, fontSize: 11.5, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _pill(BuildContext context, IconData icon, String text) {
    final p = Palette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: p.chipBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.blue),
          const SizedBox(width: 5),
          Text(text,
              style: TextStyle(color: p.text, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
