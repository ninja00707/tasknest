// ── App Bar ───────────────────────────────────────────────────────────────────
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';

class CommonDetailAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  final TicketModel? ticket;
  final String? title;
  final bool issuffixStatus;
  final VoidCallback? onHistoryPressed;
  final String? userName;

  const CommonDetailAppbar({
    super.key,
    required this.ticket,
    required this.title,
    required this.issuffixStatus,
    this.onHistoryPressed,
    this.userName,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 57,
      child: AppBar(
        backgroundColor: ThemeColors.unifiedSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: ThemeColors.unifiedBorder),
        ),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ThemeColors.unifiedBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: ThemeColors.unifiedTextPrimary,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeColors.unifiedBackground,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: ThemeColors.unifiedBorder,
                  width: 1.5,
                ),
              ),
              child: Text(
                '#${title ?? ticket?.id}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextMuted,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${title ?? ticket?.title}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextPrimary,
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Print button
          if (ticket != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                icon: const Icon(
                  Icons.print_rounded,
                  size: 20,
                  color: ThemeColors.unifiedTextPrimary,
                ),
                onPressed: () => _printTicket(context, ticket!, userName: userName),
                tooltip: 'Print ticket',
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: onHistoryPressed != null
                ? IconButton(
                    icon: const Icon(
                      Icons.history_rounded,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                    onPressed: onHistoryPressed,
                  )
                : const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: issuffixStatus && ticket != null
                ? Row(
                    children: [
                      PriorityBadge(priority: ticket!.priority),
                      const SizedBox(width: 6),
                      StatusBadge(status: ticket!.status),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

void _printTicket(BuildContext context, TicketModel t, {String? userName}) {
  final htmlContent = _buildPrintHtml(t, userName: userName);
  // Use srcdoc approach — avoids contentDocument cross-origin issues
  final iframe = html.IFrameElement()
    ..style.position = 'fixed'
    ..style.left = '-9999px'
    ..style.top = '-9999px'
    ..style.width = '800px'
    ..style.height = '600px'
    ..style.border = 'none'
    ..srcdoc = htmlContent;
  html.document.body!.append(iframe);
  // srcdoc auto-triggers print via inline <script>; just clean up after
  iframe.onLoad.listen((_) async {
    await Future.delayed(const Duration(seconds: 1));
    iframe.remove();
  });
}

String _buildPrintHtml(TicketModel t, {String? userName}) {
  final dateStr = t.createdAt.toString().substring(0, 19).replaceAll('T', ' ');
  final nowStr = DateTime.now().toString().substring(0, 19).replaceAll('T', ' ');
  return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Ticket #${t.ticketNumber.isNotEmpty ? t.ticketNumber : t.id}</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Segoe UI', Arial, sans-serif; padding: 40px; color: #1F2937; }
    .header { text-align: center; margin-bottom: 30px; padding-bottom: 20px; border-bottom: 2px solid #E5E7EB; }
    .header h1 { font-size: 22px; font-weight: 800; }
    .header .id { color: #6B7280; font-size: 13px; margin-top: 4px; }
    .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px; }
    .field .label { font-size: 10px; font-weight: 700; color: #9CA3AF; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px; }
    .field .value { font-size: 14px; font-weight: 600; color: #1F2937; }
    .section { margin-bottom: 24px; }
    .section h2 { font-size: 13px; font-weight: 700; color: #374151; margin-bottom: 8px; padding-bottom: 4px; border-bottom: 1px solid #E5E7EB; }
    .desc { font-size: 13px; line-height: 1.7; color: #4B5563; white-space: pre-wrap; }
    .footer { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #E5E7EB; font-size: 10px; color: #D1D5DB; }
    .badge { display: inline-block; padding: 2px 10px; border-radius: 10px; font-size: 11px; font-weight: 700; }
    .badge-open { background: #DCFCE7; color: #166534; }
    .badge-in_progress { background: #DBEAFE; color: #1E40AF; }
    .badge-completed { background: #D1FAE5; color: #065F46; }
    .badge-closed { background: #F3F4F6; color: #374151; }
    .badge-urgent { background: #FEE2E2; color: #991B1B; }
    .badge-high { background: #FFEDD5; color: #9A3412; }
    .badge-medium { background: #FEF9C3; color: #854D0E; }
    .badge-low { background: #E0E7FF; color: #3730A3; }
  </style>
</head>
<body>
  <div class="header">
    <h1>${_e(t.title)}</h1>
    <div class="id">Ticket #${t.ticketNumber.isNotEmpty ? t.ticketNumber : t.id}</div>
  </div>
  <div class="grid">
    <div class="field">
      <div class="label">Status</div>
      <div class="value"><span class="badge badge-${t.status}">${t.status.replaceAll('_', ' ').toUpperCase()}</span></div>
    </div>
    <div class="field">
      <div class="label">Priority</div>
      <div class="value"><span class="badge badge-${t.priority}">${t.priority.toUpperCase()}</span></div>
    </div>
    <div class="field">
      <div class="label">Department</div>
      <div class="value">${_e(t.assignedDeptCode)}</div>
    </div>
    <div class="field">
      <div class="label">Created By</div>
      <div class="value">${_e(t.createdByName)}</div>
    </div>
    <div class="field">
      <div class="label">Assigned To</div>
      <div class="value">${_e(t.assignedToName ?? 'Unassigned')}</div>
    </div>
    <div class="field">
      <div class="label">Created Date</div>
      <div class="value">$dateStr</div>
    </div>
  </div>
  <div class="section">
    <h2>Description</h2>
    <div class="desc">${_e(t.description)}</div>
  </div>
  <div class="footer">Printed by ${_e(userName ?? 'Unknown')} · TaskNest · $nowStr</div>
  <script>window.onload=function(){window.print()}</script>
</body>
</html>
''';
}

String _e(String s) {
  return s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;')
      .replaceAll('\n', '<br>');
}

// ── Print Preview Dialog (screenshot-friendly) ──────────────────────────────
class _PrintPreview extends StatelessWidget {
  final TicketModel ticket;
  const _PrintPreview({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final dateStr = ticket.createdAt.toString().substring(0, 19).replaceAll('T', ' ');
    final nowStr = DateTime.now().toString().substring(0, 19).replaceAll('T', ' ');

    return Container(
      width: 600,
      constraints: const BoxConstraints(maxHeight: 700),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                const Icon(Icons.print_rounded, size: 18, color: Color(0xFF374151)),
                const SizedBox(width: 8),
                const Text('Print Preview',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
          // ── Content ─────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(ticket.title,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 4),
                        Text(
                          'Ticket #${ticket.ticketNumber.isNotEmpty ? ticket.ticketNumber : ticket.id}',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(children: [
                    _pField('Status', ticket.status.replaceAll('_', ' ').toUpperCase()),
                    const SizedBox(width: 24),
                    _pField('Priority', ticket.priority.toUpperCase()),
                    const SizedBox(width: 24),
                    _pField('Department', ticket.assignedDeptCode),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    _pField('Created By', ticket.createdByName),
                    const SizedBox(width: 24),
                    _pField('Assigned To', ticket.assignedToName ?? 'Unassigned'),
                  ]),
                  const SizedBox(height: 16),
                  _pField('Created Date', dateStr),
                  const SizedBox(height: 24),
                  const Text('DESCRIPTION',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF), letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(ticket.description,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.6)),
                  ),
                  const SizedBox(height: 24),
                  Center(child: Text('Printed from TaskNest · $nowStr',
                      style: const TextStyle(fontSize: 10, color: Color(0xFFD1D5DB)))),
                ],
              ),
            ),
          ),
          // ── Footer buttons ──────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFD1D5DB)),
                    ),
                    child: const Text('Close',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    final w = html.window.open('', '_blank');
                    if (w != null) {
                      (w as dynamic).document.write(_buildPrintHtml(ticket));
                      (w as dynamic).document.close();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.print_rounded, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text('Print', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF), letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
      ],
    );
  }
}
