import 'package:equatable/equatable.dart';
import 'package:tasknest/core/constant/const_dep.dart';

sealed class CreateTicketBaseState extends Equatable {
  const CreateTicketBaseState();
}

class CreateTicketFormState extends CreateTicketBaseState {
  final Priorities priority;
  final List<Departments> selectedDepartments;
  final dynamic selectedEmployee;
  final bool selfAssign;
  final bool submitting;

  const CreateTicketFormState({
    required this.priority,
    required this.selectedDepartments,
    this.selectedEmployee,
    this.selfAssign = false,
    this.submitting = false,
  });

  static final initial = CreateTicketFormState(
    priority: Priorities(name: 'medium', id: 1),
    selectedDepartments: [],
  );

  bool get isMulti => selectedDepartments.length > 1;

  CreateTicketFormState copyWith({
    Priorities? priority,
    List<Departments>? selectedDepartments,
    dynamic selectedEmployee = _sentinel,
    bool? selfAssign,
    bool? submitting,
  }) {
    return CreateTicketFormState(
      priority: priority ?? this.priority,
      selectedDepartments: selectedDepartments ?? this.selectedDepartments,
      selectedEmployee: identical(selectedEmployee, _sentinel)
          ? this.selectedEmployee
          : selectedEmployee,
      selfAssign: selfAssign ?? this.selfAssign,
      submitting: submitting ?? this.submitting,
    );
  }

  static const _sentinel = Object();

  @override
  List<Object?> get props => [
        priority.name,
        selectedDepartments.map((d) => d.id).toList(),
        selectedEmployee?.hashCode,
        selfAssign,
        submitting,
      ];
}

class CreateTicketSuccess extends CreateTicketBaseState {
  final CreateTicketFormState formState;
  const CreateTicketSuccess(this.formState);
  @override
  List<Object?> get props => [];
}

class CreateTicketError extends CreateTicketBaseState {
  final String message;
  final CreateTicketFormState formState;
  const CreateTicketError(this.message, this.formState);
  @override
  List<Object?> get props => [message];
}
