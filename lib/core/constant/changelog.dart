/// Add new entries at the TOP of the list.
/// When deploying, increment [currentVersion] so the dialog triggers.
class ChangelogEntry {
  final String version;
  final String date;
  final List<ChangelogSection> sections;

  const ChangelogEntry(this.version, this.date, this.sections);
}

class ChangelogSection {
  final String title;
  final List<String> changes;

  const ChangelogSection(this.title, this.changes);
}

const String currentVersion = '1.0.1';

const List<ChangelogEntry> changelog = [
  ChangelogEntry('1.0.1', 'June 30, 2026', [
    // ChangelogSection('🔒 Privacy & Security', [
    //   'Company Isolation: CEOs and Directors can now ONLY see tickets from their own company. Other companies\' shared-department tickets are completely hidden.',
    //   'Notifications are now sent ONLY to directly involved users (creator, assignee, sub-ticket members) — NOT to the entire department/section.',
    // ]),
    ChangelogSection('📊 Dashboard & Stats', [
      'Dashboard counts now match the ticket list exactly (only top-level tickets are counted).',
      'Ticket list section on dashboard is now hidden for Managers can see in the All department screen now  — only regular Employees can see it. Managers see stats, metrics, and priority breakdown instead.',
      'Recent Activities timeline is redesigned with colored status dots, connecting lines, and clean card layout.',
    ]),
    ChangelogSection('🔔 Notifications & Alerts', [
      'Bell icon now ALWAYS shows your unread notification count (grey when 0, red when new)',
      'Duplicate notifications are blocked — same message for the same ticket will never appear twice (protected at both database and app level).',
    ]),
    ChangelogSection('✅ Bug Fixes', [
      'Filter "All" button now correctly clears all filters.',
      'Filter selection is now instant — no more waiting for the call.',
      'Comment permission issue fixed when viewing master tickets via sub-ticket access.',
      'Flutter web TextField tap issue resolved (no more re-mounting).',
      'All ID fields now correctly handle Flutter web double JSON values.',
    ]),
    ChangelogSection('💬 Comments & Assignments', [
      'Assigned To section now shows ALL sub-ticket assignees in the detail screen.',
      'Comment tiles now display department code (e.g., "ABC") next to user name.',
    ]),
    ChangelogSection('🎨 UI Improvements', [
      'Tasknest view added — toggle between List and Board view (columns by status).',
      'Sidebar on web is now collapsible with a toggle button.',
      'Print button added to ticket detail — opens browser print dialog with clean layout and "Printed by" footer.',
      'My Tickets redesigned with gradient header, stats cards, and filter tabs.',
      'Sent Sub-Tickets redesigned with stats header and pagination.',
      'Ticket titles no longer show "Project: " prefix. Existing data has been cleaned up.',
    ]),
    ChangelogSection('⚡ Performance', [
      'Departments and sent-tickets are now cached across reloads.',
    ]),
    ChangelogSection('🛠️ Other Fixes', [
      'Auto-assign duplicate dispatch removed.',
      'assignToEmployee now notifies all involved users, not just the reassigned employee.',
    ]),
  ]),
];
