import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'post.dart';

class CreatePostSheet extends StatefulWidget {
  final String username;

  const CreatePostSheet({
    super.key,
    required this.username,
  });

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _selectedImageName;
  Uint8List? _selectedImageBytes;
  bool _isPicking = false;

  Future<void> _pickImage() async {
    setState(() {
      _isPicking = true;
    });

    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedImageName = file.name;
          _selectedImageBytes = bytes;
          _imageController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }

  void submitPost() {
    final String caption = _captionController.text.trim();
    final String imageUrl = _imageController.text.trim();

    if (caption.isEmpty && _selectedImageBytes == null && imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete both fields before submitting!'),
        ),
      );
      return;
    }

    if (caption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a caption before submitting!'),
        ),
      );
      return;
    }

    if (_selectedImageBytes == null && imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a photo or enter an image URL!'),
        ),
      );
      return;
    }

    if (_selectedImageBytes == null && imageUrl.isNotEmpty) {
      final uri = Uri.tryParse(imageUrl);
      if (uri == null ||
          !uri.hasAuthority ||
          (uri.scheme != 'https' && uri.scheme != 'http')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter a valid HTTP or HTTPS image URL.'),
          ),
        );
        return;
      }
    }

    final Post newPost = Post(
      username: widget.username,
      caption: caption,
      imageBytes: _selectedImageBytes,
      imageUrl: _selectedImageBytes == null ? imageUrl : null,
    );

    Navigator.pop(context, newPost);
  }

  @override
  void dispose() {
    _captionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Create Post',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Cancel',
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _captionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Caption',
                hintText: "What's on your mind?",
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Image Upload Section
            if (_selectedImageBytes == null) ...[
              InkWell(
                onTap: _isPicking ? null : _pickImage,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.indigo.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: _isPicking
                        ? const CircularProgressIndicator()
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 44,
                                color: Colors.indigo,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to upload photo from device',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.indigo,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Select from Gallery or Files',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR ENTER URL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _imageController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'https://picsum.photos/id/20/600/400',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
              ),
            ] else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _selectedImageBytes!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          radius: 18,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close, color: Colors.white, size: 20),
                            tooltip: 'Remove photo',
                            onPressed: () {
                              setState(() {
                                _selectedImageName = null;
                                _selectedImageBytes = null;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedImageName != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _selectedImageName!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _isPicking ? null : _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose a different photo'),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: submitPost,
              icon: const Icon(Icons.publish),
              label: const Text('Submit Post'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
