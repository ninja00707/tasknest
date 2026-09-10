import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/projects/bloc/project_bloc.dart';
import 'package:tasknest/presentation/projects/bloc/project_event.dart';
import 'package:tasknest/presentation/projects/model/project_models.dart';
import 'package:tasknest/presentation/projects/widgets/team_manage_sheets.dart';
import 'package:tasknest/presentation/projects/widgets/ui_helpers.dart';

class TeamManagementSection extends StatelessWidget {
  final ProjectModel project;
  final bool canManage;
  const TeamManagementSection({
    super.key,
    required this.project,
    required this.canManage,
  });

  Future<void> _addPeople(
    BuildContext context, {
    required String title,
    required Set<int> existingIds,
    required bool isObserver,
  }) async {
    final bloc = context.read<ProjectBloc>();
    final result = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddPeopleSheet(title: title, existingIds: existingIds),
    );
    if (result == null || result.isEmpty) return;
    bloc.add(
      isObserver
          ? AddProjectObservers(projectId: project.id, userIds: result)
          : AddProjectMembers(projectId: project.id, userIds: result),
    );
  }

  void _removePeople(
    BuildContext context, {
    required bool isObserver,
    required int userId,
  }) {
    context.read<ProjectBloc>().add(
      isObserver
          ? RemoveProjectObserver(projectId: project.id, userId: userId)
          : RemoveProjectMember(projectId: project.id, userId: userId),
    );
  }

  Future<void> _addDepartments(BuildContext context) async {
    final bloc = context.read<ProjectBloc>();
    final result = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddDepartmentsSheet(
        title: 'Add Departments',
        existingIds: {for (final d in project.departments) d.id},
      ),
    );
    if (result == null || result.isEmpty) return;
    bloc.add(
      AddProjectDepartments(projectId: project.id, departmentIds: result),
    );
  }

  void _removeDepartment(BuildContext context, {required int departmentId}) {
    context.read<ProjectBloc>().add(
      RemoveProjectDepartment(
        projectId: project.id,
        departmentId: departmentId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = project.members;
    final observers = project.observers;
    final departments = project.departments;

    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.group_rounded,
            title: 'Members (${members.length})',
            trailing: canManage
                ? _AddButton(
                    onPressed: () => _addPeople(
                      context,
                      title: 'Add members',
                      existingIds: {for (final m in members) m.id},
                      isObserver: false,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          if (members.isEmpty)
            const FriendlyEmptyState(
              icon: Icons.person_outline_rounded,
              message: 'No members assigned.',
              hint: 'Members will appear here once added.',
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in members)
                  _PeopleChip(
                    name: m.name,
                    color: ThemeColors.unifiedPrimary,
                    onRemove: canManage
                        ? () => _removePeople(
                            context,
                            isObserver: false,
                            userId: m.id,
                          )
                        : null,
                  ),
              ],
            ),
          const SizedBox(height: 24),
          SectionHeader(
            icon: Icons.visibility_outlined,
            title: 'Observers (${observers.length})',
            trailing: canManage
                ? _AddButton(
                    onPressed: () => _addPeople(
                      context,
                      title: 'Add observers',
                      existingIds: {for (final o in observers) o.id},
                      isObserver: true,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          if (observers.isEmpty)
            const FriendlyEmptyState(
              icon: Icons.visibility_outlined,
              message: 'No observers.',
              hint: 'Observers can view the project.',
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final o in observers)
                  _PeopleChip(
                    name: o.name,
                    color: ThemeColors.unifiedAccent,
                    onRemove: canManage
                        ? () => _removePeople(
                            context,
                            isObserver: true,
                            userId: o.id,
                          )
                        : null,
                  ),
              ],
            ),
          const SizedBox(height: 24),
          SectionHeader(
            icon: Icons.apartment_rounded,
            title: 'Departments (${departments.length})',
            trailing: canManage
                ? _AddButton(
                    onPressed: () => _addDepartments(context),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          if (departments.isEmpty)
            const FriendlyEmptyState(
              icon: Icons.apartment_rounded,
              message: 'No departments linked.',
              hint: 'Departments will appear here once added.',
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final dept in departments)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColors.unifiedPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.apartment_rounded,
                          size: 14,
                          color: ThemeColors.unifiedPrimary.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dept.code.isNotEmpty ? dept.code : dept.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: ThemeColors.unifiedPrimary,
                          ),
                        ),
                        if (canManage) ...[
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () =>
                                _removeDepartment(context, departmentId: dept.id),
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.close_rounded,
                                size: 13,
                                color: ThemeColors.unifiedTextMuted,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PeopleChip extends StatelessWidget {
  final String name;
  final Color color;
  final VoidCallback? onRemove;
  const _PeopleChip({required this.name, required this.color, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 11,
        top: 7,
        bottom: 7,
        right: onRemove != null ? 6 : 11,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InitialsAvatar(name: name, size: 24),
          const SizedBox(width: 7),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: ThemeColors.unifiedTextPrimary,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: ThemeColors.unifiedTextMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Add'),
      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
    );
  }
}
