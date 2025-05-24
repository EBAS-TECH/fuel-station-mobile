import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:station_manager/core/injection_container.dart';
import 'package:station_manager/core/themes/app_theme.dart';
import 'package:station_manager/core/utils/token_services.dart';
import 'package:station_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:station_manager/features/auth/presentation/pages/login_page.dart';
import 'package:station_manager/features/dashboard/pages/home_page.dart';
import 'package:station_manager/features/fuel_avaliabilty/presentation/bloc/fuel_availablity_bloc.dart';
import 'package:station_manager/features/station/presentation/bloc/station_bloc.dart';
import 'package:station_manager/features/user/presentation/bloc/user_bloc.dart';
import 'package:station_manager/l10n/app_localizations.dart';
import 'package:station_manager/settings/locale_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final prefs = await SharedPreferences.getInstance();
  final tokenService = TokenService(prefs);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  setUpDependencies();
  runApp(MainApp(tokenService: tokenService));
}

class MainApp extends StatelessWidget {
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
  final TokenService tokenService;
  const MainApp({super.key, required this.tokenService});

  @override
  Widget build(BuildContext context) {
    return Provider<TokenService>.value(
      value: tokenService,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<AuthBloc>()),
          BlocProvider(create: (_) => sl<UserBloc>()),
          BlocProvider(create: (_) => sl<StationBloc>()),
          BlocProvider(create: (_) => sl<FuelAvailablityBloc>()),
          BlocProvider(create: (_) => LocaleBloc()),
        ],
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
                      return HomePage(userId: userId);
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
      ),
    );
  }
}

