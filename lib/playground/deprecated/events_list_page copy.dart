// import 'package:crew_app/features/events/data/event.dart';
// import 'package:flutter/material.dart';
// import '../../../core/network/api_service.dart';
// import 'events_detail_page.dart';

// class EventsListPage extends StatelessWidget {
//   const EventsListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final api = ApiService();
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Events'),
//       ),
//       body: FutureBuilder<List<Event>>(
//         future: api.getEvents(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//           final events = snapshot.data ?? const <Event>[];
//           if (events.isEmpty) {
//             return const Center(child: Text('暂无活动'));
//           }
//           return ListView.builder(
//             itemCount: events.length,
//             itemBuilder: (context, i) {
//               final ev = events[i];
//               return ListTile(
//                 title: Text(ev.title),
//                 subtitle: Text(ev.location),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => EventDetailPage(event: ev)),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }