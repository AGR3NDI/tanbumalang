import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class InfoController extends GetxController {
  final CollectionReference infoCollection = FirebaseFirestore.instance.collection('info');
  final FirebaseStorage storage = FirebaseStorage.instance;

  final titleController = ''.obs;
  final descriptionController = ''.obs;
  final linkController = ''.obs; // Added for storing link
  final Rx<File?> imageFile = Rx<File?>(null);

  final ImagePicker picker = ImagePicker();

  // Function to pick an image
  Future<void> pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Function to upload image to Firebase Storage
  Future<String> uploadImageToStorage(File image) async {
    try {
      final ref = storage.ref().child('info_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image', snackPosition: SnackPosition.BOTTOM);
      return '';
    }
  }

  // Function to add info data to Firestore
  Future<void> addInfo() async {
    if (titleController.value.isEmpty || descriptionController.value.isEmpty) {
      Get.snackbar('Error', 'Title and Description are required', snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[200],
        colorText: Colors.black,);
      return;
    }

    String imageUrl = '';
    if (imageFile.value != null) {
      imageUrl = await uploadImageToStorage(imageFile.value!);
    }

    try {
      await infoCollection.add({
        'title': titleController.value,
        'description': descriptionController.value,
        'link': linkController.value, // Include the link field
        'imageUrl': imageUrl,
      });

      // Clear fields after uploading
      titleController.value = '';
      descriptionController.value = '';
      linkController.value = ''; // Clear the link
      imageFile.value = null;

      Get.snackbar('Success', 'Info added successfully', snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[200],
        colorText: Colors.black,);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add info', snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[200],
        colorText: Colors.white,);
    }
  }
}


class InfoPageAdmin extends StatelessWidget {
  final InfoController infoController = Get.put(InfoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        title: const Text('Add Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) => infoController.titleController.value = value,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              onChanged: (value) => infoController.descriptionController.value = value,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            TextField(
              onChanged: (value) => infoController.linkController.value = value, // Input for WebView link
              decoration: InputDecoration(labelText: 'Enter WebView Link'),
            ),
            const SizedBox(height: 16),
            Obx(() => infoController.imageFile.value == null
                ? GestureDetector(
              onTap: infoController.pickImage,
              child: Container(
                height: 100,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Center(
                  child: Text('Select an Image'),
                ),
              ),
            )
                : Image.file(infoController.imageFile.value!, height: 100, fit: BoxFit.cover)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[300]),
              onPressed: infoController.addInfo,
              child: const Text('Add Info'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green[300],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white70,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/icon_home.png', width: 24, height: 24),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icon_mutasi.png', width: 24, height: 24),
            label: 'Mutasi',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  'assets/icon_qr_code.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icon_info.png', width: 24, height: 24),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icon_profile.png', width: 24, height: 24),
            label: 'Profile',
          ),
        ],
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home_admin');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/mutasi_admin');
              break;
            case 2:
            // Handle QR code
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/info_admin');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profil_admin');
              break;
          }
        },
      ),
    );
  }
}