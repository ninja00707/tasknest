import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/domain/repositories_impl/ticket_impl/ticket_impl.dart';
import 'package:tasknest/presentation/create_ticket_module/bloc/create_ticket_event.dart';
import 'package:tasknest/presentation/create_ticket_module/bloc/create_ticket_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateTicketBloc extends Bloc<CreateTicketEvent, CreateTicketBaseState> {
  final TicketRepositoryImpl _dataSource;

  CreateTicketBloc(this._dataSource) : super(CreateTicketFormState.initial) {
    on<UpdatePriority>(_onUpdatePriority);
    on<AddDepartment>(_onAddDepartment);
    on<RemoveDepartment>(_onRemoveDepartment);
    on<UpdateEmployee>(_onUpdateEmployee);
    on<ToggleSelfAssign>(_onToggleSelfAssign);
    on<SubmitTicket>(_onSubmit);
    on<ResetCreateForm>(_onReset);
  }

  CreateTicketFormState get _form => state as CreateTicketFormState;

  void _onUpdatePriority(
    UpdatePriority event,
    Emitter<CreateTicketBaseState> emit,
  ) {
    emit(_form.copyWith(priority: event.priority));
  }

  void _onAddDepartment(
    AddDepartment event,
    Emitter<CreateTicketBaseState> emit,
  ) {
    final updated = [..._form.selectedDepartments, event.department];
    emit(_form.copyWith(
      selectedDepartments: updated,
      selectedEmployee: null,
    ));
  }

  void _onRemoveDepartment(
    RemoveDepartment event,
    Emitter<CreateTicketBaseState> emit,
  ) {
    final updated = _form.selectedDepartments
        .where((d) => d.id != event.department.id)
        .toList();
    emit(_form.copyWith(
      selectedDepartments: updated,
      selectedEmployee: null,
    ));
  }

  void _onUpdateEmployee(
    UpdateEmployee event,
    Emitter<CreateTicketBaseState> emit,
  ) {
    emit(_form.copyWith(selectedEmployee: event.employee));
  }

  void _onToggleSelfAssign(
    ToggleSelfAssign event,
    Emitter<CreateTicketBaseState> emit,
  ) {
    emit(_form.copyWith(selfAssign: event.value));
  }

  Future<void> _onSubmit(
    SubmitTicket event,
    Emitter<CreateTicketBaseState> emit,
  ) async {
    if (_form.selectedDepartments.isEmpty) return;

    if (_form.isMulti && event.deptTickets != null) {
      for (final entry in event.deptTickets!.entries) {
        if (entry.value.title.isEmpty || entry.value.description.isEmpty) return;
      }
    }

    emit(_form.copyWith(submitting: true));

    try {
      final deptTicketsMap = _form.isMulti && event.deptTickets != null
          ? event.deptTickets!.entries
              .map((e) => <String, dynamic>{
                    'department_id': e.key,
                    'title': e.value.title,
                    'description': e.value.description,
                  })
              .toList()
          : null;

      await _dataSource.createTicket(
        title: event.title,
        description: event.description,
        priority: _form.priority.name,
        departmentIds: _form.selectedDepartments.map((d) => d.id).toList(),
        createdById: event.createdById,
        createdByDept: event.createdByDept,
        assignedToId: _form.isMulti ? null : _form.selectedEmployee?.id,
        dueDate: null,
        parentTicketId: event.parentTicketId,
        selfAssign: _form.selfAssign,
        subTitle: null,
        subDescription: null,
        deptTickets: deptTicketsMap,
        projectId: event.projectId,
      );

      emit(CreateTicketSuccess(_form));
      emit(CreateTicketFormState.initial);
    } catch (e) {
      emit(CreateTicketError(e.toString(), _form.copyWith(submitting: false)));
    }
  }

  void _onReset(ResetCreateForm event, Emitter<CreateTicketBaseState> emit) {
    emit(CreateTicketFormState.initial);
  }
}
