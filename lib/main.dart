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



// 1. إنشاء مفتاح عام للتنقل (Navigator Key)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
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
                return user == null ? const LoginPage() : const MainScreen();
                // return const MainScreen();                                 
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
