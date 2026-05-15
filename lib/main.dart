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
import 'services/theme_service.dart';
import 'models/user_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:reporting_system/services/notification_service.dart';
import 'firebase_options.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_provider.dart';
import 'package:provider/provider.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );


  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      if(context.mounted) {
        NotificationService().handleForegroundMessage(context, message);
      }
    }
  });


  await UserService().loadUser();
  await LocalizationService().loadLocale();
  await ThemeService().loadTheme();




  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocalizationService.currentLocale,
      builder: (context, locale, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService().themeMode,
          builder: (context, themeMode, child) {
            return ToastificationWrapper(
              child: MultiProvider(
                providers: [
                  ChangeNotifierProvider(create: (_) => AuthProvider()),
                ],
                child: MaterialApp(
                  title: 'Reporting System',
                  navigatorKey: navigatorKey,
                  locale: locale,
                  supportedLocales: const [Locale('en'), Locale('ar')],
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  themeMode: themeMode,
                  theme: ThemeData(
                    primaryColor: const Color(0xFF1e3a8a),
                    scaffoldBackgroundColor: const Color(0xFFf5f5f5),
                    textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
                    useMaterial3: true,
                    brightness: Brightness.light,
                    cardColor: Colors.white,
                    inputDecorationTheme: InputDecorationTheme(
                      fillColor: const Color(0xFFFAFAFA),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                    ),
                  ),
                  darkTheme: ThemeData(
                    primaryColor: const Color(0xFF3b82f6),
                    scaffoldBackgroundColor: const Color(0xFF121212),
                    textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
                      bodyColor: Colors.white,
                      displayColor: Colors.white,
                    ),
                    useMaterial3: true,
                    brightness: Brightness.dark,
                    cardColor: const Color(0xFF1e1e1e),
                    inputDecorationTheme: InputDecorationTheme(
                      fillColor: const Color(0xFF2a2a2a),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF444444)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      hintStyle: const TextStyle(color: Color(0xFF888888)),
                    ),
                  ),
                  home: ValueListenableBuilder<UserModel?>(
                    valueListenable: UserService().currentUser,
                    builder: (context, user, _) {
                      if (user == null) return const LoginPage();
                      return const MainScreen(key: ValueKey('main_screen'));
                    },
                  ),
                  debugShowCheckedModeBanner: false,
                ),
              ),
            );
          },
        );
      },
    );
  }
}


class _SubRouteObserver extends NavigatorObserver {
  final ValueNotifier<int> counter;

  _SubRouteObserver(this.counter);

  @override
  void didPush(Route route, Route? previousRoute) {
    if (previousRoute != null) {
      counter.value++;
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (counter.value > 0) counter.value--;
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    if (counter.value > 0) counter.value--;
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;


  final ValueNotifier<int> _subRouteCount = ValueNotifier(0);
  
  List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  late List<_SubRouteObserver> _observers;

  @override
  void initState() {
    super.initState();
    _observers = [
      _SubRouteObserver(_subRouteCount),
      _SubRouteObserver(_subRouteCount),
      _SubRouteObserver(_subRouteCount),
    ];
    LocalizationService.currentLocale.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocalizationService.currentLocale.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    setState(() {
       _subRouteCount.value = 0; 
      _navigatorKeys = [
        GlobalKey<NavigatorState>(),
        GlobalKey<NavigatorState>(),
        GlobalKey<NavigatorState>(),
      ];
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      _navigatorKeys[_selectedIndex].currentState?.popUntil((route) => route.isFirst);
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildNavigator(int index, Widget page) {
    return Navigator(
      key: _navigatorKeys[index],
      observers: [_observers[index]],
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => page,
        settings: settings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final currentNavigator = _navigatorKeys[_selectedIndex].currentState;
        if (currentNavigator != null && currentNavigator.canPop()) {
          currentNavigator.pop();
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildNavigator(0, HomePage(onNavigateToProfile: () => _onItemTapped(2))),
            _buildNavigator(1, const ReportsHistoryPage()),
            _buildNavigator(2, const ProfileSettingsPage()),
          ],
        ),
         bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: _subRouteCount,
          builder: (context, count, child) {
            return AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              offset: count > 0 ? const Offset(0, 1) : Offset.zero,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: count > 0 ? 0.0 : 1.0,
                child: child!,
              ),
            );
          },
          child: CustomBottomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        ),
      ),
    );
  }
}