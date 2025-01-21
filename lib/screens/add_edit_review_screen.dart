import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../api_service.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class AddEditReviewScreen extends StatefulWidget {
  final String username;
  final Map<String, dynamic>? review;

  const AddEditReviewScreen({Key? key, required this.username, this.review}) : super(key: key);

  @override
  _AddEditReviewScreenState createState() => _AddEditReviewScreenState();
}

class _AddEditReviewScreenState extends State<AddEditReviewScreen> {
  final _titleController = TextEditingController();
  final _ratingController = TextEditingController();
  final _commentController = TextEditingController();
  final _imageController = TextEditingController();
  final _apiService = ApiService();
  XFile? _image;
  String base64Image = '';
  

  @override
  void initState() {
    super.initState();
    if (widget.review != null) {
      _titleController.text = widget.review!['title'];
      _ratingController.text = widget.review!['rating'].toString();
      _commentController.text = widget.review!['comment'];
      _imageController.text = widget.review!['image'];
    }
  }

  void _saveReview() async {
    // await _convertImageToBase64();
    final title = _titleController.text.trim();
    final rating = int.tryParse(_ratingController.text) ?? 0;
    final comment = _commentController.text.trim();
    final image = await _convertImageToBase64();
    
    // Validasi input
    if (title.isEmpty || rating < 1 || rating > 10 || comment.isEmpty || image == null ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data tidak valid. Judul, komentar, gambar, dan rating (1-10) harus diisi.')),
      );
      return;
    }

    bool success;
    if (widget.review == null) {
      // Tambah review baru
      success = await _apiService.addReview(widget.username, title, rating, comment, image);
    } else {
      // Edit review
      success = await _apiService.updateReview(widget.review!['_id'], widget.username, title, rating, comment, image);
    }

    if (success) {
      Navigator.pop(context, true); // Berhasil, kembali ke layar sebelumnya
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan review')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      // Pilih gambar dari galeri
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
      } else {

        print('No image selected');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<String?> _convertImageToBase64() async {
    if (_image == null) return null;

    try {
      final imageBytes = await _image!.readAsBytes();
      final base64Image = base64Encode(imageBytes); // Mengonversi gambar menjadi base64
      print("Base64 Image: $base64Image");
      return base64Image.toString(); // Mengembalikan nilai base64Image
    } catch (e) {
      print("Error converting image to Base64: $e");
      return null; // Mengembalikan null jika terjadi error
    }
  }


  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.review != null;

    Uint8List byteToImg = _imageController.text.isNotEmpty
    ? base64Decode(_imageController.text)
    : Uint8List(0);

    

    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? 'Edit Review' : 'Tambah Review')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Judul Film'),
              readOnly: isEditMode, // Nonaktifkan input jika dalam mode edit
            ),
            TextField(
              controller: _ratingController,
              decoration: InputDecoration(labelText: 'Rating (1-10)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(labelText: 'Komentar'),
            ),
            SizedBox(
              height: 20,
            ),

            if (isEditMode) // UPDATE
              Column(
                children: [
                  if (_image != null)
                    Column(
                      children: [
                        Image.file(
                          File(_image!.path),
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ],
                    )
                  else 
                    Image.memory(
                      byteToImg,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                ],
              )
            else // CREATE
              if (_image != null)
                Image.file(
                  File(_image!.path),
                  height: 200,
                  width: 200,
                ),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Select Image'),
              ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: _saveReview,
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
