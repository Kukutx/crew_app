import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

/// 裁剪配置
class CropConfig {
  /// 裁剪宽高比
  final List<CropAspectRatioPreset>? aspectRatioPresets;

  /// 裁剪标题
  final String? title;

  /// 最大宽度
  final int? maxWidth;

  /// 最大高度
  final int? maxHeight;

  /// 压缩质量 (0-100)
  final int compressQuality;

  /// UI 设置
  final CropStyle cropStyle;

  const CropConfig({
    this.aspectRatioPresets,
    this.title,
    this.maxWidth,
    this.maxHeight,
    this.compressQuality = 90,
    this.cropStyle = CropStyle.rectangle,
  });

  /// 头像裁剪配置（正方形）
  static const CropConfig avatar = CropConfig(
    aspectRatioPresets: [CropAspectRatioPreset.square],
    title: '裁剪头像',
    maxWidth: 512,
    maxHeight: 512,
    compressQuality: 95,
    cropStyle: CropStyle.circle,
  );

  /// 封面裁剪配置（16:9）
  static const CropConfig cover = CropConfig(
    aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
    title: '裁剪封面',
    maxWidth: 1920,
    maxHeight: 1080,
    compressQuality: 90,
  );

  /// 自由裁剪配置
  static CropConfig free({String? title}) => CropConfig(
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
          CropAspectRatioPreset.original,
        ],
        title: title ?? '裁剪图片',
        compressQuality: 85,
      );
}

/// 压缩配置
class CompressionConfig {
  /// 压缩质量 (0-100)
  final int quality;

  /// 目标最大宽度
  final int? maxWidth;

  /// 目标最大高度
  final int? maxHeight;

  /// 目标最大文件大小（MB）
  final double? targetSizeMB;

  /// 是否保持 EXIF 信息
  final bool keepExif;

  /// 压缩格式
  final CompressFormat format;

  const CompressionConfig({
    this.quality = 85,
    this.maxWidth,
    this.maxHeight,
    this.targetSizeMB,
    this.keepExif = false,
    this.format = CompressFormat.jpeg,
  });

  /// 默认压缩配置
  static const CompressionConfig standard = CompressionConfig(
    quality: 85,
    maxWidth: 1920,
    maxHeight: 1920,
    targetSizeMB: 2.0,
  );

  /// 高质量压缩
  static const CompressionConfig highQuality = CompressionConfig(
    quality: 95,
    maxWidth: 4096,
    maxHeight: 4096,
    targetSizeMB: 5.0,
  );

  /// 缩略图压缩
  static const CompressionConfig thumbnail = CompressionConfig(
    quality: 80,
    maxWidth: 500,
    maxHeight: 500,
    targetSizeMB: 0.5,
  );
}

/// 媒体选择配置
class MediaPickerConfig {
  /// 图片质量 (0-100)
  final int imageQuality;

  /// 最大文件大小（MB）
  final double? maxFileSizeMB;

  /// 是否启用自动压缩
  final bool autoCompress;

  /// 压缩配置
  final CompressionConfig? compressionConfig;

  /// 是否启用裁剪
  final bool enableCrop;

  /// 裁剪配置
  final CropConfig? cropConfig;

  const MediaPickerConfig({
    this.imageQuality = 85,
    this.maxFileSizeMB,
    this.autoCompress = true,
    this.compressionConfig,
    this.enableCrop = false,
    this.cropConfig,
  });

  static const MediaPickerConfig defaultConfig = MediaPickerConfig();

  static const MediaPickerConfig highQuality = MediaPickerConfig(
    imageQuality: 95,
    autoCompress: false,
  );

  static const MediaPickerConfig lowQuality = MediaPickerConfig(
    imageQuality: 60,
    autoCompress: true,
    compressionConfig: CompressionConfig.thumbnail,
  );

  /// 头像选择配置（带裁剪）
  static const MediaPickerConfig avatar = MediaPickerConfig(
    imageQuality: 90,
    autoCompress: true,
    compressionConfig: CompressionConfig(
      quality: 95,
      maxWidth: 512,
      maxHeight: 512,
    ),
    enableCrop: true,
    cropConfig: CropConfig.avatar,
  );

