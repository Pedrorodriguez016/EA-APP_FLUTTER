import 'package:flutter/material.dart';

class UserInfoBasic extends StatelessWidget {
  final String name;
  final String email;
  final String birthday;
  final String? imageUrl; // Opcional, por si en el futuro quieres mostrar foto

  const UserInfoBasic({
    Key? key,
    required this.name,
    required this.email,
    required this.birthday,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // 🧑 Avatar circular (con fallback elegante)
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.indigo.shade100,
              backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
                  ? NetworkImage(imageUrl!)
                  : null,
              child: (imageUrl == null || imageUrl!.isEmpty)
                  ? const Icon(Icons.person, size: 40, color: Colors.indigo)
                  : null,
            ),
            const SizedBox(width: 20),

            // 🧾 Información del usuario
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.cake_outlined,
                            size: 18, color: Colors.pink.shade400),
                        const SizedBox(width: 6),
                        Text(
                          birthday,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
