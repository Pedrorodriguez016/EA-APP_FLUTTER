import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  final int totalItems;
  final String itemTypePlural; // e.g., "usuarios" o "eventos"
  final bool isLoading;
  final VoidCallback? onPreviousPage; // Null si está deshabilitado
  final VoidCallback? onNextPage; // Null si está deshabilitado
  final void Function(int page) onPageSelected;

  const PaginationControls({
    super.key,
    required this.totalPages,
    required this.currentPage,
    required this.totalItems,
    this.itemTypePlural = "items", // Valor por defecto
    required this.isLoading,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                // El padre (la pantalla) decide si está habilitado
                onPressed: onPreviousPage,
              ),

              // Botones de página
              for (int i = 1; i <= totalPages; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentPage == i
                          ? Colors.indigo
                          : Colors.grey.shade200,
                      foregroundColor: currentPage == i
                          ? Colors.white
                          : Colors.black,
                      minimumSize: const Size(36, 36),
                      padding: EdgeInsets.zero,
                    ),
                    // Deshabilitar si está cargando
                    onPressed: isLoading ? null : () => onPageSelected(i),
                    child: Text('$i'),
                  ),
                ),

              IconButton(
                icon: const Icon(Icons.chevron_right),
                // El padre (la pantalla) decide si está habilitado
                onPressed: onNextPage,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Página $currentPage de $totalPages ($totalItems $itemTypePlural)",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}