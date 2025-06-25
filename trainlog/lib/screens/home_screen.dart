import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/l10n/app_localizations.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
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
            // Contenu de fond (pour que l'effet glass soit visible)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.1),
                      Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            ),
            // Effet Liquid Glass pour la barre de navigation
            LiquidGlass(
              shape: LiquidRoundedSuperellipse(
                borderRadius: Radius.circular(32),
              ),
              settings: LiquidGlassSettings(
                ambientStrength: 2,
                lightAngle: 100 * math.pi,
                lightIntensity: 1,
                chromaticAberration: 2,
                glassColor: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.5),
                blur: 1.5,
                thickness: 11,
              ),
              child: Container(
                height: 60,
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
                        child: _buildNavItem(2, Icons.leaderboard_outlined,
                            l10n.navigationStats)),
                    Expanded(
                        child: _buildNavItem(
                            3, Icons.person_outline, l10n.navigationProfile)),
                  ],
                ),
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

    Widget iconWidget = Icon(
      icon,
      color: color,
      size: 30,
    );

    // Si l'élément est sélectionné, l'entourer avec un fond vert simple

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            /* const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ), */
          ],
        ),
      ),
    );
  }
}
