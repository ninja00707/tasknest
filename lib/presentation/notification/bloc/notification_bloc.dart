import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/data/datasource/socket_service.dart';
import 'package:tasknest/domain/repositories_impl/ticket_impl/ticket_impl.dart';
import 'package:tasknest/presentation/notification/models/notification_model.dart';
import 'package:injectable/injectable.dart';

// ── Events ────────────────────────────────────────────────────────────────
abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {}

class MarkAsReadEvent extends NotificationEvent {
  final int id;
  MarkAsReadEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class MarkAllReadEvent extends NotificationEvent {}

class UpdateUnreadCount extends NotificationEvent {
  final int count;
  UpdateUnreadCount(this.count);
  @override
  List<Object?> get props => [count];
}

class SocketNotificationReceived extends NotificationEvent {
  final String type;
  final Map<String, dynamic> data;
  SocketNotificationReceived(this.type, this.data);
  @override
  List<Object?> get props => [type, data];
}

class RemoveToast extends NotificationEvent {
  final int id;
  RemoveToast(this.id);
  @override
  List<Object?> get props => [id];
}

// ── Toast Data ────────────────────────────────────────────────────────────
class ToastData extends Equatable {
  final int id;
  final String type;
  final String? ticketNumber;
  final String message;
  const ToastData({required this.id, required this.type, this.ticketNumber, required this.message});
  @override
  List<Object?> get props => [id, type, ticketNumber, message];
}

// ── States ────────────────────────────────────────────────────────────────
abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final List<ToastData> toasts;
  NotificationLoaded({required this.notifications, required this.unreadCount, this.toasts = const []});
  @override
  List<Object?> get props => [notifications, unreadCount, toasts];
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────
@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final TicketRepositoryImpl _repo;
  StreamSubscription<SocketEvent>? _socketSub;
  bool _socketInitialized = false;
  int _toastIdSeq = 0;
  final Set<int> _recentNotificationIds = {};

  NotificationBloc(this._repo) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<MarkAllReadEvent>(_onMarkAllRead);
    on<UpdateUnreadCount>(_onUpdateUnreadCount);
    on<SocketNotificationReceived>(_onSocketNotification);
    on<RemoveToast>(_onRemoveToast);
    _initSocket();
  }

  Future<void> _initSocket() async {
    if (_socketInitialized && SocketService().isConnected) return;
    _socketSub?.cancel();
    _socketSub = SocketService().events.listen((event) {
      if (isClosed) return;
      if (event.type == 'SOCKET_CONNECTED') return;
      if (event.type == 'NOTIFICATION_COUNT') {
        final count = event.data['count'] as int?;
        if (count != null) add(UpdateUnreadCount(count));
        return;
      }
      final data = event.data is Map ? Map<String, dynamic>.from(event.data as Map) : <String, dynamic>{};
      final notifId = data['notificationId'];
      if (notifId == null) return;
      if (_recentNotificationIds.contains(notifId)) return;
      _recentNotificationIds.add(notifId);
      if (_recentNotificationIds.length > 50) _recentNotificationIds.remove(_recentNotificationIds.first);
      add(SocketNotificationReceived(event.type, data));
    });
    _socketInitialized = true;
  }

  @override
  Future<void> close() {
    _socketSub?.cancel();
    return super.close();
  }

  Future<void> _onLoad(LoadNotifications event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final response = await _repo.getNotifications();
      final currentToasts = state is NotificationLoaded ? (state as NotificationLoaded).toasts : <ToastData>[];
      emit(NotificationLoaded(
        notifications: response.notifications,
        unreadCount: response.unreadCount,
        toasts: currentToasts,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(MarkAsReadEvent event, Emitter<NotificationState> emit) async {
    try {
      await _repo.markAsRead(ids: [event.id]);
      add(LoadNotifications());
    } catch (_) {}
  }

  Future<void> _onMarkAllRead(MarkAllReadEvent event, Emitter<NotificationState> emit) async {
    try {
      await _repo.markAsRead();
      add(LoadNotifications());
    } catch (_) {}
  }

  void _onUpdateUnreadCount(UpdateUnreadCount event, Emitter<NotificationState> emit) {
    final current = state;
    if (current is NotificationLoaded) {
      emit(NotificationLoaded(
        notifications: current.notifications,
        unreadCount: event.count,
        toasts: current.toasts,
      ));
    }
  }

  void _onSocketNotification(SocketNotificationReceived event, Emitter<NotificationState> emit) {
    final id = ++_toastIdSeq;
    final toast = ToastData(
      id: id,
      type: event.type,
      ticketNumber: event.data['ticketNumber'] as String?,
      message: event.data['message'] as String? ?? _labelFor(event.type),
    );
    final current = state;
    final currentToasts = current is NotificationLoaded ? current.toasts : <ToastData>[];
    final currentNotifs = current is NotificationLoaded ? current.notifications : <NotificationModel>[];
    final currentUnread = current is NotificationLoaded ? current.unreadCount : 0;
    emit(NotificationLoaded(
      notifications: currentNotifs,
      unreadCount: currentUnread,
      toasts: [...currentToasts, toast],
    ));
    Future.delayed(const Duration(seconds: 5), () {
      if (!isClosed) add(RemoveToast(id));
    });
  }

  void _onRemoveToast(RemoveToast event, Emitter<NotificationState> emit) {
    final current = state;
    if (current is NotificationLoaded) {
      emit(NotificationLoaded(
        notifications: current.notifications,
        unreadCount: current.unreadCount,
        toasts: current.toasts.where((t) => t.id != event.id).toList(),
      ));
    }
  }

  String _labelFor(String type) {
    switch (type) {
      case 'TICKET_CREATED': return 'New ticket created';
      case 'TICKET_ASSIGNED': return 'Ticket assigned';
      case 'TICKET_STATUS_UPDATED': return 'Ticket status updated';
      case 'TICKET_REOPENED': return 'Ticket reopened';
      case 'SUB_TICKET_CREATED': return 'Sub-ticket created';
      case 'SUB_TICKET_ASSIGNED': return 'Sub-ticket assigned';
      case 'SUB_TICKET_PROGRESS': return 'Sub-ticket progress updated';
      case 'SUB_TICKET_COMPLETED': return 'Sub-ticket completed';
      case 'SUB_TICKET_REOPENED': return 'Sub-ticket reopened';
      case 'COMMENT_ADDED': return 'New comment added';
      case 'NOTIFICATION': return 'New notification';
      case 'TICKET_UPDATED': return 'Ticket details updated';
      default: return type;
    }
  }
}
