import 'package:basu_118/services/hive/hive_models/reminder_model.dart';
import 'package:basu_118/services/hive/hive_service.dart';
import 'package:basu_118/services/notification/notification_service.dart';
import 'package:basu_118/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

class ReminderDialog {
  static Future<void> show({
    required BuildContext context,
    required int cid,
    String? contactName,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) {
        return _ReminderDialogContent(
          cid: cid,
          contactName: contactName,
        );
      },
    );
  }
}

class _ReminderDialogContent extends StatefulWidget {
  final int cid;
  final String? contactName;

  const _ReminderDialogContent({
    required this.cid,
    this.contactName,
  });

  @override
  State<_ReminderDialogContent> createState() => _ReminderDialogContentState();
}

class _ReminderDialogContentState extends State<_ReminderDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  Jalali? _selectedJalaliDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    // Get current date/time
    final now = DateTime.now();
    
    // Convert current date to Jalali correctly
    _selectedJalaliDate = Jalali.fromDateTime(now).addDays(1);
    _selectedTime = const TimeOfDay(hour: 9, minute: 0);
    
    _titleController.text = widget.contactName != null 
        ? 'یادآور برای ${widget.contactName}'
        : 'یادآور جدید';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _getFormattedDate() {
    if (_selectedJalaliDate == null) return 'انتخاب تاریخ';
    return _selectedJalaliDate!.formatFullDate();
  }

  String _getFormattedTime() {
    if (_selectedTime == null) return 'انتخاب زمان';
    
    final hour = _selectedTime!.hour;
    final minute = _selectedTime!.minute.toString().padLeft(2, '0'); // English numbers
    
    if (hour < 12) {
      final displayHour = hour == 0 ? '12' : hour.toString(); // English numbers
      return '$displayHour:$minute صبح';
    } else if (hour == 12) {
      return '12:$minute ظهر'; // English numbers
    } else {
      final displayHour = (hour - 12).toString(); // English numbers
      return '$displayHour:$minute بعدازظهر';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final today = Jalali.fromDateTime(now);
    
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: _selectedJalaliDate ?? today.addDays(1),
      firstDate: today,
      lastDate: today.addYears(2),
      initialEntryMode: PersianDatePickerEntryMode.calendarOnly,
      initialDatePickerMode: PersianDatePickerMode.day,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedJalaliDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false,
            ),
            child: child!,
          ),
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedJalaliDate == null || _selectedTime == null) {
      showAppSnackBar(
        context, 
        message: "لطفا تاریخ و زمان را انتخاب نمایید!", 
        type: AppSnackBarType.warning
      );
      return;
    }

    try {
      // Convert Jalali to DateTime
      final gregorianDate = _selectedJalaliDate!.toDateTime();
      
      // Create DateTime with selected date and time
      final reminderDateTime = DateTime(
        gregorianDate.year,
        gregorianDate.month,
        gregorianDate.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
        0, // seconds
        0, // milliseconds
      );

      // Check if date is in the past
      if (reminderDateTime.isBefore(DateTime.now())) {
        showAppSnackBar(
          context, 
          message: "زمان یادآور نمی تواند در گذشته باشد!", 
          type: AppSnackBarType.warning
        );
        return;
      }

      final reminder = Reminder(
        id: '${widget.cid}_${reminderDateTime.millisecondsSinceEpoch}',
        cid: widget.cid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        reminderDateTime: reminderDateTime,
        isActive: true,
        contactName: widget.contactName,
      );

      // Save to Hive
      final hive = HiveService();
      await hive.saveReminder(reminder);

      // Schedule notification
      final notificationService = NotificationService();
      await notificationService.scheduleReminderNotification(reminder);

      if (!mounted) return;
      
      // Show success message
      showAppSnackBar(
        context,
        message: 'یادآور با موفقیت ذخیره شد\n${_getFormattedDate()} - ${_getFormattedTime()}',
        type: AppSnackBarType.success,
      );
      
      // Close dialog
      Navigator.of(context).pop();
      
    } catch (e) {
      if (!mounted) return;
      
      showAppSnackBar(
        context, 
        message: "خطا در ذخیره یادآوری", 
        type: AppSnackBarType.error
      );
      
      print('Error saving reminder: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications_active,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تنظیم یادآور',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            if (widget.contactName != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'برای ${widget.contactName}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                Divider(color: Colors.grey.shade300, height: 1),
                const SizedBox(height: 24),
                
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Field
                      _buildLabel('عنوان یادآور'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'مثال: تماس برای پیگیری پروژه',
                          hintTextDirection: TextDirection.rtl,
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          prefixIcon: Icon(
                            Icons.title,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'لطفا عنوان یادآور را وارد کنید';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Description Field
                      _buildLabel('توضیحات (اختیاری)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'توضیحات بیشتر درباره یادآور...',
                          hintTextDirection: TextDirection.rtl,
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          alignLabelWithHint: true,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Date & Time Section
                      _buildLabel('زمان یادآوری'),
                      const SizedBox(height: 8),
                      
                      // Date Card
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.calendar_today_rounded,
                                  color: Colors.blue.shade600,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'تاریخ',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getFormattedDate(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.grey.shade400,
                                size: 18,
                                textDirection: TextDirection.ltr,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Time Card
                      GestureDetector(
                        onTap: () => _selectTime(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.access_time_rounded,
                                  color: Colors.orange.shade600,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'زمان',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getFormattedTime(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.grey.shade400,
                                size: 18,
                                textDirection: TextDirection.ltr,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          'برای تغییر روی کارت مورد نظر ضربه بزنید',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.grey.shade700,
                              ),
                              child: const Text(
                                'انصراف',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveReminder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                              child: const Text(
                                'ذخیره یادآور',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
          height: 1.6,
        ),
      ),
    );
  }
}