import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/features/events/presentation/pages/map/services/map_selection_flow.dart';
import 'package:crew_app/features/events/presentation/pages/map/services/quick_trip_guard.dart';
import 'package:crew_app/features/events/presentation/pages/map/sheets/destination_selection_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/map/sheets/map_place_details_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/events_map_ui_controller.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_selection_controller.dart';
import 'package:crew_app/features/events/state/events_providers.dart';
import 'package:crew_app/features/events/state/places_providers.dart';
import 'package:crew_app/features/events/state/user_location_provider.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:crew_app/core/network/places/places_service.dart';
import '../../../../data/event.dart';

class MapInteractionController {
  MapInteractionController(this._ref);

  final WidgetRef _ref;

  Future<void> onMapTap(BuildContext context, LatLng position) async {
    final loc = AppLocalizations.of(context)!;
    final places = _ref.read(placesServiceProvider);

    try {
      final placeId = await places.findPlaceId(position);
      if (!context.mounted) {
        return;
      }
      if (placeId == null) {
        await _showPlaceDetails(context, Future<PlaceDetails?>.value(null), loc);
        return;
      }

      await _showPlaceDetails(
        context,
        places.getPlaceDetails(placeId),
        loc,
      );
    } on PlacesApiException catch (error) {
      if (!context.mounted) {
        return;
      }
      final message = error.message.contains('not configured')
          ? loc.map_place_details_missing_api_key
          : error.message;
      _showSnackBar(
        context,
        message.isEmpty ? loc.map_place_details_error : message,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, loc.map_place_details_error);
    }
  }

  Future<void> startQuickTripFromQuickActions(
    BuildContext context,
    Future<void> Function(LatLng target, {double zoom}) moveCamera,
    Future<void> Function() hideEventCard,
  ) async {
    hideEventCard();
    final flow = _ref.read(mapSelectionFlowProvider);
    await flow.clearSelectedLocation();
    final selectionController =
        _ref.read(mapSelectionControllerProvider.notifier);
    final userLocation = _ref.read(userLocationProvider).value;
    if (userLocation != null) {
      selectionController.setSelectedLatLng(userLocation);
      selectionController.setDestinationLatLng(null);
      await moveCamera(userLocation, zoom: 15);
      await flow.showStartLocationSheet(context, moveCamera);
      return;
    }
    final loc = AppLocalizations.of(context)!;
    _showSnackBar(context, loc.map_quick_trip_select_start_tip);
  }

  Future<void> handleQuickTripResult(
    BuildContext context,
    QuickRoadTripResult result,
  ) async {
    final destination = result.destination;
    if (destination == null) {
      return;
    }
    final guard = _ref.read(quickTripGuardProvider);
    if (!await guard.ensureNetworkAvailable(context)) {
      return;
    }
    if (!await guard.ensureDisclaimerAccepted(context)) {
      return;
    }

    final loc = AppLocalizations.of(context)!;
    final title = result.title.trim();
    final startDisplay = _formatLocationDisplay(
      result.startAddress,
      result.start,
      loc,
    );
    final destinationDisplay = _formatLocationDisplay(
      result.destinationAddress,
      destination,
      loc,
    );

    try {
      await _ref.read(eventsProvider.notifier).createEvent(
            title: title.isEmpty ? loc.map_quick_trip_default_title : title,
            description:
                loc.map_quick_trip_description(startDisplay, destinationDisplay),
            pos: result.start,
            locationName: '$startDisplay → $destinationDisplay',
          );
      _showSnackBar(context, loc.map_quick_trip_created);
    } on ApiException catch (error) {
      final message = error.message.isEmpty
          ? loc.map_quick_trip_create_failed
          : error.message;
      _showSnackBar(context, message);
    } catch (_) {
      _showSnackBar(context, loc.map_quick_trip_create_failed);
    }
  }

  void onAvatarTap(BuildContext context, bool authed) {
    if (!authed) {
      Navigator.of(context).pushNamed('/login');
      return;
    }
    _ref.read(quickTripGuardProvider).openProfileOverlay();
  }

  void focusOnEvent(
    Event event,
    Future<void> Function(LatLng target, {double zoom}) moveCamera,
    PageController controller,
    WidgetRef ref,
  ) {
    moveCamera(LatLng(event.latitude, event.longitude), zoom: 14);
    ref.read(eventsMapUiControllerProvider.notifier).showEventCard(event);
    ref
        .read(eventsMapUiControllerProvider.notifier)
        .setHasMovedToSelected(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uiState = ref.read(eventsMapUiControllerProvider);
      if (!controller.hasClients) {
        return;
      }
      controller.jumpToPage(uiState.initialPage);
    });
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showPlaceDetails(
    BuildContext context,
    Future<PlaceDetails?> details,
    AppLocalizations loc,
  ) {
    return showMapPlaceDetailsSheet(
      context: context,
      detailsFuture: details,
      emptyMessage: loc.map_place_details_not_found,
    );
  }

  String _formatLocationDisplay(
    String? address,
    LatLng coords,
    AppLocalizations loc,
  ) {
    final trimmed = address?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    return loc.location_coordinates(
      coords.latitude.toStringAsFixed(6),
      coords.longitude.toStringAsFixed(6),
    );
  }
}

final mapInteractionControllerProvider = Provider.autoDispose(
  MapInteractionController.new,
);
