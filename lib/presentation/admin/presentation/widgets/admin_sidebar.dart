import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onNav;
  final UserModel user;
  final VoidCallback? onBackToMain;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onNav,
    required this.user,
    this.onBackToMain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: ThemeColors.unifiedSurface,
        border: Border(right: BorderSide(color: ThemeColors.unifiedBorder)),
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [ThemeColors.unifiedGradStart, ThemeColors.unifiedGradEnd],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: const Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text('Admin Panel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _item(Icons.dashboard_outlined, 'Dashboard', 0),
          _item(Icons.people_outlined, 'Users', 1),
          _item(Icons.business_outlined, 'Departments', 2),
          _item(Icons.confirmation_number_outlined, 'Tickets', 3),
          const Spacer(),
          if (onBackToMain != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: InkWell(
                onTap: onBackToMain,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_back, size: 19, color: ThemeColors.unifiedTextMuted),
                      SizedBox(width: 12),
                      Text('Back to Main', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ThemeColors.unifiedTextMuted)),
                    ],
                  ),
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeColors.unifiedBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ThemeColors.unifiedBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: ThemeColors.unifiedPrimary,
                  child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: ThemeColors.unifiedTextPrimary)),
                      const Text('Admin', style: TextStyle(fontSize: 11, color: ThemeColors.unifiedTextMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, int index) {
    final sel = selectedIndex == index;
    return GestureDetector(
      onTap: () => onNav(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          gradient: sel ? const LinearGradient(colors: [ThemeColors.unifiedGradStart, ThemeColors.unifiedGradEnd]) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: sel ? Colors.white : ThemeColors.unifiedTextMuted),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                color: sel ? Colors.white : ThemeColors.unifiedTextMuted)),
          ],
        ),
      ),
    );
  }
}
