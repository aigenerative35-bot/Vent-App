import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';

class Avatar extends StatelessWidget {
  final String label;
  final double size;
  final Color? color;
  const Avatar({super.key, required this.label, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Brand.blue;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        label.isNotEmpty ? label[0].toUpperCase() : '?',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 0.4),
      ),
    );
  }
}

class MoodChip extends StatelessWidget {
  final String mood;
  const MoodChip({super.key, required this.mood});

  @override
  Widget build(BuildContext context) {
    final c = moodColors[mood] ?? Brand.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(mood,
          style: TextStyle(color: c, fontSize: 11.5, fontWeight: FontWeight.w700)),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  const SectionHeader({super.key, required this.title, this.subtitle, this.icon});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Brand.blue),
            const SizedBox(width: 7),
          ],
          Text(title,
              style: TextStyle(color: p.text, fontSize: 15.5, fontWeight: FontWeight.w800)),
          if (subtitle != null) ...[
            const SizedBox(width: 6),
            Expanded(
              child: Text(subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: p.secondary, fontSize: 12.5)),
            ),
          ],
        ],
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
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: p.secondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

/// Facebook post: header (avatar, name, time + globe), body, then
/// Like / Comment / Share.
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  const PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return FbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                Avatar(
                    label: post.anonymous ? 'A' : post.author,
                    color: post.anonymous ? p.secondary : Brand.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.name,
                          style: TextStyle(
                              color: p.text, fontWeight: FontWeight.w700, fontSize: 14.5)),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          Text(post.time,
                              style: TextStyle(color: p.secondary, fontSize: 12)),
                          const SizedBox(width: 5),
                          Icon(Icons.public, size: 12, color: p.secondary),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_horiz, color: p.secondary),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.text,
                    style: TextStyle(color: p.text, fontSize: 15, height: 1.4)),
                const SizedBox(height: 10),
                MoodChip(mood: post.mood),
              ],
            ),
          ),
          Divider(height: 1, color: p.divider),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: ActionRow(post: post, onComment: onTap),
          ),
        ],
      ),
    );
  }
}

class ActionRow extends StatelessWidget {
  final Post post;
  final VoidCallback onComment;
  const ActionRow({super.key, required this.post, required this.onComment});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Row(
      children: [
        Expanded(
          child: FbAction(
            icon: post.liked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
            label: 'Like',
            color: post.liked ? Brand.blue : p.secondary,
            onTap: () => appState.toggleLike(post),
          ),
        ),
        Expanded(
          child: FbAction(
            icon: Icons.mode_comment_outlined,
            label: 'Comment',
            color: p.secondary,
            onTap: onComment,
          ),
        ),
        Expanded(
          child: FbAction(
            icon: Icons.share_outlined,
            label: 'Share',
            color: post.reposted ? Brand.green : p.secondary,
            onTap: () => appState.toggleShare(post),
          ),
        ),
      ],
    );
  }
}

class FbAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const FbAction({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(width: 7),
            Text(label,
                style: TextStyle(color: color, fontSize: 13.5, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

/// A circular story at the top of the feed.
class StoryCircle extends StatelessWidget {
  final String label;
  final Color color;
  final bool add;
  final VoidCallback? onTap;
  const StoryCircle({
    super.key,
    required this.label,
    this.color = Brand.blue,
    this.add = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 74,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: Brand.gradient,
              ),
              padding: const EdgeInsets.all(2.5),
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: p.surface),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  alignment: Alignment.center,
                  child: add
                      ? Icon(Icons.add, color: Colors.white, size: 26)
                      : Text(label[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: p.text, fontSize: 11.5, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
