import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../utils/date_formatter.dart';

/// Polished custom text field designed for SmartVault forms.
/// Supports validation, prefix/suffix icons, obscure text toggles, and custom styling.
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String label;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final int maxLines;
  final int? minLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  const CustomTextField({
    super.key,
    this.controller,
    this.initialValue,
    required this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          maxLines: maxLines,
          minLines: minLines,
          readOnly: readOnly,
          onTap: onTap,
          inputFormatters: inputFormatters,
          autofocus: autofocus,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: 20,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  )
                : null,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

/// Custom Date Picker trigger button field with formatted date label.
class CustomDatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;
  final String? hint;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool isRequired;

  const CustomDatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.hint,
    this.firstDate,
    this.lastDate,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? now,
              firstDate: firstDate ?? DateTime(1970),
              lastDate: lastDate ?? DateTime(2045),
              builder: (context, child) {
                return Theme(
                  data: isDark ? ThemeData.dark() : ThemeData.light(),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          borderRadius: AppRadius.radiusMd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceLight : AppColors.lightSurface,
              borderRadius: AppRadius.radiusMd,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormatter.formatDate(selectedDate)
                      : (hint ?? 'Select date'),
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedDate != null
                        ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                        : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                  ),
                ),
                Row(
                  children: [
                    if (selectedDate != null && !isRequired)
                      GestureDetector(
                        onTap: () => onDateSelected(null),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                      ),
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: AppColors.champagne,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom dropdown selector for Document and Product categories.
class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.champagne),
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: 20,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
