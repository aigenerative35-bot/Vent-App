import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ads.dart';
import 'auth.dart';
import 'theme.dart';
import 'models.dart';
import 'widgets.dart';

void openPost(BuildContext context, Post post) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)));
}

void openCompose(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ComposeScreen()));
}

void openUser(BuildContext context, User user) {
  if (user.isMe) return;
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => UserProfileScreen(user: user)));
}

void openTopic(BuildContext context, String tag) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => TopicScreen(tag: tag)));
}

Future<void> pickStatus(BuildContext context) async {
  final picker = ImagePicker();
  final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
  if (file == null) return;
  final bytes = await file.readAsBytes();
  appState.addStatus(imageBytes: bytes);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Status added - it disappears in 24 hours')),
    );
  }
}

void openStatus(BuildContext context, Status status) {
  final p = Palette.of(context);
  final grad = statusGradients[status.gradientIndex % statusGradients.length];
  final h = status.remaining.inHours;
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: status.imageBytes != null
                  ? Image.memory(status.imageBytes!, fit: BoxFit.cover)
                  : Container(
                      decoration: BoxDecoration(gradient: LinearGradient(colors: grad)),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(24),
                      child: Text(status.caption.isEmpty ? status.author : status.caption,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text('${status.author}  ·  expires in ${h}h', style: TextStyle(color: p.surface, fontSize: 13)),
        ],
      ),
    ),
  );
}

