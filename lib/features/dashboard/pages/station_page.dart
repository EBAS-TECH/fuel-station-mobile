import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:station_manager/core/themes/app_palette.dart';
import 'package:station_manager/l10n/app_localizations.dart';
import 'package:station_manager/features/station/presentation/bloc/station_bloc.dart';
import 'package:station_manager/features/station/presentation/bloc/station_event.dart';
import 'package:station_manager/features/station/presentation/bloc/station_state.dart';

class StationPage extends StatefulWidget {
  final String userId;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const StationPage({
    super.key,
    required this.userId,
    required this.scaffoldKey,
  });

  @override
  State<StationPage> createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {
  @override
  void initState() {
    super.initState();
    context.read<StationBloc>().add(GetStationIdEvent(id: widget.userId));
  }

  Future<void> getStation() async {
    context.read<StationBloc>().add(GetStationIdEvent(id: widget.userId));
  }

  Future<void> _launchMaps(double latitude, double longitude) async {
    final l10n = AppLocalizations.of(context)!;

    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.launchError)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.launchError}: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<StationBloc, StationState>(
      builder: (context, state) {
        if (state is StationLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StationSuccess) {
          final station = state.response['data'];
          return _buildStationContent(context, station, l10n);
        } else if (state is StationFailure) {
          return Center(child: Text('Error: ${state.error}'));
        } else if (state is StationNotFound) {
          return Center(child: Text(state.message));
        }
        return Center(child: Text(l10n.noStationsFound));
      },
    );
  }

  Widget _buildStationContent(
    BuildContext context,
    Map<String, dynamic> station,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: getStation,
      child: CustomScrollView(
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
                        station['en_name'] ?? l10n.stationName,
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
                          station['status'] == 'VERIFIED'
                              ? l10n.verified
                              : station['status'] == 'PENDING'
                              ? l10n.pending
                              : l10n.unknownStatus,
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppPallete.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: AppPallete.primaryColor,
                    ),
                  ),
                  title: Text(l10n.location),
                  subtitle: Text(station['address'] ?? l10n.notProvided),
                  trailing: IconButton(
                    icon: Icon(Icons.map, color: AppPallete.primaryColor),
                    onPressed: () {
                      if (station['latitude'] != null &&
                          station['longitude'] != null) {
                        _launchMaps(
                          double.parse(station['latitude'].toString()),
                          double.parse(station['longitude'].toString()),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.stationInformation,
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
                  title: l10n.tinNumber,
                  value: station['tin_number'] ?? 'N/A',
                  l10n: l10n,
                ),
                _buildDetailTile(
                  context,
                  icon: Icons.calendar_today,
                  title: l10n.registeredSince,
                  value: station['created_at'] != null
                      ? station['created_at'].toString().split('T')[0]
                      : l10n.notProvided,
                  l10n: l10n,
                ),
              ]),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  Widget _buildDetailTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required AppLocalizations l10n,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

