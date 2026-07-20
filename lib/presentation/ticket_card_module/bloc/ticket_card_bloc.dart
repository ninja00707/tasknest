import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/presentation/ticket_card_module/bloc/ticket_card_event.dart';
import 'package:tasknest/presentation/ticket_card_module/bloc/ticket_card_state.dart';

class TicketCardBloc extends Bloc<TicketCardEvent, TicketCardState> {
  Timer? _pulseTimer;
  Timer? _cleanupTimer;
  final Map<int, DateTime> _updateTimestamps = {};

  TicketCardBloc() : super(TicketCardState.initial) {
    on<InitializeTicketTracking>(_onInitialize);
    on<PulseTick>(_onPulseTick);
    on<CleanupStaleTickets>(_onCleanup);

    _startTimers();
  }

  void _startTimers() {
    _pulseTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (_) {
        if (!isClosed) add(const PulseTick());
      },
    );
    _cleanupTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        if (!isClosed) add(const CleanupStaleTickets());
      },
    );
  }

  void _onInitialize(
    InitializeTicketTracking event,
    Emitter<TicketCardState> emit,
  ) {
    final now = DateTime.now();
    for (final ticket in event.tickets) {
      final updated = ticket.lastUpdatedAt ?? ticket.createdAt;
      if (now.difference(updated).inSeconds < 10) {
        _updateTimestamps[ticket.id] = updated;
      }
    }
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
      (_, time) => now.difference(time).inSeconds >= 10,
    );
    emit(state.copyWith(
      recentlyUpdatedIds: _updateTimestamps.keys.toSet(),
    ));
  }

  @override
  Future<void> close() {
    _pulseTimer?.cancel();
    _cleanupTimer?.cancel();
    return super.close();
  }
}
