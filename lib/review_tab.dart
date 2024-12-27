import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

class ReviewTab extends StatefulWidget {
  const ReviewTab({Key? key}) : super(key: key);

  @override
  State<ReviewTab> createState() => _ReviewTabState();
}

class _ReviewTabState extends State<ReviewTab>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, String>> _reviews = [];
  bool isSelectionMode = false;
  final Set<int> selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  // SharedPreferences에서 리뷰 데이터 로드
  Future<void> _loadReviews() async {
    prefs = await SharedPreferences.getInstance();
    final reviewsString = prefs.getString('reviews');
    if (reviewsString != null) {
      setState(() {
        _reviews = (jsonDecode(reviewsString) as List)
            .map((review) => Map<String, String>.from(review))
            .toList();
      });
    }
  }

  // SharedPreferences에 리뷰 데이터 저장
  Future<void> _saveReviews() async {
    await prefs.setString('reviews', jsonEncode(_reviews));
  }

  // 리뷰 추가
  void _addReview(Map<String, String> newReview) {
    setState(() => _reviews.add(newReview));
    _saveReviews();
  }

  // 리뷰 수정
  void _editReview(int index, Map<String, String> updatedReview) {
    setState(() => _reviews[index] = updatedReview);
    _saveReviews();
  }

  // 리뷰 삭제
  void _deleteReview(int index) {
    setState(() => _reviews.removeAt(index));
    _saveReviews();
  }

  // 선택된 리뷰 삭제
  void _deleteSelectedReviews() {
    setState(() {
      _reviews = _reviews
          .asMap()
          .entries
          .where((entry) => !selectedIndexes.contains(entry.key))
          .map((entry) => entry.value)
          .toList();
      selectedIndexes.clear();
      isSelectionMode = false;
    });
    _saveReviews();
  }

  // 선택 모드 토글
  void _toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      selectedIndexes.clear();
    });
  }

  // 리뷰 추가 및 수정 다이얼로그 표시
  void _showReviewDialog({
    required String title,
    Map<String, String>? currentReview,
    required void Function(Map<String, String>) onSubmit,
  }) {
    final titleController =
        TextEditingController(text: currentReview?['title']);
    final authorController =
        TextEditingController(text: currentReview?['author']);
    final genreController =
        TextEditingController(text: currentReview?['genre']);
    final contentController =
        TextEditingController(text: currentReview?['content']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(controller: titleController, label: '책 제목'),
                const SizedBox(height: 12),
                _buildTextField(controller: authorController, label: '작가'),
                const SizedBox(height: 12),
                _buildTextField(controller: genreController, label: '장르'),
                const SizedBox(height: 12),
                _buildTextField(
                    controller: contentController, label: '리뷰 내용', maxLines: 5),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    authorController.text.isNotEmpty &&
                    genreController.text.isNotEmpty &&
                    contentController.text.isNotEmpty) {
                  onSubmit({
                    'title': titleController.text,
                    'author': authorController.text,
                    'genre': genreController.text,
                    'date': currentReview?['date'] ??
                        DateTime.now().toString().split(' ')[0],
                    'content': contentController.text,
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  // 공통 텍스트 필드 생성
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  // 리뷰 카드 생성
  Widget _buildReviewCard(Map<String, String> review, int index) {
    return GestureDetector(
      onTap: () {
        if (isSelectionMode) {
          setState(() {
            selectedIndexes.contains(index)
                ? selectedIndexes.remove(index)
                : selectedIndexes.add(index);
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewDetailPage(
                review: review,
                onUpdate: (updatedReview) => _editReview(index, updatedReview),
                onDelete: () {
                  _deleteReview(index);
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
        }
      },
      child: Card(
        color: selectedIndexes.contains(index) ? Colors.blue[50] : Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (isSelectionMode)
                Checkbox(
                  value: selectedIndexes.contains(index),
                  activeColor: Color(0xFF33CCCC),
                  checkColor: Colors.white,
                  onChanged: (value) {
                    setState(() {
                      value!
                          ? selectedIndexes.add(index)
                          : selectedIndexes.remove(index);
                    });
                  },
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['title'] ?? '제목 없음',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review['author'] ?? '작가 정보 없음',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                        Text(
                          review['genre'] ?? '장르 정보 없음',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        review['date'] ?? '날짜 정보 없음',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(isSelectionMode ? '리뷰 선택' : '나의 리뷰'),
        actions: isSelectionMode
            ? [
                TextButton(
                  onPressed: _toggleSelectionMode,
                  child:
                      const Text('취소', style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: _deleteSelectedReviews,
                  child:
                      const Text('삭제', style: TextStyle(color: Colors.black)),
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.checklist),
                  onPressed: _toggleSelectionMode,
                ),
              ],
      ),
      body: _reviews.isEmpty
          ? const Center(child: Text('저장된 리뷰가 없습니다.'))
          : ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) =>
                  _buildReviewCard(_reviews[index], index),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showReviewDialog(
            title: '리뷰 추가',
            onSubmit: _addReview,
          );
        },
        backgroundColor: Color(0xFF33CCCC),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ReviewDetailPage extends StatelessWidget {
  final Map<String, String> review;
  final void Function(Map<String, String>) onUpdate;
  final VoidCallback onDelete;

  const ReviewDetailPage({
    Key? key,
    required this.review,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(text: review['title']);
    final authorController = TextEditingController(text: review['author']);
    final genreController = TextEditingController(text: review['genre']);
    final contentController = TextEditingController(text: review['content']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('리뷰 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(controller: titleController, label: '책 제목'),
              const SizedBox(height: 12),
              _buildTextField(controller: authorController, label: '작가'),
              const SizedBox(height: 12),
              _buildTextField(controller: genreController, label: '장르'),
              const SizedBox(height: 12),
              _buildTextField(
                  controller: contentController, label: '리뷰 내용', maxLines: 5),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  onUpdate({
                    'title': titleController.text,
                    'author': authorController.text,
                    'genre': genreController.text,
                    'date': review['date']!,
                    'content': contentController.text,
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
