// app_state.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'gallery_tab.dart'; // Add this line to import the ImageItemDetailPage
import 'dart:io';

class AppState extends ChangeNotifier {
  List<Map<String, String>> _reviews = [];
  List<Map<String, String>> _imageItems = [];
  List<String> _folders = [];

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();

  // 데이터 가져오기 (Immutable)
  List<Map<String, String>> get reviews => List.unmodifiable(_reviews);
  List<Map<String, String>> get imageItems => List.unmodifiable(_imageItems);
  List<String> get folders => List.unmodifiable(_folders);

  // 생성자: SharedPreferences에서 초기 데이터를 불러옴
  AppState() {
    _loadReviews();
    _loadFolders();
    _loadImageItems();
    _loadProfile();
    _loadReviewDates();
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
    _totalTextReviews++;
    _saveReviews();
    _saveReviewCounts();
    final date = newReview['date']!.split(' ')[0];
    if (!_reviewDates.contains(date)) {
      _reviewDates.add(date);
      print("새로운 날짜 추가: $date");
      print("리뷰 날짜: $_reviewDates");
      _saveReviewDates();
    }
    notifyListeners();
    _checkBadgeUnlock();
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

  Future<void> _loadFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final foldersString = prefs.getString('folders');
    if (foldersString != null) {
      _folders = (jsonDecode(foldersString) as List).cast<String>();
      notifyListeners();
    }
  }

