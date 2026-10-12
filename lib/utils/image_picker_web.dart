// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'image_picker_stub.dart';

void pickDeviceImage(ImagePickCallback onImagePicked) {
  final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
  uploadInput.click();

  uploadInput.onChange.listen((event) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final reader = html.FileReader();
      reader.readAsDataUrl(files[0]);
      reader.onLoadEnd.listen((e) {
        final result = reader.result as String?;
        if (result != null && result.isNotEmpty) {
          onImagePicked(result);
        }
      });
    }
  });
}
