import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:station_manager/core/themes/app_palette.dart';
import 'package:station_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:station_manager/features/auth/presentation/bloc/auth_event.dart';
import 'package:station_manager/features/auth/presentation/pages/login_page.dart';
import 'package:station_manager/features/fuel_avaliabilty/presentation/bloc/fuel_availablity_bloc.dart';
import 'package:station_manager/features/fuel_avaliabilty/presentation/bloc/fuel_availablity_event.dart';
import 'package:station_manager/features/fuel_avaliabilty/presentation/bloc/fuel_availablity_state.dart';
import 'package:station_manager/features/station/presentation/bloc/station_bloc.dart';
import 'package:station_manager/features/station/presentation/bloc/station_event.dart';
import 'package:station_manager/features/station/presentation/bloc/station_state.dart';
import 'package:station_manager/features/user/presentation/bloc/user_bloc.dart';
import 'package:station_manager/features/user/presentation/bloc/user_event.dart';
import 'package:station_manager/features/user/presentation/bloc/user_state.dart';
import 'package:station_manager/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  final String? userId;
  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _stationId;
  bool _petrolAvailable = true;
  bool _dieselAvailable = true;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      context.read<UserBloc>().add(GetUserByIdEvent(userId: widget.userId!));
      context.read<StationBloc>().add(GetStationIdEvent(id: widget.userId!));
    }
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

  void _checkFuelAvailability(String stationId) {
    context.read<FuelAvailablityBloc>().add(
      CheckPetrolAvailabilityEvent(stationId: stationId, fuelType: 'PETROL'),
    );
    context.read<FuelAvailablityBloc>().add(
      CheckDieselAvailabilityEvent(stationId: stationId, fuelType: 'DIESEL'),
    );
  }

  void _changeFuelAvailability(String fuelType, bool isAvailable) {
    if (fuelType == 'PETROL') {
      context.read<FuelAvailablityBloc>().add(
        ChangePetrolAvailabilityEvent(
          stationId: _stationId,
          fuelType: fuelType,
        ),
      );
    } else {
      context.read<FuelAvailablityBloc>().add(
        ChangeDieselAvailabilityEvent(
          stationId: _stationId,
          fuelType: fuelType,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<StationBloc, StationState>(
          listener: (context, state) {
            if (state is StationSuccess) {
              setState(() {
                _stationId = state.response['data']['id'];
              });
              _checkFuelAvailability(_stationId);
            }
          },
        ),
        BlocListener<FuelAvailablityBloc, FuelAvailabilityState>(
          listener: (context, state) {
            if (state is FuelAvailabilitySuccess) {
              if (state.response['fuel_type'] == 'PETROL') {
                setState(() {
                  _petrolAvailable = state.response['available'] ?? true;
                });
              } else if (state.response['fuel_type'] == 'DIESEL') {
                setState(() {
                  _dieselAvailable = state.response['available'] ?? true;
                });
              }
            } else if (state is FuelAvailabilityError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Station Manager',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppPallete.primaryColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
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
        body: BlocBuilder<StationBloc, StationState>(
          builder: (context, state) {
            if (state is StationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is StationSuccess) {
              final station = state.response['data'];
              return _buildStationContent(context, station);
            } else if (state is StationFailure) {
              return Center(child: Text('Error: ${state.error}'));
            } else if (state is StationNotFound) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('No station data available'));
          },
        ),
      ),
    );
  }

  Widget _buildStationContent(
    BuildContext context,
    Map<String, dynamic> station,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppPallete.primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          station['logo'] ??
                              'https://img.icons8.com/color/96/gas-pump.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.local_gas_station,
                            size: 50,
                            color: AppPallete.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      station['en_name'] ?? 'Station Name',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      station['am_name'] ?? 'ጣቢያ',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: station['status'] == 'VERIFIED'
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: station['status'] == 'VERIFIED'
                              ? Colors.green
                              : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        station['status'] ?? 'UNKNOWN',
                        style: TextStyle(
                          color: station['status'] == 'VERIFIED'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Station Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildListDelegate([
              _buildDetailTile(
                context,
                icon: Icons.assignment_ind,
                title: 'TIN Number',
                value: station['tin_number'] ?? 'N/A',
              ),
              _buildDetailTile(
                context,
                icon: Icons.location_on,
                title: 'Address',
                value: station['address'] ?? 'N/A',
              ),
              _buildDetailTile(
                context,
                icon: Icons.calendar_today,
                title: 'Registered Since',
                value: station['created_at'] != null
                    ? station['created_at'].toString().split('T')[0]
                    : 'N/A',
              ),
              _buildDetailTile(
                context,
                icon: Icons.phone,
                title: 'Contact',
                value: station['phone'] ?? 'N/A',
              ),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Fuel Availability',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildFuelSwitchTile(
                      context,
                      title: 'Petrol',
                      subtitle: _petrolAvailable
                          ? 'Available'
                          : 'Not Available',
                      value: _petrolAvailable,
                      onChanged: (value) {
                        setState(() {
                          _petrolAvailable = value;
                        });
                        _changeFuelAvailability('PETROL', value);
                      },
                      icon: Icons.local_gas_station,
                      activeColor: _petrolAvailable ? Colors.green : Colors.red,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildFuelSwitchTile(
                      context,
                      title: 'Diesel',
                      subtitle: _dieselAvailable
                          ? 'Available'
                          : 'Not Available',
                      value: _dieselAvailable,
                      onChanged: (value) {
                        setState(() {
                          _dieselAvailable = value;
                        });
                        _changeFuelAvailability('DIESEL', value);
                      },
                      icon: Icons.local_gas_station,
                      activeColor: _dieselAvailable ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        /*      SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Location',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_pin,
                          color: AppPallete.primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Coordinates',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${station['latitude'] ?? 'N/A'}, ${station['longitude'] ?? 'N/A'}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement map view
                        },
                        icon: const Icon(Icons.map, size: 20),
                        label: const Text('View on Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ), */
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }

  Widget _buildDetailTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppPallete.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: AppPallete.primaryColor),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color activeColor,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: activeColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: activeColor),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
      ),
      trailing: Transform.scale(
        scale: 0.9,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: activeColor,
          activeTrackColor: activeColor.withOpacity(0.5),
          inactiveThumbColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          inactiveTrackColor: isDarkMode ? Colors.grey[600] : Colors.grey[300],
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      minVerticalPadding: 0,
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
            decoration: BoxDecoration(
              color: AppPallete.primaryColor,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppPallete.primaryColor,
                  AppPallete.primaryColor.withOpacity(0.8),
                ],
              ),
            ),
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

