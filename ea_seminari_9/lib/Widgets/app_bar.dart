import 'package:flutter/material.dart';

class StandardAppBar extends StatelessWidget implements PreferredSizeWidget {
  
  final String title; 
  final VoidCallback? onSearchPressed; 

  const StandardAppBar({
    Key? key,
    required this.title,
    this.onSearchPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,

      iconTheme: const IconThemeData(color: Colors.black87), 
      
      actions: [
        // Solo mostramos el botón de búsqueda si se pasa una función
        if (onSearchPressed != null)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, color: Colors.grey),
            ),
            onPressed: onSearchPressed,
          ),
      ],
    );
  }
  
  // Esto es necesario para que funcione como un AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); 
}
