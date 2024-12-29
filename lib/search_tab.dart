import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'review_tab.dart';
import 'gallery_tab.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({Key? key}) : super(key: key);

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  bool _showRecentSearches = false;
  List<dynamic> _books = [];
  bool _isLoading = false;
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    context.read<AppState>().loadRecentSearches();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showRecentSearches = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _showRecentSearches = false;
      });
      _searchBooks(query);
      context.read<AppState>().addRecentSearch(query);
    }
  }

  // Google Books API 호출
  Future<void> _searchBooks(String query) async {
    setState(() {
      _isLoading = true;
      _books = [];
    });

    const apiKey =
        'AIzaSyDNWjiG_ysdjVdSvDRZpn2farxHYIqPkuk'; // Google Books API 키
    final url = Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=40&key=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _books = data['items'] ?? [];
        });
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      setState(() {
        _books = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('검색 실패: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 책 선택 옵션
  void _showBookOptions(BuildContext context, Map<String, dynamic> book) {
    final Map<String, String> stringBook = {
      'title': book['title'] ?? '제목 없음',
      'author': (book['authors'] as List<dynamic>?)?.join(', ') ?? '작가 정보 없음',
      'genre': (book['categories'] as List<dynamic>?)?.join(', ') ?? '장르 정보 없음',
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
          title: Row(children: <Widget>[
            Image.asset(
              'assets/img/dokki_logo.png',
              width: 30,
              height: 30,
            ),
            SizedBox(width: 10),
            Text('기록하기'),
          ]),
          content: const Text('이 도서를 어떻게 기록하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GalleryDetailPage(
                      index: context.read<AppState>().images.length,
                      image: book['imageLinks']['thumbnail'],
                      description: '',
                      timestamp: DateTime.now().toString(),
                      onDelete: (index) =>
                          context.read<AppState>().deleteImage(index),
                      onSave: (index, newDescription) => context
                          .read<AppState>()
                          .editImage(index, newDescription),
                    ),
                  ),
                );
              },
              child: const Text('사진'),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewDetailPage(
                      review: {
                        'title': stringBook['title']!,
                        'author': stringBook['author']!,
                        'genre': stringBook['genre']!,
                        'content': '',
                      },
                      onSubmit: (newReview) =>
                          context.read<AppState>().addReview(newReview),
                    ),
                  ),
                );
              },
              child: const Text('텍스트'),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentSearches = context.watch<AppState>().recentSearches;
    final isSearchHistoryEnabled = context.watch<AppState>().isSearchHistoryEnabled;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 80,
        title: Row(
          children: [
            Image.asset(
              'assets/img/dokki_logo.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                controller: _searchController,
                onSubmitted: _onSearchSubmitted,
                cursorColor: Colors.grey,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  hintText: "도서를 검색하세요.",
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: _showRecentSearches
    ? context.watch<AppState>().isSearchHistoryEnabled
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 상단 버튼 영역: "검색어 저장 끄기"와 "전체 삭제"를 나란히 배치
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 검색어 저장 끄기 버튼
                    TextButton(
                      onPressed: () {
                        context.read<AppState>().toggleSearchHistory();
                      },
                      child: const Text("검색어 저장 끄기"),
                    ),
                    // 전체 삭제 버튼
                    TextButton(
                      onPressed: () {
                        context.read<AppState>().clearRecentSearches();
                      },
                      child: const Text("전체 삭제"),
                    ),
                  ],
                ),
              ),
              // 최근 검색어 리스트
              Expanded(
                child: ListView(
                  children: context.watch<AppState>().recentSearches.map(
                    (query) {
                      return ListTile(
                        title: Text(query),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            context.read<AppState>().removeRecentSearch(query);
                          },
                        ),
                        onTap: () {
                          _searchController.text = query;
                          _onSearchSubmitted(query);
                        },
                      );
                    },
                  ).toList(),
                ),
              ),
            ],
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("최근 검색어 기능이 꺼져 있습니다."),
                TextButton(
                  onPressed: () {
                    context.read<AppState>().toggleSearchHistory();
                  },
                  child: const Text("검색어 저장 켜기"),
                ),
              ],
            ),
          )
    : _isLoading
        ? const Center(child: CircularProgressIndicator()) // 로딩 중 표시
        : _books.isEmpty
            ? const Center(child: Text("검색 결과가 없습니다."))
            : ListView.builder(
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  final Map<String, dynamic> book =
                      _books[index]['volumeInfo'] ?? {};
                  return ListTile(
                    leading: book['imageLinks'] != null
                        ? Image.network(
                            book['imageLinks']['thumbnail'],
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          )
                        : const Icon(Icons.book, size: 50),
                    title: Text(book['title'] ?? '제목 없음'),
                    subtitle: Text(
                      (book['authors'] as List<dynamic>?)?.join(', ') ??
                          '작가 정보 없음',
                    ),
                    onTap: () => _showBookOptions(context, book),
                  );
                },
              ),
    );
  }
}
