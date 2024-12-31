// gallery_tab.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class GalleryTab extends StatefulWidget {
  const GalleryTab({super.key});

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  String currentFolder = '나의 독서 앨범';
  bool isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;
    final folders = Provider.of<AppState>(context).folders;
    var currentImages;
    if (currentFolder == '나의 독서 앨범') {
      currentImages = Provider.of<AppState>(context).imageItems;
    } else {
      currentImages = Provider.of<AppState>(context)
          .imageItems
          .where((element) => element['folderName'] == currentFolder)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          leading: currentFolder == '나의 독서 앨범'
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
                      tooltip: MaterialLocalizations.of(context)
                          .openAppDrawerTooltip,
                    );
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(
                      () {
                        currentFolder = '나의 독서 앨범';
                      },
                    );
                  },
                ),
          title: Text(
            currentFolder,
            style: const TextStyle(color: Colors.black),
          ),
          actions: isSelectionMode
              ? <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      // 삭제 기능 구현
                      setState(() {
                        isSelectionMode = false;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline,
                        color: Colors.purple),
                    onPressed: () {
                      setState(() {
                        isSelectionMode = false;
                      });
                    },
                  ),
                ]
              : <Widget>[
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline,
                        color: Colors.purple),
                    onPressed: () {
                      setState(() {
                        isSelectionMode = true;
                      });
                    },
                  ),
                ]),
      drawer: Drawer(
        width: sizeX * 0.4,
        shape: Border(
          right: BorderSide(color: Colors.teal, width: 0),
        ),
        backgroundColor: Colors.teal[50],
        child: ListView.builder(
          itemCount: folders.length + 2,
          itemBuilder: (context, folderIndex) {
            return _buildFolder(
              folders: folders,
              folderIndex: folderIndex,
            );
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
                      folderName: currentFolder,
                      images: currentImages,
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
                            .pickImageFromCamera(context, currentFolder);
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
                            .pickImageFromGallery(context, currentFolder);
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

  Widget _buildFolder({
    required List<String> folders,
    required int folderIndex,
  }) {
    return GestureDetector(
      onTap: () {
        if (folderIndex == 0) {
          // 전체 이미지
          setState(() {
            currentFolder = '나의 독서 앨범';
          });
          Navigator.pop(context);
          return;
        } else if (folderIndex == folders.length + 1) {
          _showCreateFolderDialog(context).then((folderName) {
            if (folderName != null) {
              context.read<AppState>().addFolder(folderName);
            }
          });
          return;
        } else {
          setState(() {
            currentFolder = folders[folderIndex - 1];
          });
        }
        Navigator.pop(context);
      },
      child: folderIndex == 0
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Icon(
                    Icons.photo_library,
                    size: 80,
                    color: Color(0xFF33CCCC),
                  ),
                  const Text(
                    '나의 독서 앨범',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            )
          : folderIndex == folders.length + 1
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.add,
                        size: 80,
                        color: Color(0xFF33CCCC),
                      ),
                      const Text(
                        '새 폴더',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder,
                        size: 80,
                        color: Color(0xFF33CCCC),
                      ),
                      Text(
                        folders[folderIndex - 1],
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
    );
  }

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

  Widget _buildImage(
      {required String folderName,
      required List<Map<String, String>> images,
      required int imageItemIndex}) {
    return isSelectionMode
        ? GestureDetector(
            onTap: () {
              setState(() {
                images[imageItemIndex]['isSelected'] = 'true';
              });
            },
            child: images[imageItemIndex]['isSelected'] == 'true'
                ? Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(
                                File(images[imageItemIndex]['image']!)),
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
                            images[imageItemIndex]['timestamp']!,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          color: Colors.black.withOpacity(0.5),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(
                                File(images[imageItemIndex]['image']!)),
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
                            images[imageItemIndex]['timestamp']!,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          color: Colors.black.withOpacity(0.5),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
          )
        : GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageItemDetailPage(
                    imageItemIndex: imageItemIndex,
                    folderName: folderName,
                    image: images[imageItemIndex]['image']!,
                    description: images[imageItemIndex]['description']!,
                    timestamp: images[imageItemIndex]['timestamp']!,
                    onDelete: (int index) {
                      context.read<AppState>().deleteImageItem(index);
                    },
                    onSave: (int index, String description) {
                      context
                          .read<AppState>()
                          .editImageItem(index, description);
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
                      image: FileImage(File(images[imageItemIndex]['image']!)),
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
                      images[imageItemIndex]['timestamp']!,
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
}

class ImageItemDetailPage extends StatefulWidget {
  final int imageItemIndex;
  final String image;
  final String description;
  final String timestamp;
  final String folderName;
  final Function(int imageItemIndex) onDelete;
  final Function(int imageItemIndex, String description) onSave;

  const ImageItemDetailPage({
    Key? key,
    required this.imageItemIndex,
    required this.image,
    required this.description,
    required this.timestamp,
    required this.folderName,
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
                widget.onDelete(widget.imageItemIndex);
              },
            ),
            IconButton(
              icon: Icon(Icons.save),
              color: Colors.purple,
              onPressed: () {
                Navigator.pop(context);
                widget.onSave(
                    widget.imageItemIndex, _descriptionController.text);
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
