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
  bool isImageSelectionMode = false;
  bool isFolderSelectionMode = false;
  List selectedFolders = [];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sizeX = MediaQuery.of(context).size.width;
    final sizeY = MediaQuery.of(context).size.height;
    final folders = Provider.of<AppState>(context).folders;
    List<Map<String, String>> currentImages;
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
          scrolledUnderElevation: 0,
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
          actions: isImageSelectionMode
              ? <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      // 삭제 기능 구현
                      setState(() {
                        isImageSelectionMode = false;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline,
                        color: Colors.purple),
                    onPressed: () {
                      setState(() {
                        isImageSelectionMode = false;
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
                        isImageSelectionMode = true;
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
        child: isFolderSelectionMode
            ? Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: folders.length + 1,
                      itemBuilder: (context, folderIndex) {
                        return _buildFolder(
                          folders: folders,
                          folderIndex: folderIndex,
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            for (int i = 0; i < selectedFolders.length; i++) {
                              String folderName =
                                  folders[folders.indexOf(selectedFolders[i])];
                              context.read<AppState>().deleteFolder(folderName);
                            }
                            selectedFolders = [];
                            isFolderSelectionMode = false;
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isFolderSelectionMode = false;
                          });
                        },
                        icon: const Icon(Icons.check_circle_outline,
                            color: Colors.purple),
                      ),
                    ],
                  )
                ],
              )
            : ListView.builder(
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
          : SizedBox(
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
              return SizedBox(
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        maximumSize: WidgetStateProperty.all(Size(100, 100)),
                      ),
                      onPressed: () {
                        Provider.of<AppState>(context, listen: false)
                            .pickImageFromCamera(context, currentFolder);
                        Navigator.pop(context);
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
                        maximumSize: WidgetStateProperty.all(Size(100, 100)),
                      ),
                      onPressed: () {
                        Provider.of<AppState>(context, listen: false)
                            .pickImageFromGallery(context, currentFolder);
                        Navigator.pop(context);
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
          // 나의 독서 앨범 이미지
          setState(() {
            currentFolder = '나의 독서 앨범';
          });
          Navigator.pop(context);
          return;
        } else {
          if (isFolderSelectionMode) {
            if (folderIndex == folders.length + 1) {
              setState(() {
                isFolderSelectionMode = false;
              });
            } else {
              if (selectedFolders.contains(folders[folderIndex - 1])) {
                setState(() {
                  selectedFolders.remove(folders[folderIndex - 1]);
                });
              } else {
                setState(() {
                  selectedFolders.add(folders[folderIndex - 1]);
                });
              }
            }
          } else {
            if (folderIndex == folders.length + 1) {
              _showCreateFolderDialog(context).then((folderName) {
                if (folderName != null) {
                  context.read<AppState>().addFolder(folderName);
                }
              });
            } else {
              setState(() {
                currentFolder = folders[folderIndex - 1];
              });
              Navigator.pop(context);
            }
          }
        }
      },
      onDoubleTap: () {
        // 배포 전에 onLongPress로 바꾸기
        if (folderIndex != 0 && folderIndex != folders.length + 1) {
          setState(() {
            isFolderSelectionMode = true;
          });
        }
      },
      child: folderIndex == 0
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Icon(
                    Icons.folder,
                    size: 80,
                    color: Color(0xFF33CCCC),
                  ),
                  const Text(
                    '전체',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            )
          : isFolderSelectionMode
              ? folderIndex == folders.length + 1
                  ? SizedBox(width: 0)
                  // ? Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: Column(
                  //       children: [
                  //         Icon(
                  //           Icons.check_circle,
                  //           size: 80,
                  //           color: Color(0xFF33CCCC),
                  //         ),
                  //         const Text(
                  //           '완료',
                  //           style: TextStyle(color: Colors.black),
                  //         ),
                  //       ],
                  //     ),
                  //   )
                  : selectedFolders.contains(folders[folderIndex - 1])
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(height: 7),
                              Image.asset('assets/img/folder_check.png',
                                  width: 67, height: 67),
                              SizedBox(height: 6),
                              Text(
                                folders[folderIndex - 1],
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(height: 7),
                              Image.asset('assets/img/folder_nocheck.png',
                                  width: 67, height: 67),
                              SizedBox(height: 6),
                              Text(
                                folders[folderIndex - 1],
                                style: const TextStyle(color: Colors.black),
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
                          Row(
                            mainAxisSize:
                                MainAxisSize.min, // Row 크기를 내용 크기에 맞게 축소
                            crossAxisAlignment:
                                CrossAxisAlignment.center, // 세로 중앙 정렬
                            children: [
                              Text(
                                folders[folderIndex - 1],
                                style: const TextStyle(color: Colors.black),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 2.0), // 텍스트와 아이콘 간 최소 간격
                                child: GestureDetector(
                                  onTap: () {
                                    _showEditFolderNameDialog(
                                            context, folders[folderIndex - 1])
                                        .then((newFolderName) {
                                      if (newFolderName != null) {
                                        context.read<AppState>().editFolder(
                                            folders[folderIndex - 1],
                                            newFolderName);
                                      }
                                    });
                                  },
                                  child: const Icon(Icons.edit,
                                      size: 16), // 아이콘 크기 조정
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
    );
  }

  // Future<void> _showDeleteFolderDialog(BuildContext context) {
  //   print('showDeleteFolderDialog');
  //   return showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       print('showDialog');
  //       return AlertDialog(
  //         title: Text('폴더 삭제'),
  //         content: Text('정말로 이 폴더를 삭제하시겠습니까?'),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('취소'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: Text('삭제'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<String?> _showCreateFolderDialog(BuildContext context) {
    TextEditingController folderNameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('새 폴더 만들기'),
          content: TextField(
            controller: folderNameController,
            decoration: InputDecoration(hintText: '새 폴더'),
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

  Future<String?> _showEditFolderNameDialog(
      BuildContext context, String currentFolder) {
    TextEditingController folderNameController =
        TextEditingController(text: currentFolder);
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('폴더 이름 수정'),
          content: TextField(
            controller: folderNameController,
            decoration: InputDecoration(hintText: '폴더 이름'),
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
    return isImageSelectionMode
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
    super.key,
    required this.imageItemIndex,
    required this.image,
    required this.description,
    required this.timestamp,
    required this.folderName,
    required this.onDelete,
    required this.onSave,
  });

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
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
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
              icon: Icon(Icons.check),
              color: Colors.purple,
              onPressed: () {
                Navigator.pop(context);
                widget.onSave(
                    widget.imageItemIndex, _descriptionController.text);
              },
            ),
          ],
        ),
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
