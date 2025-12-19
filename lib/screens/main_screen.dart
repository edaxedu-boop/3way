import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import 'home_screen.dart';
import 'debts_screen.dart';
import 'scan_screen.dart';
import 'investments_screen.dart';
import 'learn_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<DebtsScreenState> _debtScreenKey =
      GlobalKey<DebtsScreenState>();
  final GlobalKey<InvestmentsScreenState> _investmentsScreenKey =
      GlobalKey<InvestmentsScreenState>();

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const HomeScreen(),
      DebtsScreen(key: _debtScreenKey),
      const ScanScreen(),
      InvestmentsScreen(key: _investmentsScreenKey),
      const LearnScreen(),
    ];
  }

  void _navigateAndRefresh(
    String routeName,
    int screenIndex,
    VoidCallback refreshCallback,
  ) async {
    final navigationProvider = Provider.of<NavigationProvider>(
      context,
      listen: false,
    );
    final result = await Navigator.pushNamed(context, routeName);
    if (result == true) {
      refreshCallback();
    }
    navigationProvider.setIndex(screenIndex);
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final selectedIndex = navigationProvider.selectedIndex;

    Widget? floatingActionButton;
    switch (selectedIndex) {
      case 1: // Debt Screen
        floatingActionButton = FloatingActionButton(
          onPressed: () => _navigateAndRefresh(
            '/register_debt',
            1,
            () => _debtScreenKey.currentState?.refreshDebtData(),
          ),
          backgroundColor: const Color(0xFFFD6B6B),
          elevation: 2,
          tooltip: 'Añadir Deuda',
          child: const Icon(Icons.add, color: Colors.white),
        );
        break;
      case 2: // Scan Screen
        floatingActionButton = FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFF30E182),
          elevation: 2,
          tooltip: 'Ahorro',
          child: const Icon(Icons.savings_rounded, color: Color(0xFF122E2A)),
        );
        break;
      case 3: // Investments Screen
        floatingActionButton = FloatingActionButton(
          onPressed: () => _navigateAndRefresh(
            '/register_investment',
            3,
            () => _investmentsScreenKey.currentState?.refreshData(),
          ),
          backgroundColor: const Color(0xFF30E182),
          elevation: 2,
          tooltip: 'Añadir Inversión',
          child: const Icon(Icons.add, color: Color(0xFF122E2A)),
        );
        break;
      default:
        floatingActionButton = FloatingActionButton(
          onPressed: () => navigationProvider.setIndex(2),
          backgroundColor: const Color(0xFF30E182),
          elevation: 2,
          tooltip: 'Ahorro',
          child: const Icon(Icons.savings_rounded, color: Color(0xFF122E2A)),
        );
        break;
    }

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: selectedIndex, children: _widgetOptions),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: const Color(0xFF1A3833),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(
              icon: Icons.home_filled,
              label: 'Inicio',
              index: 0,
              selectedIndex: selectedIndex,
              navigationProvider: navigationProvider,
            ),
            _buildNavItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Deudas',
              index: 1,
              selectedIndex: selectedIndex,
              navigationProvider: navigationProvider,
            ),
            const SizedBox(width: 48),
            _buildNavItem(
              icon: Icons.trending_up,
              label: 'Inversiones',
              index: 3,
              selectedIndex: selectedIndex,
              navigationProvider: navigationProvider,
            ),
            _buildNavItem(
              icon: Icons.lightbulb_outline,
              label: 'Aprende',
              index: 4,
              selectedIndex: selectedIndex,
              navigationProvider: navigationProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required int selectedIndex,
    required NavigationProvider navigationProvider,
  }) {
    final bool isSelected = selectedIndex == index;
    final Color color = isSelected
        ? const Color(0xFF30E182)
        : Colors.white.withAlpha(153);
    return InkWell(
      onTap: () => navigationProvider.setIndex(index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
