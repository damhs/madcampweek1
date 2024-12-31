// gallery_tab.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_state.dart';

late SharedPreferences prefs;

class GalleryTab extends StatefulWidget {
  final List<Map<String, String>> images;

  const GalleryTab({
    Key? key,
    required this.images,
  }) : super(key: key);

  @override
  _GalleryTabState createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab>
    with AutomaticKeepAliveClientMixin {
  int _currentFolderIndex = 0;

  @override
  bool get wantKeepAlive => true;

  Future<String?> _showCreateFolderDialog(BuildContext context) {
    TextEditingController folderNameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('새 폴더 만들기'),
          content: TextField(
            controller: folderNameController,
            decoration: InputDecoration(helperText: '새 폴더'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(folderNameController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFolder(
      {required List<Map<String, List<Map<String, String>>>> folders,
      required int folderIndex}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFolderIndex = folderIndex;
        });
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Column(
            children: [
              Icon(
                Icons.folder,
                size: 80,
                color: Color(0xFF33CCCC),
              ),
              Text(
                folders[folderIndex].keys.first,
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage(
      {required List<Map<String, List<Map<String, String>>>> folders,
      required int folderIndex,
      required int imageItemIndex}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageItemDetailPage(
              folderIndex: folderIndex,
              imageItemIndex: imageItemIndex,
              image: folders[folderIndex].values.first[imageItemIndex]
                  ['image']!,
              description: folders[folderIndex].values.first[imageItemIndex]
                  ['description']!,
              timestamp: folders[folderIndex].values.first[imageItemIndex]
                  ['timestamp']!,
              onDelete: (int folderIndex, int index) {
                context
                    .read<AppState>()
                    .deleteImageItemFromFolder(folderIndex, index);
              },
              onSave: (int folderIndex, int index, String description) {
                context
                    .read<AppState>()
                    .editImageItemInFolder(folderIndex, index, description);
              },
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(folders[folderIndex]
                    .values
                    .first[imageItemIndex]['image']!)),
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
                folders[folderIndex].values.first[imageItemIndex]['timestamp']!,
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
    final folders = Provider.of<AppState>(context).folders;
    final currentImages = _currentFolderIndex == 0
        ? folders[0].values.first
        : folders[_currentFolderIndex].values.first;
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: _currentFolderIndex == 0
            ? Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    color: Color(0xFF33CCCC),
                    icon: const Icon(
                      Icons.menu,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    tooltip:
                        MaterialLocalizations.of(context).openAppDrawerTooltip,
                  );
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(
                    () {
                      _currentFolderIndex = 0;
                    },
                  );
                },
              ),
        title: Row(
          children: [
            // IconButton(
            //   icon: Image.asset(
            //     'assets/img/dokki_logo.png',
            //     width: 30,
            //     height: 30,
            //   ),
            //   onPressed: () {
            //     setState(
            //       () {
            //         _currentFolderIndex = null;
            //       },
            //     );
            //   },
            // ),
            // const SizedBox(width: 10),
            Text(
              '나의 독서 앨범',
              style: const TextStyle(color: Colors.black),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.create_new_folder),
              color: Colors.purple,
              onPressed: () async {
                String? folderName = await _showCreateFolderDialog(context);
                if (folderName != null) {
                  Provider.of<AppState>(context, listen: false)
                      .addFolder(folderName);
                }
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      drawer: Drawer(
        width: sizeX * 0.4,
        shape: Border(
          right: BorderSide(color: Colors.teal, width: 0),
        ),
        backgroundColor: Colors.teal[50],
        child: ListView.builder(
          itemCount: folders.length,
          itemBuilder: (context, folderIndex) {
            return _buildFolder(folders: folders, folderIndex: folderIndex);
          },
        ),
      ),
      body: currentImages.isEmpty
          ? const Center(child: Text('이미지가 없습니다.'))
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
                itemCount: currentImages.length,
                padding: const EdgeInsets.all(5.0),
                itemBuilder: (context, index) {
                  return _buildImage(
                      folders: folders,
                      folderIndex: _currentFolderIndex,
                      imageItemIndex: index);
                },
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: Colors.white,
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        maximumSize: MaterialStateProperty.all(Size(100, 100)),
                      ),
                      onPressed: () {
                        Provider.of<AppState>(context, listen: false)
                            .pickImageFromCamera(context);
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/img/camera.png',
                            width: 50,
                            height: 50,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '카메라',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        maximumSize: MaterialStateProperty.all(Size(100, 100)),
                      ),
                      onPressed: () {
                        Provider.of<AppState>(context, listen: false)
                            .pickImageFromGallery(context);
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/img/gallery.png',
                            width: 50,
                            height: 50,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '갤러리',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
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

class ImageItemDetailPage extends StatefulWidget {
  final int folderIndex;
  final int imageItemIndex;
  final String image;
  final String description;
  final String timestamp;
  final Function(int folderIndex, int imageItemIndex) onDelete;
  final Function(int folderIndex, int imageItemIndex, String description)
      onSave;

  const ImageItemDetailPage({
    Key? key,
    required this.folderIndex,
    required this.imageItemIndex,
    required this.image,
    required this.description,
    required this.timestamp,
    required this.onDelete,
    required this.onSave,
  }) : super(key: key);

  @override
  _ImageItemDetailPageState createState() => _ImageItemDetailPageState();
}

class _ImageItemDetailPageState extends State<ImageItemDetailPage> {
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
                widget.onDelete(widget.folderIndex, widget.imageItemIndex);
              },
            ),
            IconButton(
              icon: Icon(Icons.save),
              color: Colors.purple,
              onPressed: () {
                Navigator.pop(context);
                widget.onSave(widget.folderIndex, widget.imageItemIndex,
                    _descriptionController.text);
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
