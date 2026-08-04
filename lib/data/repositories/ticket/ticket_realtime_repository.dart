import 'dart:async';
import 'package:tasknest/data/datasource/socket_helper.dart';
import 'package:tasknest/data/datasource/ticketdatasource/ticket_remote_data_source.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

class TicketRealtimeRepository {
  static final TicketRealtimeRepository _instance = TicketRealtimeRepository._();
  factory TicketRealtimeRepository() => _instance;
  TicketRealtimeRepository._();

  StreamSubscription<SocketEvent>? _rootSub;
  final StreamController<SocketEvent> _ticketEvents = StreamController<SocketEvent>.broadcast();
  final StreamController<SocketEvent> _connectionEvents = StreamController<SocketEvent>.broadcast();
  final StreamController<SocketEvent> _disputeEvents = StreamController<SocketEvent>.broadcast();
  final StreamController<Map<String, dynamic>> _notificationEvents = StreamController<Map<String, dynamic>>.broadcast();
  bool _initialized = false;

  /// Backend fan-out delivers the same mutation multiple times (raw event +
  /// TICKET_ENRICHED, each to user_ and dept_ rooms). Deduplicate by logical
  /// (ticketId, eventType) within a short window so one DB mutation produces
  /// exactly one realtime notification. Copies carrying a [notificationId]
  /// (user-room deliveries) are always preferred over bare dept-room copies.
  static const Duration _dedupeWindow = Duration(milliseconds: 1500);
  final Map<String, ({DateTime seenAt, bool sawNotification})> _recentEvents = {};

  /// All ticket-related events (created, updated, status, enriched, child_updated, etc.)
  Stream<SocketEvent> get ticketEvents => _ticketEvents.stream;

  /// Socket connection lifecycle events
  Stream<SocketEvent> get connectionEvents => _connectionEvents.stream;

  /// Dispute workflow events (DISPUTE_UPDATED)
  Stream<SocketEvent> get disputeEvents => _disputeEvents.stream;

  /// Notification count updates and toast-worthy events
  Stream<Map<String, dynamic>> get notificationEvents => _notificationEvents.stream;

  void initialize() {
    if (_initialized) return;
    _initialized = true;

    _rootSub = SocketHelper().events.listen((event) {
      if (!_isDuplicate(event)) {
        _routeEvent(event);
      }
    });
  }

  void _routeEvent(SocketEvent event) {
    if (event.type == 'SOCKET_CONNECTED') {
      _connectionEvents.add(event);
      return;
    }

    if (event.type == 'DISPUTE_UPDATED') {
      _disputeEvents.add(event);
      _ticketEvents.add(event);
      return;
    }

    if (event.type == 'NOTIFICATION_COUNT') {
      _notificationEvents.add({
        'type': 'NOTIFICATION_COUNT',
        'data': event.data,
      });
      return;
    }

    if (_isTicketEvent(event.type)) {
      _ticketEvents.add(event);

      final data = event.data;
      if (data is Map && data['notificationId'] != null) {
        _notificationEvents.add({
          'type': event.type,
          'data': data,
        });
      }
    }
  }

  bool _isDuplicate(SocketEvent event) {
    final data = event.data;
    if (data is! Map) return false;
    final ticketId = data['ticketId'];
    if (ticketId == null) return false;

    final eventType = data['event'] ?? event.type;
    final key = '$ticketId:$eventType';
    final now = DateTime.now();
    final hasNotification = data['notificationId'] != null;

    if (_recentEvents.length > 256) {
      _recentEvents.removeWhere(
        (_, e) => now.difference(e.seenAt) > _dedupeWindow,
      );
    }

    final last = _recentEvents[key];
    if (last != null && now.difference(last.seenAt) < _dedupeWindow) {
      // Prefer the user-room copy that carries the notification id; route it
      // through even if a dept-room copy was seen first.
      if (hasNotification && !last.sawNotification) {
        _recentEvents[key] = (seenAt: now, sawNotification: true);
        return false;
      }
      return true;
    }
    _recentEvents[key] = (seenAt: now, sawNotification: hasNotification);
    return false;
  }

  void dispose() {
    _rootSub?.cancel();
    _ticketEvents.close();
    _connectionEvents.close();
    _disputeEvents.close();
    _notificationEvents.close();
    _initialized = false;
  }

  /// Watch a specific ticket by ID. Returns a stream that emits updated
  /// [TicketModel] whenever the ticket or any of its ancestors/descendants change.
  /// If [initial] is provided, it is emitted immediately instead of performing
  /// a redundant initial fetch (the caller already fetched the ticket).
  Stream<TicketModel> watchTicket(
    int ticketId,
    TicketRemoteDataSource dataSource, {
    TicketModel? initial,
  }) {
    final controller = StreamController<TicketModel>();
    Timer? debounce;
    TicketModel? lastTicket = initial;

    if (initial != null) {
      if (!controller.isClosed) controller.add(initial);
    } else {
      // Initial fetch
      dataSource.getTicket(ticketId).then((ticket) {
        lastTicket = ticket;
        if (!controller.isClosed) controller.add(ticket);
      }).catchError((_) {});
    }

    final sub = ticketEvents.listen((event) {
      final data = event.data;
      if (data is! Map) return;

      final eid = data['ticketId'];
      final parentId = data['parentTicketId'] ?? data['ticket']?['parent_ticket_id'];
      final parentChain = data['parentChain'];
      final isRelevant = eid == ticketId ||
          parentId == ticketId ||
          (parentChain is List && parentChain.contains(ticketId));

      if (!isRelevant) return;

      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 300), () async {
        try {
          final updated = await dataSource.getTicket(ticketId);
          if (!controller.isClosed) {
            if (lastTicket == null ||
                updated.status != lastTicket!.status ||
                updated.overallProgress != lastTicket!.overallProgress ||
                updated.lastUpdatedAt != lastTicket!.lastUpdatedAt ||
                updated.assignedToId != lastTicket!.assignedToId) {
              lastTicket = updated;
              controller.add(updated);
            }
          }
        } catch (_) {}
      });
    });

    controller.onCancel = () {
      debounce?.cancel();
      sub.cancel();
    };

    return controller.stream;
  }

  static const _ticketEventTypes = {
    'TICKET_CREATED',
    'TICKET_ASSIGNED',
    'TICKET_STATUS_UPDATED',
    'TICKET_REOPENED',
    'TICKET_UPDATED',
    'TICKET_CLOSED',
    'TICKET_CHILD_UPDATED',
    'COMMENT_ADDED',
    'SUB_TICKET_CREATED',
    'SUB_TICKET_ASSIGNED',
    'SUB_TICKET_PROGRESS',
    'SUB_TICKET_COMPLETED',
    'SUB_TICKET_REOPENED',
    'TICKET_ENRICHED',
  };

  bool _isTicketEvent(String type) => _ticketEventTypes.contains(type);
}
