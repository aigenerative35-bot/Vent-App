import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';

String fmt(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}

IconData visibilityIcon(PostVisibility v) {
  switch (v) {
    case PostVisibility.public:
      return Icons.public;
    case PostVisibility.followers:
      return Icons.people_alt_outlined;
    case PostVisibility.private:
      return Icons.lock_outline;
  }
}

class Avatar extends StatelessWidget {
  final String label;
  final double size;
  final Color? color;
  final bool verified;
  const Avatar({super.key, required this.label, this.size = 42, this.color, this.verified = false});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Brand.blue;
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            label.isNotEmpty ? label[0].toUpperCase() : '?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 0.4),
          ),
        ),
        if (verified)
          Positioned(
            right: -1,
            bottom: -1,
            child: VerifiedBadge(size: size * 0.42),
          ),
      ],
    );
  }
}

class VerifiedBadge extends StatelessWidget {
  final double size;
  const VerifiedBadge({super.key, this.size = 15});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Brand.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Palette.of(context).surface, width: size * 0.12),
      ),
      child: Icon(Icons.check, size: size * 0.62, color: Colors.white),
    );
  }
}

class MoodTag extends StatelessWidget {
  final String mood;
  const MoodTag({super.key, required this.mood});

  @override
  Widget build(BuildContext context) {
    final c = moodColors[mood] ?? Brand.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(20)),
      child: Text(mood, style: TextStyle(color: c, fontSize: 11.5, fontWeight: FontWeight.w800)),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.subtitle, this.icon, this.trailing});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 18, color: Brand.blue), const SizedBox(width: 7)],
          Text(title, style: TextStyle(color: p.text, fontSize: 16, fontWeight: FontWeight.w800)),
          if (subtitle != null) ...[
            const SizedBox(width: 6),
            Expanded(
              child: Text(subtitle!,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: p.secondary, fontSize: 12.5)),
            ),
          ] else
            const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Renders text with tappable #hashtags.
class TagText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final void Function(String tag) onTag;
  const TagText({super.key, required this.text, required this.style, required this.onTag});

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    final parts = text.split(' ');
    for (var i = 0; i < parts.length; i++) {
      final w = parts[i];
      final space = i == parts.length - 1 ? '' : ' ';
      if (w.startsWith('#') && w.length > 1) {
        spans.add(TextSpan(
          text: '$w$space',
          style: style.copyWith(color: Brand.blue, fontWeight: FontWeight.w700),
          recognizer: TapGestureRecognizer()..onTap = () => onTag(w.substring(1)),
        ));
      } else {
        spans.add(TextSpan(text: '$w$space', style: style));
      }
    }
    return RichText(text: TextSpan(children: spans));
  }
}

class StatAction extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;
  final VoidCallback onTap;
  final bool showLabel;
  final String? label;
  const StatAction({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
    required this.onTap,
    this.showLabel = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(showLabel ? (label ?? '$value') : fmt(value),
                style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class FollowButton extends StatelessWidget {
  final User user;
  const FollowButton({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.isMe) return const SizedBox.shrink();
    final following = appState.isFollowing(user);
    return following
        ? OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () => appState.toggleFollow(user),
            child: const Text('Following'),
          )
        : FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            ),
            onPressed: () => appState.toggleFollow(user),
            child: const Text('Follow'),
          );
  }
}

