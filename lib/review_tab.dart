import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'package:intl/intl.dart';

class ReviewTab extends StatefulWidget {
  const ReviewTab({super.key});

  @override
  State<ReviewTab> createState() => _ReviewTabState();
}

String _sortCriteria = 'date';
bool _isAscending = true;

class _ReviewTabState extends State<ReviewTab>
    with AutomaticKeepAliveClientMixin {
  bool isSelectionMode = false;
  final Set<int> selectedIndexes = {};

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final reviews = context.watch<AppState>().reviews;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset(
              'assets/img/dokki_logo.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 10),
            Text(
              isSelectionMode ? '리뷰 선택' : '나의 리뷰',
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
        actions: isSelectionMode
            ? [
                TextButton(
                  onPressed: _toggleSelectionMode,
                  child:
                      const Text('취소', style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    context
                        .read<AppState>()
                        .deleteSelectedReviews(selectedIndexes);
                    _toggleSelectionMode();
                  },
                  child:
                      const Text('삭제', style: TextStyle(color: Colors.black)),
                ),
              ]
            : [
                PopupMenuButton<String>(
                  color: Colors.white,
                  icon: const Icon(Icons.sort, color: Colors.purple),
                  onSelected: (criteria) {
                    setState(() {
                      if (_sortCriteria == criteria) {
                        _isAscending = !_isAscending;
                      } else {
                        _sortCriteria = criteria;
                        _isAscending = true;
                      }
                      context
                          .read<AppState>()
                          .sortReviews(_sortCriteria, _isAscending);
                    });
                  },
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
                  icon: const Icon(Icons.check_circle_outline,
                      color: Colors.purple),
                  onPressed: _toggleSelectionMode,
                ),
              ],
      ),
      backgroundColor: Colors.teal[50],
      body: reviews.isEmpty
          ? const Center(child: Text('저장된 리뷰가 없습니다.'))
          : ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) =>
                  _buildReviewCard(reviews[index], index),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewDetailPage(
                review: null,
                onSubmit: (newReview) {
                  context.read<AppState>().addReview(newReview);
                },
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF33CCCC),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

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
                onSubmit: (updatedReview) =>
                    context.read<AppState>().editReview(index, updatedReview),
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
                  activeColor: const Color(0xFF33CCCC),
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

  void _toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      selectedIndexes.clear();
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class ReviewDetailPage extends StatelessWidget {
  final Map<String, String>? review;
  final void Function(Map<String, String>) onSubmit;

  const ReviewDetailPage({
    super.key,
    this.review,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(text: review?['title'] ?? '');
    final authorController =
        TextEditingController(text: review?['author'] ?? '');
    final genreController = TextEditingController(text: review?['genre'] ?? '');
    final contentController =
        TextEditingController(text: review?['content'] ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(review == null ? '리뷰 추가' : '리뷰 수정',
            style: TextStyle(fontFamily: "Pretendard")),
        backgroundColor: Colors.teal[50],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLinedTextField(controller: titleController, label: '제목'),
            _buildLinedTextField(controller: authorController, label: '작가'),
            _buildLinedTextField(controller: genreController, label: '장르'),
            _buildLinedTextField(
              controller: contentController,
              label: '리뷰 내용',
              maxLines: 10,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final now = DateTime.now();
                    final formattedDate =
                        DateFormat('yyyy-MM-dd HH:mm').format(now);

                    final newReview = {
                      'title': titleController.text,
                      'author': authorController.text,
                      'genre': genreController.text,
                      'content': contentController.text,
                      'date': formattedDate,
                    };
                    onSubmit(newReview);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[300],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                  ),
                  child: const Text('저장'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinedTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: null, // InputDecoration 제거
          style: const TextStyle(fontSize: 16),
          cursorColor: Colors.black, // 커서 색상
        ),
        const Divider(
          color: Colors.black, // 가로선 색상
          thickness: 1, // 가로선 두께
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
