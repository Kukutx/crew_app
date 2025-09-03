import 'package:crew_app/playground/StaggeredGrid/pages/home_page.dart';
import 'package:crew_app/playground/StaggeredGrid/pages/mine_page.dart';
import 'package:flutter/material.dart';



class TestStaggeredGrid extends StatelessWidget {
  const TestStaggeredGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const IndexPage(),
    );
  }
}

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final List<Widget> tabPages = const [GridHomePage(), GridMinePage()];
  int currentIndex = 0;

  final List<BottomNavigationBarItem> bottomTabs = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: .5,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(bottomTabs[currentIndex].label ?? ''),
      ),
      body: IndexedStack(index: currentIndex, children: tabPages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        items: bottomTabs,
        onTap: (idx) => setState(() => currentIndex = idx),
      ),
    );
  }
}