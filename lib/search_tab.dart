import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:madcampweek1/gallery_tab.dart';
import 'package:madcampweek1/review_tab.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({Key? key}) : super(key: key);

  @override
  State<SearchTab> createState() => _SearchTabState();
}
void _showBookOptions(BuildContext context, Map<String, dynamic> book){
  final Map<String, String> stringBook = {
    'title': book['title'] ?? '제목 없음',
    'authors': book['authors']?.join(', ') ?? '작가 정보 없음',
    'genre': book['categories']?.join(', ') ?? '장르 정보 없음',
  };
  showDialog(
    context: context,
    builder: (BuildContext context){
      return AlertDialog(
        title: Text('기록하기'),
        content: const Text('이 도서를 어떻게 기록하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GalleryTab(),
                ),
              );
            },
            child: const Text('사진으로 기록'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewDetailPage(
                    review: {
                      'title': stringBook['title'] ?? '제목 없음',
                      'author': stringBook['authors'] ?? '작가 정보 없음',
                      'genre': stringBook['genre'] ?? '장르 정보 없음',
                      'content': '',
                    },
                    onSubmit: (newReview) {
                      //Navigator.pop(context, newReview);
                    },
                  ),
                ),
              );
            },
            child: const Text('텍스트로 기록'),
          ),
        ],
      );
    },
  );
}
class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _books = [];
  bool _isLoading = false;

  // Google Books API 호출
  Future<void> _searchBooks(String query) async {
    setState(() {
      _isLoading = true;
    });

    const apiKey =
        'AIzaSyDNWjiG_ysdjVdSvDRZpn2farxHYIqPkuk'; // Google Books API 키 입력
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

  @override
  Widget build(BuildContext context) {
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
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                onSubmitted: _searchBooks,
                cursorColor: Colors.grey,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: "도서를 검색하세요.",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중 표시
          : _books.isEmpty
              ? Center(child: Text("검색 결과가 없습니다."))
              : ListView.builder(
                  itemCount: _books.length,
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> book = _books[index]['volumeInfo'] ?? {};
                    return ListTile(
                      leading: book['imageLinks'] != null
                          ? Image.network(
                              book['imageLinks']['thumbnail'],
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            )
                          : Icon(Icons.book, size: 50),
                      title: Text(book['title'] ?? '제목 없음'),
                      subtitle: Text(book['authors']?.join(', ') ?? '작가 정보 없음'),
                      onTap: () => _showBookOptions(context, book),
                    );
                  },
                ),
    );
  }
}
