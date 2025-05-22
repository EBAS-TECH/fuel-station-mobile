import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:station_manager/core/injection_container.dart';
import 'package:station_manager/core/themes/app_theme.dart';
import 'package:station_manager/core/utils/token_services.dart';
import 'package:station_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:station_manager/features/auth/presentation/pages/login_page.dart';
import 'package:station_manager/features/dashboard/presentation/pages/home_page.dart';
import 'package:station_manager/l10n/app_localizations.dart';
import 'package:station_manager/settings/locale_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final prefs = await SharedPreferences.getInstance();
  final tokenService = TokenService(prefs);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MainApp(tokenService: tokenService));
}

class MainApp extends StatelessWidget {
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
  final TokenService tokenService;
  const MainApp({super.key, required this.tokenService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => sl<AuthBloc>())],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'Station Manager',
            locale: context.watch<LocaleBloc>().state,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('am')],
            theme: AppTheme.lightThemeMode,
            darkTheme: AppTheme.darkThemeMode,
            themeMode: ThemeMode.system,
            home: FutureBuilder<String?>(
              future: tokenService.getToken(),
              builder: (context, snapshot) {
                final hasToken = snapshot.data != null;
                final userId = tokenService.getUserId();

                if (hasToken) {
                  if (userId != null) {
                    return HomePage();
                  } else {
                    return const LoginPage();
                  }
                } else {
                  return const LoginPage();
                }
              },
            ),
            navigatorObservers: [routeObserver],
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

