import 'package:flutter/material.dart';
import '../Models/user.dart';

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(user.username),
        subtitle: Text(user.gmail),
        trailing: Text(user.birthday),

      ),
    );
  }
}
