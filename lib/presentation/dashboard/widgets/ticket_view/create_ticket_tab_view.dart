import 'package:flutter/material.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/create_ticket_unified.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class CreateTicketTabView extends StatelessWidget {
  final UserModel user;
  const CreateTicketTabView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return CreateTicketUnified(user: user);
  }
}
