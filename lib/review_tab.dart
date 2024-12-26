import 'package:flutter/material.dart';

class ReviewTab extends StatelessWidget {
  const ReviewTab({Key? key}) : super(key: key);
  final List<Map<String, String>> reviews = const[
    {
      'title': '1984',
      'author': 'George Orwell',
      'genre': 'Dystopian',
      'date': '2024-11-27',
      'content': '정말 재미있어요!',
    },
    {
      'title': '채식주의자',
      'author': '한 강',
      'genre': '장편소설',
      'date': '2024-12-24',
      'content': '흥미로운 내용이에요!',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Padding(padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('제목: ${review['title'] ?? 'No Title'}'),
            Text('작가: ${review['author'] ?? 'No Author'}'),
            Text('장르: ${review['genre'] ?? 'No Genre'}'),
            Text('리뷰 날짜: ${review['date'] ?? 'No Date'}'),
            Text('리뷰 내용: ${review['content'] ?? 'No Content'}'),
            const Divider(),
            ],
          ),
        );
      },
    );
  }
}