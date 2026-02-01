import 'package:flutter/material.dart';
import '../services/inventory_controller.dart';
import '../theme/game_theme.dart';

class BackpackView extends StatelessWidget {
  final InventoryController inventory;
  final Function(String) onNotify;

  const BackpackView({super.key, required this.inventory, required this.onNotify});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: 40,
      itemBuilder: (context, index) {
        bool hasItem = index < inventory.items.length;
        final item = hasItem ? inventory.items[index] : null;

        return GestureDetector(
          onTap: () {
            if (hasItem) {
              onNotify("${item!.name}: ${item.description}");
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: hasItem
                ? const Center(child: Icon(Icons.inventory_2, color: GameTheme.textGreen))
                : null,
          ),
        );
      },
    );
  }
}