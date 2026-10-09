import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';

String fmt(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}

class Avatar extends StatelessWidget {
  final String label;
  final double size;
  final Color? color;
  const Avatar({super.key, required this.label, this.size = 42, this.color});

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

class MoodTag extends StatelessWidget {
  final String mood;
  const MoodTag({super.key, required this.mood});

  @override
  Widget build(BuildContext context) {
    final c = moodColors[mood] ?? Brand.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(mood, style: TextStyle(color: c, fontSize: 11.5, fontWeight: FontWeight.w800)),
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
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Brand.blue),
            const SizedBox(width: 7),
          ],
          Text(title, style: TextStyle(color: p.text, fontSize: 16, fontWeight: FontWeight.w800)),
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

class StatAction extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;
  final VoidCallback onTap;
  const StatAction({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
    required this.onTap,
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
            Text(fmt(value),
                style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w700)),
          ],
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
                Avatar(
                    label: post.anonymous ? 'A' : post.author,
                    color: post.anonymous ? p.secondary : Brand.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(post.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: p.text,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14.5)),
                          ),
                          if (post.anonymous) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                  color: Brand.blue.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(5)),
                              child: const Text('Anon',
                                  style: TextStyle(
                                      color: Brand.blue,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(post.time, style: TextStyle(color: p.secondary, fontSize: 12)),
                    ],
                  ),
                ),
                Icon(Icons.more_horiz, color: p.secondary, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Text(post.text, style: TextStyle(color: p.text, fontSize: 15, height: 1.45)),
            const SizedBox(height: 10),
            MoodTag(mood: post.mood),
            const SizedBox(height: 6),
            Divider(height: 1, color: p.divider),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: StatAction(
                      icon: Icons.visibility_outlined,
                      value: post.views,
                      color: p.secondary,
                      onTap: onTap),
                ),
                Expanded(
                  child: StatAction(
                      icon: Icons.mode_comment_outlined,
                      value: post.comments.length,
                      color: p.secondary,
                      onTap: onTap),
                ),
                Expanded(
                  child: StatAction(
                      icon: Icons.repeat,
                      value: post.lifts,
                      color: post.lifted ? Brand.green : p.secondary,
                      onTap: () => appState.toggleLift(post)),
                ),
                Expanded(
                  child: StatAction(
                      icon: post.liked ? Icons.favorite : Icons.favorite_border,
                      value: post.likes,
                      color: post.liked ? Brand.red : p.secondary,
                      onTap: () => appState.toggleLike(post)),
                ),
              ],
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
  const CommentTile({
    super.key,
    required this.comment,
    required this.onReply,
    required this.onLike,
  });

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
                        Text(comment.author,
                            style: TextStyle(
                                color: p.text, fontWeight: FontWeight.w800, fontSize: 13.5)),
                        const Spacer(),
                        Text(comment.time,
                            style: TextStyle(color: p.secondary, fontSize: 11.5)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(comment.text,
                        style: TextStyle(color: p.text, fontSize: 14, height: 1.35)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _mini(context,
                            comment.liked ? Icons.favorite : Icons.favorite_border,
                            '${comment.likes}',
                            comment.liked ? Brand.red : p.secondary,
                            onLike),
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
                            Text(r.author,
                                style: TextStyle(
                                    color: p.text, fontWeight: FontWeight.w700, fontSize: 12.5)),
                            const Spacer(),
                            Text(r.time,
                                style: TextStyle(color: p.secondary, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(r.text,
                            style: TextStyle(color: p.text, fontSize: 13.5, height: 1.35)),
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
            Text(label,
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
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
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20)),
                        ),
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
