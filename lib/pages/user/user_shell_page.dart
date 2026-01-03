import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'home/user_home_page.dart';
import 'favorite/user_favorite_page.dart';
import 'history/user_history_page.dart';
import 'account/user_account_page.dart';

class UserShellPage extends StatefulWidget {
  const UserShellPage({super.key});

  @override
  State<UserShellPage> createState() => _UserShellPageState();
}

class _UserShellPageState extends State<UserShellPage> {
  int index = 0;

  // ✅ FIX: gunakan List<Widget> (bukan List<StatefulWidget>)
  final List<Widget> pages = const [
    UserHomePage(),
    UserFavoritePage(),
    UserHistoryPage(),
    UserAccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: AppTheme.navy,
        unselectedItemColor: Colors.black54,
        onTap: (i) => setState(() => index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}
