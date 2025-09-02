
import 'package:crew_app/Models/event.dart';
import 'package:crew_app/Pages/event_detail_page.dart';
import 'package:crew_app/Pages/events_map_page.dart';
import 'package:crew_app/Pages/profile_page.dart';
import 'package:crew_app/Pages/search_events_page.dart';
import 'package:crew_app/Services/api_service.dart';
import 'package:flutter/material.dart';

class EventsListPage extends StatefulWidget {
  final ApiService api;
  const EventsListPage({super.key, required this.api});

  @override
  EventsListPageState createState() => EventsListPageState();
}


class EventsListPageState extends State<EventsListPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      EventsListContent(api: widget.api),
      EventsMapPage(),
      SearchEventsPage(),
      ProfilePage(),
    ];
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Events Demo"),
        actions: [
        IconButton(
          icon: Icon(Icons.login),
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
        ),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
        ],
      ),
      body: IndexedStack(   // 用 IndexedStack 保持页面状态
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}


class EventsListContent extends StatelessWidget {
  final ApiService api;
  const EventsListContent({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return FutureBuilder<List<Event>>(
      future: api.getEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        final events = snapshot.data ?? [];
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final ev = events[index];
            return ListTile(
              title: Text(ev.title),
              subtitle: Text(ev.location),
              onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailPage(event: ev), // 这里跳转到详情页
        ),
      );
    },
            );
          },
        );
      },
    );
  }
}