class UserTile extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;
  const UserTile({super.key, required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Block(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Avatar(label: user.name, size: 48, color: avatarColors[user.colorIndex], verified: user.verified),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user.name, style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 14.5)),
                    if (user.verified) ...[const SizedBox(width: 4), const VerifiedBadge(size: 14)],
                  ],
                ),
                const SizedBox(height: 2),
                Text('${user.handle}  ·  ${fmt(user.followers)} followers',
                    style: TextStyle(color: p.secondary, fontSize: 12.5)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FollowButton(user: user),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final void Function(String tag)? onTag;
  final void Function(User user)? onAuthor;
  final VoidCallback? onShare;
  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.onTag,
    this.onAuthor,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final author = appState.userFor(post.author);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Block(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: post.anonymous ? null : () => onAuthor?.call(author),
                  child: Avatar(
                    label: post.anonymous ? 'A' : post.author,
                    color: post.anonymous ? p.secondary : avatarColors[author.colorIndex],
                    verified: !post.anonymous && author.verified,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: post.anonymous ? null : () => onAuthor?.call(author),
                              child: Text(post.name,
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 14.5)),
                            ),
                          ),
                          if (!post.anonymous && author.verified) ...[
                            const SizedBox(width: 4),
                            const VerifiedBadge(size: 14),
                          ],
                          if (post.anonymous) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(color: Brand.blue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(5)),
                              child: const Text('Anon', style: TextStyle(color: Brand.blue, fontSize: 10, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          Text(post.time, style: TextStyle(color: p.secondary, fontSize: 12)),
                          const SizedBox(width: 5),
                          Icon(visibilityIcon(post.visibility), size: 12, color: p.secondary),
                          if (post.daysLeft <= 5) ...[
                            const SizedBox(width: 6),
                            Text('· ${post.daysLeft}d left', style: TextStyle(color: Brand.red, fontSize: 11)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (!post.anonymous && !author.isMe && onAuthor != null) ...[
                  FollowButton(user: author),
                  const SizedBox(width: 4),
                ],
                Icon(Icons.more_horiz, color: p.secondary, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            onTag != null
                ? TagText(
                    text: post.text,
                    style: TextStyle(color: p.text, fontSize: 15, height: 1.45),
                    onTag: onTag!,
                  )
                : Text(post.text, style: TextStyle(color: p.text, fontSize: 15, height: 1.45)),
            const SizedBox(height: 10),
            Row(
              children: [
                MoodTag(mood: post.mood),
                if (post.groupName != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.groups_outlined, size: 12, color: p.secondary),
                        const SizedBox(width: 4),
                        Text(post.groupName!,
                            style: TextStyle(color: p.secondary, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            if (post.poll != null) PollView(post: post),
            const SizedBox(height: 6),
            Divider(height: 1, color: p.divider),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: StatAction(
                    icon: post.liked ? Icons.favorite : Icons.favorite_border,
                    value: post.likes,
                    color: post.liked ? Brand.red : p.secondary,
                    onTap: () => appState.toggleLike(post),
                  ),
                ),
                Expanded(
                  child: StatAction(
                    icon: Icons.mode_comment_outlined,
                    value: post.comments.length,
                    color: p.secondary,
                    onTap: onTap,
                  ),
                ),
                Expanded(
                  child: StatAction(
                    icon: Icons.repeat,
                    value: post.lifts,
                    color: post.lifted ? Brand.green : p.secondary,
                    onTap: () {
                      final was = post.lifted;
                      appState.toggleLift(post);
                      if (!was) {
                        showFlash(context,
                            title: 'Lift', subtitle: 'Reposted', icon: Icons.repeat, color: Brand.green);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: StatAction(
                    icon: Icons.visibility_outlined,
                    value: post.views,
                    color: p.secondary,
                    onTap: onTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A feed-native sponsored slot (looks like a post, is clearly marked).
class SponsoredCard extends StatelessWidget {
  const SponsoredCard({super.key});

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
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(gradient: Brand.gradient, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
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
            const SizedBox(height: 10),
            Text('Feeling overwhelmed? A 5-minute guided breathing break can help.',
                style: TextStyle(color: p.text, fontSize: 14.5, height: 1.4)),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                onPressed: () {},
                child: const Text('Learn more'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentTile extends StatelessWidget {
  final Comment comment;
  final VoidCallback onReply;
  final VoidCallback onLike;
  const CommentTile({super.key, required this.comment, required this.onReply, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(label: comment.author, size: 36, color: p.secondary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(comment.author, style: TextStyle(color: p.text, fontWeight: FontWeight.w800, fontSize: 13.5)),
                        const Spacer(),
                        Text(comment.time, style: TextStyle(color: p.secondary, fontSize: 11.5)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(comment.text, style: TextStyle(color: p.text, fontSize: 14, height: 1.35)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _mini(context, comment.liked ? Icons.favorite : Icons.favorite_border, '${comment.likes}',
                            comment.liked ? Brand.red : p.secondary, onLike),
                        const SizedBox(width: 16),
                        _mini(context, Icons.reply, 'Reply', p.secondary, onReply),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          ...comment.replies.map(
            (r) => Padding(
              padding: const EdgeInsets.only(left: 46, top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Avatar(label: r.author, size: 28, color: p.secondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(r.author, style: TextStyle(color: p.text, fontWeight: FontWeight.w700, fontSize: 12.5)),
                            const Spacer(),
                            Text(r.time, style: TextStyle(color: p.secondary, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(r.text, style: TextStyle(color: p.text, fontSize: 13.5, height: 1.35)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mini(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class StatusRing extends StatelessWidget {
  final String label;
  final bool add;
  final Gradient gradient;
  final Uint8List? imageBytes;
  final VoidCallback? onTap;
  const StatusRing({
    super.key,
    required this.label,
    this.add = false,
    this.gradient = Brand.gradient,
    this.imageBytes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient),
              padding: const EdgeInsets.all(2.5),
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: p.surface),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: imageBytes != null
                      ? Image.memory(imageBytes!, fit: BoxFit.cover, width: 58, height: 58)
                      : Container(
                          color: add ? p.surfaceAlt : Brand.blue,
                          alignment: Alignment.center,
                          child: add
                              ? Icon(Icons.add, color: Brand.blue, size: 26)
                              : Text(label[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: p.text, fontSize: 11.5, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: p.secondary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: p.secondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

/// A poll attached to a post: tap an option to vote.
class PollView extends StatelessWidget {
  final Post post;
  const PollView({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final poll = post.poll!;
    final total = poll.total;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(poll.options.length, (i) {
            final pct = total == 0 ? 0.0 : poll.votes[i] / total;
            final chosen = poll.myVote == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () => appState.votePoll(post, i),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: chosen ? Brand.blue : p.border, width: chosen ? 1.6 : 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: pct.clamp(0.0, 1.0),
                            heightFactor: 1,
                            child: Container(color: Brand.blue.withValues(alpha: 0.16)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(poll.options[i],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: p.text,
                                        fontSize: 14,
                                        fontWeight: chosen ? FontWeight.w800 : FontWeight.w500)),
                              ),
                              Text('${(pct * 100).round()}%',
                                  style: TextStyle(
                                      color: p.secondary, fontSize: 13, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          Text('$total votes', style: TextStyle(color: p.secondary, fontSize: 12)),
        ],
      ),
    );
  }
}

/// Brief animated confirmation (post = "Snip", repost = "Lift").
void showFlash(BuildContext context,
    {required String title, required String subtitle, required IconData icon, Color? color}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _Flash(
      title: title,
      subtitle: subtitle,
      icon: icon,
      color: color ?? Brand.blue,
      onDone: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _Flash extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onDone;
  const _Flash({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onDone,
  });

  @override
  State<_Flash> createState() => _FlashState();
}

class _FlashState extends State<_Flash> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
  ]).animate(_c);
  late final Animation<double> _scale =
      CurvedAnimation(parent: _c, curve: const Interval(0, 0.4, curve: Curves.elasticOut));

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 38),
                  const SizedBox(height: 8),
                  Text(widget.title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(widget.subtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
