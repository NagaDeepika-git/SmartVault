import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../core/widgets/vault_card.dart';
import '../../data/models/reminder_model.dart';
import 'reminder_provider.dart';

/// Central Reminder & Expiration Alert center for SmartVault.
/// Displays active countdowns for warranties, document renewals, and scheduled maintenance.
class ReminderCenterScreen extends StatefulWidget {
  const ReminderCenterScreen({super.key});

  @override
  State<ReminderCenterScreen> createState() => _ReminderCenterScreenState();
}

class _ReminderCenterScreenState extends State<ReminderCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().loadReminders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddReminderDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime targetDate = DateTime.now().add(const Duration(days: 7));
    ReminderType selectedType = ReminderType.maintenance;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Create Reminder',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: titleController,
                        label: 'Reminder Title *',
                        hint: 'e.g. Renew passport, Replace Dyson HEPA filter',
                        prefixIcon: Icons.alarm_rounded,
                        validator: (val) => Validators.required(val, 'Title'),
                      ),
                      const SizedBox(height: 14),
                      CustomDropdownField<ReminderType>(
                        label: 'Reminder Category',
                        value: selectedType,
                        prefixIcon: Icons.category_rounded,
                        items: const [
                          DropdownMenuItem(
                            value: ReminderType.maintenance,
                            child: Text('Scheduled Maintenance'),
                          ),
                          DropdownMenuItem(
                            value: ReminderType.warrantyExpiry,
                            child: Text('Warranty Expiration'),
                          ),
                          DropdownMenuItem(
                            value: ReminderType.documentExpiry,
                            child: Text('Document Expiration'),
                          ),
                          DropdownMenuItem(
                            value: ReminderType.serviceAppointment,
                            child: Text('Service Appointment'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedType = val);
                        },
                      ),
                      const SizedBox(height: 14),
                      CustomDatePickerField(
                        label: 'Reminder Date *',
                        selectedDate: targetDate,
                        isRequired: true,
                        onDateSelected: (date) {
                          if (date != null) setModalState(() => targetDate = date);
                        },
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: descriptionController,
                        label: 'Notes / Description (Optional)',
                        hint: 'Additional instructions or contact details',
                        prefixIcon: Icons.notes_rounded,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            final newReminder = ReminderModel(
                              id: const Uuid().v4(),
                              title: titleController.text.trim(),
                              targetDate: targetDate,
                              type: selectedType,
                              description: descriptionController.text.trim().isEmpty
                                  ? null
                                  : descriptionController.text.trim(),
                              isCompleted: false,
                            );
                            final success = await context
                                .read<ReminderProvider>()
                                .createReminder(newReminder);
                            if (ctx.mounted) Navigator.of(ctx).pop();
                            if (context.mounted && success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Reminder scheduled successfully'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.champagne,
                            foregroundColor: const Color(0xFF1A1300),
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                          ),
                          child: const Text('Schedule Reminder',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ReminderProvider>();
    final pending = provider.pendingReminders;
    final completed = provider.completedReminders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders & Alerts'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.champagne,
          labelColor: AppColors.champagne,
          unselectedLabelColor:
              isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          tabs: [
            Tab(text: 'Pending (${pending.length})'),
            Tab(text: 'Completed (${completed.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_reminders',
        onPressed: () => _showAddReminderDialog(context),
        backgroundColor: AppColors.champagne,
        foregroundColor: const Color(0xFF1A1300),
        icon: const Icon(Icons.alarm_add_rounded),
        label: const Text('Add Reminder', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ResponsiveContentContainer(
        child: Column(
          children: [
            if (provider.overdueCount > 0)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${provider.overdueCount} item(s) are overdue or past expiration date!',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: provider.isLoading
                  ? const LoadingStateView(message: 'Loading alert schedule...')
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildReminderList(pending, isPending: true),
                        _buildReminderList(completed, isPending: false),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderList(List<ReminderModel> list, {required bool isPending}) {
    if (list.isEmpty) {
      return EmptyStateView.noReminders();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final reminder = list[index];
        final isOverdue = reminder.isOverdue && !reminder.isCompleted;

        return VaultCard(
          margin: const EdgeInsets.only(bottom: 10.0),
          border: isOverdue
              ? Border.all(color: AppColors.error.withValues(alpha: 0.6), width: 1.2)
              : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: reminder.isCompleted,
                activeColor: AppColors.champagne,
                checkColor: const Color(0xFF1A1300),
                onChanged: (val) {
                  context.read<ReminderProvider>().toggleComplete(reminder.id);
                },
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        decoration: reminder.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: reminder.isCompleted
                            ? (isDark ? AppColors.textMutedDark : AppColors.textMutedLight)
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: isOverdue
                              ? AppColors.error
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Due: ${DateFormatter.formatDate(reminder.targetDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                            color: isOverdue
                                ? AppColors.error
                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceAlt,
                            borderRadius: AppRadius.radiusSm,
                          ),
                          child: Text(
                            reminder.type.label,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (reminder.description != null && reminder.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        reminder.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                tooltip: 'Delete',
                onPressed: () {
                  context.read<ReminderProvider>().deleteReminder(reminder.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
