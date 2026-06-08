import 'package:flutter/material.dart';

import '../models/models.dart';

/// Trophy badge shown on ROMs that have a RetroAchievements set.
///
/// Two presentations share one look so the badge reads the same everywhere:
/// [RetroAchievementsBadge] is an inline chip (list tiles, info rows) and
/// [RetroAchievementsOverlayBadge] is a circular overlay for box-art stacks.
class RetroAchievementsBadge extends StatelessWidget {
  final RomEntry entry;
  final bool showCount;

  const RetroAchievementsBadge({
    super.key,
    required this.entry,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!entry.hasRetroAchievements) return const SizedBox.shrink();

    final count = entry.raNumAchievements;
    final label = showCount && count != null ? '$count' : 'RA';

    final bg = Theme.of(context).colorScheme.primaryContainer;
    final fg = Theme.of(context).colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, size: 10, color: fg),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular trophy overlay for use inside a box-art [Stack] (e.g. grid cards).
class RetroAchievementsOverlayBadge extends StatelessWidget {
  final RomEntry entry;

  const RetroAchievementsOverlayBadge({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    if (!entry.hasRetroAchievements) return const SizedBox.shrink();

    final bg = Theme.of(context).colorScheme.primaryContainer;
    final fg = Theme.of(context).colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.emoji_events,
        size: 14,
        color: fg,
      ),
    );
  }
}
