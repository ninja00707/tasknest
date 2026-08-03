import 'package:equatable/equatable.dart';
import 'package:tasknest/presentation/disputes/models/dispute_model.dart';

abstract class DisputeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DisputeInitial extends DisputeState {}

class DisputeLoading extends DisputeState {}

class DisputeListLoaded extends DisputeState {
  final List<DisputeModel> disputes;
  DisputeListLoaded(this.disputes);
  @override
  List<Object?> get props => [disputes];
}

class DisputeLoaded extends DisputeState {
  final DisputeModel? dispute;
  DisputeLoaded(this.dispute);
  @override
  List<Object?> get props => [dispute];
}

class DisputeActionInProgress extends DisputeState {}

class DisputeActionSuccess extends DisputeState {
  final String message;
  DisputeActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class DisputeActionError extends DisputeState {
  final String message;
  DisputeActionError(this.message);
  @override
  List<Object?> get props => [message];
}
