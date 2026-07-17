import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/widgets/bloc/ticket_list_event.dart';
import 'package:tasknest/presentation/ticket/widgets/bloc/ticket_list_state.dart';
import 'package:tasknest/presentation/ticket/widgets/config.dart';

class TicketListBloc extends Bloc<TicketListEvent, TicketListState> {
  final int pageSize;
  final bool enablePagination;

  TicketListBloc({
    required List<TicketModel> tickets,
    required TicketListConfig config,
    bool isWide = false,
    double screenWidth = 0,
  })  : pageSize = config.pageSize,
        enablePagination = config.enablePagination,
        super(TicketListState.initial(
          tickets: tickets,
          pageSize: config.pageSize,
          enablePagination: config.enablePagination,
          isWide: isWide,
          screenWidth: screenWidth,
        )) {
    on<FilterChanged>(_onFilterChanged);
    on<PageChanged>(_onPageChanged);
    on<ScreenSizeChanged>(_onScreenSizeChanged);
    on<TicketsChanged>(_onTicketsChanged);
  }

  void _onFilterChanged(FilterChanged event, Emitter<TicketListState> emit) {
    emit(state.copyWithFiltered(event.filter, pageSize, enablePagination));
  }

  void _onPageChanged(PageChanged event, Emitter<TicketListState> emit) {
    emit(state.copyWithPaged(event.page, pageSize, enablePagination));
  }

  void _onScreenSizeChanged(
    ScreenSizeChanged event,
    Emitter<TicketListState> emit,
  ) {
    emit(state.copyWith(isWide: event.isWide, screenWidth: event.screenWidth));
  }

  void _onTicketsChanged(TicketsChanged event, Emitter<TicketListState> emit) {
    emit(TicketListState.initial(
      tickets: event.tickets,
      pageSize: pageSize,
      enablePagination: enablePagination,
      isWide: state.isWide,
      screenWidth: state.screenWidth,
    ));
  }
}
