import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchTab extends StatefulWidget {
  const SearchTab({Key? key}) : super(key: key);

  @override
  State<SearchTab> createState() => _SearchTabState();
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
              'img/dokki_logo.png',
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
                    final book = _books[index]['volumeInfo'];
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
                      onTap: () {
                        // 도서 상세 정보 페이지 이동 가능
                      },
                    );
                  },
                ),
    );
  }
}
