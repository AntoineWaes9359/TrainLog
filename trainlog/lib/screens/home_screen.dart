import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'upcoming_screen.dart';
import 'history_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';
import '../widgets/add_button.dart';
import '../services/method_channel_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final MethodChannelService _methodChannelService = MethodChannelService();

  final List<Widget> _screens = [
    const UpcomingScreen(),
    const HistoryScreen(),
    const StatsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _methodChannelService.setupImageChannel(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        extendBody: true,
        body: _screens[_selectedIndex],
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: SizedBox(
        height: 80,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.07),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                      child: _buildNavItem(
                          0, Icons.explore_outlined, l10n.navigationTrips)),
                  Expanded(
                      child: _buildNavItem(
                          1, Icons.history, l10n.navigationHistory)),
                  const Expanded(child: SizedBox()),
                  Expanded(
                      child: _buildNavItem(
                          2, Icons.leaderboard_outlined, l10n.navigationStats)),
                  Expanded(
                      child: _buildNavItem(
                          3, Icons.person_outline, l10n.navigationProfile)),
                ],
              ),
            ),
            const Positioned(
              top: 0,
              child: AddButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
