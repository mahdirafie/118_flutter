import 'package:basu_118/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:basu_118/services/hive/hive_models/reminder_model.dart';
import 'package:basu_118/services/hive/hive_service.dart';
import 'package:basu_118/services/notification/notification_service.dart';
import 'package:basu_118/theme/app_colors.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  final HiveService _hiveService = HiveService();
  final NotificationService _notificationService = NotificationService();
  bool _showActiveOnly = true;
  String _sortBy = 'date'; // 'date' or 'title'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'یادآورهای من',
          style: TextStyle(
            color: AppColors.onBackground,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          // Filter and Sort Menu
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.filter_list_rounded,
              color: AppColors.onBackground,
            ),
            onSelected: (value) {
              if (value == 'toggle_active') {
                setState(() {
                  _showActiveOnly = !_showActiveOnly;
                });
              } else if (value == 'sort_date' || value == 'sort_title') {
                setState(() {
                  _sortBy = value == 'sort_date' ? 'date' : 'title';
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'toggle_active',
                  child: Row(
                    children: [
                      Icon(
                        _showActiveOnly
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _showActiveOnly
                            ? 'نمایش غیرفعال‌ها'
                            : 'فقط نمایش فعال‌ها',
                        style: const TextStyle(color: AppColors.onBackground),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                CheckedPopupMenuItem<String>(
                  value: 'sort_date',
                  checked: _sortBy == 'date',
                  child: const Text(
                    'مرتب‌سازی بر اساس تاریخ',
                    style: TextStyle(color: AppColors.onBackground),
                  ),
                ),
                CheckedPopupMenuItem<String>(
                  value: 'sort_title',
                  checked: _sortBy == 'title',
                  child: const Text(
                    'مرتب‌سازی بر اساس عنوان',
                    style: TextStyle(color: AppColors.onBackground),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Card
          _buildStatsCard(),

          // Reminders List
          Expanded(
            child: ValueListenableBuilder<Box<Reminder>>(
              valueListenable: _hiveService.remindersBox.listenable(),
              builder: (context, box, widget) {
                final allReminders = box.values.toList();

                if (allReminders.isEmpty) {
                  return _buildEmptyState();
                }

                // Apply filters and sorting
                List<Reminder> filteredReminders =
                    allReminders.where((reminder) {
                      if (_showActiveOnly) {
                        return reminder.isActive;
                      }
                      return true;
                    }).toList();

                // Apply sorting
                filteredReminders.sort((a, b) {
                  if (_sortBy == 'date') {
                    return a.reminderDateTime.compareTo(b.reminderDateTime);
                  } else {
                    return a.title.compareTo(b.title);
                  }
                });

                if (filteredReminders.isEmpty) {
                  return _buildNoRemindersForFilter();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredReminders.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildReminderCard(filteredReminders[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return ValueListenableBuilder<Box<Reminder>>(
      valueListenable: _hiveService.remindersBox.listenable(),
      builder: (context, box, widget) {
        final allReminders = box.values.toList();
        final activeReminders = allReminders.where((r) => r.isActive).length;
        final upcomingReminders =
            allReminders
                .where(
                  (r) =>
                      r.isActive && r.reminderDateTime.isAfter(DateTime.now()),
                )
                .length;
        final pastReminders =
            allReminders
                .where(
                  (r) =>
                      r.isActive && r.reminderDateTime.isBefore(DateTime.now()),
                )
                .length;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'همه',
                allReminders.length.toString(),
                Icons.list_rounded,
              ),
              _buildStatItem(
                'فعال',
                activeReminders.toString(),
                Icons.notifications_active_rounded,
              ),
              _buildStatItem(
                'آینده',
                upcomingReminders.toString(),
                Icons.schedule_rounded,
              ),
              _buildStatItem(
                'گذشته',
                pastReminders.toString(),
                Icons.history_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.onSurface),
        ),
      ],
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    final isPast = reminder.reminderDateTime.isBefore(DateTime.now());
    final jalaliDate = Jalali.fromDateTime(reminder.reminderDateTime);
    final formattedTime = _formatTime(reminder.reminderDateTime);

    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.error50,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(
          Icons.delete_forever_rounded,
          color: AppColors.error500,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(reminder);
      },
      child: GestureDetector(
        onTap: () => _showReminderDetails(reminder),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  reminder.isActive
                      ? AppColors.outline
                      : AppColors.onSurface.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getStatusColor(reminder).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(reminder),
                        color: _getStatusColor(reminder),
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Reminder Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            reminder.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                                  reminder.isActive
                                      ? AppColors.onBackground
                                      : AppColors.onSurface,
                              decoration:
                                  reminder.isActive
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // Date and Time
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: AppColors.onSurface,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                jalaliDate.formatCompactDate(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: AppColors.onSurface,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formattedTime,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),

                          // Contact Name
                          if (reminder.contactName != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                reminder.contactName!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],

                          // Description
                          if (reminder.description != null &&
                              reminder.description!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                reminder.description!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.onSurface,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],

                          // Past Status Badge
                          if (isPast && reminder.isActive) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.watch_later_rounded,
                                    size: 14,
                                    color: AppColors.warning500,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'گذشته',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.warning800,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Active Toggle Button (Top Left)
              Positioned(
                top: 12,
                left: 12,
                child: GestureDetector(
                  onTap: () => _toggleReminderStatus(reminder),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          reminder.isActive
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.onSurface.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            reminder.isActive
                                ? AppColors.primary.withOpacity(0.3)
                                : AppColors.onSurface.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          reminder.isActive
                              ? Icons.toggle_on_rounded
                              : Icons.toggle_off_rounded,
                          color:
                              reminder.isActive
                                  ? AppColors.primary
                                  : AppColors.onSurface,
                          size: 24,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reminder.isActive ? 'فعال' : 'غیرفعال',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                reminder.isActive
                                    ? AppColors.primary
                                    : AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Delete Button (Bottom Left)
              Positioned(
                bottom: 12,
                right: 12,
                child: IconButton(
                  onPressed: () => _showDeleteConfirmation(reminder),
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error500,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 80,
            color: AppColors.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          const Text(
            'هیچ یادآوری ندارید',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'برای ایجاد یادآور جدید، از صفحه جزئیات مخاطب اقدام کنید',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoRemindersForFilter() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_alt_off_rounded,
            size: 80,
            color: AppColors.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            _showActiveOnly
                ? 'یادآور فعالی وجود ندارد'
                : 'هیچ یادآوری وجود ندارد',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _showActiveOnly = !_showActiveOnly;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _showActiveOnly
                  ? 'مشاهده یادآورهای غیرفعال'
                  : 'مشاهده یادآورهای فعال',
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(Reminder reminder) {
    if (!reminder.isActive) return AppColors.onSurface;
    if (reminder.reminderDateTime.isBefore(DateTime.now())) {
      return AppColors.warning500;
    }
    return AppColors.primary;
  }

  IconData _getStatusIcon(Reminder reminder) {
    if (!reminder.isActive) return Icons.notifications_off_rounded;
    if (reminder.reminderDateTime.isBefore(DateTime.now())) {
      return Icons.watch_later_rounded;
    }
    return Icons.notifications_active_rounded;
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');

    if (hour < 12) {
      final displayHour = hour == 0 ? '12' : hour.toString();
      return '$displayHour:$minute صبح';
    } else if (hour == 12) {
      return '12:$minute ظهر';
    } else {
      final displayHour = (hour - 12).toString();
      return '$displayHour:$minute بعدازظهر';
    }
  }

  Future<void> _toggleReminderStatus(Reminder reminder) async {
    final updatedReminder = Reminder(
      id: reminder.id,
      cid: reminder.cid,
      title: reminder.title,
      description: reminder.description,
      reminderDateTime: reminder.reminderDateTime,
      isActive: !reminder.isActive,
      contactName: reminder.contactName,
    );

    // Update in Hive
    await _hiveService.saveReminder(updatedReminder);

    // Update notification
    if (updatedReminder.isActive) {
      // Schedule notification
      await _notificationService.scheduleReminderNotification(updatedReminder);
    } else {
      // Cancel notification
      await _notificationService.cancelReminderNotification(updatedReminder);
    }

    showAppSnackBar(
      context,
      message:
          updatedReminder.isActive ? 'یادآور فعال شد' : 'یادآور غیرفعال شد',
      type:
          updatedReminder.isActive
              ? AppSnackBarType.success
              : AppSnackBarType.warning,
    );
  }

  Future<bool> _showDeleteConfirmation(Reminder reminder) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'حذف یادآور',
              style: TextStyle(color: AppColors.onBackground),
            ),
            content: const Text(
              'آیا مطمئن هستید که می‌خواهید این یادآور را حذف کنید؟',
              style: TextStyle(color: AppColors.onSurface),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'لغو',
                  style: TextStyle(color: AppColors.onSurface),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('حذف', style: TextStyle(color: AppColors.error500)),
              ),
            ],
          ),
        );
      },
    );

    if (result == true) {
      // Cancel notification first
      await _notificationService.cancelReminderNotification(reminder);
      
      // Then delete from Hive
      await _hiveService.deleteReminder(reminder.id);
      
      showAppSnackBar(
        context,
        message: 'یادآور حذف شد',
        type: AppSnackBarType.success,
      );
    }

    return result ?? false;
  }

  void _showReminderDetails(Reminder reminder) {
    final jalaliDate = Jalali.fromDateTime(reminder.reminderDateTime);

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'جزئیات یادآور',
              style: TextStyle(color: AppColors.onBackground),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'عنوان',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reminder.title,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.onBackground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contact Name
                  if (reminder.contactName != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مخاطب',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              reminder.contactName!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Description
                  if (reminder.description != null &&
                      reminder.description!.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'توضیحات',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              reminder.description!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.onBackground,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Date and Time - Fixed layout to prevent overflow
                  Column(
                    children: [
                      // Date
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تاریخ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 18,
                                  color: AppColors.onSurface,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    jalaliDate.formatFullDate(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.onBackground,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'زمان',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 18,
                                  color: AppColors.onSurface,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _formatTime(reminder.reminderDateTime),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.onBackground,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'وضعیت',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              reminder.isActive
                                  ? AppColors.primary.withOpacity(0.08)
                                  : AppColors.onSurface.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              reminder.isActive
                                  ? Icons.toggle_on_rounded
                                  : Icons.toggle_off_rounded,
                              color:
                                  reminder.isActive
                                      ? AppColors.primary
                                      : AppColors.onSurface,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              reminder.isActive ? 'فعال' : 'غیرفعال',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    reminder.isActive
                                        ? AppColors.primary
                                        : AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'بستن',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}