import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  List<Map<String, String>> _reviews = [];

  // 리뷰 데이터 가져오기 (Immutable)
  List<Map<String, String>> get reviews => List.unmodifiable(_reviews);

  List<Map<String, String>> _items = [];

  List<Map<String, String>> get items => List.unmodifiable(_items);

  // 생성자: SharedPreferences에서 초기 데이터를 불러옴
  AppState() {
    _loadReviews();
    _loadGalleryItems();
  }

  // SharedPreferences에서 데이터 로드
  Future<void> _loadReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final reviewsString = prefs.getString('reviews');
    if (reviewsString != null) {
      _reviews = (jsonDecode(reviewsString) as List)
          .map((review) => Map<String, String>.from(review))
          .toList();
      notifyListeners(); // 상태 변경 알림
    }
  }

  // SharedPreferences에 데이터 저장
  Future<void> _saveReviews() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reviews', jsonEncode(_reviews));
  }

  // 새로운 리뷰 추가
  void addReview(Map<String, String> newReview) {
    _reviews.add(newReview);
    print('Added Review: $_reviews');
    _saveReviews();
    notifyListeners();
  }

  // 기존 리뷰 수정
  void editReview(int index, Map<String, String> updatedReview) {
    _reviews[index] = updatedReview;
    _saveReviews();
    notifyListeners();
  }

  // 리뷰 삭제
  void deleteReview(int index) {
    _reviews.removeAt(index);
    _saveReviews();
    notifyListeners();
  }

  // 선택된 리뷰 삭제
  void deleteSelectedReviews(Set<int> selectedIndexes) {
    _reviews = _reviews
        .asMap()
        .entries
        .where((entry) => !selectedIndexes.contains(entry.key))
        .map((entry) => entry.value)
        .toList();
    _saveReviews();
    notifyListeners();
  }

  // 리뷰 정렬
  void sortReviews(String criteria, bool isAscending) {
    _reviews.sort((a, b) {
      int comparison;
      switch (criteria) {
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
      return isAscending ? comparison : -comparison;
    });
    notifyListeners();
  }

  Future<void> _loadGalleryItems() async {
    final prefs = await SharedPreferences.getInstance();
    final images = prefs.getStringList('images');
    if (images != null) {
      _items = images.map((image) {
        final List<String> parts = image.split(',');
        return {
          'image': parts[0],
          'description': parts[1],
          'timestamp': parts[2],
        };
      }).toList();
      notifyListeners();
    }
  }

  Future<void> _saveGalleryItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'images',
      _items.map((item) {
        return '${item['image']},${item['description']},${item['timestamp']}';
      }).toList(),
    );
  }

  void addGalleryItem(Map<String, String> newItem) {
    _items.add(newItem);
    _saveGalleryItems();
    notifyListeners();
  }

  void editGalleryItem(int index, Map<String, String> updatedItem) {
    _items[index] = updatedItem;
    _saveGalleryItems();
    notifyListeners();
  }

  void deleteGalleryItem(int index) {
    _items.removeAt(index);
    _saveGalleryItems();
    notifyListeners();
  }
}
