import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/login/models/auth_response_model.dart';

class TicketTypeGridArgs {
  final List<TicketModel> tickets;
  final String title;
  final UserModel user;
  const TicketTypeGridArgs({
    required this.tickets,
    required this.title,
    required this.user,
  });
}
