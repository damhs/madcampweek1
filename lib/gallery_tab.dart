// gallery_tab.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_state.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

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

  Widget _buildImage(
      {required List<Map<String, String>> images, required int index}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryDetailPage(
              index: index,
              image: images[index]['image']!,
              description: images[index]['description']!,
              timestamp: images[index]['timestamp']!,
              onDelete:
                  Provider.of<AppState>(context, listen: false).deleteImage,
              onSave: Provider.of<AppState>(context, listen: false).editImage,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(images[index]['image']!)),
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
                images[index]['timestamp']!,
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;
    final images = Provider.of<AppState>(context).images;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/img/dokki_logo.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 10),
            Text(
              '나의 독서 앨범',
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: images.isEmpty
          ? const Center(child: Text('저장된 사진이 없습니다.'))
          : Row(
              children: [
                Expanded(
                  flex: 3, // 30% 영역
                  child: Container(
                    color: Colors.teal[100],
                    child: ListView(
                      children: [
                        ListTile(
                          leading: Icon(Icons.folder, color: Colors.teal),
                          title: Text('폴더 1'),
                          onTap: () {
                            // 폴더 선택 로직
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.folder, color: Colors.teal),
                          title: Text('폴더 2'),
                          onTap: () {
                            // 폴더 선택 로직
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.folder, color: Colors.teal),
                          title: Text('폴더 3'),
                          onTap: () {
                            // 폴더 선택 로직
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Container(
                    width: sizeX,
                    height: sizeY,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 5.0,
                        mainAxisSpacing: 5.0,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: images.length,
                      padding: const EdgeInsets.all(5.0),
                      itemBuilder: (context, index) {
                        return _buildImage(images: images, index: index);
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          icon: Image.asset(
                            'assets/img/camera.png',
                            width: 50,
                            height: 50,
                          ),
                          iconSize: 50,
                          onPressed: () {
                            Provider.of<AppState>(context, listen: false)
                                .pickImageFromCamera(context);
                            Navigator.pop(context);
                          },
                        ),
                        const Text('카메라'),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Image.asset(
                            'assets/img/gallery.png',
                            width: 50,
                            height: 50,
                          ),
                          iconSize: 50,
                          onPressed: () {
                            Provider.of<AppState>(context, listen: false)
                                .pickImageFromGallery(context);
                            Navigator.pop(context);
                          },
                        ),
                        const Text('갤러리'),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        backgroundColor: Color(0xFF33CCCC),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class GalleryDetailPage extends StatefulWidget {
  final int index;
  final String image;
  final String description;
  final String timestamp;
  final Function(int index) onDelete;
  final Function(int index, String description) onSave;

  const GalleryDetailPage({
    Key? key,
    required this.index,
    required this.image,
    required this.description,
    required this.timestamp,
    required this.onDelete,
    required this.onSave,
  }) : super(key: key);

  @override
  _GalleryDetailPageState createState() => _GalleryDetailPageState();
}

class _GalleryDetailPageState extends State<GalleryDetailPage> {
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.description);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  widget.timestamp,
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
                widget.onDelete(widget.index);
              },
            ),
            IconButton(
              icon: Icon(Icons.save),
              color: Colors.purple,
              onPressed: () {
                Navigator.pop(context);
                widget.onSave(widget.index, _descriptionController.text);
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.file(File(widget.image)),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _descriptionController,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '설명을 입력하세요.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
