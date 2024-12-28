import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

late SharedPreferences prefs;

class GalleryTab extends StatefulWidget {
  const GalleryTab({Key? key}) : super(key: key);

  @override
  _GalleryTabState createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool isEditing = false;
  TextEditingController _descriptionController = TextEditingController();

  List<Map<String, String>> items = [];

  void initState() {
    super.initState();
    _loadImages();
    isEditing = false;
    _descriptionController = TextEditingController(text: '');
  }

  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadImages() async {
    prefs = await SharedPreferences.getInstance();
    final List<String>? images = prefs.getStringList('images');
    if (images != null) {
      setState(() {
        items = images.map((image) {
          final List<String> parts = image.split(',');
          return {
            'image': parts[0],
            'description': parts[1],
            'timestamp': parts[2],
          };
        }).toList();
      });
    }
  }

  Future<void> _saveImages() async {
    await prefs.setStringList(
      'images',
      items.map((item) {
        return '${item['image']},${item['description']},${item['timestamp']}';
      }).toList(),
    );
  }

  void _addImage(String image, String description, String timestamp) {
    setState(() {
      items.add({
        'image': image,
        'description': description,
        'timestamp': timestamp,
      });
    });
    _saveImages();
  }

  void _editImage(int index, String description) {
    setState(() {
      items[index]['description'] = description;
    });
    _saveImages();
  }

  void _deleteImage(int index) {
    setState(() {
      items.removeAt(index);
    });
    _saveImages();
  }

  final ImagePicker _picker = ImagePicker();

  // 갤러리에서 이미지를 선택
  Future<void> _pickImage() async {
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
        isEditing = true;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryDetailPage(
              index: items.length,
              image: pickedFile.path,
              description: '',
              timestamp:
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
            ),
          ),
        );
        _addImage(pickedFile.path, _descriptionController.text,
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('갤러리 접근 권한이 필요합니다.')),
      );
    }
  }

  Widget _buildImage(
      {required List<Map<String, String>> items, required int index}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryDetailPage(
              index: index,
              image: items[index]['image']!,
              description: items[index]['description']!,
              timestamp: items[index]['timestamp']!,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(items[index]['image']!)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
            ),
            margin: const EdgeInsets.all(5.0),
          ),
          Positioned(
            bottom: 5,
            left: 5,
            child: Container(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                items[index]['timestamp']!,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget GalleryDetailPage({
    required int index,
    required String image,
    required String description,
    required String timestamp,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('독서 정보'),
                Text(
                  timestamp,
                  style: const TextStyle(fontSize: 12.0),
                ),
              ],
            ),
            Spacer(),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () {
                Navigator.pop(context);
                _deleteImage(index);
              },
            ),
            IconButton(
              icon: Icon(isEditing ? Icons.save : Icons.edit),
              color: isEditing ? Color(0xFF33CCCC) : Colors.purple,
              onPressed: () {
                if (isEditing) {
                  setState(() {
                    isEditing = false;
                  });
                  _editImage(index, _descriptionController.text);
                } else {
                  setState(() {
                    isEditing = true;
                    _descriptionController.text = description;
                  });
                }
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Image.file(File(image)),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: isEditing
                  ? TextField(
                      controller: _descriptionController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '설명을 입력하세요.',
                      ),
                    )
                  : Text(
                      _descriptionController.text,
                      style: const TextStyle(fontSize: 16.0),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 독서 모음'),
        backgroundColor: Colors.white,
      ),
      body: items.isEmpty
          ? const Center(child: Text('저장된 사진이 없습니다.'))
          : Container(
              width: sizeX,
              height: sizeY,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: items.length,
                padding: const EdgeInsets.all(5.0),
                itemBuilder: (context, index) {
                  return _buildImage(items: items, index: index);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        backgroundColor: Color(0xFF33CCCC),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
