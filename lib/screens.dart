import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';
import 'widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vent'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          const SizedBox(width: 4),
        ],
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
            children: [
              const PromptBanner(),
              const SizedBox(height: 12),
              ...appState.posts.map(
                (p) => PostCard(
                  post: p,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PostDetailScreen(post: p)),
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

class PromptBanner extends StatelessWidget {
  const PromptBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [ZColors.primary, Color(0xFF4B8BF5)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_outlined, color: Colors.white),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aaj ka prompt', style: TextStyle(color: Colors.white70, fontSize: 12)),
                SizedBox(height: 2),
                Text('Aaj tumhara mood kaisa hai?',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: ZColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: () {},
            child: const Text('Likho'),
          ),
        ],
      ),
    );
  }
}

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Explore'),
          bottom: const TabBar(
            labelColor: ZColors.primary,
            unselectedLabelColor: ZColors.textSecondary,
            indicatorColor: ZColors.primary,
            tabs: [Tab(text: 'Naya'), Tab(text: 'Trending')],
          ),
        ),
        body: ListenableBuilder(
          listenable: appState,
          builder: (context, _) {
            return TabBarView(
              children: [
                _postList(context, appState.posts),
                _postList(context, appState.trending),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _postList(BuildContext context, List<Post> posts) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      children: posts
          .map((p) => PostCard(
                post: p,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PostDetailScreen(post: p)),
                ),
              ))
          .toList(),
    );
  }
}

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
    return Scaffold(
      appBar: AppBar(title: const Text('Naya post')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Mood chuno',
              style: TextStyle(fontWeight: FontWeight.w600, color: ZColors.textPrimary)),
          const SizedBox(height: 8),
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
                selectedColor: c.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color: selected ? c : ZColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
                side: BorderSide(color: selected ? c : ZColors.border),
                backgroundColor: ZColors.surface,
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
            title: const Text('Anjaan rehna (anonymous)',
                style: TextStyle(fontSize: 14, color: ZColors.textPrimary)),
            subtitle: const Text('Tumhara naam kisi ko nahi dikhega',
                style: TextStyle(fontSize: 12, color: ZColors.textSecondary)),
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
                  padding: const EdgeInsets.all(16),
                  children: [
                    CardShell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AvatarCircle(label: post.anonymous ? 'A' : post.author),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(post.anonymous ? 'Anjaan' : post.author,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: ZColors.textPrimary,
                                            fontSize: 14)),
                                    Text(post.time,
                                        style: const TextStyle(
                                            color: ZColors.textSecondary, fontSize: 11.5)),
                                  ],
                                ),
                              ),
                              MoodChip(mood: post.mood),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(post.text,
                              style: const TextStyle(
                                  color: ZColors.textPrimary, fontSize: 15, height: 1.45)),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              ActionButton(
                                icon: post.liked ? Icons.favorite : Icons.favorite_border,
                                label: '${post.likes}',
                                active: post.liked,
                                onTap: () => appState.toggleLike(post),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Comments (${post.comments.length})',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, color: ZColors.textPrimary, fontSize: 15)),
                    const SizedBox(height: 10),
                    if (post.comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('Pehla comment tum karo.',
                            style: TextStyle(color: ZColors.textSecondary)),
                      ),
                    ...post.comments.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: CardShell(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AvatarCircle(label: c.author, color: ZColors.textSecondary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.author,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: ZColors.textPrimary,
                                            fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text(c.text,
                                        style: const TextStyle(
                                            color: ZColors.textPrimary,
                                            fontSize: 13.5,
                                            height: 1.35)),
                                    const SizedBox(height: 2),
                                    Text(c.time,
                                        style: const TextStyle(
                                            color: ZColors.textSecondary, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  decoration: const BoxDecoration(
                    color: ZColors.surface,
                    border: Border(top: BorderSide(color: ZColors.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(hintText: 'Comment likho...'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _send,
                        icon: const Icon(Icons.send_rounded, size: 18),
                      ),
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

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: appState.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final n = appState.notifications[i];
              return CardShell(
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: ZColors.chipBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(n.icon, size: 19, color: ZColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.text,
                              style: const TextStyle(
                                  color: ZColors.textPrimary, fontSize: 13.5, height: 1.3)),
                          const SizedBox(height: 3),
                          Text(n.time,
                              style: const TextStyle(
                                  color: ZColors.textSecondary, fontSize: 11.5)),
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

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _stat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: ZColors.textPrimary, fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: ZColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              CardShell(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const AvatarCircle(label: 'A'),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(appState.username,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: ZColors.textPrimary,
                                      fontSize: 16)),
                              const SizedBox(height: 2),
                              const Text('Member since Oct 2026',
                                  style: TextStyle(
                                      color: ZColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: ZColors.chipBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department,
                                  size: 16, color: ZColors.primary),
                              const SizedBox(width: 4),
                              Text('${appState.streak} din',
                                  style: const TextStyle(
                                      color: ZColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _stat('${appState.myPosts.length}', 'Posts'),
                        _stat('${appState.streak}', 'Streak'),
                        _stat('${appState.badges.length}', 'Badges'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Badges',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: ZColors.textPrimary, fontSize: 15)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: appState.badges
                    .map(
                      (b) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: ZColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: ZColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified, size: 15, color: ZColors.success),
                            const SizedBox(width: 6),
                            Text(b,
                                style: const TextStyle(
                                    color: ZColors.textPrimary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              const Text('Mere posts',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: ZColors.textPrimary, fontSize: 15)),
              const SizedBox(height: 8),
              if (appState.myPosts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Abhi tak koi post nahi. "Post" tab se likho.',
                      style: TextStyle(color: ZColors.textSecondary)),
                )
              else
                ...appState.myPosts.map(
                  (p) => PostCard(
                    post: p,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PostDetailScreen(post: p)),
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
