import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

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
