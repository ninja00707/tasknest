import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/presentation/admin/data/models/admin_models.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_bloc.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_event.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_state.dart';
import 'package:intl/intl.dart';

class AdminProjectsScreen extends StatefulWidget {
  final AdminBloc bloc;
  const AdminProjectsScreen({super.key, required this.bloc});

  @override
  State<AdminProjectsScreen> createState() => _AdminProjectsScreenState();
}

class _AdminProjectsScreenState extends State<AdminProjectsScreen> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.bloc.add(LoadProjects());
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      buildWhen: (prev, curr) =>
          curr is ProjectsLoaded || curr is AdminLoading || curr is AdminError,
      builder: (context, state) {
        final projects = state is ProjectsLoaded ? state.projects : <AdminProjectModel>[];
        final searchQuery = state is ProjectsLoaded ? state.searchQuery : '';
        final page = state is ProjectsLoaded ? state.clampedPage : 1;
        final totalPages = state is ProjectsLoaded ? state.totalPages : 1;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Projects', style: AppTextStyles.pageTitle),
                  Row(
                    children: [
                      _searchField(widget.bloc, searchQuery),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => widget.bloc.add(LoadProjects()),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (state is AdminLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state is ProjectsLoaded)
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: _buildTable(context, projects)),
                      if (totalPages > 1)
                        _pagination(widget.bloc, page, totalPages, projects.length),
                    ],
                  ),
                )
              else if (state is AdminError)
                Expanded(
                  child: Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: ThemeColors.unifiedDanger),
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _searchField(AdminBloc bloc, String searchQuery) {
    final ctl = TextEditingController(text: searchQuery);
    return SizedBox(
      width: 220,
      child: TextField(
        controller: ctl,
        decoration: InputDecoration(
          hintText: 'Search projects...',
          hintStyle: TextStyle(
            color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.6),
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: ThemeColors.unifiedTextMuted,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    size: 16,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                  onPressed: () {
                    ctl.clear();
                    bloc.add(UpdateProjectSearchQuery(''));
                  },
                )
              : null,
          filled: true,
          fillColor: ThemeColors.unifiedBackground,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: ThemeColors.unifiedBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: ThemeColors.unifiedBorder.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: ThemeColors.unifiedPrimary,
              width: 1.5,
            ),
          ),
        ),
        onSubmitted: (v) => bloc.add(UpdateProjectSearchQuery(v)),
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<AdminProjectModel> projects) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        controller: _verticalController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _verticalController,
          scrollDirection: Axis.vertical,
          child: Scrollbar(
            controller: _horizontalController,
            thumbVisibility: true,
            notificationPredicate: (notif) => notif.depth == 0,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  ThemeColors.unifiedBackground,
                ),
                columns: const [
                  DataColumn(
                    label: Text(
                      '#',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Company',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Priority',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Progress',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Members',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Tickets',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Created By',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Created',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Actions',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                ],
                rows: projects
                    .map(
                      (p) => DataRow(
                        cells: [
                          DataCell(
                            Text('${p.id}', style: const TextStyle(fontSize: 12)),
                          ),
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: Text(
                                p.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              p.companyName ?? '-',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          DataCell(_badge(p.status)),
                          DataCell(_priorityBadge(p.priority)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: LinearProgressIndicator(
                                    value: (p.progress / 100).clamp(0.0, 1.0),
                                    minHeight: 6,
                                    backgroundColor:
                                        ThemeColors.unifiedBorder,
                                    valueColor: const AlwaysStoppedAnimation(
                                      ThemeColors.unifiedPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${p.progress.toStringAsFixed(0)}%',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              '${p.memberCount}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${p.ticketCount}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          DataCell(
                            Text(
                              p.createdByName ?? '-',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          DataCell(
                            Text(
                              p.createdAt != null
                                  ? DateFormat('dd/MM/yy')
                                      .format(DateTime.parse(p.createdAt!))
                                  : '-',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(
                                Icons.visibility_outlined,
                                size: 17,
                                color: ThemeColors.unifiedSecondary,
                              ),
                              onPressed: () => _openDetail(context, p),
                              tooltip: ConstStrings.ticketDetail,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pagination(AdminBloc bloc, int page, int totalPages, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: page > 1 ? () => bloc.add(UpdateProjectPage(page - 1)) : null,
          ),
          const SizedBox(width: 8),
          Text(
            'Page $page of $totalPages ($count projects)',
            style: AppTextStyles.bodySmallMuted,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: page < totalPages
                ? () => bloc.add(UpdateProjectPage(page + 1))
                : null,
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, AdminProjectModel project) {
    showDialog(
      context: context,
      builder: (_) => _ProjectDetailDialog(project: project),
    );
  }

  Widget _badge(String status) {
    Color bg, fg;
    switch (status) {
      case 'active':
        bg = ThemeColors.statusProgressBg;
        fg = ThemeColors.statusProgressFg;
      case 'completed':
        bg = ThemeColors.statusClosedBg;
        fg = ThemeColors.statusClosedFg;
      default:
        bg = ThemeColors.statusOpenBg;
        fg = ThemeColors.statusOpenFg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _priorityBadge(String priority) {
    Color bg, fg;
    switch (priority) {
      case 'low':
        bg = ThemeColors.priorityLowBg;
        fg = ThemeColors.priorityLowFg;
      case 'medium':
        bg = ThemeColors.priorityMedBg;
        fg = ThemeColors.priorityMedFg;
      case 'high':
        bg = ThemeColors.priorityHighBg;
        fg = ThemeColors.priorityHighFg;
      default:
        bg = ThemeColors.priorityUrgentBg;
        fg = ThemeColors.priorityUrgentFg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ProjectDetailDialog extends StatelessWidget {
  final AdminProjectModel project;
  const _ProjectDetailDialog({required this.project});

  @override
  Widget build(BuildContext context) {
    final p = project;
    return Dialog(
      backgroundColor: ThemeColors.unifiedSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.folder_rounded,
                  color: ThemeColors.unifiedPrimary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    p.name,
                    style: AppTextStyles.pageTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),
            _infoRow('Code', _text(p.projectCode ?? '-')),
            _infoRow('Company', _text(p.companyName ?? '-')),
            _infoRow('Status', _text(p.status)),
            _infoRow('Priority', _text(p.priority)),
            _infoRow('Progress', _text('${p.progress.toStringAsFixed(0)}%')),
            _infoRow('Members', _text('${p.memberCount}')),
            _infoRow('Tickets', _text('${p.ticketCount}')),
            _infoRow('Created By', _text(p.createdByName ?? '-')),
            if (p.createdAt != null)
              _infoRow(
                'Created',
                _text(DateFormat('dd MMM yyyy').format(DateTime.parse(p.createdAt!))),
              ),
            if (p.description != null && p.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.unifiedTextMuted,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeColors.unifiedInputBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(p.description!, style: const TextStyle(fontSize: 13)),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(ConstStrings.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _text(String value) => Text(value, style: const TextStyle(fontSize: 13));

  Widget _infoRow(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}