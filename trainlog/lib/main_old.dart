import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trainlog/theme/colors.dart';
import 'screens/history_screen.dart';
import 'screens/upcoming_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'providers/trip_provider.dart';
import 'providers/auth_provider.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/add_trip_screen_v3.dart';
import 'package:trainlog/services/ticket_scanner_service.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('fr_FR', null);

  // Initialiser home_widget avec l'AppGroupId
  await HomeWidget.setAppGroupId('group.TrainLog.prochainTrain');

  runApp(const TrainLogApp());
}

class TrainLogApp extends StatelessWidget {
  const TrainLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Force la barre de statut en noir (texte sombre)
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner:
            false, // Cette ligne désactive le bandeau debug

        title: 'TrainLog',
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary, // Bleu foncé
            secondary: AppColors.secondary, // Vert bleuté
            surface: AppColors.light, // Gris clair
            error: Colors.red,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: AppColors.dark, // Gris foncé
            onError: Colors.white,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          cardTheme: CardTheme(
            color: AppColors.light,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.secondary,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _ticketScanner = TicketScannerService();

  final List<Widget> _screens = [
    const UpcomingScreen(),
    const HistoryScreen(),
    const StatsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _setupImageChannel();
  }

  void _setupImageChannel() {
    const channel = MethodChannel('com.trainlog.app/image');
    channel.setMethodCallHandler((call) async {
      if (call.method == 'processImage') {
        final imagePath = call.arguments as String;
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTripScreenV3(
                initialImagePath: imagePath,
              ),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: SizedBox(
          height: 80,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dark.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                        child:
                            _buildNavItem(0, Icons.calendar_month, 'Trajets')),
                    Expanded(
                        child: _buildNavItem(1,
                            Icons.history_toggle_off_outlined, 'Historique')),
                    const Expanded(child: SizedBox()),
                    Expanded(child: _buildNavItem(2, Icons.bar_chart, 'Stats')),
                    Expanded(
                        child: _buildNavItem(3, Icons.card_travel, 'Profil')),
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
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected
                ? AppColors.primary
                : AppColors.secondary.withValues(alpha: 0.3),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.secondary.withValues(alpha: 0.3),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  const AddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.train,
          size: 32,
          color: AppColors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTripScreenV3(),
            ),
          );
        },
      ),
    );
  }
}
