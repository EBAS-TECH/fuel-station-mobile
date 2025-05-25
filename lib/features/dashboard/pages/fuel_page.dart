import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:station_manager/core/utils/token_services.dart';
import 'package:station_manager/features/fuel_avaliabilty/presentation/bloc/fuel_availablity_bloc.dart';
import 'package:station_manager/features/fuel_avaliabilty/presentation/bloc/fuel_availablity_event.dart';
import 'package:station_manager/features/fuel_avaliabilty/presentation/bloc/fuel_availablity_state.dart';

class FuelPage extends StatefulWidget {
  final String userId;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const FuelPage({super.key, required this.userId, required this.scaffoldKey});

  @override
  State<FuelPage> createState() => _FuelPageState();
}

class _FuelPageState extends State<FuelPage> {
  late TokenService _tokenService;
  bool _petrolAvailable = false;
  bool _dieselAvailable = false;
  bool _isPetrolLoading = false;
  bool _isDieselLoading = false;

  @override
  void initState() {
    super.initState();
    _tokenService = context.read<TokenService>();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final stationId = _tokenService.getStationId();
    if (stationId != null) {
      context.read<FuelAvailablityBloc>().add(
        CheckPetrolAvailabilityEvent(stationId: stationId, fuelType: 'PETROL'),
      );
      context.read<FuelAvailablityBloc>().add(
        CheckDieselAvailabilityEvent(stationId: stationId, fuelType: 'DIESEL'),
      );
    }
  }

  void _changeFuelAvailability(String fuelType, bool currentValue) {
    final stationId = _tokenService.getStationId();
    if (stationId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Station ID not found')));
      return;
    }

    setState(() {
      if (fuelType == 'PETROL') {
        _isPetrolLoading = true;
      } else {
        _isDieselLoading = true;
      }
    });

    if (fuelType == 'PETROL') {
      context.read<FuelAvailablityBloc>().add(
        ChangePetrolAvailabilityEvent(stationId: stationId, fuelType: fuelType),
      );
    } else {
      context.read<FuelAvailablityBloc>().add(
        ChangeDieselAvailabilityEvent(stationId: stationId, fuelType: fuelType),
      );
    }

    // Refresh data after a short delay to ensure backend has processed the change
    Future.delayed(const Duration(milliseconds: 100), () {
      _refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FuelAvailablityBloc, FuelAvailabilityState>(
      listener: (context, state) {
        if (state is FuelAvailabilityUpdated) {
          setState(() {
            _petrolAvailable = state.petrolAvailable ?? _petrolAvailable;
            _dieselAvailable = state.dieselAvailable ?? _dieselAvailable;
            _isPetrolLoading = false;
            _isDieselLoading = false;
          });
        } else if (state is FuelAvailabilityError) {
          setState(() {
            _isPetrolLoading = false;
            _isDieselLoading = false;
          });
          if (!state.message.toLowerCase().contains('success')) {
            debugPrint(state.message);
          } else {
            if (state.isPetrolError == true) {
              _petrolAvailable = !_petrolAvailable;
            } else {
              _dieselAvailable = !_dieselAvailable;
            }
          }
        }
      },
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: _buildFuelContent(
          context,
          petrolAvailable: _petrolAvailable,
          dieselAvailable: _dieselAvailable,
          isPetrolLoading: _isPetrolLoading,
          isDieselLoading: _isDieselLoading,
        ),
      ),
    );
  }

  Widget _buildFuelContent(
    BuildContext context, {
    required bool petrolAvailable,
    required bool dieselAvailable,
    required bool isPetrolLoading,
    required bool isDieselLoading,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                      subtitle: petrolAvailable ? 'Available' : 'Not Available',
                      value: petrolAvailable,
                      onChanged: (value) =>
                          _changeFuelAvailability('PETROL', value),
                      icon: Icons.local_gas_station,
                      activeColor: petrolAvailable ? Colors.green : Colors.red,
                      isLoading: isPetrolLoading,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildFuelSwitchTile(
                      context,
                      title: 'Diesel',
                      subtitle: dieselAvailable ? 'Available' : 'Not Available',
                      value: dieselAvailable,
                      onChanged: (value) =>
                          _changeFuelAvailability('DIESEL', value),
                      icon: Icons.local_gas_station,
                      activeColor: dieselAvailable ? Colors.green : Colors.red,
                      isLoading: isDieselLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
    required bool isLoading,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return ListTile(
      leading: isLoading
          ? const SizedBox(
              width: 40,
              height: 40,
              child: Center(child: CircularProgressIndicator()),
            )
          : Container(
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
      trailing: isLoading
          ? const SizedBox(
              width: 48,
              height: 24,
              child: Center(child: CircularProgressIndicator()),
            )
          : Switch.adaptive(
              value: value,
              onChanged: isLoading ? null : onChanged,
              activeColor: activeColor,
              activeTrackColor: activeColor.withOpacity(0.5),
              inactiveThumbColor: isDarkMode
                  ? Colors.grey[400]
                  : Colors.grey[600],
              inactiveTrackColor: isDarkMode
                  ? Colors.grey[600]
                  : Colors.grey[300],
            ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      minVerticalPadding: 0,
    );
  }
}

