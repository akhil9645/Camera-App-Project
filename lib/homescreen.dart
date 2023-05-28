import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera_app/db_functions/db_functions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera_app/models/imagemodel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  int _currentScreen = 0;
  final screens = [
    HomeScreen(),
    GalleryScreen(),
  ];
  Widget build(BuildContext context) {
    getImageFromDb();
    return Scaffold(
        body: screens[_currentScreen],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentScreen,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt),
                label: 'Camera',
                backgroundColor: Colors.blue),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.photo,
                ),
                label: 'Photos',
                backgroundColor: Colors.blue),
          ],
          onTap: (value) {
            setState(() {
              _currentScreen = value;
            });
          },
        ));
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _image;
  final imagepicker = ImagePicker();
  Future getimage() async {
    // ignore: deprecated_member_use
    final image = await imagepicker.getImage(source: ImageSource.camera);
    setState(() {
      if (image != null) {
        _image = image.path;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Preview'),
      ),
      body: Center(
          child: Column(
        children: [
          Container(
              width: 400,
              height: 550,
              child: Center(
                child: _image == null
                    ? Text('Take image')
                    : Image(image: FileImage(File(_image!))),
              )),
          ElevatedButton.icon(
              onPressed: () {
                onSaveButton(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (ctx) {
                  return GalleryScreen();
                }));
              },
              icon: Icon(Icons.save_alt),
              label: Text('save'))
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: getimage,
        backgroundColor: Colors.blue,
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  Future<void> onSaveButton(BuildContext context) async {
    final _imgPath = _image;
    if (_imgPath!.isEmpty) {
      return;
    }
    setState(() {
      _imgPath == null;
    });
    final img = ImageModel(image: _imgPath);
    addImageToDb(img);
  }
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (ctx) {
                return MainScreen();
              }));
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: ValueListenableBuilder(
          valueListenable: imageNotifier,
          builder:
              (BuildContext ctx, List<ImageModel> imagesList, Widget? child) {
            return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4),
                itemCount: imagesList.length,
                itemBuilder: (BuildContext cntx, int index) {
                  final data = imagesList[index];
                  print('Image path: ${data.image}');
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (ctx) {
                        return PreViewScreen(
                          data: data,
                          indx: index,
                        );
                      }));
                    },
                    child: Image(image: FileImage(File(data.image))),
                  );
                });
          }),
    );
  }
}

class PreViewScreen extends StatefulWidget {
  PreViewScreen({super.key, required this.data, required this.indx});
  ImageModel data;
  final int indx;

  @override
  State<PreViewScreen> createState() => _PreViewScreenState();
}

class _PreViewScreenState extends State<PreViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image'),
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (ctx) {
                return GalleryScreen();
              }));
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 400,
            height: 600,
            child: Image(image: FileImage(File(widget.data.image))),
          ),
          ElevatedButton.icon(
            onPressed: () {
              deleteButton(context, widget.indx);
            },
            icon: Icon(Icons.delete),
            label: Text('Delete'),
          )
        ],
      )),
    );
  }

  Future<void> deleteButton(BuildContext ctx, index) async {
    showDialog(
      context: context,
      builder: ((ctx) => AlertDialog(
            content: const Text('Really Want To Delete ?'),
            actions: [
              TextButton(
                onPressed: () {
                  deleteImage(index).then((value) => deleteAlert());

                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (ctx) {
                    return MainScreen();
                  }));
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black),
                ),
              )
            ],
          )),
    );
  }

  void deleteAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Text(
          'Image is deleted',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
