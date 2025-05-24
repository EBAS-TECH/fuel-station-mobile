import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:station_manager/core/themes/app_palette.dart';
import 'package:station_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:station_manager/features/auth/presentation/bloc/auth_event.dart';
import 'package:station_manager/features/auth/presentation/pages/login_page.dart';
import 'package:station_manager/features/dashboard/pages/fuel_page.dart';
import 'package:station_manager/features/dashboard/pages/station_page.dart';
import 'package:station_manager/features/dashboard/widgets/bottom_nav_bar.dart';
import 'package:station_manager/features/user/presentation/bloc/user_bloc.dart';
import 'package:station_manager/features/user/presentation/bloc/user_event.dart';
import 'package:station_manager/features/user/presentation/bloc/user_state.dart';
import 'package:station_manager/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  final String userId;
  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  late final List<Widget> _pages;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _pages = [
      StationPage(
        key: ValueKey('station_${widget.userId}'),
        userId: widget.userId,
        scaffoldKey: _scaffoldKey,
      ),
      FuelPage(
        key: ValueKey('fuel_${widget.userId}'),
        userId: widget.userId,
        scaffoldKey: _scaffoldKey,
      ),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserBloc>().add(GetUserByIdEvent(userId: widget.userId));
    });
  }

  Future<void> _handleLogOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logOut),
        content: Text(l10n.logOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.logOut, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<AuthBloc>().add(AuthLogOutEvent());
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Station Manager',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppPallete.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserSuccess) {
            final user = state.responseData["data"];
            return _buildProfileDrawer(context, user);
          } else if (state is UserFailure) {
            return Drawer(
              backgroundColor: Colors.white,
              child: Center(child: Text('Error loading profile')),
            );
          }
          return const Drawer(
            backgroundColor: Colors.white,
            child: Center(child: CircularProgressIndicator()),
          );
        },
      ),
      body: _pages[currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildProfileDrawer(BuildContext context, Map<String, dynamic> user) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              "${user["first_name"] ?? ''} ${user["last_name"] ?? ''}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(user["email"] ?? ''),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                child: ClipOval(
                  child: user["profile_pic"] != null
                      ? Image.network(
                          user["profile_pic"],
                          fit: BoxFit.cover,
                          width: 64,
                          height: 64,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person,
                            size: 48,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 48,
                          color: theme.colorScheme.onPrimary,
                        ),
                ),
              ),
            ),
            decoration: BoxDecoration(color: AppPallete.primaryColor),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  color: Colors.red,
                  onTap: () => _handleLogOut(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: color ?? (isDarkMode ? Colors.white70 : Colors.black54),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? (isDarkMode ? Colors.white : Colors.black87),
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 24,
    );
  }
}

