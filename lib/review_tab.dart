import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

class ReviewTab extends StatefulWidget {
  const ReviewTab({Key? key}) : super(key: key);

  @override
  State<ReviewTab> createState() => _ReviewTabState();
}

String _sortCriteria = 'date';
bool _isAscending = true;

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
  void _sortReviews(String criteria) {
    setState(() {
      if (_sortCriteria == criteria) {
        _isAscending = !_isAscending;
      } else {
        _sortCriteria = criteria;
        _isAscending = true;
      }
      _reviews.sort((a, b) {
        int comparison;
        switch (_sortCriteria) {
          case 'title':
            comparison = a['title']!.compareTo(b['title']!);
            break;
          case 'author':
            comparison = a['author']!.compareTo(b['author']!);
            break;
          case 'genre':
            comparison = a['genre']!.compareTo(b['genre']!);
            break;
          case 'date':         
          default:
            comparison = a['date']!.compareTo(b['date']!);
            break;
        }
        return _isAscending ? comparison : -comparison;
      });
    });
  }
  // 공통 텍스트 필드 생성

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
                onSubmit: (updatedReview) => _editReview(index, updatedReview),
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
                            const TextStyle(fontSize: 12, color: Colors.grey),
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
                child: const Text('취소', style: TextStyle(color: Colors.black)),
              ),
              TextButton(
                onPressed: _deleteSelectedReviews,
                child: const Text('삭제', style: TextStyle(color: Colors.black)),
              ),
            ]
          : [
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  //side: const BorderSide(width: 1, color: Color(0xFF33CCCC)),
                ),
                color: Colors.white,
                icon: const Icon(Icons.sort, color: Colors.purple),
                onSelected: _sortReviews,
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'title',
                    child: Text(
                      '제목 ${_sortCriteria == 'title' ? (_isAscending ? '▾' : '▴') : ''}', 
                    ),
                  ),
                  PopupMenuItem(
                    value: 'author',
                    child: Text(
                      '작가 ${_sortCriteria == 'author' ? (_isAscending ? '▾' : '▴') : ''}', 
                    ),
                  ),
                  PopupMenuItem(
                    value: 'genre',
                    child: Text(
                      '장르 ${_sortCriteria == 'genre' ? (_isAscending ? '▾' : '▴') : ''}',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'date',
                    child: Text(
                      '날짜 ${_sortCriteria == 'date' ? (_isAscending ? '▾' : '▴') : ''}',
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_outline, color: Colors.purple),
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewDetailPage(
              review: null,
              onSubmit: _addReview,
          ),
        ),
        );
      },
      backgroundColor: const Color(0xFF33CCCC),
      child: const Icon(Icons.add, color: Colors.white),
    ),
  );
}
  @override
  bool get wantKeepAlive => true;
}

class ReviewDetailPage extends StatelessWidget {
  final Map<String, String>? review;
  final void Function(Map<String, String>) onSubmit;
  final VoidCallback? onDelete;

  const ReviewDetailPage({
    Key? key,
    this.review,
    required this.onSubmit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(text: review?['title']);
    final authorController = TextEditingController(text: review?['author']);
    final genreController = TextEditingController(text: review?['genre']);
    final contentController = TextEditingController(text: review?['content']);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        //title: const Text('리뷰 상세'),
        actions: review != null && onDelete != null
        ? [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ] : null,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      onSubmit({
                        'title': titleController.text,
                        'author': authorController.text,
                        'genre': genreController.text,
                        'date': review?['date'] ?? DateTime.now().toString().split(' ')[0],
                        'content': contentController.text,
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('저장'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    )
                  ),
                ],
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
