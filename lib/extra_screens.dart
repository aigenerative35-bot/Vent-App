import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';
import 'widgets.dart';
import 'i18n.dart';
import 'screens.dart';

void openScreen(BuildContext c, Widget w) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => w));

/// Search across users, #tags and post text.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('action.search'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _q,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search users, posts, #tags',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _q.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _q.clear();
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: appState,
              builder: (context, _) {
                final q = _q.text.trim();
                if (q.isEmpty) {
                  return EmptyState(icon: Icons.search, message: tr('empty.search'));
                }
                final users = appState.searchUsers(q);
                final tags = appState.searchTags(q);
                final posts = appState.searchPosts(q);
                if (users.isEmpty && tags.isEmpty && posts.isEmpty) {
                  return EmptyState(icon: Icons.search_off, message: 'No results for "$q".');
                }
                return ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    if (users.isNotEmpty) const SectionHeader(title: 'People', icon: Icons.person_outline),
                    ...users.map((u) => UserTile(user: u, onTap: () => openScreen(context, UserProfileScreen(user: u)))),
                    if (tags.isNotEmpty) const SectionHeader(title: 'Tags', icon: Icons.tag),
                    if (tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tags
                              .take(20)
                              .map((t) => ActionChip(label: Text('#$t'), onPressed: () => openScreen(context, TopicScreen(tag: t))))
                              .toList(),
                        ),
                      ),
                    if (posts.isNotEmpty) const SectionHeader(title: 'Posts', icon: Icons.article_outlined),
                    ...posts.map((post) => PostCard(
                          post: post,
                          onTap: () => openScreen(context, PostDetailScreen(post: post)),
                          onTag: (t) => openScreen(context, TopicScreen(tag: t)),
                          onAuthor: (u) => openScreen(context, UserProfileScreen(user: u)),
                        )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Posts the user saved with the bookmark action.
class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('title.bookmarks'))),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final list = appState.bookmarkedPosts;
          if (list.isEmpty) {
            return EmptyState(icon: Icons.bookmark_border, message: tr('empty.bookmarks'));
          }
          return ListView(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            children: list
                .map((post) => PostCard(
                      post: post,
                      onTap: () => openScreen(context, PostDetailScreen(post: post)),
                      onTag: (t) => openScreen(context, TopicScreen(tag: t)),
                      onAuthor: (u) => openScreen(context, UserProfileScreen(user: u)),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

/// Unfinished posts, saved for later.
class DraftsScreen extends StatelessWidget {
  const DraftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr('title.drafts'))),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final list = appState.drafts;
          if (list.isEmpty) {
            return EmptyState(icon: Icons.edit_note, message: tr('empty.drafts'));
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: list
                .map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Block(
                        padding: const EdgeInsets.all(14),
                        onTap: () => openScreen(context, ComposeScreen(draft: d)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                MoodTag(mood: d.mood),
                                const SizedBox(width: 8),
                                Text('Draft', style: TextStyle(color: p.secondary, fontSize: 12)),
                                const Spacer(),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: Icon(Icons.delete_outline, size: 20, color: p.secondary),
                                  onPressed: () => appState.removeDraft(d),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(d.text.isEmpty ? '(empty)' : d.text,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: p.text, fontSize: 14.5, height: 1.35)),
                            if (d.imageBytes != null) ...[
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(d.imageBytes!, height: 120, width: double.infinity, fit: BoxFit.cover),
                              ),
                            ],
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

/// Followers / following lists with follow buttons.
class FollowListScreen extends StatelessWidget {
  const FollowListScreen({super.key, this.startOnFollowing = true});
  final bool startOnFollowing;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: startOnFollowing ? 1 : 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('title.people')),
          bottom: TabBar(tabs: [Tab(text: tr('title.followers')), Tab(text: tr('title.following'))]),
        ),
        body: ListenableBuilder(
          listenable: appState,
          builder: (context, _) {
            final followers = appState.followersList;
            final following = appState.followingList;
            return TabBarView(
              children: [
                followers.isEmpty
                    ? const EmptyState(icon: Icons.person_outline, message: 'No followers yet.')
                    : ListView(
                        padding: const EdgeInsets.only(top: 8, bottom: 20),
                        children: followers.map((u) => UserTile(user: u, onTap: () => openScreen(context, UserProfileScreen(user: u)))).toList(),
                      ),
                following.isEmpty
                    ? const EmptyState(icon: Icons.person_add_alt, message: 'You are not following anyone yet.')
                    : ListView(
                        padding: const EdgeInsets.only(top: 8, bottom: 20),
                        children: following.map((u) => UserTile(user: u, onTap: () => openScreen(context, UserProfileScreen(user: u)))).toList(),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Manage blocked and muted accounts.
class BlockedMutedScreen extends StatelessWidget {
  const BlockedMutedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('title.blocked'))),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final blocked = appState.blockedUsers;
          final muted = appState.mutedUsers;
          if (blocked.isEmpty && muted.isEmpty) {
            return EmptyState(icon: Icons.block, message: tr('empty.blocked'));
          }
          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            children: [
              if (blocked.isNotEmpty) const SectionHeader(title: 'Blocked', icon: Icons.block),
              ...blocked.map((u) => _row(context, u, true)),
              if (muted.isNotEmpty) const SectionHeader(title: 'Muted', icon: Icons.volume_off_outlined),
              ...muted.map((u) => _row(context, u, false)),
            ],
          );
        },
      ),
    );
  }

  Widget _row(BuildContext context, User u, bool blocked) {
    return Block(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Avatar(label: u.name, size: 44, color: avatarColors[u.colorIndex], verified: u.verified, imageBytes: u.avatarBytes),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.name, style: TextStyle(color: Palette.of(context).text, fontWeight: FontWeight.w800, fontSize: 14.5)),
                Text(u.handle, style: TextStyle(color: Palette.of(context).secondary, fontSize: 12.5)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => blocked ? appState.toggleBlock(u) : appState.toggleMute(u),
            child: Text(blocked ? tr('action.unblock') : tr('action.unmute')),
          ),
        ],
      ),
    );
  }
}
