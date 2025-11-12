import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

/// 图片分享和保存工具类
/// 统一处理 RenderRepaintBoundary 转图片、分享、保存等逻辑
class ImageShareHelper {
  /// 从 RenderRepaintBoundary 获取图片字节数据
  static Future<Uint8List?> getImageBytesFromBoundary(
    BuildContext context,
    GlobalKey key,
  ) async {
    final boundary = key.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;

    try {
      final ui.Image image = await boundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      image.dispose();
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Failed to convert boundary to image: $e');
      return null;
    }
  }

  /// 分享图片和文本
  /// 
  /// [key] - 预览组件的 GlobalKey
  /// [shareText] - 分享的文本内容
  /// [fallbackToTextOnly] - 如果图片获取失败，是否回退到只分享文本
  /// [onError] - 错误回调
  /// 
  /// 返回是否成功分享
  static Future<bool> shareImageWithText({
    required BuildContext context,
    required GlobalKey key,
    required String shareText,
    bool fallbackToTextOnly = true,
    void Function(String error)? onError,
  }) async {
    final bytes = await getImageBytesFromBoundary(context, key);
    
    try {
      if (bytes != null) {
        final xFile = XFile.fromData(
          bytes,
          mimeType: 'image/png',
          name: 'crew_share.png',
        );
        await SharePlus.instance.share(
          ShareParams(text: shareText, files: [xFile]),
        );
        return true;
      } else if (fallbackToTextOnly) {
        await SharePlus.instance.share(ShareParams(text: shareText));
        return true;
      } else {
        onError?.call('无法生成分享图片');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to share image: $e');
      
      // 如果分享图片失败，尝试只分享文本
      if (fallbackToTextOnly) {
        try {
          await SharePlus.instance.share(ShareParams(text: shareText));
          return true;
        } catch (fallbackError) {
          debugPrint('Failed to share text: $fallbackError');
          onError?.call('分享失败，请重试');
          return false;
        }
      } else {
        onError?.call('分享失败，请重试');
        return false;
      }
    }
  }

  /// 保存图片到相册
  /// 
  /// [key] - 预览组件的 GlobalKey
  /// [fileName] - 保存的文件名（不含扩展名）
  /// [onSuccess] - 成功回调
  /// [onError] - 错误回调
  /// 
  /// 返回是否成功保存
  static Future<bool> saveImageToGallery({
    required BuildContext context,
    required GlobalKey key,
    required String fileName,
    void Function()? onSuccess,
    void Function(String error)? onError,
  }) async {
    final bytes = await getImageBytesFromBoundary(context, key);
    if (bytes == null) {
      onError?.call('无法生成图片');
      return false;
    }

    try {
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        name: fileName,
        quality: 100,
        isReturnImagePathOfIOS: true,
      );

      final success = result is Map &&
          (result['isSuccess'] == true || result['success'] == true);

      if (success) {
        onSuccess?.call();
        return true;
      } else {
        onError?.call('保存失败');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to save image: $e');
      onError?.call('保存失败，请重试');
      return false;
    }
  }
}

