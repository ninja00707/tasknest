import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

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
