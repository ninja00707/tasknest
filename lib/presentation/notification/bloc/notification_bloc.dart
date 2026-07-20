import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  NotificationBloc(this._repo) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoad);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<MarkAllReadEvent>(_onMarkAllRead);
    on<UpdateUnreadCount>(_onUpdateUnreadCount);
    on<RemoveToast>(_onRemoveToast);
  }

  @override
  Future<void> close() {
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
}
