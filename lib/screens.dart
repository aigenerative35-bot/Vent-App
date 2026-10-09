import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'theme.dart';
import 'models.dart';
import 'widgets.dart';

void openPost(BuildContext context, Post post) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)));
}

void openCompose(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ComposeScreen()));
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
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: grad),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(24),
                      child: Text(status.caption.isEmpty ? status.author : status.caption,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text('${status.author}  ·  expires in ${h}h',
              style: TextStyle(color: p.surface, fontSize: 13)),
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
        return appState.forYouFeed;
      case 1:
        return appState.feed;
      default:
        return appState.hotFeed;
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
              decoration: BoxDecoration(
                  gradient: Brand.gradient, borderRadius: BorderRadius.circular(9)),
              alignment: Alignment.center,
              child: const Text('V',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    color: p.surfaceAlt, borderRadius: BorderRadius.circular(19)),
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
        bottom: TabBar(
          controller: _tab,
          onTap: (_) => setState(() {}),
          tabs: const [Tab(text: 'For You'), Tab(text: 'Latest'), Tab(text: 'Hot')],
        ),
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final list = _list();
          return ListView(
            controller: _scroll,
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            children: [
              if (_tab.index == 0) ...[
                const CreateBox(),
                const SizedBox(height: 12),
                const StatusRow(),
                const SectionHeader(
                    icon: Icons.auto_awesome,
                    title: 'Recommended for you',
                    subtitle: 'AI picked'),
              ],
              ...list.map((post) => PostCard(post: post, onTap: () => openPost(context, post))),
              if (appState.hasMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text('You are all caught up',
                        style: TextStyle(color: p.secondary, fontSize: 12.5)),
                  ),
                ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Block(
        onTap: () => openCompose(context),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Avatar(label: 'A', color: Brand.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text('What is on your mind?',
                  style: TextStyle(color: p.secondary, fontSize: 15)),
            ),
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
              Text('Status',
                  style: TextStyle(color: p.text, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('disappears after 24 hours',
                    style: TextStyle(color: p.secondary, fontSize: 12)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 104,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              StatusRing(
                label: 'Add status',
                add: true,
                onTap: () => pickStatus(context),
              ),
              ...statuses.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: StatusRing(
                    label: s.author,
                    imageBytes: s.imageBytes,
                    gradient: LinearGradient(
                        colors: statusGradients[s.gradientIndex % statusGradients.length]),
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
                  decoration: InputDecoration(
                    hintText: 'Search posts, moods, people...',
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                ),
              ),
              const SectionHeader(icon: Icons.local_fire_department, title: 'Hot right now'),
              ...appState.trending
                  .take(12)
                  .map((post) => PostCard(post: post, onTap: () => openPost(context, post))),
            ],
          );
        },
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
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: Brand.gradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Add a photo status',
                              style: TextStyle(
                                  color: p.text, fontSize: 15, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text('It stays for 24 hours, then deletes itself',
                              style: TextStyle(color: p.secondary, fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Recent statuses',
                  style: TextStyle(color: p.text, fontSize: 16, fontWeight: FontWeight.w800)),
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
                            width: 60,
                            height: 60,
                            child: s.imageBytes != null
                                ? Image.memory(s.imageBytes!, fit: BoxFit.cover)
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: statusGradients[
                                          s.gradientIndex % statusGradients.length]),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.author,
                                  style: TextStyle(
                                      color: p.text, fontSize: 14.5, fontWeight: FontWeight.w800)),
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
                .map(
                  (n) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Block(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                                gradient: Brand.gradient,
                                borderRadius: BorderRadius.circular(12)),
                            child: Icon(n.icon, size: 20, color: Colors.white),
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
                                    style: TextStyle(color: Brand.blue, fontSize: 12)),
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
      appBar: AppBar(
        title: const Text('Create post'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10)),
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
              Avatar(
                  label: _anonymous ? 'A' : appState.username[0],
                  color: _anonymous ? p.secondary : Brand.blue),
              const SizedBox(width: 10),
              Text(_anonymous ? 'Anjaan' : appState.username,
                  style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            maxLines: 8,
            maxLength: 300,
            autofocus: true,
            style: TextStyle(color: p.text, fontSize: 18, height: 1.45),
            decoration: const InputDecoration(
              hintText: 'What is on your mind?',
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
                selectedColor: c.withValues(alpha: 0.16),
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
          const SizedBox(height: 16),
          Block(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: SwitchListTile(
              value: _anonymous,
              onChanged: (v) => setState(() => _anonymous = v),
              title: Text('Post anonymously',
                  style: TextStyle(color: p.text, fontSize: 14.5, fontWeight: FontWeight.w700)),
              subtitle: Text('Your name will not be shown',
                  style: TextStyle(color: p.secondary, fontSize: 12.5)),
            ),
          ),
          const SizedBox(height: 8),
          Text('Posts are text only. Use Status for photos.',
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
      appBar: AppBar(title: const Text('Post')),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 10),
                  children: [
                    PostCard(post: post, onTap: () {}),
                    const SectionHeader(title: 'Comments'),
                    if (post.comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: EmptyState(
                            icon: Icons.chat_bubble_outline, message: 'No comments yet.'),
                      ),
                    ...post.comments.map(
                      (c) => Padding(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                        child: CommentTile(
                          comment: c,
                          onReply: () {
                            setState(() => _replyTo = c);
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
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
                  decoration: BoxDecoration(
                    color: p.surface,
                    border: Border(top: BorderSide(color: p.divider)),
                  ),
                  child: Column(
                    children: [
                      if (_replyTo != null)
                        Row(
                          children: [
                            Text('Replying to ${_replyTo!.author}',
                                style: TextStyle(color: Brand.blue, fontSize: 12)),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => setState(() => _replyTo = null),
                              child: Text('Cancel',
                                  style: TextStyle(color: p.secondary, fontSize: 12)),
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
                              decoration: InputDecoration(
                                  hintText:
                                      _replyTo == null ? 'Write a comment...' : 'Write a reply...'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                              onPressed: _send, icon: const Icon(Icons.send_rounded, size: 18)),
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
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
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
                      if (mine.isEmpty) {
                        return const EmptyState(
                            icon: Icons.edit_note, message: 'No posts yet.');
                      }
                      return ListView(
                        padding: const EdgeInsets.only(top: 10, bottom: 20),
                        children: mine
                            .map((post) =>
                                PostCard(post: post, onTap: () => openPost(context, post)))
                            .toList(),
                      );
                    },
                  ),
                  ListenableBuilder(
                    listenable: appState,
                    builder: (context, _) {
                      final mine = appState.activeStatuses
                          .where((s) => s.author == appState.username)
                          .toList();
                      if (mine.isEmpty) {
                        return const EmptyState(
                            icon: Icons.auto_stories_outlined,
                            message: 'No status yet. Add one from the Status tab.');
                      }
                      return ListView(
                        padding: const EdgeInsets.all(14),
                        children: mine
                            .map((s) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Block(
                                    onTap: () => openStatus(context, s),
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                        'Status · expires in ${s.remaining.inHours}h',
                                        style: TextStyle(color: p.text, fontSize: 14)),
                                  ),
                                ))
                            .toList(),
                      );
                    },
                  ),
                  ListView(
                    children: [
                      ListTile(
                        leading: Icon(Icons.info_outline, color: p.secondary),
                        title: Text(appState.bio, style: TextStyle(color: p.text, fontSize: 14)),
                      ),
                      ListTile(
                        leading: Icon(Icons.calendar_today_outlined, color: p.secondary),
                        title: Text('Joined October 2026',
                            style: TextStyle(color: p.text, fontSize: 14)),
                      ),
                      ListTile(
                        leading: Icon(Icons.local_fire_department_outlined, color: p.secondary),
                        title: Text('${appState.streak}-day streak',
                            style: TextStyle(color: p.text, fontSize: 14)),
                      ),
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
                    decoration: BoxDecoration(shape: BoxShape.circle, color: p.bg),
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
        Text('${appState.following} following  ·  ${appState.friends} followers',
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
                child: OutlinedButton(onPressed: () {}, child: const Text('Edit profile')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
