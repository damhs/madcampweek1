import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'search_tab.dart';
import 'gallery_tab.dart';
import 'review_tab.dart';
import 'profile_tab.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        final appState = AppState();

        // 테스트 데이터 추가

        return appState;
      },
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1.0),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal, width: 2.0),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        colorScheme:
            ColorScheme.fromSwatch(primarySwatch: Colors.teal).copyWith(
          secondary: Colors.deepPurple, // Secondary 색상 정의
          onSurface: Colors.black,
        ),
        appBarTheme: AppBarTheme(backgroundColor: Colors.white),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'MoneyGraphy',
        textTheme: const TextTheme(
          bodyLarge:
              TextStyle(fontSize: 16.0, color: Color.fromARGB(255, 0, 0, 0)),
          bodyMedium:
              TextStyle(fontSize: 14.0, color: Color.fromARGB(255, 0, 0, 0)),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // 기본으로 두 번째 탭 선택

  late final List<Widget> _tabContents;

  @override
  void initState() {
    super.initState();
    _tabContents = [
      const SearchTab(),
      const GalleryTab(),
      const ReviewTab(),
      const ProfileTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabContents[_currentIndex],
      bottomNavigationBar: SizedBox(
        height: 100,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: const Color(0xFF33CCCC),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '검색',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library),
              label: '갤러리',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: '리뷰',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '프로필',
            ),
          ],
        ),
      ),
    );
  }
}
