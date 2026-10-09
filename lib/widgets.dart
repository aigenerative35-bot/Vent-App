import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';

class AvatarCircle extends StatelessWidget {
  final String label;
  final Color color;
  const AvatarCircle({super.key, required this.label, this.color = ZColors.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        label.isNotEmpty ? label[0].toUpperCase() : '?',
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16),
      ),
    );
  }
}

class MoodChip extends StatelessWidget {
  final String mood;
  const MoodChip({super.key, required this.mood});

  @override
  Widget build(BuildContext context) {
    final c = moodColors[mood] ?? ZColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(mood, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class CardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const CardShell({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ZColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  const PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CardShell(
        onTap: onTap,
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
                      Text(
                        post.anonymous ? 'Anjaan' : post.author,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ZColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      Text(post.time,
                          style: const TextStyle(color: ZColors.textSecondary, fontSize: 11.5)),
                    ],
                  ),
                ),
                MoodChip(mood: post.mood),
              ],
            ),
            const SizedBox(height: 10),
            Text(post.text,
                style: const TextStyle(color: ZColors.textPrimary, fontSize: 14.5, height: 1.4)),
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
                const SizedBox(width: 4),
                ActionButton(
                  icon: Icons.mode_comment_outlined,
                  label: '${post.comments.length}',
                  active: false,
                  onTap: onTap,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.share_outlined, size: 18, color: ZColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = active ? ZColors.danger : ZColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: c),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(color: c, fontSize: 12.5, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
