import 'dart:io';
import 'dart:ui' as ui;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/card_item.dart';

typedef TempDirGetter = Future<Directory> Function();
typedef ShareFilesFunction =
    Future<void> Function(List<XFile> files, {String? text});

/// A small service responsible for rendering a card (title + code) as a PNG
/// image and delegating to the platform share sheet.
///
/// It's dependency-injectable: you may provide custom implementations for
/// temporary directory retrieval and the share function to improve testability
/// and follow dependency inversion (SOLID).
class ShareService {
  final TempDirGetter _getTempDir;
  final ShareFilesFunction _shareFiles;

  // Test hook: when set, this function will be used instead of the full
  // rendering-and-sharing flow. This allows fast tests to assert the
  // share was triggered without doing widget-to-image work.
  static Future<void> Function(BuildContext context, CardItem card)?
  testShareHook;

  ShareService({TempDirGetter? getTempDir, ShareFilesFunction? shareFiles})
    : _getTempDir = getTempDir ?? getTemporaryDirectory,
      _shareFiles =
          shareFiles ??
          ((files, {text}) => Share.shareXFiles(files, text: text));

  /// Share a [card] as an image. Requires a [BuildContext] that has an Overlay.
  Future<void> shareCardAsImage(BuildContext context, CardItem card) async {
    // If a test hook is present, delegate to it for fast testing.
    if (testShareHook != null) {
      await testShareHook!(context, card);
      return;
    }
    final boundaryKey = GlobalKey();
    final isQr = card.isQrCode;

    final imageWidget = Material(
      type: MaterialType.transparency,
      child: Center(
        child: RepaintBoundary(
          key: boundaryKey,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if ((card.title).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      card.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                isQr
                    ? QrImageView(
                      data: card.name,
                      size: 320,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      eyeStyle: const QrEyeStyle(color: Colors.black),
                      dataModuleStyle: const QrDataModuleStyle(
                        color: Colors.black,
                      ),
                    )
                    : BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: card.name,
                      width: 320,
                      height: 120,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      color: Theme.of(context).colorScheme.onSurface,
                      drawText: false,
                    ),
              ],
            ),
          ),
        ),
      ),
    );

    final overlay = OverlayEntry(builder: (_) => imageWidget);
    final overlayState = Overlay.of(context);
    overlayState.insert(overlay);
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject();
      if (boundary is RenderRepaintBoundary) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          final tempDir = await _getTempDir();
          final file =
              await File(
                '${tempDir.path}/card_${card.id ?? card.name}.png',
              ).create();
          await file.writeAsBytes(pngBytes);
          await _shareFiles([XFile(file.path)], text: card.title);
        }
      }
    } finally {
      overlay.remove();
    }
  }

  /// Convenience static method that uses default dependencies so existing
  /// code can continue calling ShareService.shareCardAsImage(...).
  static Future<void> shareCardAsImageStatic(
    BuildContext context,
    CardItem card,
  ) async {
    final service = ShareService();
    await service.shareCardAsImage(context, card);
  }
}
