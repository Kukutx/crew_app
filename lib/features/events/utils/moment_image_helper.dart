import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Moment 图片处理辅助类
/// 统一处理图片选择、压缩、缓存等逻辑
class MomentImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// 选择单张图片
  static Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// 选择多张图片
  static Future<List<File>> pickMultipleImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      return pickedFiles.map((file) => File(file.path)).toList();
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  /// 选择视频
  static Future<File?> pickVideo({ImageSource source = ImageSource.gallery}) async {
    try {
      final pickedFile = await _picker.pickVideo(source: source);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking video: $e');
      return null;
    }
  }

  /// 压缩图片（简单实现，实际可以使用 flutter_image_compress）
  /// 返回压缩后的文件路径
  static Future<String?> compressImage(String filePath) async {
    // TODO: 实现图片压缩逻辑
    // 可以使用 flutter_image_compress 包
    // 或者使用 image 包进行压缩
    return filePath;
  }

  /// 读取图片为字节数组
  static Future<Uint8List?> readImageBytes(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      debugPrint('Error reading image bytes: $e');
      return null;
    }
  }

  /// 获取图片文件大小（MB）
  static Future<double> getImageSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final size = await file.length();
        return size / (1024 * 1024); // 转换为 MB
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting image size: $e');
      return 0;
    }
  }
}

/// Moment 图片数据模型
/// 统一处理本地图片和网络图片
class MomentImage {
  final String? localPath;
  final Uint8List? bytes;
  final String? networkUrl;
  final String name;

  const MomentImage._({
    this.localPath,
    this.bytes,
    this.networkUrl,
    required this.name,
  });

  /// 从本地文件路径创建
  factory MomentImage.fromFile(String filePath) {
    return MomentImage._(
      localPath: filePath,
      name: filePath.split('/').last,
    );
  }

  /// 从字节数组创建
  factory MomentImage.fromBytes({
    required Uint8List bytes,
    required String name,
  }) {
    return MomentImage._(
      bytes: bytes,
      name: name,
    );
  }

  /// 从网络 URL 创建
  factory MomentImage.fromUrl(String url) {
    return MomentImage._(
      networkUrl: url,
      name: url.split('/').last,
    );
  }

  /// 是否为网络图片
  bool get isNetwork => networkUrl != null;

  /// 是否为本地图片
  bool get isLocal => localPath != null || bytes != null;

  /// 显示名称
  String get displayName => name;

  /// 构建 Widget
  Widget build({
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (networkUrl != null) {
      // 使用网络图片（建议使用 cached_network_image）
      return Image.network(
        networkUrl!,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              const Icon(Icons.image_not_supported_outlined);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ??
              const Center(child: CircularProgressIndicator());
        },
      );
    } else if (localPath != null) {
      return Image.file(
        File(localPath!),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              const Icon(Icons.image_not_supported_outlined);
        },
      );
    } else if (bytes != null) {
      return Image.memory(
        bytes!,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              const Icon(Icons.image_not_supported_outlined);
        },
      );
    } else {
      return errorWidget ?? const Icon(Icons.image_not_supported_outlined);
    }
  }
}

