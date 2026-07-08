import 'package:flutter/material.dart';
import 'package:tasknest/presentation/dashboard/widgets/meta_chip.dart'
    show MetaChip;

class IdentityPill extends StatelessWidget {
  final String userName;
  final String designation;
  final String? departmentName, roleName, companyName;

  const IdentityPill({
    super.key,
    required this.userName,
    this.designation = '',
    this.departmentName,
    this.roleName,
    this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1.2),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                if (companyName != null) MetaChip(companyName!),
                if (departmentName != null) MetaChip(departmentName!),
                MetaChip(
                  roleName?.toLowerCase() == 'ceo'
                      ? 'CEO'
                      : (designation.isNotEmpty
                            ? designation
                            : (roleName ?? '')),
                  emphasis: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
