import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';
import 'widgets.dart';

void openPost(BuildContext context, Post post) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
  );
}

String shortNum(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}

// ---------------------------------------------------------------- HOME

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _filter = 0;
  static const _filters = ['For You', 'Trending', 'New', ...moodList];

  List<Post> _list() {
    switch (_filter) {
      case 0:
        return appState.forYou;
      case 1:
        return appState.trending;
      case 2:
        return appState.posts;
      default:
        return appState.byMood(_filters[_filter]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: Brand.gradient,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: const Text('V',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            ),
            const SizedBox(width: 10),
            Text('Vent',
                style: TextStyle(color: p.text, fontWeight: FontWeight.w900, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          const SizedBox(width: 4),
        ],
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final posts = _list();
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How are you feeling today?',
                        style: TextStyle(
                            color: p.text,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.2)),
                    const SizedBox(height: 4),
                    Text('Say it anonymously. Someone out there gets it.',
                        style: TextStyle(color: p.secondary, fontSize: 13.5)),
                  ],
                ),
              ),
              _chips(context),
              if (_filter == 0)
                const SectionHeader(
                  icon: Icons.auto_awesome,
                  title: 'Recommended for you',
                  subtitle: 'Picked by AI from what is resonating',
                )
              else if (_filter == 1)
                const SectionHeader(icon: Icons.trending_up, title: 'Trending now')
              else if (_filter >= 3)
                SectionHeader(icon: Icons.local_fire_department, title: '${_filters[_filter]} posts'),
              if (posts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: EmptyState(icon: Icons.inbox_outlined, message: 'Nothing here yet.'),
                ),
              ...posts.map((post) => PostCard(post: post, onTap: () => openPost(context, post))),
            ],
          );
        },
      ),
    );
  }

  Widget _chips(BuildContext context) {
    final p = Palette.of(context);
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = i == _filter;
          return ChoiceChip(
            label: Text(_filters[i]),
            avatar: i == 0
                ? Icon(Icons.auto_awesome,
                    size: 15, color: selected ? Colors.white : Brand.violet)
                : null,
            selected: selected,
            onSelected: (_) => setState(() => _filter = i),
            showCheckmark: false,
            labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : p.text),
            selectedColor: Brand.violet,
            backgroundColor: p.surface,
            side: BorderSide(color: p.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------- SEARCH

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search posts, moods, people...',
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                ),
              ),
              const SectionHeader(icon: Icons.trending_up, title: 'Trending now'),
              ...appState.trending
                  .map((post) => PostCard(post: post, onTap: () => openPost(context, post))),
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
        const SnackBar(content: Text('Write something first')),
      );
      return;
    }
    appState.addPost(text, _mood, _anonymous);
    _controller.clear();
    FocusScope.of(context).unfocus();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Posted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final len = _controller.text.characters.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Create post')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          SoftCard(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Avatar(label: _anonymous ? 'A' : appState.username[0], size: 40),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_anonymous ? 'Anjaan' : appState.username,
                            style: TextStyle(
                                color: p.text, fontWeight: FontWeight.w800, fontSize: 14.5)),
                        Text(_anonymous ? '@anjaan' : appState.handle,
                            style: TextStyle(color: p.secondary, fontSize: 12.5)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  onChanged: (_) => setState(() {}),
                  maxLines: 8,
                  maxLength: 300,
                  style: TextStyle(color: p.text, fontSize: 16.5, height: 1.45),
                  decoration: const InputDecoration(
                    hintText: 'What is on your mind?',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    counterText: '',
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('$len/300',
                      style: TextStyle(
                          color: len > 280 ? Brand.pink : p.secondary, fontSize: 12.5)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('Pick a mood',
              style: TextStyle(color: p.text, fontSize: 14.5, fontWeight: FontWeight.w800)),
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
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5),
                side: BorderSide(color: selected ? c : p.border),
                backgroundColor: p.surface,
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: SwitchListTile(
              value: _anonymous,
              onChanged: (v) => setState(() => _anonymous = v),
              title: Text('Post anonymously',
                  style: TextStyle(fontSize: 14.5, color: p.text, fontWeight: FontWeight.w700)),
              subtitle: Text('Your name will not be shown',
                  style: TextStyle(fontSize: 12.5, color: p.secondary)),
            ),
          ),
          const SizedBox(height: 22),
          GradientButton(
            label: 'Post',
            icon: Icons.send_rounded,
            onTap: _controller.text.trim().isEmpty ? null : _submit,
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
                  padding: const EdgeInsets.only(top: 12),
                  children: [
                    PostCard(post: post, onTap: () {}),
                    const SectionHeader(title: 'Replies'),
                    if (post.comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: EmptyState(
                            icon: Icons.chat_bubble_outline,
                            message: 'No replies yet. Be the first.'),
                      ),
                    ...post.comments.map(
                      (c) => Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                        child: SoftCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Avatar(label: c.author, size: 38),
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
                                        Text('  ·  ${c.time}',
                                            style: TextStyle(
                                                color: p.secondary, fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(c.text,
                                        style: TextStyle(
                                            color: p.text, fontSize: 14.5, height: 1.4)),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                      const Avatar(label: 'A', size: 36),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(hintText: 'Write a reply...'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                          onPressed: _send, icon: const Icon(Icons.send_rounded, size: 18)),
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
      appBar: AppBar(title: const Text('Activity')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
            children: appState.notifications
                .map(
                  (n) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SoftCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: Brand.gradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(n.icon, size: 20, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.text,
                                    style: TextStyle(
                                        color: p.text, fontSize: 14, height: 1.3)),
                                const SizedBox(height: 3),
                                Text(n.time,
                                    style: TextStyle(color: p.secondary, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------- PROFILE
// X-style: gradient banner, overlapping avatar, bio, stats, tabs, post list.

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
            const SizedBox(width: 4),
          ],
        ),
        body: Column(
          children: [
            _header(context, p),
            const TabBar(
              tabs: [Tab(text: 'Posts'), Tab(text: 'Replies'), Tab(text: 'Media'), Tab(text: 'Likes')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListenableBuilder(
                    listenable: appState,
                    builder: (context, _) {
                      final mine = appState.myPosts;
                      if (mine.isEmpty) {
                        return const EmptyState(
                            icon: Icons.edit_note,
                            message: 'No posts yet. Tap Post to write one.');
                      }
                      return ListView(
                        padding: const EdgeInsets.only(top: 12, bottom: 24),
                        children: mine
                            .map((post) =>
                                PostCard(post: post, onTap: () => openPost(context, post)))
                            .toList(),
                      );
                    },
                  ),
                  const EmptyState(icon: Icons.chat_bubble_outline, message: 'No replies yet.'),
                  const EmptyState(icon: Icons.perm_media_outlined, message: 'No media yet.'),
                  const EmptyState(icon: Icons.favorite_border, message: 'No likes yet.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 152,
          child: Stack(
            children: [
              Container(height: 112, decoration: const BoxDecoration(gradient: Brand.gradient)),
              Positioned(
                left: 16,
                top: 70,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: p.bg),
                  child: const Avatar(label: 'A', size: 84),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appState.username,
                            style: TextStyle(
                                color: p.text, fontSize: 20, fontWeight: FontWeight.w800)),
                        Text(appState.handle,
                            style: TextStyle(color: p.secondary, fontSize: 14)),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    ),
                    onPressed: () {},
                    child: const Text('Edit profile'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(appState.bio, style: TextStyle(color: p.text, fontSize: 14, height: 1.4)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: p.secondary),
                  const SizedBox(width: 6),
                  Text('Joined October 2026',
                      style: TextStyle(color: p.secondary, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _count(context, shortNum(appState.following), 'Following'),
                  const SizedBox(width: 18),
                  _count(context, shortNum(appState.followers), 'Followers'),
                  const SizedBox(width: 18),
                  _count(context, '${appState.myPosts.length}', 'Posts'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _count(BuildContext context, String value, String label) {
    final p = Palette.of(context);
    return RichText(
      text: TextSpan(
        style: TextStyle(color: p.secondary, fontSize: 13.5),
        children: [
          TextSpan(
              text: value,
              style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 14)),
          TextSpan(text: '  $label'),
        ],
      ),
    );
  }
}
