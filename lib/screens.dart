import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';
import 'widgets.dart';

void openPost(BuildContext context, Post post) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
  );
}

void openCompose(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const ComposeScreen()),
  );
}

// ---------------------------------------------------------------- HOME

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: Brand.blue, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Text('V',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: p.surfaceAlt,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 18, color: p.secondary),
                    const SizedBox(width: 8),
                    Text('Search Vent', style: TextStyle(color: p.secondary, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          const SizedBox(width: 4),
        ],
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final rec = appState.forYou.take(2).toList();
          final recIds = rec.map((e) => e.id).toSet();
          final rest = appState.posts.where((e) => !recIds.contains(e.id)).toList();
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 8),
              const CreateBox(),
              const SizedBox(height: 8),
              const StoriesRow(),
              const SizedBox(height: 4),
              const SectionHeader(
                  icon: Icons.auto_awesome, title: 'Suggested for you', subtitle: 'Picked for you'),
              ...rec.map((post) => PostCard(post: post, onTap: () => openPost(context, post))),
              const SizedBox(height: 8),
              const SectionHeader(title: 'Latest'),
              ...rest.map((post) => PostCard(post: post, onTap: () => openPost(context, post))),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

class CreateBox extends StatelessWidget {
  const CreateBox({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return FbCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
        child: Column(
          children: [
            Row(
              children: [
                const Avatar(label: 'A'),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => openCompose(context),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      height: 42,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: p.surfaceAlt,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text('What is on your mind, Anjaan?',
                          style: TextStyle(color: p.secondary, fontSize: 15)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: p.divider),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(child: _quick(context, Icons.videocam_outlined, 'Live', Brand.red)),
                Expanded(child: _quick(context, Icons.photo_library_outlined, 'Photo', Brand.green)),
                Expanded(
                    child: _quick(context, Icons.emoji_emotions_outlined, 'Feeling',
                        const Color(0xFFF7B928))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quick(BuildContext context, IconData icon, String label, Color color) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(width: 7),
          Text(label,
              style: TextStyle(color: p.secondary, fontSize: 13.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class StoriesRow extends StatelessWidget {
  const StoriesRow({super.key});

  @override
  Widget build(BuildContext context) {
    final people = appState.people;
    return SizedBox(
      height: 106,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          const StoryCircle(label: 'Create story', add: true),
          ...people.map((person) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: StoryCircle(label: person.name.split(' ').first, color: Brand.blueDark),
              )),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- FRIENDS

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.only(bottom: 20),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Text('People you may know',
                    style: TextStyle(color: p.text, fontSize: 16, fontWeight: FontWeight.w800)),
              ),
              ...appState.people.map(
                (person) => Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: FbCard(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Avatar(label: person.name, size: 52),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(person.name,
                                    style: TextStyle(
                                        color: p.text,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(person.mutual,
                                    style: TextStyle(color: p.secondary, fontSize: 12.5)),
                              ],
                            ),
                          ),
                          person.friend
                              ? OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  ),
                                  onPressed: () => appState.toggleFriend(person),
                                  child: const Text('Friends'),
                                )
                              : FilledButton(
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                  ),
                                  onPressed: () => appState.toggleFriend(person),
                                  child: const Text('Add friend'),
                                ),
                        ],
                      ),
                    ),
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

// --------------------------------------------------------------- WATCH

class WatchScreen extends StatelessWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watch')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            children: [
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

// -------------------------------------------------------- NOTIFICATIONS

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: appState.notifications
                .map(
                  (n) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FbCard(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                Avatar(label: 'A', size: 44),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                        color: Brand.blue, shape: BoxShape.circle),
                                    child: Icon(n.icon, size: 11, color: Colors.white),
                                  ),
                                ),
                              ],
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
                                      style: TextStyle(color: Brand.blue, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
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

// ------------------------------------------------------------- COMPOSE

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key});

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
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
    if (text.isEmpty) return;
    appState.addPost(text, _mood, _anonymous);
    _controller.clear();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Posted')));
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create post')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          FbCard(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Avatar(label: _anonymous ? 'A' : appState.username[0],
                          color: _anonymous ? p.secondary : Brand.blue),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_anonymous ? 'Anjaan' : appState.username,
                              style: TextStyle(
                                  color: p.text, fontWeight: FontWeight.w700, fontSize: 14.5)),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: p.surfaceAlt,
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text('Public',
                                    style: TextStyle(color: p.secondary, fontSize: 11)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  TextField(
                    controller: _controller,
                    onChanged: (_) => setState(() {}),
                    maxLines: 7,
                    maxLength: 300,
                    style: TextStyle(color: p.text, fontSize: 17, height: 1.4),
                    decoration: const InputDecoration(
                      hintText: 'What is on your mind?',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      counterText: '',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Add a mood',
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
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5),
                side: BorderSide(color: selected ? c : p.border),
                backgroundColor: p.surface,
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          FbCard(
            child: SwitchListTile(
              value: _anonymous,
              onChanged: (v) => setState(() => _anonymous = v),
              title: Text('Post anonymously',
                  style: TextStyle(color: p.text, fontSize: 14.5, fontWeight: FontWeight.w700)),
              subtitle: Text('Your name will not be shown',
                  style: TextStyle(color: p.secondary, fontSize: 12.5)),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _controller.text.trim().isEmpty ? null : _submit,
              child: const Text('Post'),
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
                  padding: const EdgeInsets.only(top: 8),
                  children: [
                    PostCard(post: post, onTap: () {}),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
                      child: Text('Comments',
                          style: TextStyle(
                              color: p.text, fontSize: 15.5, fontWeight: FontWeight.w800)),
                    ),
                    if (post.comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: EmptyState(
                            icon: Icons.chat_bubble_outline,
                            message: 'No comments yet. Be the first.'),
                      ),
                    ...post.comments.map(
                      (c) => Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        child: FbCard(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Avatar(label: c.author, size: 36),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: p.surfaceAlt,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(c.author,
                                                style: TextStyle(
                                                    color: p.text,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 13)),
                                            const SizedBox(height: 2),
                                            Text(c.text,
                                                style: TextStyle(
                                                    color: p.text,
                                                    fontSize: 14,
                                                    height: 1.35)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(c.time,
                                          style: TextStyle(color: p.secondary, fontSize: 11.5)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                  color: p.surface,
                  child: Row(
                    children: [
                      const Avatar(label: 'A', size: 36),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(hintText: 'Write a comment...'),
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

// ------------------------------------------------------------- PROFILE

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
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            const SizedBox(width: 4),
          ],
        ),
        body: Column(
          children: [
            _header(context, p),
            const TabBar(
              tabs: [Tab(text: 'Posts'), Tab(text: 'About'), Tab(text: 'Friends'), Tab(text: 'Photos')],
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
                            message: 'No posts yet. Tap the create box to write one.');
                      }
                      return ListView(
                        padding: const EdgeInsets.only(top: 8, bottom: 20),
                        children: mine
                            .map((post) =>
                                PostCard(post: post, onTap: () => openPost(context, post)))
                            .toList(),
                      );
                    },
                  ),
                  _about(context, p),
                  _friends(context, p),
                  const EmptyState(icon: Icons.photo_library_outlined, message: 'No photos yet.'),
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
      children: [
        SizedBox(
          height: 148,
          child: Stack(
            children: [
              Container(height: 140, decoration: const BoxDecoration(gradient: Brand.cover)),
              Positioned(
                left: 0,
                right: 0,
                top: 86,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: p.surface),
                    child: const Avatar(label: 'A', size: 96),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(appState.username,
            style: TextStyle(color: p.text, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text('${appState.friends} friends',
            style: TextStyle(color: p.secondary, fontSize: 13.5)),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => openCompose(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add to story'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Edit profile'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _about(BuildContext context, Palette p) {
    Widget row(IconData icon, String text) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: p.secondary),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: TextStyle(color: p.text, fontSize: 14))),
            ],
          ),
        );
    return ListView(
      children: [
        row(Icons.info_outline, appState.bio),
        row(Icons.calendar_today_outlined, 'Joined October 2026'),
        row(Icons.location_on_outlined, 'Lives in India'),
        row(Icons.local_fire_department_outlined, '${appState.streak}-day streak'),
      ],
    );
  }

  Widget _friends(BuildContext context, Palette p) {
    return ListView(
      children: appState.people
          .map(
            (person) => Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  Avatar(label: person.name, size: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(person.name,
                        style: TextStyle(
                            color: p.text, fontSize: 14.5, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
