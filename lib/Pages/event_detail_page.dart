import 'package:crew_app/Models/event.dart';
import 'package:crew_app/Pages/events_map_page.dart';
import 'package:flutter/material.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;
  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Location: ${event.location}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Description: ${event.description}"),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // 跳转到地图页，并传递 selectedEvent
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventsMapPage(selectedEvent: event),
                  ),
                );
              },
              icon: Icon(Icons.map),
              label: Text("查看地图"),
            ),
          ],
        ),
      ),
    );
  }
}
