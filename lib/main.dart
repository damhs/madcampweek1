// main.dart
import 'package:flutter/material.dart';
import 'search_tab.dart';
import 'gallery_tab.dart';
import 'review_tab.dart';

void main() {
  runApp(const MyApp());
}

// 전체 앱 구성
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

// 실제 화면(탭 기능)을 담당하는 StatefulWidget
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 두 번째 탭(인덱스 1)을 기본 선택
  int _currentIndex = 1;

  late final List<Widget> _tabContents;

  @override
  void initState() {
    super.initState();
    _tabContents = [
      const SearchTab(),
      const GalleryTab(),
      const ReviewTab(),
    ];
  }
  /*
  // 탭마다 다른 텍스트를 보여줄 예시
  final List<Widget> _tabContents = [
    const Center(child: Text('도서 검색 탭', style: TextStyle(fontSize: 20))),
    const Center(child: Text('갤러리 탭', style: TextStyle(fontSize: 20))),
    const Center(child: Text('리뷰 작성 탭', style: TextStyle(fontSize: 20))),
  ];
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('독서 리뷰 앱'),
      ),
      // 현재 탭에 해당하는 위젯만 표시
      body: _tabContents[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        // 탭을 클릭하면 상태 변경
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // 선택/비선택 탭 색상 (테마 기본값 등 적용)
        selectedItemColor: Colors.blue,
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
        ],
      ),
    );
  }
}
