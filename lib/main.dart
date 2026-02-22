import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_page.dart';
import 'screens/reports_history_page.dart';
import 'screens/profile_settings_page.dart';
import 'screens/login_page.dart';
import 'widgets/bottom_nav_bar.dart';
import 'services/localization_service.dart';
import 'services/user_service.dart';
import 'models/user_model.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserService().loadUser();
  await LocalizationService().loadLocale();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocalizationService.currentLocale,
      builder: (context, locale, child) {
        return MaterialApp(
          title: 'Reporting System',
          locale: locale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            primaryColor: const Color(0xFF1e3a8a),
            scaffoldBackgroundColor: const Color(0xFFf5f5f5),
            textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
            useMaterial3: true,
          ),
          home: ValueListenableBuilder<UserModel?>(
            valueListenable: UserService().currentUser,
            builder: (context, user, _) {
              return user == null ? const LoginPage() : const MainScreen();
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = [
      HomePage(onNavigateToProfile: () => _onItemTapped(2)),
      const ReportsHistoryPage(),
      const ProfileSettingsPage(),
    ];
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: widgetOptions),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
