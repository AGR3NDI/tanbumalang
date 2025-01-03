import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../pages/webview/webview_screen.dart'; // Import WebViewScreen to display links

class InfoPage extends StatelessWidget {
  final CollectionReference infoCollection =
  FirebaseFirestore.instance.collection('info');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        title: const Text('Info'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/logo.png', width: 50, height: 50),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: infoCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading data.'));
            }
            final documents = snapshot.data?.docs ?? [];

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final infoData = documents[index].data() as Map<String, dynamic>;
                final title = infoData['title'] ?? 'No Title';
                final description = infoData['description'] ?? 'No Description';
                final imageUrl = infoData['imageUrl'] ?? '';
                final link = infoData['link'] ?? '';

                return InfoCard(
                  title: title,
                  description: description,
                  imageUrl: imageUrl,
                  link: link,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String link;

  const InfoCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.link,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (link.isNotEmpty) {
          Get.to(() => WebViewScreen(url: link));
        } else {
          Get.snackbar('No Link', 'This item has no link available.',
              snackPosition: SnackPosition.BOTTOM);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            imageUrl.isNotEmpty
                ? Image.network(imageUrl, height: 100, fit: BoxFit.cover)
                : Container(
              height: 100,
              color: Colors.grey[400],
              child: const Center(
                child: Text('No Image',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
