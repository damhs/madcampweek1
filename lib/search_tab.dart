import 'package:flutter/material.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      // 실제 검색 UI를 만들기 전, 간단한 텍스트 표시
      child: Text(
        '도서 검색 탭',
        style: TextStyle(fontSize: 22),
      ),
    );
  }
}
