import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

class ReviewTab extends StatefulWidget {
  const ReviewTab({Key? key}) : super(key: key);

  @override
  State<ReviewTab> createState() => _ReviewTabState();
}

class _ReviewTabState extends State<ReviewTab> with AutomaticKeepAliveClientMixin {
  List<Map<String, String>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews(); // 앱 실행 시 저장된 리뷰 로드
  }

  // 리뷰 데이터 로드
  Future<void> _loadReviews() async {
    prefs = await SharedPreferences.getInstance();
    final String? reviewsString = prefs.getString('reviews');
    if (reviewsString != null) {
      setState(() {
        _reviews = (jsonDecode(reviewsString) as List)
            .map((review) => Map<String, String>.from(review))
            .toList();
      });
    }
  }

  // 리뷰 데이터 저장
  Future<void> _saveReviews() async {
    await prefs.setString('reviews', jsonEncode(_reviews));
  }

  // 리뷰 삭제 함수
  void _deleteReview(int index) {
    setState(() {
      _reviews.removeAt(index);
    });
    _saveReviews();
  }

  // 리뷰 수정 함수
  void _editReview(int index, Map<String, String> updatedReview) {
    setState(() {
      _reviews[index] = updatedReview;
    });
    _saveReviews();
  }

  // 리뷰 추가 함수
  void _addReview(Map<String, String> newReview) {
    setState(() {
      _reviews.add(newReview);
    });
    _saveReviews();
  }

  // 리뷰 추가 다이얼로그 띄우기
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

  // 리뷰 수정 다이얼로그 띄우기
  void _showEditReviewDialog(int index) {
    final currentReview = _reviews[index];
    final TextEditingController titleController = TextEditingController(text: currentReview['title']);
    final TextEditingController authorController = TextEditingController(text: currentReview['author']);
    final TextEditingController genreController = TextEditingController(text: currentReview['genre']);
    final TextEditingController contentController = TextEditingController(text: currentReview['content']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('리뷰 수정'),
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
                  _editReview(index, {
                    'title': titleController.text,
                    'author': authorController.text,
                    'genre': genreController.text,
                    'date': currentReview['date']!,
                    'content': contentController.text,
                  });
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                }
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin을 위해 호출
    return Scaffold(
      body: ListView.builder(
        itemCount: _reviews.length,
        itemBuilder: (context, index) {
          final review = _reviews[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '제목: ${review['title'] ?? 'No Title'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditReviewDialog(index);
                        } else if (value == 'delete') {
                          _deleteReview(index);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('수정'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('삭제'),
                        ),
                      ],
                    ),
                  ],
                ),
                Text('작가: ${review['author'] ?? 'No Author'}'),
                Text('장르: ${review['genre'] ?? 'No Genre'}'),
                Text('리뷰 날짜: ${review['date'] ?? 'No Date'}'),
                Text('리뷰 내용: ${review['content'] ?? 'No Content'}'),
                const Divider(), // 항목 간 구분선
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReviewDialog, // 리뷰 추가 다이얼로그 호출
        child: const Icon(Icons.add),
        tooltip: '리뷰 추가',
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // 상태 유지 활성화
}
