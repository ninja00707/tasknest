import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

class PrintButton extends StatelessWidget {
  final TicketModel ticket;
  final String userName;

  const PrintButton({super.key, required this.ticket, required this.userName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _printTicket(context, ticket, userName: userName);
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: ThemeColors.unifiedBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
        ),
        child: const Icon(
          Icons.print_rounded,
          size: 17,
          color: ThemeColors.unifiedTextPrimary,
        ),
      ),
    );
  }

  void _printTicket(BuildContext context, TicketModel t, {String? userName}) {
    final htmlContent = _buildPrintHtml(t, userName: userName);
    final iframe = html.IFrameElement()
      ..style.position = 'fixed'
      ..style.left = '-9999px'
      ..style.top = '-9999px'
      ..style.width = '800px'
      ..style.height = '600px'
      ..style.border = 'none'
      ..srcdoc = htmlContent;
    html.document.body!.append(iframe);
    iframe.onLoad.listen((_) async {
      await Future.delayed(const Duration(seconds: 1));
      iframe.remove();
    });
  }

  String _buildPrintHtml(TicketModel t, {String? userName}) {
    final dateStr = t.createdAt
        .toString()
        .substring(0, 19)
        .replaceAll('T', ' ');
    final nowStr = DateTime.now()
        .toString()
        .substring(0, 19)
        .replaceAll('T', ' ');
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
  </style>
</head>
<body>
  <div class="header">
    <h1>${_e(t.title)}</h1>
    <div class="id">Ticket #${t.ticketNumber.isNotEmpty ? t.ticketNumber : t.id}</div>
  </div>
  <div class="grid">
    <div class="field"><div class="label">Status</div><div class="value">${t.status.replaceAll('_', ' ').toUpperCase()}</div></div>
    <div class="field"><div class="label">Priority</div><div class="value">${t.priority.toUpperCase()}</div></div>
    <div class="field"><div class="label">Department</div><div class="value">${_e(t.assignedDeptCode)}</div></div>
    <div class="field"><div class="label">Created By</div><div class="value">${_e(t.createdByName)}</div></div>
    <div class="field"><div class="label">Assigned To</div><div class="value">${_e(t.assignedToName ?? 'Unassigned')}</div></div>
    <div class="field"><div class="label">Created Date</div><div class="value">$dateStr</div></div>
  </div>
  <div class="section">
    <h2>DESCRIPTION</h2>
    <div class="desc">${_e(t.description)}</div>
  </div>
  <div class="footer">Printed by ${_e(userName ?? 'Unknown')} \u00b7 TaskNest \u00b7 $nowStr</div>
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
}
