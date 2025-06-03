import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:station_manager/core/utils/token_services.dart';
import 'package:station_manager/features/fuel_avaliabilty/presentation/bloc/fuel_availablity_bloc.dart';
import 'package:station_manager/features/fuel_avaliabilty/presentation/bloc/fuel_availablity_event.dart';
import 'package:station_manager/features/fuel_avaliabilty/presentation/bloc/fuel_availablity_state.dart';
import 'package:station_manager/l10n/app_localizations.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tokenService = context.read<TokenService>();
    _refreshData();
    setState(() {
      _isLoading = true;
    });
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.stationIdNotFound),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
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

    Future.delayed(const Duration(milliseconds: 500), () {
      _refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FuelAvailablityBloc, FuelAvailabilityState>(
      listener: (context, state) {
        if (state is FuelAvailabilityUpdated) {
          setState(() {
            _petrolAvailable = state.petrolAvailable ?? _petrolAvailable;
            _dieselAvailable = state.dieselAvailable ?? _dieselAvailable;
            _isLoading = false;
          });
        } else if (state is FuelAvailabilityError) {
          setState(() {
            _isLoading = false;
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
      builder: (context, state) {
        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refreshData,
              child: _buildFuelContent(
                context,
                petrolAvailable: _petrolAvailable,
                dieselAvailable: _dieselAvailable,
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFuelContent(
    BuildContext context, {
    required bool petrolAvailable,
    required bool dieselAvailable,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.fuelAvailabilityTitle,
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
                      title: l10n.petrol,
                      subtitle: petrolAvailable
                          ? l10n.available
                          : l10n.notAvailable,
                      value: petrolAvailable,
                      onChanged: (value) =>
                          _changeFuelAvailability('PETROL', value),
                      icon: Icons.local_gas_station,
                      activeColor: petrolAvailable ? Colors.green : Colors.red,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildFuelSwitchTile(
                      context,
                      title: l10n.diesel,
                      subtitle: dieselAvailable
                          ? l10n.available
                          : l10n.notAvailable,
                      value: dieselAvailable,
                      onChanged: (value) =>
                          _changeFuelAvailability('DIESEL', value),
                      icon: Icons.local_gas_station,
                      activeColor: dieselAvailable ? Colors.green : Colors.red,
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
      trailing: Switch.adaptive(
        value: value,
        onChanged: _isLoading ? null : onChanged,
        activeColor: activeColor,
        activeTrackColor: activeColor.withOpacity(0.5),
        inactiveThumbColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        inactiveTrackColor: isDarkMode ? Colors.grey[600] : Colors.grey[300],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      minVerticalPadding: 0,
    );
  }
}

