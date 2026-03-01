import 'package:admin/services/file_handling/file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProductImageCard extends StatelessWidget {
  final String labelText;
  final String? imageUrlForUpdateImage;
  final AppFile? imageFile;
  final VoidCallback onTap;
  final VoidCallback? onRemoveImage;
  final bool isUploading;
  final String? uploadedUrl;

  const ProductImageCard({
    Key? key,
    required this.labelText,
    this.imageFile,
    required this.onTap,
    this.imageUrlForUpdateImage,
    this.onRemoveImage,
    this.isUploading = false,
    this.uploadedUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Card(
          child: Container(
            height: 130,
            width: size.width < 600 ? size.width * 0.25 : size.width * 0.12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: GestureDetector(
              onTap: isUploading ? null : onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (isUploading)
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  else if (uploadedUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        uploadedUrl!,
                        width: double.infinity,
                        height: 80,
                        fit: BoxFit.scaleDown,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
                      ),
                    )
                  else if (imageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: getFileImage(
                        imageFile!,
                        width: double.infinity,
                        height: 80,
                        fit: BoxFit.scaleDown,
                      ),
                    )
                  else if (imageUrlForUpdateImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrlForUpdateImage ?? '',
                        width: double.infinity,
                        height: 80,
                        fit: BoxFit.scaleDown,
                      ),
                    )
                  else
                    Icon(Icons.camera_alt, size: 50, color: Colors.grey[600]),
                  SizedBox(height: 8),
                  Text(
                    isUploading ? 'Uploading...' : labelText,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUploading ? Colors.blue : Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if ((imageFile != null || uploadedUrl != null) && !isUploading && onRemoveImage != null)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: onRemoveImage,
            ),
          ),
      ],
    );
  }
}
