import 'package:diamond_booking/constants/colors.dart';
import 'package:diamond_booking/screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'general_provider.dart';
import 'localization/demo_localization.dart';
import 'localization/language_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => GeneralProvider(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) async {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? language = sharedPreferences.getString("Language");
    if (language == null || language.isEmpty) {
      state?.setLocale(newLocale);
    } else {
      Locale newLocale = Locale(language, "SA");
      state?.setLocale(newLocale);
    }
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  late FirebaseAnalytics analytics;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    analytics = FirebaseAnalytics.instance;
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (_locale == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    } else {
      return Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Flutter Localization Demo",
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
              fontFamily: 'CODE_Light',
              textTheme:
              GoogleFonts.lailaTextTheme(Theme.of(context).textTheme),
            ),
            locale: _locale,
            supportedLocales: const [
              Locale("en", "US"),
              Locale("ar", "SA"),
            ],
            localizationsDelegates: const [
              DemoLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode &&
                    supportedLocale.countryCode == locale?.countryCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: analytics),
            ],
            home: const Splashscreen(),
          );
        },
      );
    }
  }
}