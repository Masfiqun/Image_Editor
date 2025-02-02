import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: EditImage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EditImage extends StatefulWidget {
  const EditImage({super.key});

  @override
  State<EditImage> createState() => _EditImageState();
}

class _EditImageState extends State<EditImage> {
  final ImagePicker picker = ImagePicker();
  XFile? image;

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  Future<void> requestStoragePermission() async {
    await Permission.storage.request();
  }

  Future<void> pickImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = pickedImage;
    });
  }

  Future<void> saveImage(Uint8List editedImage) async {
    final result = await ImageGallerySaver.saveImage(editedImage);
    
    if (result['isSuccess']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image saved to gallery!"))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save image!"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Image Editor',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.cyan,
        actions: [
          if (image != null)
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () async {
                  File file = File(image!.path);
                  Uint8List imgBytes = await file.readAsBytes();

                  final editedImage = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageEditor(
                        images: [imgBytes], 
                      ),
                    ),
                  );

                  if (editedImage != null && editedImage is Uint8List) {
                    await saveImage(editedImage);
                  }
                },
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: image == null
                    ? Text(
                        'No Image selected',
                        style: TextStyle(fontSize: 18),
                      )
                    : Image.file(File(image!.path), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: Icon(Icons.image),
              label: Text(
                'Select Image from gallery',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.cyan,
              ),
            )
          ],
        ),
      ),
    );
  }
}
