import 'package:flutter/material.dart';
import 'package:station_manager/core/themes/app_palette.dart';
import 'package:station_manager/features/dashboard/widgets/bottom_nav_bar_item.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppPallete.darkBackgroundColor
            : AppPallete.lightCardColor,
        boxShadow: [
          if (isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          else
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
        ],
      ),
      child: Row(
        children: [
          BottomNavBarItem(
            label: 'Station',
            icon: Icons.local_gas_station,
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          BottomNavBarItem(
            label: 'Fuel',
            icon: Icons.oil_barrel,
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
        ],
      ),
    );
  }
}

