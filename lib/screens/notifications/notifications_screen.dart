import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/app_colors.dart';
import '../../models/notification_model.dart';
import '../../models/notification_preference_model.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NotificationProvider>();
      provider.loadNotifications(refresh: true);
      provider.loadPreferences(force: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<NotificationProvider>().loadMore();
    }
  }

  Future<void> _refresh() async {
    final provider = context.read<NotificationProvider>();
    await Future.wait([
      provider.loadNotifications(refresh: true),
      provider.refreshUnreadCount(),
    ]);
  }

  Future<void> _handleMarkAllAsRead() async {
    try {
      await context.read<NotificationProvider>().markAllAsRead();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to mark all as read. Please try again.'),
        ),
      );
    }
  }

  Future<void> _handleDelete(NotificationModel notification) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete notification?'),
        content: const Text(
          'Are you sure you want to delete this notification?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await context.read<NotificationProvider>().deleteNotification(
        notification.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Notification deleted')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete notification. Please try again.'),
        ),
      );
    }
  }

  Future<void> _handleTap(NotificationModel notification) async {
    if (notification.isRead) return;
    try {
      await context.read<NotificationProvider>().markAsRead(notification.id);
    } catch (_) {
      // The provider already reverted its optimistic update; nothing more
      // to do here besides letting the tile re-render as unread.
    }
  }

  Future<void> _handleTogglePreference(
    NotificationPreferenceModel current,
    NotificationPreferenceModel updated,
  ) async {
    try {
      await context.read<NotificationProvider>().updatePreference(updated);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update settings. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: _handleMarkAllAsRead,
              child: const Text('Mark all as read'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _PreferencesCard(
                  provider: provider,
                  onToggle: _handleTogglePreference,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Notifications',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _buildBody(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationProvider provider) {
    if (provider.isLoading && provider.notifications.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.errorMessage != null && provider.notifications.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.gray400),
                const SizedBox(height: 16),
                Text(
                  'Unable to load notifications',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.gray600),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      context.read<NotificationProvider>().loadNotifications(
                        refresh: true,
                      ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (provider.notifications.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.notifications_none,
          title: 'No notifications yet',
          message: "You're all caught up.",
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverList.separated(
        itemCount:
            provider.notifications.length + (provider.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= provider.notifications.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final notification = provider.notifications[index];
          return _NotificationTile(
            notification: notification,
            onTap: () => _handleTap(notification),
            onDelete: () => _handleDelete(notification),
          );
        },
      ),
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  final NotificationProvider provider;
  final Future<void> Function(
    NotificationPreferenceModel current,
    NotificationPreferenceModel updated,
  )
  onToggle;

  const _PreferencesCard({required this.provider, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final preferences = provider.preferences;

    if (provider.isLoadingPreferences && preferences == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (preferences == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.preferencesError ??
                    'Unable to load notification preferences.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.gray600),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Preferences',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          _preferenceSwitch(
            context,
            title: 'Push notifications',
            subtitle: 'Master switch for all notifications',
            value: preferences.pushEnabled,
            onChanged: (value) => onToggle(
              preferences,
              preferences.copyWith(pushEnabled: value),
            ),
          ),
          _preferenceSwitch(
            context,
            title: 'Task reminders',
            subtitle: 'Get notified before a task is due',
            value: preferences.taskReminderEnabled,
            onChanged: (value) => onToggle(
              preferences,
              preferences.copyWith(taskReminderEnabled: value),
            ),
          ),
          _preferenceSwitch(
            context,
            title: 'Habit reminders',
            subtitle: 'Daily reminders for incomplete habits',
            value: preferences.habitReminderEnabled,
            onChanged: (value) => onToggle(
              preferences,
              preferences.copyWith(habitReminderEnabled: value),
            ),
          ),
          _preferenceSwitch(
            context,
            title: 'Due-date reminders',
            subtitle: 'Get notified on the day a task is due',
            value: preferences.dueDateReminderEnabled,
            onChanged: (value) => onToggle(
              preferences,
              preferences.copyWith(dueDateReminderEnabled: value),
            ),
          ),
          _preferenceSwitch(
            context,
            title: 'General notifications',
            subtitle: 'Announcements and other updates',
            value: preferences.generalNotificationEnabled,
            onChanged: (value) => onToggle(
              preferences,
              preferences.copyWith(generalNotificationEnabled: value),
            ),
          ),
          _preferenceSwitch(
            context,
            title: 'Sound',
            value: preferences.soundEnabled,
            onChanged: (value) =>
                onToggle(preferences, preferences.copyWith(soundEnabled: value)),
          ),
          _preferenceSwitch(
            context,
            title: 'Vibration',
            value: preferences.vibrationEnabled,
            onChanged: (value) => onToggle(
              preferences,
              preferences.copyWith(vibrationEnabled: value),
            ),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _preferenceSwitch(
    BuildContext context, {
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: (next) => onChanged(next),
      contentPadding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: isLast ? 8 : 0,
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  IconData get _icon {
    switch (notification.type) {
      case 'task_reminder':
        return Icons.task_alt;
      case 'due_date':
        return Icons.event_outlined;
      case 'habit_reminder':
        return Icons.track_changes;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final local = dateTime.toLocal();
    final diff = now.difference(local);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(local);
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Card(
      color: isUnread ? AppColors.peach50 : null,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          _icon,
          color: isUnread ? AppColors.peach900 : AppColors.gray400,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8),
                decoration: const BoxDecoration(
                  color: AppColors.peach900,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 6),
            Text(
              _relativeTime(notification.createdAt),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
