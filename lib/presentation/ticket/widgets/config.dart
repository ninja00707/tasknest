import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

/// Determines how tickets are visually arranged.
enum TicketViewType {
  /// Multi-column responsive grid (default for most views)
  grid,

  /// Vertical timeline with dot + line connectors
  timeline,

  /// Horizontal kanban board (columns by status)
  kanban,

  /// Simple vertical list
  list,
}

/// Determines which card widget is used for each ticket.
enum TicketCardStyle {
  /// Full card with priority stripe, journey, actions (TicketCard)
  full,

  /// Compact card with color bar, chips (TicketGridCard)
  compact,

  /// Timeline card with status dot, dept arrows
  timelineCard,

  /// Minimal card for kanban columns
  kanbanCard,
}

/// Pre-built header styles matching the existing views.
enum TicketHeaderStyle {
  /// Blue gradient icon + "My Tickets" + mini stats
  myTickets,

  /// Green gradient icon + "Recent Activity" + count
  recentActivity,

  /// Purple gradient icon + "Sent Sub-Tickets" + mini stats
  sentSubTickets,

  /// No header — caller provides their own
  none,
}

/// Configuration for [TicketListWidget].
///
/// Pass this once and the widget handles everything:
/// rendering, filtering, pagination, empty states.
class TicketListConfig {
  final TicketViewType viewType;
  final TicketCardStyle cardStyle;
  final TicketHeaderStyle headerStyle;

  /// Custom header replaces [headerStyle] entirely when set.
  final Widget? customHeader;

  /// Custom card builder overrides [cardStyle].
  final Widget Function(TicketModel ticket)? customCardBuilder;

  /// Callback when a ticket is tapped.
  final void Function(TicketModel ticket)? onTap;

  /// Filter tabs displayed above the list.
  final List<String>? statusTabs;

  /// Enable client-side pagination (15 per page).
  final bool enablePagination;
  final int pageSize;

  /// Enable client-side status/priority filter tabs.
  final bool enableFilters;

  /// Icon for empty state.
  final IconData emptyIcon;

  /// Title for empty state.
  final String emptyTitle;

  /// Subtitle for empty state.
  final String? emptySubtitle;

  /// User model (needed for full cards with action buttons).
  // ignore: avoid_init_to_null
  final dynamic user;

  const TicketListConfig({
    this.viewType = TicketViewType.grid,
    this.cardStyle = TicketCardStyle.full,
    this.headerStyle = TicketHeaderStyle.none,
    this.customHeader,
    this.customCardBuilder,
    this.onTap,
    this.statusTabs,
    this.enablePagination = false,
    this.pageSize = 15,
    this.enableFilters = false,
    this.emptyIcon = Icons.inbox_rounded,
    this.emptyTitle = ConstStrings.noTickets,
    this.emptySubtitle,
    this.user,
  });

  // ── Pre-built configs matching existing views ──

  /// "My Tickets" view.
  factory TicketListConfig.myTickets({required dynamic user}) => TicketListConfig(
        viewType: TicketViewType.grid,
        cardStyle: TicketCardStyle.compact,
        headerStyle: TicketHeaderStyle.myTickets,
        statusTabs: const ['All', 'Open', 'In Progress', 'Completed'],
        enablePagination: false,
        enableFilters: true,
        emptyIcon: Icons.inbox_rounded,
        emptyTitle: ConstStrings.noTicketsAssigned,
        emptySubtitle: ConstStrings.newTicketsWillAppear,
        user: user,
        onTap: null,
      );

  /// "Recent Activity" view.
  factory TicketListConfig.recentActivity() => TicketListConfig(
        viewType: TicketViewType.timeline,
        cardStyle: TicketCardStyle.timelineCard,
        headerStyle: TicketHeaderStyle.recentActivity,
        enablePagination: true,
        pageSize: 15,
        emptyIcon: Icons.history_toggle_off,
        emptyTitle: ConstStrings.noRecentActivity,
        emptySubtitle: 'Ticket activity will appear here as updates come in',
      );

  /// "Sent Sub-Tickets" view.
  factory TicketListConfig.sentSubTickets({required dynamic user}) =>
      TicketListConfig(
        viewType: TicketViewType.grid,
        cardStyle: TicketCardStyle.compact,
        headerStyle: TicketHeaderStyle.sentSubTickets,
        enablePagination: true,
        pageSize: 15,
        emptyIcon: Icons.share_outlined,
        emptyTitle: ConstStrings.noSubTicketsSent,
        emptySubtitle:
            'Sub-tickets created for other departments will appear here',
        user: user,
      );
}