void shareSheet(BuildContext context, Post post) {
  final p = Palette.of(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: p.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Text('Share', style: TextStyle(color: p.text, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ListTile(
            leading: Icon(Icons.people_alt_outlined, color: Brand.blue),
            title: Text('Share to my followers', style: TextStyle(color: p.text)),
            onTap: () {
              appState.share(post);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shared to your followers')));
            },
          ),
          ...appState.groups.map(
            (g) => ListTile(
              leading: Icon(Icons.groups_outlined, color: Brand.blue),
              title: Text('Share to ${g.name}', style: TextStyle(color: p.text)),
              onTap: () {
                appState.share(post, toGroup: g.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Shared to ${g.name}')));
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.link, color: Brand.blue),
            title: Text('Copy link', style: TextStyle(color: p.text)),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied')));
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------- HOME

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 3, vsync: this);
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 500) {
        appState.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    _scroll.dispose();
    super.dispose();
  }

  List<Post> _list() {
    switch (_tab.index) {
      case 0:
        return appState.interestFeed;
      case 1:
        return appState.feed;
      default:
        return appState.groupFeed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 14,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(gradient: Brand.gradient, borderRadius: BorderRadius.circular(9)),
              alignment: Alignment.center,
              child: const Text('S', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(19)),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 18, color: p.secondary),
                    const SizedBox(width: 8),
                    Text('Search Snip', style: TextStyle(color: p.secondary, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tab,
          onTap: (_) => setState(() {}),
          tabs: const [Tab(text: 'For You'), Tab(text: 'Latest'), Tab(text: 'Group Feed')],
        ),
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final list = _list();
          final children = <Widget>[];
          if (_tab.index == 0) {
            children.add(const CreateBox());
            children.add(const SizedBox(height: 12));
            children.add(const StatusRow());
            children.add(_topicsRow(context));
            children.add(const SectionHeader(icon: Icons.auto_awesome, title: 'Recommended for you', subtitle: '70% matched to your interests'));
          }
          if (_tab.index == 2) {
            children.add(const SectionHeader(icon: Icons.groups_outlined, title: 'Group Feed', subtitle: 'Posts from groups you joined'));
          }
          for (var i = 0; i < list.length; i++) {
            children.add(PostCard(
              post: list[i],
              onTap: () => openPost(context, list[i]),
              onTag: (t) => openTopic(context, t),
              onAuthor: (u) => openUser(context, u),
            ));
            if (i > 0 && i % 7 == 0) children.add(const FeedAdSlot());
          }
          if (appState.hasMore) {
            children.add(const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
            ));
          } else {
            children.add(Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('You are all caught up', style: TextStyle(color: p.secondary, fontSize: 12.5))),
            ));
          }
          return ListView(controller: _scroll, padding: const EdgeInsets.only(top: 10, bottom: 20), children: children);
        },
      ),
    );
  }

  Widget _topicsRow(BuildContext context) {
    final p = Palette.of(context);
    final topics = appState.trendingTopics;
    if (topics.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Row(
            children: [
              Icon(Icons.tag, size: 17, color: Brand.blue),
              const SizedBox(width: 6),
              Text('Trending topics', style: TextStyle(color: p.text, fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: topics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final t = topics[i];
              return GestureDetector(
                onTap: () => openTopic(context, t.name),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: p.border),
                  ),
                  child: Row(
                    children: [
                      Text('#${t.name}', style: TextStyle(color: p.text, fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      Text(fmt(t.posts), style: TextStyle(color: p.secondary, fontSize: 11.5)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CreateBox extends StatelessWidget {
  const CreateBox({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Block(
        onTap: () => openCompose(context),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Avatar(label: 'A', color: Brand.blue),
            const SizedBox(width: 12),
            Expanded(child: Text('What is on your mind?', style: TextStyle(color: p.secondary, fontSize: 15))),
            const Icon(Icons.edit_outlined, size: 20, color: Brand.blue),
          ],
        ),
      ),
    );
  }
}

class StatusRow extends StatelessWidget {
  const StatusRow({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final statuses = appState.activeStatuses;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
          child: Row(
            children: [
              Text('Status', style: TextStyle(color: p.text, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Expanded(child: Text('disappears after 24 hours', style: TextStyle(color: p.secondary, fontSize: 12))),
            ],
          ),
        ),
        SizedBox(
          height: 104,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              StatusRing(label: 'Add status', add: true, onTap: () => pickStatus(context)),
              ...statuses.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: StatusRing(
                    label: s.author,
                    imageBytes: s.imageBytes,
                    gradient: LinearGradient(colors: statusGradients[s.gradientIndex % statusGradients.length]),
                    onTap: () => openStatus(context, s),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ DISCOVER

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 4, 14, 6),
                child: TextField(
                  decoration: InputDecoration(hintText: 'Search posts, moods, people...', prefixIcon: Icon(Icons.search, size: 20)),
                ),
              ),
              const SectionHeader(icon: Icons.tag, title: 'Trending topics'),
              ...appState.trendingTopics.map(
                (t) => ListTile(
                  onTap: () => openTopic(context, t.name),
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Brand.blue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.tag, color: Brand.blue, size: 20),
                  ),
                  title: Text('#${t.name}', style: TextStyle(color: p.text, fontWeight: FontWeight.w700, fontSize: 14.5)),
                  subtitle: Text('${fmt(t.posts)} posts', style: TextStyle(color: p.secondary, fontSize: 12.5)),
                ),
              ),
              const SectionHeader(icon: Icons.local_fire_department, title: 'Hot right now'),
              ...appState.trending.take(8).map((post) => PostCard(
                    post: post,
                    onTap: () => openPost(context, post),
                    onTag: (t) => openTopic(context, t),
                    onAuthor: (u) => openUser(context, u),
                  )),
            ],
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------- GROUPS

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Brand.blue,
        onPressed: () => _createDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 90),
            children: appState.groups
                .map((g) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Block(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 46, height: 46,
                                  decoration: BoxDecoration(gradient: Brand.gradient, borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.groups, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(g.name, style: TextStyle(color: p.text, fontSize: 15, fontWeight: FontWeight.w800)),
                                      Text('${fmt(g.members)} members', style: TextStyle(color: p.secondary, fontSize: 12.5)),
                                    ],
                                  ),
                                ),
                                g.joined
                                    ? OutlinedButton(
                                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                                        onPressed: () => appState.toggleGroup(g),
                                        child: const Text('Joined'))
                                    : FilledButton(
                                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9)),
                                        onPressed: () => appState.toggleGroup(g),
                                        child: const Text('Join')),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(g.description, style: TextStyle(color: p.secondary, fontSize: 13.5, height: 1.35)),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }

  void _createDialog(BuildContext context) {
    final name = TextEditingController();
    final desc = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(hintText: 'Group name')),
            const SizedBox(height: 10),
            TextField(controller: desc, decoration: const InputDecoration(hintText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isNotEmpty) appState.addGroup(name.text.trim(), desc.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------- STATUS

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Status')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final statuses = appState.activeStatuses;
          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
            children: [
              Block(
                onTap: () => pickStatus(context),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: const BoxDecoration(gradient: Brand.gradient, shape: BoxShape.circle),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Add a photo status', style: TextStyle(color: p.text, fontSize: 15, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text('It stays for 24 hours, then deletes itself', style: TextStyle(color: p.secondary, fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Recent statuses', style: TextStyle(color: p.text, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              if (statuses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: EmptyState(icon: Icons.auto_stories_outlined, message: 'No statuses right now.'),
                ),
              ...statuses.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Block(
                    onTap: () => openStatus(context, s),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 60, height: 60,
                            child: s.imageBytes != null
                                ? Image.memory(s.imageBytes!, fit: BoxFit.cover)
                                : Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: statusGradients[s.gradientIndex % statusGradients.length])),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.author, style: TextStyle(color: p.text, fontSize: 14.5, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 3),
                              Text('Expires in ${s.remaining.inHours}h ${s.remaining.inMinutes % 60}m',
                                  style: TextStyle(color: Brand.blue, fontSize: 12.5)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: p.secondary),
                      ],
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
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
            children: appState.notifications
                .map((n) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Block(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 42, height: 42,
                              decoration: BoxDecoration(gradient: Brand.gradient, borderRadius: BorderRadius.circular(12)),
                              child: Icon(n.icon, size: 20, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n.text, style: TextStyle(color: p.text, fontSize: 14, height: 1.3)),
                                  const SizedBox(height: 3),
                                  Text(n.time, style: TextStyle(color: Brand.blue, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
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
  final _pollControllers = List.generate(4, (_) => TextEditingController());
  bool _pollOn = false;
  String _mood = moodList.first;
  late bool _anonymous = appState.publicByDefault ? false : true;
  PostVisibility _visibility = PostVisibility.public;

  @override
  void dispose() {
    _controller.dispose();
    for (final c in _pollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _tags(String text) =>
      text.split(RegExp(r'\s+')).where((w) => w.startsWith('#') && w.length > 1).toList();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Poll? poll;
    if (_pollOn) {
      final opts = _pollControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
      if (opts.length >= 2) poll = Poll(options: opts);
    }
    appState.addPost(text, _mood, _anonymous, _visibility, _tags(text), poll);
    _controller.clear();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Posted')));
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create post'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10)),
              onPressed: _controller.text.trim().isEmpty ? null : _submit,
              child: const Text('Post'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        children: [
          Row(
            children: [
              Avatar(label: _anonymous ? 'A' : appState.me.name[0],
                  color: _anonymous ? p.secondary : Brand.blue, verified: !_anonymous),
              const SizedBox(width: 10),
              Text(_anonymous ? 'Anjaan' : appState.me.name,
                  style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            maxLines: 7,
            maxLength: 300,
            autofocus: true,
            style: TextStyle(color: p.text, fontSize: 18, height: 1.45),
            decoration: const InputDecoration(
              hintText: 'What is on your mind?  Use #tags to join a topic',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              counterText: '',
            ),
          ),
          const SizedBox(height: 6),
          Divider(color: p.divider),
          const SizedBox(height: 14),
          Text('Who can see this', style: TextStyle(color: p.text, fontSize: 14.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: PostVisibility.values.map((v) {
              final selected = v == _visibility;
              final label = v == PostVisibility.public ? 'Public' : v == PostVisibility.followers ? 'Followers' : 'Private';
              return ChoiceChip(
                avatar: Icon(visibilityIcon(v), size: 15, color: selected ? Colors.white : p.secondary),
                label: Text(label),
                selected: selected,
                onSelected: (_) => setState(() => _visibility = v),
                showCheckmark: false,
                selectedColor: Brand.blue,
                labelStyle: TextStyle(color: selected ? Colors.white : p.text, fontWeight: FontWeight.w700, fontSize: 12.5),
                backgroundColor: p.surface,
                side: BorderSide(color: p.border),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('Add a mood', style: TextStyle(color: p.text, fontSize: 14.5, fontWeight: FontWeight.w800)),
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
                selectedColor: c.withValues(alpha: 0.16),
                labelStyle: TextStyle(color: selected ? c : p.secondary, fontWeight: FontWeight.w700, fontSize: 12.5),
                side: BorderSide(color: selected ? c : p.border),
                backgroundColor: p.surface,
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Block(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: SwitchListTile(
              value: _anonymous,
              onChanged: (v) => setState(() => _anonymous = v),
              title: Text('Post anonymously', style: TextStyle(color: p.text, fontSize: 14.5, fontWeight: FontWeight.w700)),
              subtitle: Text('Your name will not be shown', style: TextStyle(color: p.secondary, fontSize: 12.5)),
            ),
          ),
          const SizedBox(height: 16),
          Block(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: SwitchListTile(
              value: _pollOn,
              onChanged: (v) => setState(() => _pollOn = v),
              title: Text('Add a poll', style: TextStyle(color: p.text, fontSize: 14.5, fontWeight: FontWeight.w700)),
              subtitle: Text('Up to 4 options', style: TextStyle(color: p.secondary, fontSize: 12.5)),
            ),
          ),
          if (_pollOn) ...[
            const SizedBox(height: 8),
            ...List.generate(4, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _pollControllers[i],
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(hintText: 'Option ${i + 1}${i < 2 ? '' : ' (optional)'}'),
                  ),
                )),
          ],
          const SizedBox(height: 8),
          Text('Posts are text only (max 300). Use Status for photos. Posts auto-delete after 1 month.',
              style: TextStyle(color: p.secondary, fontSize: 12)),
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
  Comment? _replyTo;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final t = _controller.text.trim();
    if (t.isEmpty) return;
    if (_replyTo != null) {
      appState.addReply(_replyTo!, t);
    } else {
      appState.addComment(widget.post, t);
    }
    _controller.clear();
    setState(() => _replyTo = null);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final post = widget.post;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          IconButton(onPressed: () => shareSheet(context, post), icon: const Icon(Icons.share_outlined)),
          const SizedBox(width: 4),
        ],
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 10),
                  children: [
                    PostCard(
                      post: post,
                      onTap: () {},
                      onTag: (t) => openTopic(context, t),
                      onAuthor: (u) => openUser(context, u),
                    ),
                    const SectionHeader(title: 'Comments'),
                    if (post.comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: EmptyState(icon: Icons.chat_bubble_outline, message: 'No comments yet.'),
                      ),
                    ...post.comments.map(
                      (c) => Padding(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                        child: CommentTile(
                          comment: c,
                          onReply: () => setState(() => _replyTo = c),
                          onLike: () => appState.toggleCommentLike(c),
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
                  decoration: BoxDecoration(color: p.surface, border: Border(top: BorderSide(color: p.divider))),
                  child: Column(
                    children: [
                      if (_replyTo != null)
                        Row(
                          children: [
                            Text('Replying to ${_replyTo!.author}', style: TextStyle(color: Brand.blue, fontSize: 12)),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => setState(() => _replyTo = null),
                              child: Text('Cancel', style: TextStyle(color: p.secondary, fontSize: 12)),
                            ),
                          ],
                        ),
                      Row(
                        children: [
                          const Avatar(label: 'A', size: 36, color: Brand.blue),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(hintText: _replyTo == null ? 'Write a comment...' : 'Write a reply...'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(onPressed: _send, icon: const Icon(Icons.send_rounded, size: 18)),
                        ],
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

// -------------------------------------------------------------- TOPIC

class TopicScreen extends StatelessWidget {
  final String tag;
  const TopicScreen({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('#$tag')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final list = appState.postsWithTag(tag);
          if (list.isEmpty) {
            return const EmptyState(icon: Icons.tag, message: 'No posts in this topic yet.');
          }
          return ListView(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            children: list.map((post) => PostCard(
                  post: post,
                  onTap: () => openPost(context, post),
                  onTag: (t) => openTopic(context, t),
                  onAuthor: (u) => openUser(context, u),
                )).toList(),
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------- USER PROFILE

class UserProfileScreen extends StatelessWidget {
  final User user;
  const UserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final theirPosts = appState.posts.where((x) => !x.anonymous && x.author == user.name).toList();
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(height: 110, decoration: const BoxDecoration(gradient: Brand.cover)),
              Transform.translate(
                offset: const Offset(0, -44),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: p.bg),
                            child: Avatar(label: user.name, size: 88, color: avatarColors[user.colorIndex], verified: user.verified),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: FollowButton(user: user),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(user.name, style: TextStyle(color: p.text, fontSize: 20, fontWeight: FontWeight.w800)),
                          if (user.verified) ...[const SizedBox(width: 5), const VerifiedBadge(size: 17)],
                        ],
                      ),
                      Text(user.handle, style: TextStyle(color: p.secondary, fontSize: 14)),
                      const SizedBox(height: 8),
                      if (user.bio.isNotEmpty) Text(user.bio, style: TextStyle(color: p.text, fontSize: 14, height: 1.4)),
                      const SizedBox(height: 8),
                      Text('${fmt(user.following)} following  ·  ${fmt(user.followers)} followers',
                          style: TextStyle(color: p.secondary, fontSize: 13)),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: p.divider),
              if (theirPosts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: EmptyState(icon: Icons.article_outlined, message: 'No public posts yet.'),
                ),
              ...theirPosts.map((post) => PostCard(
                    post: post,
                    onTap: () => openPost(context, post),
                    onTag: (t) => openTopic(context, t),
                  )),
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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Me'),
          actions: [
            IconButton(onPressed: () => openStudio(context), icon: const Icon(Icons.insights_outlined)),
            IconButton(onPressed: () => _open(context, const SettingsScreen()), icon: const Icon(Icons.settings_outlined)),
            const SizedBox(width: 4),
          ],
        ),
        body: Column(
          children: [
            _header(context, p),
            const TabBar(tabs: [Tab(text: 'Posts'), Tab(text: 'Status'), Tab(text: 'About')]),
            Expanded(
              child: TabBarView(
                children: [
                  ListenableBuilder(
                    listenable: appState,
                    builder: (context, _) {
                      final mine = appState.myPosts;
                      if (mine.isEmpty) return const EmptyState(icon: Icons.edit_note, message: 'No posts yet.');
                      return ListView(
                        padding: const EdgeInsets.only(top: 10, bottom: 20),
                        children: mine.map((post) => PostCard(
                              post: post,
                              onTap: () => openPost(context, post),
                              onTag: (t) => openTopic(context, t),
                            )).toList(),
                      );
                    },
                  ),
                  ListenableBuilder(
                    listenable: appState,
                    builder: (context, _) {
                      final mine = appState.activeStatuses.where((s) => s.author == appState.me.name).toList();
                      if (mine.isEmpty) {
                        return const EmptyState(icon: Icons.auto_stories_outlined, message: 'No status yet. Add one from the Status tab.');
                      }
                      return ListView(
                        padding: const EdgeInsets.all(14),
                        children: mine.map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Block(
                                onTap: () => openStatus(context, s),
                                padding: const EdgeInsets.all(12),
                                child: Text('Status · expires in ${s.remaining.inHours}h', style: TextStyle(color: p.text, fontSize: 14)),
                              ),
                            )).toList(),
                      );
                    },
                  ),
                  ListView(
                    children: [
                      ListTile(leading: Icon(Icons.info_outline, color: p.secondary), title: Text(appState.me.bio, style: TextStyle(color: p.text, fontSize: 14))),
                      ListTile(leading: Icon(Icons.alternate_email, color: p.secondary), title: Text(appState.me.handle, style: TextStyle(color: p.text, fontSize: 14))),
                      ListTile(leading: Icon(Icons.link, color: p.secondary), title: Text(appState.me.link.isEmpty ? 'No link yet' : appState.me.link, style: TextStyle(color: p.text, fontSize: 14))),
                      ListTile(leading: Icon(Icons.public, color: p.secondary), title: Text(appState.me.country.isEmpty ? 'No country set' : appState.me.country, style: TextStyle(color: p.text, fontSize: 14))),
                      ListTile(leading: Icon(Icons.local_fire_department_outlined, color: p.secondary), title: Text('${appState.streak}-day streak', style: TextStyle(color: p.text, fontSize: 14))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget w) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));
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
                left: 0, right: 0, top: 86,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: p.bg),
                    child: const Avatar(label: 'A', size: 96, verified: false),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(appState.me.name, style: TextStyle(color: p.text, fontSize: 22, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 2),
        Text('${fmt(appState.me.following)} following  ·  ${fmt(appState.me.followers)} followers',
            style: TextStyle(color: p.secondary, fontSize: 13)),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => openCompose(context),
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  label: const Text('New post'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen())),
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
}

// --------------------------------------------------------- ADMIN PANEL

class StudioScreen extends StatelessWidget {
  const StudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Studio')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
            children: [
              Text('Analytics', style: TextStyle(color: p.text, fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _stat(context, Icons.visibility_outlined, fmt(appState.totalViews), 'Views'),
                  const SizedBox(width: 10),
                  _stat(context, Icons.favorite_border, fmt(appState.totalLikes), 'Likes'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _stat(context, Icons.mode_comment_outlined, fmt(appState.totalComments), 'Comments'),
                  const SizedBox(width: 10),
                  _stat(context, Icons.people_alt_outlined, fmt(appState.me.followers), 'Followers'),
                ],
              ),
              const SizedBox(height: 18),
              Text('Views this week', style: TextStyle(color: p.text, fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              _chart(context, appState.viewsByDay),
              const SizedBox(height: 20),
              Text('Manage', style: TextStyle(color: p.text, fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              _action(context, Icons.edit_outlined, 'Create a post', () => openCompose(context)),
              _action(context, Icons.link, 'Links', () => _linksDialog(context)),
              _action(context, Icons.info_outline, 'About us', () => _aboutDialog(context)),
              _action(context, Icons.groups_outlined, 'Groups', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GroupsScreen()))),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(BuildContext context, IconData icon, String value, String label) {
    final p = Palette.of(context);
    return Expanded(
      child: Block(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Brand.blue),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: p.text, fontSize: 20, fontWeight: FontWeight.w800)),
            Text(label, style: TextStyle(color: p.secondary, fontSize: 12.5)),
          ],
        ),
      ),
    );
  }

  Widget _chart(BuildContext context, List<int> data) {
    final p = Palette.of(context);
    final maxV = data.reduce((a, b) => a > b ? a : b);
    return Block(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 120,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data
              .map((v) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: (v / maxV) * 90 + 6,
                            decoration: BoxDecoration(
                              gradient: Brand.gradient,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('$v', style: TextStyle(color: p.secondary, fontSize: 9.5)),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _action(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Block(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: Brand.blue, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(color: p.text, fontSize: 14.5, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, color: p.secondary),
          ],
        ),
      ),
    );
  }

  void _linksDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Links'),
        content: const Text('Add links to your profile - website, socials, contact.\n\n(Stored once the backend is connected.)'),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _aboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About us'),
        content: const Text('Snip is a safe, anonymous place to say how you feel.\n\nBe kind. Report abuse. Posts auto-delete after 1 month.'),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }
}

// ----------------------------------------------------------- SETTINGS

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
            children: [
              Text('Account', style: TextStyle(color: p.text, fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Block(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Avatar(label: 'A', size: 44, color: Brand.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appState.me.name, style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 14.5)),
                          Text(appState.me.handle, style: TextStyle(color: p.secondary, fontSize: 12.5)),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                      onPressed: () {
                        appState.me.handle = appState.suggestUsername(appState.me.name);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('New username: ${appState.me.handle}')),
                        );
                      },
                      child: const Text('New username'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text('Notifications', style: TextStyle(color: p.text, fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Block(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: appState.notifyReplies,
                      onChanged: (v) => setState(() => appState.notifyReplies = v),
                      title: Text('Replies and comments', style: TextStyle(color: p.text, fontSize: 14)),
                    ),
                    SwitchListTile(
                      value: appState.notifyLikes,
                      onChanged: (v) => setState(() => appState.notifyLikes = v),
                      title: Text('Likes and follows', style: TextStyle(color: p.text, fontSize: 14)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text('Privacy', style: TextStyle(color: p.text, fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Block(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: appState.publicByDefault,
                      onChanged: (v) => setState(() => appState.publicByDefault = v),
                      title: Text('New posts are public by default', style: TextStyle(color: p.text, fontSize: 14)),
                    ),
                    SwitchListTile(
                      value: appState.showAds,
                      onChanged: (v) => setState(() => appState.showAds = v),
                      title: Text('Show sponsored posts', style: TextStyle(color: p.text, fontSize: 14)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Block(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, color: Brand.blue),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Every post auto-deletes 1 month after it is created.', style: TextStyle(color: p.secondary, fontSize: 13))),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Block(
                onTap: () => auth.signOut(),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Brand.red),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Sign out', style: TextStyle(color: Brand.red, fontSize: 14.5, fontWeight: FontWeight.w700))),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<void> openStudio(BuildContext context) async {
  await showRewardedAd();
  if (!context.mounted) return;
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudioScreen()));
}

/// Native ad slot that blends into the feed.
class FeedAdSlot extends StatelessWidget {
  const FeedAdSlot({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Block(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(gradient: Brand.gradient, borderRadius: BorderRadius.circular(11)),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sponsored', style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 14)),
                      Text('Based on your interests', style: TextStyle(color: p.secondary, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(6)),
                  child: Text('Ad', style: TextStyle(color: p.secondary, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            nativeAdWidget(),
          ],
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _name = TextEditingController(text: appState.me.name);
  late final _handle = TextEditingController(text: appState.me.handle);
  late final _bio = TextEditingController(text: appState.me.bio);
  late final _link = TextEditingController(text: appState.me.link);
  late final _country = TextEditingController(text: appState.me.country);

  @override
  void dispose() {
    _name.dispose();
    _handle.dispose();
    _bio.dispose();
    _link.dispose();
    _country.dispose();
    super.dispose();
  }

  void _save() {
    setState(() {
      if (_name.text.trim().isNotEmpty) appState.me.name = _name.text.trim();
      if (_handle.text.trim().isNotEmpty) appState.me.handle = _handle.text.trim();
      appState.me.bio = _bio.text.trim();
      appState.me.link = _link.text.trim();
      appState.me.country = _country.text.trim();
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10)),
              onPressed: _save,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Center(child: Avatar(label: appState.me.name, size: 88, color: Brand.blue)),
          const SizedBox(height: 6),
          Center(
            child: TextButton.icon(
              onPressed: () {
                appState.me.handle = appState.suggestUsername(_name.text);
                _handle.text = appState.me.handle;
                setState(() {});
              },
              icon: const Icon(Icons.autorenew, size: 17),
              label: const Text('Generate username'),
            ),
          ),
          const SizedBox(height: 10),
          Text('Display name', style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 6),
          TextField(controller: _name, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'Your name')),
          const SizedBox(height: 16),
          Text('Username', style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 6),
          TextField(controller: _handle, decoration: const InputDecoration(hintText: '@username')),
          const SizedBox(height: 16),
          Text('Bio', style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 6),
          TextField(controller: _bio, maxLines: 3, decoration: const InputDecoration(hintText: 'About you')),
          const SizedBox(height: 16),
          Text('Link', style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 6),
          TextField(controller: _link, keyboardType: TextInputType.url, decoration: const InputDecoration(hintText: 'https://your-site.com')),
          const SizedBox(height: 16),
          Text('Country', style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 6),
          TextField(controller: _country, decoration: const InputDecoration(hintText: 'India')),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- AUTH

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isSignUp = false;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    final email = _email.text.trim();
    if (email.isEmpty || _pass.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter email and password')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      if (_isSignUp) {
        final name = _name.text.trim().isEmpty ? email.split('@').first : _name.text.trim();
        await auth.signUp(name, email, _pass.text);
      } else {
        await auth.signInWithEmail(email, _pass.text);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          children: [
            Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(gradient: Brand.gradient, borderRadius: BorderRadius.circular(22)),
                alignment: Alignment.center,
                child: const Text('S',
                    style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: Text('Snip', style: TextStyle(color: p.text, fontSize: 30, fontWeight: FontWeight.w900))),
            const SizedBox(height: 6),
            Center(child: Text('Say it. Snip it.', style: TextStyle(color: p.secondary, fontSize: 14))),
            const SizedBox(height: 34),
            if (_isSignUp) ...[
              TextField(controller: _name, decoration: const InputDecoration(hintText: 'Name')),
              const SizedBox(height: 12),
            ],
            TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Email')),
            const SizedBox(height: 12),
            TextField(
                controller: _pass,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Password')),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _busy ? null : _go,
              child: Text(_busy ? 'Please wait...' : (_isSignUp ? 'Create account' : 'Sign in')),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _busy ? null : () => setState(() => _isSignUp = !_isSignUp),
              child: Text(_isSignUp ? 'Already have an account? Sign in' : 'New here? Create an account'),
            ),
            const SizedBox(height: 6),
            OutlinedButton(
              onPressed: _busy ? null : () => auth.continueAsGuest(),
              child: const Text('Continue as guest'),
            ),
            const SizedBox(height: 22),
            Text('Google / Apple sign-in gets wired up with the backend.',
                textAlign: TextAlign.center, style: TextStyle(color: p.secondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
