import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';

class AvatarCircle extends StatelessWidget {
  final String label;
  final double size;
  final Color? color;
  const AvatarCircle({super.key, required this.label, this.size = 42, this.color});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final c = color ?? AppColors.blue;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        label.isNotEmpty ? label[0].toUpperCase() : '?',
        style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: size * 0.4),
      ),
    );
  }
}

class MoodChip extends StatelessWidget {
  final String mood;
  const MoodChip({super.key, required this.mood});

  @override
  Widget build(BuildContext context) {
    final c = moodColors[mood] ?? AppColors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(mood, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

/// X-style post: flat list row, thin divider, action row with
/// comment / repost / like / share.
class TweetCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback? onAvatarTap;
  const TweetCard({super.key, required this.post, required this.onTap, this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 6),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onAvatarTap,
              child: AvatarCircle(label: post.anonymous ? 'A' : post.author),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          post.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: p.text,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          post.handle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: p.secondary, fontSize: 13.5),
                        ),
                      ),
                      Text(' · ${post.time}',
                          style: TextStyle(color: p.secondary, fontSize: 13.5)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    post.text,
                    style: TextStyle(color: p.text, fontSize: 15, height: 1.35),
                  ),
                  const SizedBox(height: 8),
                  MoodChip(mood: post.mood),
                  const SizedBox(height: 4),
                  ActionRow(post: post, onComment: onTap),
                ],
              ),
            ),
          ],
        ),
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
          child: Align(
            alignment: Alignment.centerLeft,
            child: _Action(
              icon: Icons.mode_comment_outlined,
              count: post.comments.length,
              color: p.secondary,
              onTap: onComment,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: _Action(
              icon: Icons.repeat,
              count: post.reposts,
              color: post.reposted ? AppColors.repost : p.secondary,
              onTap: () => appState.toggleRepost(post),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: _Action(
              icon: post.liked ? Icons.favorite : Icons.favorite_border,
              count: post.likes,
              color: post.liked ? AppColors.like : p.secondary,
              onTap: () => appState.toggleLike(post),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: _Action(
              icon: Icons.ios_share,
              count: null,
              color: p.secondary,
              onTap: () {},
            ),
          ),
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final int? count;
  final Color color;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.count, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            if (count != null) ...[
              const SizedBox(width: 6),
              Text('$count',
                  style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}
