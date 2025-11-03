// import 'package:crew_app/core/network/places/places_service.dart';
// import 'package:crew_app/l10n/generated/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// Future<void> showMapLocationInfoSheet({
//   required BuildContext context,
//   required LatLng position,
//   required Future<String?> addressFuture,
//   Future<List<NearbyPlace>>? nearbyPlacesFuture,
//   VoidCallback? onCreateEvent,
// }) {
//   return showModalBottomSheet(
//     context: context,
//     useSafeArea: true,
//     isScrollControlled: true,
//     backgroundColor: Theme.of(context).colorScheme.surface,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//     ),
//     builder: (_) => _MapLocationInfoSheet(
//       position: position,
//       addressFuture: addressFuture,
//       nearbyPlacesFuture: nearbyPlacesFuture,
//       onCreateEvent: onCreateEvent,
//     ),
//   );
// }

// class _MapLocationInfoSheet extends StatelessWidget {
//   const _MapLocationInfoSheet({
//     required this.position,
//     required this.addressFuture,
//     this.nearbyPlacesFuture,
//     this.onCreateEvent,
//   });

//   final LatLng position;
//   final Future<String?> addressFuture;
//   final Future<List<NearbyPlace>>? nearbyPlacesFuture;
//   final VoidCallback? onCreateEvent;

//   @override
//   Widget build(BuildContext context) {
//     final loc = AppLocalizations.of(context)!;
//     final theme = Theme.of(context);

//     return Padding(
//       padding: EdgeInsets.only(
//         left: 24,
//         right: 24,
//         top: 24,
//         bottom: MediaQuery.of(context).viewInsets.bottom + 24,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             loc.map_location_info_title,
//             style: theme.textTheme.titleMedium,
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               const Icon(Icons.location_on_outlined, color: Colors.redAccent),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   loc.location_coordinates(
//                     position.latitude.toStringAsFixed(6),
//                     position.longitude.toStringAsFixed(6),
//                   ),
//                   style: theme.textTheme.bodyMedium,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           FutureBuilder<String?>(
//             future: addressFuture,
//             builder: (context, snapshot) {
//               final icon = Icon(
//                 Icons.home_outlined,
//                 color: Colors.blueGrey.shade600,
//               );
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return _SheetRow(
//                   icon: icon,
//                   child: Text(loc.map_location_info_address_loading),
//                 );
//               }
//               if (snapshot.hasError) {
//                 return _SheetRow(
//                   icon: icon,
//                   child: Text(loc.map_location_info_address_unavailable),
//                 );
//               }
//               final address = snapshot.data;
//               final text = (address == null || address.trim().isEmpty)
//                   ? loc.map_location_info_address_unavailable
//                   : address;
//               return _SheetRow(
//                 icon: icon,
//                 child: Text(text),
//               );
//             },
//           ),
//           if (nearbyPlacesFuture != null) ...[
//             const SizedBox(height: 24),
//             _NearbyPlacesSection(nearbyPlacesFuture: nearbyPlacesFuture!),
//           ],
//           if (onCreateEvent != null) ...[
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: FilledButton(
//                 onPressed: onCreateEvent,
//                 child: Text(loc.map_location_info_create_event),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// class _SheetRow extends StatelessWidget {
//   const _SheetRow({required this.icon, required this.child});

//   final Icon icon;
//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         icon,
//         const SizedBox(width: 8),
//         Expanded(child: child),
//       ],
//     );
//   }
// }

// class _NearbyPlacesSection extends StatelessWidget {
//   const _NearbyPlacesSection({required this.nearbyPlacesFuture});

//   final Future<List<NearbyPlace>> nearbyPlacesFuture;

//   static const _cardHeight = 180.0;

//   @override
//   Widget build(BuildContext context) {
//     final loc = AppLocalizations.of(context)!;
//     final theme = Theme.of(context);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           loc.map_location_info_nearby_title,
//           style: theme.textTheme.titleMedium,
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           height: _cardHeight,
//           child: FutureBuilder<List<NearbyPlace>>(
//             future: nearbyPlacesFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (snapshot.hasError) {
//                 return Center(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Text(
//                       loc.map_location_info_nearby_error,
//                       textAlign: TextAlign.center,
//                       style: theme.textTheme.bodyMedium,
//                     ),
//                   ),
//                 );
//               }
//               final places = snapshot.data;
//               if (places == null || places.isEmpty) {
//                 return Center(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Text(
//                       loc.map_location_info_nearby_empty,
//                       textAlign: TextAlign.center,
//                       style: theme.textTheme.bodyMedium,
//                     ),
//                   ),
//                 );
//               }
//               return ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.only(right: 8),
//                 itemBuilder: (context, index) {
//                   final place = places[index];
//                   return _NearbyPlaceCard(place: place);
//                 },
//                 separatorBuilder: (_, _) => const SizedBox(width: 12),
//                 itemCount: places.length,
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _NearbyPlaceCard extends StatelessWidget {
//   const _NearbyPlaceCard({required this.place});

//   final NearbyPlace place;

//   static const _cardWidth = 220.0;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return SizedBox(
//       width: _cardWidth,
//       child: Card(
//         clipBehavior: Clip.antiAlias,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _NearbyPlaceImage(photoUrl: place.photoUrl),
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     place.displayName,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: theme.textTheme.titleSmall,
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     place.formattedAddress ?? '',
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: theme.textTheme.bodySmall,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _NearbyPlaceImage extends StatelessWidget {
//   const _NearbyPlaceImage({required this.photoUrl});

//   final String? photoUrl;

//   @override
//   Widget build(BuildContext context) {
//     if (photoUrl == null) {
//       return _PlaceholderImage(
//         icon: Icons.image_outlined,
//         backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest ,
//       );
//     }
//     return AspectRatio(
//       aspectRatio: 16 / 9,
//       child: Image.network(
//         photoUrl!,
//         fit: BoxFit.cover,
//         loadingBuilder: (context, child, progress) {
//           if (progress == null) {
//             return child;
//           }
//           return const Center(child: CircularProgressIndicator());
//         },
//         errorBuilder: (context, error, stackTrace) => _PlaceholderImage(
//           icon: Icons.broken_image_outlined,
//           backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest ,
//         ),
//       ),
//     );
//   }
// }

// class _PlaceholderImage extends StatelessWidget {
//   const _PlaceholderImage({
//     required this.icon,
//     required this.backgroundColor,
//   });

//   final IconData icon;
//   final Color backgroundColor;

//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: 16 / 9,
//       child: Container(
//         color: backgroundColor,
//         child: Icon(
//           icon,
//           size: 48,
//           color: Theme.of(context).colorScheme.onSurfaceVariant,
//         ),
//       ),
//     );
//   }
// }
