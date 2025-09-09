import 'package:crew_app/features/events/presentation/map/events_map_page.dart';
import 'package:flutter/material.dart';
import '../data/event.dart';
import '../../../core/network/api_service.dart';

class SearchEventsPage extends StatefulWidget {
  const SearchEventsPage({super.key});

  @override
  SearchEventsPageState createState() => SearchEventsPageState();
}

class SearchEventsPageState extends State<SearchEventsPage> {
  final ApiService api = ApiService();
  final TextEditingController _controller = TextEditingController();
  List<Event> results = [];
  bool isLoading = false;

  void _search() async {
    setState(() => isLoading = true);
    try {
      final data = await api.searchEvents(_controller.text);
      setState(() => results = data);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("搜索活动")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "输入活动标题...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _search,
                  child: Text("搜索"),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : results.isEmpty
                    ? Center(child: Text("没有找到活动"))
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final event = results[index];
                          return ListTile(
                            title: Text(event.title),
                            subtitle: Text(event.description),
                            trailing: Icon(Icons.location_on),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventsMapPage(
                                    selectedEvent: event, // 把选中的活动传过去
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
