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
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:reporting_system/services/notification_service.dart';
import 'firebase_options.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/services.dart';


// 1. إنشاء مفتاح عام للتنقل (Navigator Key)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // يخلي الإشعار يظهر كـ Alert
    badge: true,
    sound: true,
  );


  // 2. الاستماع للإشعارات والتطبيق مفتوح (Foreground)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Message received in foreground: ${message.notification?.title}');
    
    // سحب الـ context من الـ navigatorKey
    final context = navigatorKey.currentContext;
    
    if (context != null) {
      // إرسال الإشعار للخدمة لكي تظهر الـ Popup
      NotificationService().handleForegroundMessage(context, message);
    }
  });


  await UserService().loadUser();
  await LocalizationService().loadLocale();




  // طلب صلاحيات الإشعارات (مهم جداً لأندرويد 13+ و iOS)
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
        return ToastificationWrapper(
          child: MaterialApp(
            title: 'Reporting System',
            // 3. ربط الـ Navigator Key بالتطبيق
            navigatorKey: navigatorKey,
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
                if (user == null) return const LoginPage();
                return const MainScreen(key: ValueKey('main_screen'));
              },
            ),
            debugShowCheckedModeBanner: false,
          ),
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

  // مفاتيح مستقلة لكل tab
  List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    // ✅ استمع لتغيير اللغة وأعد بناء الـ Navigators
    LocalizationService.currentLocale.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocalizationService.currentLocale.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    setState(() {
      // ✅ GlobalKeys جديدة = الصفحات الجوه بتتبنى من أول وجديد بالترجمة الجديدة
      _navigatorKeys = [
        GlobalKey<NavigatorState>(),
        GlobalKey<NavigatorState>(),
        GlobalKey<NavigatorState>(),
      ];
    });
  }

  void _onItemTapped(int index) {
    // لو دوست على نفس الـ tab، ارجع للـ root بتاعه
    if (_selectedIndex == index) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      _navigatorKeys[_selectedIndex].currentState?.popUntil((route) => route.isFirst);
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // لما تضغط Back على الموبايل
  Future<bool> _onWillPop() async {
    final currentNavigator = _navigatorKeys[_selectedIndex].currentState;
    if (currentNavigator != null && currentNavigator.canPop()) {
      currentNavigator.pop();
      return false; // متخرجش من الأبلكيشن
    }
    return true;
  }

  Widget _buildNavigator(int index, Widget page) {
    return Navigator(
      key: _navigatorKeys[index],
      observers: [],
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => page,
        settings: settings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
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
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}