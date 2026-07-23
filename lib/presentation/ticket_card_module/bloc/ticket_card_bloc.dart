import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/data/datasource/socket_helper.dart';
import 'package:tasknest/data/repositories/ticket/ticket_realtime_repository.dart';
import 'package:tasknest/presentation/ticket_card_module/bloc/ticket_card_event.dart';
import 'package:tasknest/presentation/ticket_card_module/bloc/ticket_card_state.dart';

class TicketCardBloc extends Bloc<TicketCardEvent, TicketCardState> {
  final TicketRealtimeRepository _realtime = TicketRealtimeRepository();
  StreamSubscription<SocketEvent>? _socketSub;
  Timer? _pulseTimer;
  Timer? _cleanupTimer;
  final Map<int, DateTime> _updateTimestamps = {};

  TicketCardBloc() : super(TicketCardState.initial) {
    on<InitializeTicketTracking>(_onInitialize);
    on<SocketTicketUpdated>(_onSocketUpdate);
    on<PulseTick>(_onPulseTick);
    on<CleanupStaleTickets>(_onCleanup);

    _startTimers();
    _listenToSocket();
  }

  void _startTimers() {
    _pulseTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (_) {
        if (!isClosed) add(const PulseTick());
      },
    );
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        if (!isClosed) add(const CleanupStaleTickets());
      },
    );
  }

  void _listenToSocket() {
    _realtime.initialize();
    _socketSub = _realtime.ticketEvents.listen((event) {
      if (isClosed) return;
      final data = event.data;
      if (data is Map && data['ticketId'] != null) {
        add(SocketTicketUpdated(data['ticketId'] as int));
      }
    });
  }

  void _onInitialize(
    InitializeTicketTracking event,
    Emitter<TicketCardState> emit,
  ) {
    final now = DateTime.now();
    for (final ticket in event.tickets) {
      final updated = ticket.lastUpdatedAt ?? ticket.createdAt;
      if (now.difference(updated).inMinutes < 15) {
        _updateTimestamps[ticket.id] = updated;
      }
    }
    emit(state.copyWith(
      recentlyUpdatedIds: _updateTimestamps.keys.toSet(),
    ));
  }

  void _onSocketUpdate(
    SocketTicketUpdated event,
    Emitter<TicketCardState> emit,
  ) {
    _updateTimestamps[event.ticketId] = DateTime.now();
    emit(state.copyWith(
      recentlyUpdatedIds: _updateTimestamps.keys.toSet(),
    ));
  }

  void _onPulseTick(PulseTick event, Emitter<TicketCardState> emit) {
    emit(state.copyWith(pulseActive: !state.pulseActive));
  }

  void _onCleanup(
    CleanupStaleTickets event,
    Emitter<TicketCardState> emit,
  ) {
    final now = DateTime.now();
    _updateTimestamps.removeWhere(
      (_, time) => now.difference(time).inMinutes >= 15,
    );
    emit(state.copyWith(
      recentlyUpdatedIds: _updateTimestamps.keys.toSet(),
    ));
  }

  @override
  Future<void> close() {
    _socketSub?.cancel();
    _pulseTimer?.cancel();
    _cleanupTimer?.cancel();
    return super.close();
  }
}
