import 'package:flutter/material.dart' hide FormField;
import 'package:tasknest/core/constant/common_status.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';

class PageHeader extends StatelessWidget {
  final int? parentId;
  final String? parentTitle;
  final bool isMulti;

  const PageHeader({
    super.key,
    this.parentId,
    this.parentTitle,
    this.isMulti = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (parentId != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: ThemeColors.unifiedBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeColors.unifiedBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.subdirectory_arrow_right_rounded,
                  size: 16,
                  color: ThemeColors.unifiedTextMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${ConstStrings.creatingSubTicketFor}$parentId ${parentTitle ?? ""}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.unifiedTextMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    ThemeColors.unifiedGradStart,
                    ThemeColors.unifiedGradEnd,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMulti
                      ? ConstStrings.createMultiTicket
                      : ConstStrings.createStandardTicket,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedTextPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  ConstStrings.fillDetailsAndAssign,
                  style: AppTextStyles.bodySmallMuted,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class FormField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool required;

  const FormField({
    super.key,
    required this.label,
    required this.icon,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: ThemeColors.unifiedTextMuted),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: ThemeColors.unifiedTextPrimary,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 3),
          const Text(
            '*',
            style: TextStyle(
              fontSize: 13,
              color: ThemeColors.unifiedDanger,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class FormCard extends StatelessWidget {
  final Widget child;
  const FormCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.unifiedGradStart,
                  ThemeColors.unifiedGradEnd,
                ],
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(24), child: child),
        ],
      ),
    );
  }
}

class StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final String? Function(String?)? validator;

  const StyledTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        color: ThemeColors.unifiedTextPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: ThemeColors.unifiedTextMuted,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: ThemeColors.unifiedInputBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: ThemeColors.unifiedBorder,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: ThemeColors.unifiedBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: ThemeColors.unifiedPrimary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: ThemeColors.unifiedDanger,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: ThemeColors.unifiedDanger,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class StyledDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;
  final bool enabled;

  const StyledDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? ThemeColors.unifiedInputBg
            : ThemeColors.unifiedBorder.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(
              color: ThemeColors.unifiedTextMuted,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: ThemeColors.unifiedTextMuted,
            size: 20,
          ),
          style: const TextStyle(
            color: ThemeColors.unifiedTextPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: ThemeColors.unifiedSurface,
          borderRadius: BorderRadius.circular(10),
          items: enabled
              ? items
                    .map(
                      (e) => DropdownMenuItem<T>(
                        value: e,
                        child: Text(labelBuilder(e)),
                      ),
                    )
                    .toList()
              : [],
          onChanged: enabled ? (v) => v != null ? onChanged(v) : null : null,
        ),
      ),
    );
  }
}

class PrioritySelector extends StatelessWidget {
  final Priorities selected;
  final ValueChanged<Priorities> onChanged;

  const PrioritySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: priorities.map((p) {
        final isSel = p.id == selected.id;
        final color = CommonStatus.ticketStatusColor(p.name);

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(p),
            child: Container(
              margin: EdgeInsets.only(
                right: p.id < priorities.length - 1 ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSel
                    ? color.withValues(alpha: 0.12)
                    : ThemeColors.unifiedInputBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSel ? color : ThemeColors.unifiedBorder,
                  width: isSel ? 2 : 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.name[0].toUpperCase() + p.name.substring(1),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? color : ThemeColors.unifiedTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SubmitButton extends StatelessWidget {
  final bool submitting;
  final bool wide;
  final VoidCallback onTap;

  const SubmitButton({
    super.key,
    required this.submitting,
    required this.onTap,
    required this.wide,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: submitting ? null : onTap,
      child: Container(
        width: wide ? null : double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          gradient: submitting
              ? null
              : const LinearGradient(
                  colors: [
                    ThemeColors.unifiedGradStart,
                    ThemeColors.unifiedGradEnd,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: submitting ? ThemeColors.unifiedBorder : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: submitting
              ? null
              : [
                  BoxShadow(
                    color: ThemeColors.unifiedPrimary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (submitting)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ThemeColors.unifiedTextMuted,
                ),
              )
            else
              const Icon(Icons.send_rounded, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              submitting ? ConstStrings.submitting : ConstStrings.submitTicket,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: submitting ? ThemeColors.unifiedTextMuted : Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DepartmentChip extends StatelessWidget {
  final Departments department;
  final VoidCallback onRemove;

  const DepartmentChip({
    super.key,
    required this.department,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ThemeColors.unifiedPrimary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            department.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ThemeColors.unifiedPrimary,
            ),
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MultiDeptSection extends StatelessWidget {
  final List<Departments> departments;
  final Map<int, DeptFormData> formData;

  const MultiDeptSection({
    super.key,
    required this.departments,
    required this.formData,
  });

  static const _deptColors = [
    Color(0xFF4F46E5),
    Color(0xFF0891B2),
    Color(0xFF059669),
    Color(0xFFD97706),
    Color(0xFFDC2626),
    Color(0xFF7C3AED),
    Color(0xFFDB2777),
    Color(0xFF2563EB),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.dashboard_customize_rounded,
              size: 16,
              color: ThemeColors.unifiedTextMuted,
            ),
            const SizedBox(width: 6),
            const Text(
              ConstStrings.departmentTickets,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: ThemeColors.unifiedPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${departments.length} depts',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...departments.asMap().entries.map((entry) {
          final idx = entry.key;
          final dept = entry.value;
          final fd = formData[dept.id];
          final color = _deptColors[idx % _deptColors.length];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: color.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        dept.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Ticket #${idx + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormField(
                        label: ConstStrings.title,
                        icon: Icons.title_rounded,
                        required: true,
                      ),
                      const SizedBox(height: 6),
                      StyledTextField(
                        controller: fd?.titleCtrl ?? TextEditingController(),
                        hint: 'Title for ${dept.name} sub-ticket',
                        validator: (v) => v == null || v.isEmpty
                            ? 'Title is required for ${dept.name}'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      FormField(
                        label: ConstStrings.descriptionLabel,
                        icon: Icons.notes_rounded,
                        required: true,
                      ),
                      const SizedBox(height: 6),
                      StyledTextField(
                        controller: fd?.descCtrl ?? TextEditingController(),
                        hint: 'Describe task for ${dept.name}...',
                        maxLines: 2,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Description is required for ${dept.name}'
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class DeptFormData {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  DeptFormData({String title = '', String description = ''})
    : titleCtrl = TextEditingController(text: title),
      descCtrl = TextEditingController(text: description);
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
  }
}
