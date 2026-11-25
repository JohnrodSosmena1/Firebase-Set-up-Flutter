import 'dart:typed_data';

class Post {
  final String username;
  final String caption;
  final String? imageUrl;
  final Uint8List? imageBytes;

  const Post({
    required this.username,
    required this.caption,
    this.imageUrl,
    this.imageBytes,
  });
}