  Future<void> _saveFolders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('folders', jsonEncode(_folders));
  }

  void addFolder(String folderName) {
    _folders.add(folderName);
    _saveFolders();
    notifyListeners();
  }

  void editFolder(String folderName, String newFolderName) {
    final index = _folders.indexOf(folderName);
    _folders[index] = newFolderName;
    for (var imageItem in _imageItems) {
      if (imageItem['folderName'] == folderName) {
        imageItem['folderName'] = newFolderName;
      }
    }
    _saveFolders();
    _saveImageItems();
    notifyListeners();
  }

  void deleteFolder(String folderName) {
    final index = _folders.indexOf(folderName);
    _folders.removeAt(index);
    _imageItems
        .removeWhere((imageItem) => imageItem['folderName'] == folderName);
    _saveFolders();
    _saveImageItems();
    notifyListeners();
  }

  Future<void> _loadImageItems() async {
    final prefs = await SharedPreferences.getInstance();
    final imageItemsString = prefs.getString('imageItems');
    if (imageItemsString != null) {
      _imageItems = (jsonDecode(imageItemsString) as List)
          .map((imageItem) => Map<String, String>.from(imageItem))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _saveImageItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('imageItems', jsonEncode(_imageItems));
  }

  void addImageItem(
      String folderName, String image, String description, String timestamp) {
    _imageItems.add({
      'folderName': folderName,
      'image': image,
      'description': description,
      'timestamp': timestamp,
      'isSelected': 'false',
    });
    _totalImageReviews++;
    _saveImageItems();
    _saveReviewCounts();
    notifyListeners();
    _checkBadgeUnlock();
  }

  void editImageItem(int index, String description) {
    _imageItems[index]['description'] = description;
    _saveImageItems();
    notifyListeners();
  }

  void deleteImageItem(int index) {
    _imageItems.removeAt(index);
    _saveImageItems();
    notifyListeners();
  }

  Future<void> pickImageFromCamera(
      BuildContext context, String folderName) async {
    bool havePermission = false;
    final request = await Permission.camera.request();
    havePermission = request.isGranted;
    print("권한 요청");
    if (havePermission) {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        _descriptionController.text = '';
        addImageItem(folderName, pickedFile.path, _descriptionController.text,
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageItemDetailPage(
              imageItemIndex: _imageItems.length,
              image: pickedFile.path,
              description: '',
              timestamp:
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
              folderName: folderName,
              onDelete: (int imageItemIndex) => deleteImageItem(imageItemIndex),
              onSave: (int imageItemIndex, String description) =>
                  editImageItem(imageItemIndex, description),
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카메라 접근 권한이 필요합니다.')),
      );
    }
  }

  Future<void> pickImageFromGallery(
      BuildContext context, String folderName) async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print(androidInfo);
    print(androidInfo.version.release);
    final int androidVersion =
        int.parse(androidInfo.version.release.split('.')[0]);
    bool havePermission = false;

    if (androidVersion >= 13) {
      final request = await Permission.photos.request();
      havePermission = request.isGranted;
    } else {
      final status = await Permission.storage.request();
      havePermission = status.isGranted;
    }
    print("권한 요청");
    if (havePermission) {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _descriptionController.text = '';
        addImageItem(folderName, pickedFile.path, _descriptionController.text,
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageItemDetailPage(
              imageItemIndex: _imageItems.length,
              image: pickedFile.path,
              description: '',
              timestamp:
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
              folderName: folderName,
              onDelete: (int imageItemIndex) => deleteImageItem(imageItemIndex),
              onSave: (int imageItemIndex, String description) {
                editImageItem(imageItemIndex, description);
              },
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('갤러리 접근 권한이 필요합니다.')),
      );
    }
  }

  //최근 검색어
  List<String> _recentSearches = [];
  bool _isSearchHistoryEnabled = true;
  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  bool get isSearchHistoryEnabled => _isSearchHistoryEnabled;

  Future<void> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = prefs.getStringList('recentSearches') ?? [];
    _isSearchHistoryEnabled = prefs.getBool('isSearchHistoryEnabled') ?? true;
    notifyListeners();
  }

  Future<void> saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentSearches', _recentSearches);
    await prefs.setBool('isSearchHistoryEnabled', _isSearchHistoryEnabled);
    notifyListeners();
  }

  void addRecentSearch(String query) {
    if (!_isSearchHistoryEnabled) return;
    if (_recentSearches.contains(query)) {
      _recentSearches.remove(query);
    }
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 10) {
      _recentSearches.removeRange(10, _recentSearches.length);
    }
    saveRecentSearches();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    saveRecentSearches();
  }

  void toggleSearchHistory() {
    _isSearchHistoryEnabled = !_isSearchHistoryEnabled;
    saveRecentSearches();
  }

  void removeRecentSearch(String query) {
    _recentSearches.remove(query);
    saveRecentSearches();
  }

  //프로필
  File? _profileImage;
  String _nickname = '사용자';

  File? get profileImage => _profileImage;
  String get nickname => _nickname;

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _nickname = prefs.getString('nickname') ?? '사용자';
    final profileImagePath = prefs.getString('profileImagePath');
    if (profileImagePath != null) {
      _profileImage = File(profileImagePath);
    }
    _statusMessage = prefs.getString('statusMessage') ?? '상태 메시지를 설정하세요.';
    _totalTextReviews = prefs.getInt('totalTextReviews') ?? 0;
    _totalImageReviews = prefs.getInt('totalImageReviews') ?? 0;
    _badges['text_review_5'] = prefs.getBool('text_review_5') ?? false;
    _badges['image_review_5'] = prefs.getBool('image_review_5') ?? false;
    _badges['text_review_10'] = prefs.getBool('text_review_10') ?? false;
    _badges['image_review_10'] = prefs.getBool('image_review_10') ?? false;
    _badges['text_review_50'] = prefs.getBool('text_review_50') ?? false;
    _badges['image_review_50'] = prefs.getBool('image_review_50') ?? false;
    notifyListeners();
  }

  Future<void> saveProfile({File? image}) async {
    final prefs = await SharedPreferences.getInstance();
    if (image != null) {
      await prefs.setString('profileImagePath', image.path);
      _profileImage = image;
    }
    await prefs.setString('nickname', _nickname);
    await prefs.setString('statusMessage', _statusMessage);
    notifyListeners();
  }

  void updateProfileImage(File image) async {
    await saveProfile(image: image);
  }

  void updateNickname(String nickname) async {
    _nickname = nickname;
    await saveProfile();
  }

  String _statusMessage = '상태 메시지를 설정하세요.';
  String get statusMessage => _statusMessage;

  void updateStatusMessage(String message) {
    _statusMessage = message;
    saveProfile();
  }

  int get reviewCount => _reviews.length;
  int get imageCount => _imageItems.length;
  int get uploadDayCount {
    final Set<String> uniqueDays = _reviews
        .map((review) => review['date']!.split(' ')[0]) // 리뷰 날짜 (yyyy-MM-dd)
        .toSet()
      ..addAll(
        _imageItems.map(
            (imageItem) => imageItem['timestamp']!.split(' ')[0]), // 이미지 업로드 날짜
      );
    return uniqueDays.length;
  }

  //뱃지
  int _totalTextReviews = 0;
  int _totalImageReviews = 0;
  int get totalTextReviews => _totalTextReviews;
  int get totalImageReviews => _totalImageReviews;

  Future<void> _saveReviewCounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalTextReviews', _totalTextReviews);
    await prefs.setInt('totalImageReviews', _totalImageReviews);
  }

  void _checkBadgeUnlock() {
    if (_totalTextReviews >= 5) {
      print("텍스트 리뷰 5개 달성!");
      _unlockBadge('text_review_5');
    }
    if (_totalTextReviews >= 10) {
      print("텍스트 리뷰 10개 달성!");
      _unlockBadge('text_review_10');
    }
    if (_totalTextReviews >= 50) {
      print("텍스트 리뷰 50개 달성!");
      _unlockBadge('text_review_50');
    }
    if (_totalImageReviews >= 5) {
      print("이미지 리뷰 5개 달성!");
      _unlockBadge('image_review_5');
    }
    if (_totalImageReviews >= 10) {
      print("이미지 리뷰 10개 달성!");
      _unlockBadge('image_review_10');
    }
    if (_totalImageReviews >= 50) {
      print("이미지 리뷰 50개 달성!");
      _unlockBadge('image_review_50');
    }
  }

  final Map<String, bool> _badges = {
    'text_review_5': false,
    'image_review_5': false,
    'text_review_10': false,
    'image_review_10': false,
    'text_review_50': false,
    'image_review_50': false,
  };

  Map<String, bool> get badges => Map.unmodifiable(_badges);

  void _unlockBadge(String badgeId) async {
    if (_badges[badgeId] == false) _badges[badgeId] = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(badgeId, true);
    print('뱃지 해금: $badgeId');
    notifyListeners();
  }

  //주간 캘린더
  List<String> getWeeklyReviewDates() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    print("현재 날짜: $now");
    print("이번 주 시작: $startOfWeek");
    print("이번 주 끝: $endOfWeek");

    final result = _reviewDates.where((date) {
      final reviewDate = DateTime.parse(date).toUtc(); // UTC로 변환
      final isInRange = reviewDate.isAtSameMomentAs(startOfWeek.toUtc()) ||
          reviewDate.isAtSameMomentAs(endOfWeek.toUtc()) ||
          (reviewDate.isAfter(startOfWeek.toUtc()) &&
              reviewDate.isBefore(endOfWeek.toUtc()));
      print("검사 중인 날짜: $reviewDate, 범위 내: $isInRange");
      return isInRange;
    }).toList();

    print("이번 주 리뷰 날짜: $result");
    return result;
  }

  List<String> _reviewDates = [];
  List<String> get reviewDates => List.unmodifiable(_reviewDates);
  Future<void> _saveReviewDates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('reviewDates', _reviewDates);
  }

  Future<void> _loadReviewDates() async {
    final prefs = await SharedPreferences.getInstance();
    _reviewDates = prefs.getStringList('reviewDates') ?? [];
    notifyListeners();
  }
}
