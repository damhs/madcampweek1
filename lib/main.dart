import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('독서 리뷰 앱'),
        ),
        body: Center(
          child: Text('Hello World'),
        ),
        
         bottomNavigationBar: BottomNavigationBar(
          /*currentIndex: _currentIndex,
          onTab:(int index){
            setState(()=>_currentIndex = index);
          },*/
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
      ),
    );
  }
}
