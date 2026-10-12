import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'image_picker_stub.dart';

final ImagePicker _picker = ImagePicker();

Future<void> pickDeviceImage(ImagePickCallback onImagePicked) async {
  try {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      onImagePicked(base64String);
    }
  } catch (e) {
    // Hata durumunda sessizce geç veya logla
  }
}
