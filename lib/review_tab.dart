import 'package:flutter/material.dart';

class ReviewTab extends StatefulWidget {
  const ReviewTab({Key? key}) : super(key: key);

  @override
  State<ReviewTab> createState() => _ReviewTabState();
}

class _ReviewTabState extends State<ReviewTab> {
  // 로컬 리뷰 데이터
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

  // 리뷰 추가 함수
  void _addReview(Map<String, String> newReview) {
    setState(() {
      reviews.add(newReview);
    });
  }

  // 다이얼로그 띄우기
  void _showAddReviewDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController authorController = TextEditingController();
    final TextEditingController genreController = TextEditingController();
    final TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('리뷰 추가'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: '책 제목'),
                ),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: '작가'),
                ),
                TextField(
                  controller: genreController,
                  decoration: const InputDecoration(labelText: '장르'),
                ),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: '리뷰 내용'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    authorController.text.isNotEmpty &&
                    genreController.text.isNotEmpty &&
                    contentController.text.isNotEmpty) {
                  _addReview({
                    'title': titleController.text,
                    'author': authorController.text,
                    'genre': genreController.text,
                    'date': DateTime.now().toString().split(' ')[0],
                    'content': contentController.text,
                  });
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                }
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('제목: ${review['title'] ?? 'No Title'}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('작가: ${review['author'] ?? 'No Author'}'),
                Text('장르: ${review['genre'] ?? 'No Genre'}'),
                Text('리뷰 날짜: ${review['date'] ?? 'No Date'}'),
                Text('리뷰 내용: ${review['content'] ?? 'No Content'}'),
                const Divider(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReviewDialog,
        child: const Icon(Icons.add),
        tooltip: '리뷰 쓰기',
      ),
    );
  }
}
