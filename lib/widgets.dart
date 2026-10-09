import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';

class Avatar extends StatelessWidget {
  final String label;
  final double size;
  const Avatar({super.key, required this.label, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: Brand.gradient),
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
    final c = moodColors[mood] ?? Brand.violet;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(mood,
          style: TextStyle(color: c, fontSize: 11.5, fontWeight: FontWeight.w800)),
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          if (icon != null) ...[
            ShaderMask(
              shaderCallback: (r) => Brand.gradient.createShader(r),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(color: p.text, fontSize: 17, fontWeight: FontWeight.w800)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!,
                        style: TextStyle(color: p.secondary, fontSize: 12.5)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const GradientButton({super.key, required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: Container(
        decoration: BoxDecoration(
          gradient: Brand.gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 19, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
            ),
          ),
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
    final p = Palette.of(context);
    final mc = moodColors[post.mood] ?? Brand.violet;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: SoftCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [mc, mc.withValues(alpha: 0.15)],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Avatar(label: post.anonymous ? 'A' : post.author, size: 42),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: p.text,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14.5)),
                            Text('${post.handle}  ·  ${post.time}',
                                style: TextStyle(color: p.secondary, fontSize: 12.5)),
                          ],
                        ),
                      ),
                      MoodChip(mood: post.mood),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(post.text,
                      style: TextStyle(color: p.text, fontSize: 15.5, height: 1.45)),
                  const SizedBox(height: 10),
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
                onTap: onComment),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: _Action(
                icon: Icons.repeat,
                count: post.reposts,
                color: post.reposted ? Brand.green : p.secondary,
                onTap: () => appState.toggleRepost(post)),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: _Action(
                icon: post.liked ? Icons.favorite : Icons.favorite_border,
                count: post.likes,
                color: post.liked ? Brand.pink : p.secondary,
                onTap: () => appState.toggleLike(post)),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: _Action(
                icon: Icons.ios_share, count: null, color: p.secondary, onTap: () {}),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: color),
            if (count != null) ...[
              const SizedBox(width: 6),
              Text(_short(count!),
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ],
        ),
      ),
    );
  }

  static String _short(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
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
            Icon(icon, size: 42, color: p.secondary),
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
