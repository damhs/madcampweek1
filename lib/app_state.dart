// app_state.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'gallery_tab.dart'; // Add this line to import the GalleryDetailPage
import 'dart:io';

class AppState extends ChangeNotifier {
  List<Map<String, String>> _reviews = [];
  List<Map<String, String>> _images = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();

  // 데이터 가져오기 (Immutable)
  List<Map<String, String>> get reviews => List.unmodifiable(_reviews);
  List<Map<String, String>> get images => List.unmodifiable(_images);

  // 생성자: SharedPreferences에서 초기 데이터를 불러옴
  AppState() {
    _loadReviews();
    _loadImages();
    _loadProfile();
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

  Future<void> _loadImages() async {
    final prefs = await SharedPreferences.getInstance();
    final images = prefs.getStringList('images');
    if (images != null) {
      _images = images.map((image) {
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

  Future<void> _saveImages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'images',
      _images.map((image) {
        return '${image['image']},${image['description']},${image['timestamp']}';
      }).toList(),
    );
  }

  void addImage(String image, String description, String timestamp) {
    _images.add({
      'image': image,
      'description': description,
      'timestamp': timestamp,
    });
    _saveImages();
    notifyListeners();
  }

  void editImage(int index, String description) {
    _images[index]['description'] = description;
    _saveImages();
    notifyListeners();
  }

  void deleteImage(int index) {
    _images.removeAt(index);
    _saveImages();
    notifyListeners();
  }

  Future<void> pickImageFromCamera(BuildContext context) async {
    bool havePermission = false;
    final request = await Permission.camera.request();
    havePermission = request.isGranted;
    print("권한 요청");
    if (havePermission) {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        _descriptionController.text = '';
        addImage(pickedFile.path, _descriptionController.text,
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryDetailPage(
              index: images.length,
              image: pickedFile.path,
              description: '',
              timestamp:
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
              onDelete: deleteImage,
              onSave: editImage,
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

  Future<void> pickImageFromGallery(BuildContext context) async {
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
        addImage(pickedFile.path, _descriptionController.text,
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryDetailPage(
              index: images.length,
              image: pickedFile.path,
              description: '',
              timestamp:
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
              onDelete: deleteImage,
              onSave: editImage,
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
    _nickname = prefs.getString('nickname')??'사용자';
    final profileImagePath = prefs.getString('profileImagePath');
    if(profileImagePath != null){
      _profileImage = File(profileImagePath);
    }
    _statusMessage = prefs.getString('statusMessage')??'상태 메시지를 설정하세요.';
    notifyListeners();
  }

  Future<void> saveProfile({File? image}) async {
    final prefs = await SharedPreferences.getInstance();
    if(image!=null) {
      await prefs.setString('profileImagePath', image.path);
      _profileImage = image;
    }
    await prefs.setString('nickname',_nickname);
    await prefs.setString('statusMessage',_statusMessage);
    notifyListeners();
  }

  void updateProfileImage(File image) async{
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
}
