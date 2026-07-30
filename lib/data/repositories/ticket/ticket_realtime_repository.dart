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
  final StreamController<Map<String, dynamic>> _notificationEvents = StreamController<Map<String, dynamic>>.broadcast();
  bool _initialized = false;

  /// All ticket-related events (created, updated, status, enriched, child_updated, etc.)
  Stream<SocketEvent> get ticketEvents => _ticketEvents.stream;

  /// Socket connection lifecycle events
  Stream<SocketEvent> get connectionEvents => _connectionEvents.stream;

  /// Notification count updates and toast-worthy events
  Stream<Map<String, dynamic>> get notificationEvents => _notificationEvents.stream;

  void initialize() {
    if (_initialized) return;
    _initialized = true;

    _rootSub = SocketHelper().events.listen((event) {
      if (event.type == 'SOCKET_CONNECTED') {
        _connectionEvents.add(event);
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
    });
  }

  void dispose() {
    _rootSub?.cancel();
    _ticketEvents.close();
    _connectionEvents.close();
    _notificationEvents.close();
    _initialized = false;
  }

  /// Watch a specific ticket by ID. Returns a stream that emits updated
  /// [TicketModel] whenever the ticket or any of its ancestors/descendants change.
  Stream<TicketModel> watchTicket(int ticketId, TicketRemoteDataSource dataSource) {
    final controller = StreamController<TicketModel>();
    Timer? debounce;
    TicketModel? lastTicket;

    // Initial fetch
    dataSource.getTicket(ticketId).then((ticket) {
      lastTicket = ticket;
      if (!controller.isClosed) controller.add(ticket);
    }).catchError((_) {});

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
