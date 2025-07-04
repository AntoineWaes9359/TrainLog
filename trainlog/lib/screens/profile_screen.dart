import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trainlog/theme/typography.dart';
import '../providers/auth_provider.dart';
import '/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            pinned: true,
            elevation: 0,
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: Text(
                l10n.profileTitle,
                style: AppTypography.displayMedium.copyWith(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
              centerTitle: false,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Carte de profil
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .shadow
                              .withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            child: Text(
                              authProvider.userName
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  '?',
                              style: AppTypography.displayMedium.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            authProvider.userName ?? l10n.defaultUserName,
                            style: AppTypography.headlineSmall.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary),
                          ),
                          Text(
                            authProvider.userEmail ?? '',
                            style: AppTypography.bodyMedium.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary
                                    .withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bouton de déconnexion
                  ListTile(
                    leading: Icon(Icons.logout,
                        color: Theme.of(context).colorScheme.onSurface),
                    title: Text(l10n.logoutButton,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface)),
                    onTap: () async {
                      try {
                        await authProvider.signOut();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.logoutError(e.toString())),
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