  /// 封面选择配置（带裁剪）
  static const MediaPickerConfig cover = MediaPickerConfig(
    imageQuality: 90,
    autoCompress: true,
    compressionConfig: CompressionConfig(
      quality: 90,
      maxWidth: 1920,
      maxHeight: 1080,
    ),
    enableCrop: true,
    cropConfig: CropConfig.cover,
  );
}

/// 批量处理进度回调
typedef ProgressCallback = void Function(int current, int total);

/// 媒体选择结果
class MediaPickerResult {
  final List<File> files;
  final String? error;

  const MediaPickerResult._({
    required this.files,
    this.error,
  });

  factory MediaPickerResult.success(List<File> files) {
    return MediaPickerResult._(files: files);
  }

  factory MediaPickerResult.failure(String error) {
    return MediaPickerResult._(files: [], error: error);
  }

  bool get isSuccess => error == null && files.isNotEmpty;
  bool get hasError => error != null;
  bool get isEmpty => files.isEmpty;
}

/// 通用媒体选择工具
///
/// 提供统一的图片和视频选择功能，支持：
/// - 单张/多张图片选择
/// - 视频选择
/// - 图片压缩（自动/手动）
/// - 图片裁剪
/// - 批量处理
/// - 进度回调
class MediaPickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// 选择单张图片（支持压缩和裁剪）
  ///
  /// [source] - 图片来源（相册或相机）
  /// [config] - 选择配置
  ///
  /// 返回选择的文件，如果取消或失败则返回 null
  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    MediaPickerConfig config = MediaPickerConfig.defaultConfig,
  }) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: config.imageQuality,
      );

      if (pickedFile == null) return null;

      File file = File(pickedFile.path);

      // 裁剪
      if (config.enableCrop && config.cropConfig != null) {
        final croppedFile = await _cropImage(file, config.cropConfig!);
        if (croppedFile != null) {
          file = croppedFile;
        }
      }

      // 压缩
      if (config.autoCompress && config.compressionConfig != null) {
        final compressedFile = await compressImage(
          file,
          config: config.compressionConfig!,
        );
        if (compressedFile != null) {
          file = compressedFile;
        }
      }

      // 检查文件大小
      if (config.maxFileSizeMB != null) {
        final fileSizeMB = await _getFileSizeMB(file);
        if (fileSizeMB > config.maxFileSizeMB!) {
          debugPrint(
            'Image size ($fileSizeMB MB) exceeds limit (${config.maxFileSizeMB} MB)',
          );
          return null;
        }
      }

      return file;
    } on PlatformException catch (e) {
      debugPrint('Platform error picking image: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// 选择多张图片（支持批量压缩）
  ///
  /// [config] - 选择配置
  /// [onProgress] - 处理进度回调
  ///
  /// 返回选择的文件列表，如果取消或失败则返回空列表
  static Future<List<File>> pickMultipleImages({
    MediaPickerConfig config = MediaPickerConfig.defaultConfig,
    ProgressCallback? onProgress,
  }) async {
    try {
      final pickedFiles = await _picker.pickMultiImage(
        imageQuality: config.imageQuality,
      );

      if (pickedFiles.isEmpty) return [];

      final files = pickedFiles.map((file) => File(file.path)).toList();

      // 批量处理
      if (config.autoCompress && config.compressionConfig != null) {
        return await compressMultipleImages(
          files,
          config: config.compressionConfig!,
          onProgress: onProgress,
        );
      }

      // 检查文件大小
      if (config.maxFileSizeMB != null) {
        final validFiles = <File>[];
        for (var i = 0; i < files.length; i++) {
          final file = files[i];
          final fileSizeMB = await _getFileSizeMB(file);
          if (fileSizeMB <= config.maxFileSizeMB!) {
            validFiles.add(file);
          } else {
            debugPrint(
              'Skipping image ${file.path}: size ($fileSizeMB MB) exceeds limit (${config.maxFileSizeMB} MB)',
            );
          }
          onProgress?.call(i + 1, files.length);
        }
        return validFiles;
      }

      return files;
    } on PlatformException catch (e) {
      debugPrint('Platform error picking images: ${e.code} - ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  /// 选择视频
  ///
  /// [source] - 视频来源（相册或相机）
  /// [maxDuration] - 最大录制时长（仅在从相机录制时有效）
  ///
  /// 返回选择的文件，如果取消或失败则返回 null
  static Future<File?> pickVideo({
    ImageSource source = ImageSource.gallery,
    Duration? maxDuration,
  }) async {
    try {
      final pickedFile = await _picker.pickVideo(
        source: source,
        maxDuration: maxDuration,
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } on PlatformException catch (e) {
      debugPrint('Platform error picking video: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error picking video: $e');
      return null;
    }
  }

  /// 压缩单张图片
  ///
  /// [file] - 要压缩的图片文件
  /// [config] - 压缩配置
  ///
  /// 返回压缩后的文件，如果失败则返回 null
  static Future<File?> compressImage(
    File file, {
    CompressionConfig config = CompressionConfig.standard,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: config.quality,
        minWidth: config.maxWidth ?? 1920,
        minHeight: config.maxHeight ?? 1920,
        keepExif: config.keepExif,
        format: config.format,
      );

      if (result == null) {
        debugPrint('Compression failed');
        return null;
      }

      final compressedFile = File(result.path);

      // 如果设置了目标文件大小，尝试进一步压缩
      if (config.targetSizeMB != null) {
        var currentSize = await _getFileSizeMB(compressedFile);
        var currentQuality = config.quality;

        // 最多尝试 5 次
        var attempts = 0;
        while (currentSize > config.targetSizeMB! &&
            currentQuality > 50 &&
            attempts < 5) {
          currentQuality -= 10;
          attempts++;

          final retryPath =
              '${dir.path}/compressed_retry_${DateTime.now().millisecondsSinceEpoch}.jpg';

          final retryResult = await FlutterImageCompress.compressAndGetFile(
            file.absolute.path,
            retryPath,
            quality: currentQuality,
            minWidth: config.maxWidth ?? 1920,
            minHeight: config.maxHeight ?? 1920,
            keepExif: config.keepExif,
            format: config.format,
          );

          if (retryResult != null) {
            // 删除旧文件
            if (await compressedFile.exists()) {
              await compressedFile.delete();
            }
            currentSize = await _getFileSizeMB(File(retryResult.path));
            return File(retryResult.path);
          }
        }
      }

      return compressedFile;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// 批量压缩图片
  ///
  /// [files] - 要压缩的图片文件列表
  /// [config] - 压缩配置
  /// [onProgress] - 处理进度回调
  ///
  /// 返回压缩后的文件列表
  static Future<List<File>> compressMultipleImages(
    List<File> files, {
    CompressionConfig config = CompressionConfig.standard,
    ProgressCallback? onProgress,
  }) async {
    final compressedFiles = <File>[];

    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final compressedFile = await compressImage(file, config: config);

      if (compressedFile != null) {
        compressedFiles.add(compressedFile);
      } else {
        // 如果压缩失败，使用原文件
        compressedFiles.add(file);
      }

      onProgress?.call(i + 1, files.length);
    }

    return compressedFiles;
  }

  /// 裁剪图片
  ///
  /// [file] - 要裁剪的图片文件
  /// [config] - 裁剪配置
  ///
  /// 返回裁剪后的文件，如果取消或失败则返回 null
  static Future<File?> cropImage(
    File file, {
    CropConfig config = const CropConfig(),
  }) async {
    return _cropImage(file, config);
  }

  /// 内部裁剪方法
  static Future<File?> _cropImage(File file, CropConfig config) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        compressQuality: config.compressQuality,
        maxWidth: config.maxWidth,
        maxHeight: config.maxHeight,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: config.title ?? '裁剪图片',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: config.aspectRatioPresets ??
                [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9,
                ],
            cropStyle: config.cropStyle,
          ),
          IOSUiSettings(
            title: config.title ?? '裁剪图片',
            aspectRatioPresets: config.aspectRatioPresets ??
                [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9,
                ],
            cropStyle: config.cropStyle,
          ),
          WebUiSettings(
            context: NavigatorObserver() as BuildContext,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(
              width: 520,
              height: 520,
            ),
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }

      return null;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }

  /// 读取图片为字节数组
  ///
  /// [filePath] - 图片文件路径
  ///
  /// 返回图片字节数组，如果失败则返回 null
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

  /// 获取文件大小（MB）
  ///
  /// [filePath] - 文件路径
  ///
  /// 返回文件大小（MB），如果失败则返回 0
  static Future<double> getFileSizeMB(String filePath) async {
    return _getFileSizeMB(File(filePath));
  }

  /// 获取文件大小（MB）- 内部方法
  static Future<double> _getFileSizeMB(File file) async {
    try {
      if (await file.exists()) {
        final size = await file.length();
        return size / (1024 * 1024); // 转换为 MB
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 0;
    }
  }

  /// 批量读取图片字节数组
  ///
  /// [filePaths] - 图片文件路径列表
  /// [onProgress] - 处理进度回调
  ///
  /// 返回图片字节数组列表
  static Future<List<Uint8List>> readMultipleImageBytes(
    List<String> filePaths, {
    ProgressCallback? onProgress,
  }) async {
    final results = <Uint8List>[];
    for (var i = 0; i < filePaths.length; i++) {
      final bytes = await readImageBytes(filePaths[i]);
      if (bytes != null) {
        results.add(bytes);
      }
      onProgress?.call(i + 1, filePaths.length);
    }
    return results;
  }

  /// 清理临时压缩文件
  ///
  /// 清理临时目录中的压缩图片
  static Future<void> cleanupTempFiles() async {
    try {
      final dir = await getTemporaryDirectory();
      final files = dir.listSync();

      for (final file in files) {
        if (file is File &&
            (file.path.contains('compressed_') ||
                file.path.contains('compressed_retry_'))) {
          await file.delete();
        }
      }

      debugPrint('Cleaned up temporary compressed files');
    } catch (e) {
      debugPrint('Error cleaning up temp files: $e');
    }
  }
}

/// 通用图片数据模型
///
/// 统一处理本地图片、字节数组和网络图片
class AppImage {
  final String? localPath;
  final Uint8List? bytes;
  final String? networkUrl;
  final String name;

  const AppImage._({
    this.localPath,
    this.bytes,
    this.networkUrl,
    required this.name,
  });

  /// 从本地文件路径创建
  factory AppImage.fromFile(String filePath) {
    return AppImage._(
      localPath: filePath,
      name: filePath.split('/').last.split('\\').last,
    );
  }

  /// 从 File 对象创建
  factory AppImage.fromFileObject(File file) {
    return AppImage.fromFile(file.path);
  }

  /// 从字节数组创建
  factory AppImage.fromBytes({
    required Uint8List bytes,
    required String name,
  }) {
    return AppImage._(
      bytes: bytes,
      name: name,
    );
  }

  /// 从网络 URL 创建
  factory AppImage.fromUrl(String url) {
    return AppImage._(
      networkUrl: url,
      name: url.split('/').last.split('?').first,
    );
  }

  /// 是否为网络图片
  bool get isNetwork => networkUrl != null;

  /// 是否为本地图片
  bool get isLocal => localPath != null || bytes != null;

  /// 是否为文件路径
  bool get isFilePath => localPath != null;

  /// 是否为字节数组
  bool get isBytes => bytes != null;

  /// 显示名称
  String get displayName => name;

  /// 获取 File 对象（仅当为本地文件时有效）
  File? get file => localPath != null ? File(localPath!) : null;

  /// 构建 Widget
  ///
  /// [fit] - 图片适配方式
  /// [width] - 图片宽度
  /// [height] - 图片高度
  /// [placeholder] - 加载中占位符
  /// [errorWidget] - 错误占位符
  ///
  /// 返回图片 Widget
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

  /// 异步加载字节数组（如果是文件路径）
  Future<Uint8List?> loadBytes() async {
    if (bytes != null) return bytes;
    if (localPath != null) {
      return MediaPickerHelper.readImageBytes(localPath!);
    }
    return null;
  }

  @override
  String toString() {
    if (networkUrl != null) return 'AppImage(network: $networkUrl)';
    if (localPath != null) return 'AppImage(file: $localPath)';
    if (bytes != null) return 'AppImage(bytes: ${bytes!.length} bytes)';
    return 'AppImage(empty)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AppImage) return false;
    return localPath == other.localPath &&
        networkUrl == other.networkUrl &&
        name == other.name;
  }

  @override
  int get hashCode => Object.hash(localPath, networkUrl, name);
}
