import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color(0xFF3DBDEC),
      unselectedItemColor: Color(0xFFB0B0B0),
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
      ),
      items: [
        // Home
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/navbar/Home.png',
            width: 24,
            height: 24,
          ),
          activeIcon: Image.asset(
            'assets/images/navbar/Home_selected.png',
            width: 24,
            height: 24,
          ),
          label: 'Home',
        ),

        // Inventory
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/navbar/Inventory.png',
            width: 24,
            height: 24,
          ),
          activeIcon: Image.asset(
            'assets/images/navbar/Inventory_selected.png',
            width: 24,
            height: 24,
          ),
          label: 'Inventory',
        ),

        // Status
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/navbar/Status.png',
            width: 24,
            height: 24,
          ),
          activeIcon: Image.asset(
            'assets/images/navbar/Status_selected.png',
            width: 24,
            height: 24,
          ),
          label: 'Status',
        ),

        // Profile
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/navbar/Profile.png',
            width: 24,
            height: 24,
          ),
          activeIcon: Image.asset(
            'assets/images/navbar/Profile_selected.png',
            width: 24,
            height: 24,
          ),
          label: 'Home',
        ),
      ],
    );
  }
}
