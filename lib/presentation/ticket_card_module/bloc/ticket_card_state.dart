import 'package:equatable/equatable.dart';

class TicketCardState extends Equatable {
  final Set<int> recentlyUpdatedIds;
  final bool pulseActive;

  const TicketCardState({
    required this.recentlyUpdatedIds,
    required this.pulseActive,
  });

  static const initial = TicketCardState(
    recentlyUpdatedIds: {},
    pulseActive: false,
  );

  TicketCardState copyWith({
    Set<int>? recentlyUpdatedIds,
    bool? pulseActive,
  }) {
    return TicketCardState(
      recentlyUpdatedIds: recentlyUpdatedIds ?? this.recentlyUpdatedIds,
      pulseActive: pulseActive ?? this.pulseActive,
    );
  }

  @override
  List<Object> get props => [recentlyUpdatedIds, pulseActive];
}
