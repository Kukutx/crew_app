import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_detail_app_bar.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_detail_body.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_detail_bottom_bar.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_share_sheet.dart';
import 'package:crew_app/features/events/presentation/sheets/create_moment_sheet.dart';
import 'package:crew_app/features/user/presentation/user_profile/user_profile_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';

class EventDetailPage extends ConsumerStatefulWidget {
  final Event event;
  const EventDetailPage({super.key, required this.event});

  @override
  ConsumerState<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends ConsumerState<EventDetailPage> {
  final PageController _pageCtrl = PageController();
  int _page = 0;
  final GlobalKey _sharePreviewKey = GlobalKey();
  SystemUiOverlayStyle? _previousOverlayStyle;

  static const _fallbackHost = (
    name: 'Crew Host',
    bio: 'Crew · 活动主理人',
    avatar: 'https://images.unsplash.com/photo-1502685104226-ee32379fefbe',
  );

  bool _following = false;

  @override
  void initState() {
    super.initState();
    _captureCurrentOverlayStyle();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  void _captureCurrentOverlayStyle() {
    // The framework does not expose the currently applied overlay style, so
    // we best-effort remember the most recently set value via
    // WidgetsBindingObserver. This page always sets a transparent status bar
    // with light icons and restores a dark style on dispose to avoid leaving
    // the app in an unexpected state.
    _previousOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final url = widget.event.firstAvailableImageUrl;
    if (url != null && url.isNotEmpty) {
      precacheImage(
        Image.network(url).image,
        context,
        onError: (error, stackTrace) {
          debugPrint('Failed to precache event image: $error');
        },
      );
    }
  }

  String get _eventShareLink => 'https://crewapp.events/${widget.event.id}';

  String _buildShareMessage() {
    final event = widget.event;
    return '${event.title} · ${event.location}\n$_eventShareLink';
  }

  void _showShareSheet(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => EventShareSheet(
        event: widget.event,
        loc: loc,
        previewKey: _sharePreviewKey,
        shareLink: _eventShareLink,
        onSaveImage: () => _saveShareImage(sheetContext),
        onShareSystem: () => _shareThroughSystem(sheetContext),
      ),
    );
  }

  Future<void> _shareThroughSystem(BuildContext sheetContext) async {
    final shareText = _buildShareMessage();
    final boundary =
        _sharePreviewKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) {
      await SharePlus.instance.share(ShareParams(text: shareText));
      if (!sheetContext.mounted) return;
      Navigator.of(sheetContext).pop();
      return;
    }

    try {
      final ui.Image image = await boundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        await SharePlus.instance.share(ShareParams(text: shareText));
      } else {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final xFile = XFile.fromData(
          pngBytes,
          mimeType: 'image/png',
          name: 'crew_event_share.png',
        );
        await SharePlus.instance.share(
          ShareParams(text: shareText, files: [xFile]),
        );
      }
    } catch (_) {
      await SharePlus.instance.share(ShareParams(text: shareText));
    }
    if (!sheetContext.mounted) return;
    Navigator.of(sheetContext).pop();
  }

  Future<void> _saveShareImage(BuildContext sheetContext) async {
    final boundary =
        _sharePreviewKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    final loc = AppLocalizations.of(context)!;

    if (boundary == null) {
      if (!mounted) return;
      Navigator.of(sheetContext).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.share_save_failure)));
      return;
    }

    try {
      final ui.Image image = await boundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        if (!sheetContext.mounted || !mounted) return;
        Navigator.of(sheetContext).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.share_save_failure)));
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final result = await ImageGallerySaverPlus.saveImage(
        pngBytes,
        name: 'crew_event_${widget.event.id}',
        quality: 100,
        isReturnImagePathOfIOS: true,
      );

      if (!sheetContext.mounted || !mounted) return;
      Navigator.of(sheetContext).pop();

      final success =
          result is Map &&
          (result['isSuccess'] == true || result['success'] == true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? loc.share_save_success : loc.share_save_failure,
          ),
        ),
      );
    } catch (_) {
      if (!sheetContext.mounted || !mounted) return;
      Navigator.of(sheetContext).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.share_save_failure)));
    }
  }

  Future<void> _showReportIssueSheet(AppLocalizations loc) async {
    final theme = Theme.of(context);
    final reportOptions = [
      loc.report_event_type_misinformation,
      loc.report_event_type_illegal,
      loc.report_event_type_fraud,
      loc.report_event_type_other,
    ];
    final detailsController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? selectedReason;
    Uint8List? attachmentPreview;
    String? attachmentName;
    bool isPickingAttachment = false;
    final imagePicker = ImagePicker();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final textTheme = Theme.of(sheetContext).textTheme;
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickAttachment() async {
              if (isPickingAttachment) return;
              setModalState(() {
                isPickingAttachment = true;
              });
              try {
                final picked = await imagePicker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                );
                if (picked == null) {
                  return;
                }
                final bytes = await picked.readAsBytes();
                if (!sheetContext.mounted) {
                  return;
                }
                setModalState(() {
                  attachmentPreview = bytes;
                  attachmentName = picked.name;
                });
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.report_event_attachment_error),
                    ),
                  );
                }
              } finally {
                if (!sheetContext.mounted) {
                  return;
                }
                setModalState(() {
                  isPickingAttachment = false;
                });
              }
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.flag_outlined,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                loc.report_issue,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loc.report_issue_description,
                          style: textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        DropdownButtonFormField<String>(
                          value: selectedReason,
                          decoration: InputDecoration(
                            labelText: loc.report_event_type_label,
                          ),
                          items: reportOptions
                              .map(
                                (option) => DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setModalState(() => selectedReason = value),
                          validator: (value) => value == null
                              ? loc.report_event_type_required
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: detailsController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: loc.report_event_content_label,
                            hintText: loc.report_event_content_hint,
                            alignLabelWithHint: true,
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? loc.report_event_content_required
                                  : null,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          loc.report_event_attachment_label,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.report_event_attachment_optional,
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (attachmentPreview != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: Image.memory(
                                    attachmentPreview!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          Colors.black.withOpacity(0.6),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.all(8),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: () {
                                      setModalState(() {
                                        attachmentPreview = null;
                                        attachmentName = null;
                                      });
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (attachmentName != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              attachmentName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: isPickingAttachment ? null : pickAttachment,
                            icon: isPickingAttachment
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.photo_library_outlined),
                            label: Text(
                              attachmentPreview == null
                                  ? loc.report_event_attachment_add
                                  : loc.report_event_attachment_replace,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              if (formKey.currentState?.validate() != true) {
                                return;
                              }
                              Navigator.of(sheetContext).pop();
                              if (!mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    loc.report_event_submit_success,
                                  ),
                                ),
                              );
                            },
                            child: Text(loc.report_event_submit),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.of(sheetContext).pop(),
                            child: Text(loc.action_cancel),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    detailsController.dispose();
  }

  void _showFeatureNotReadyMessage(AppLocalizations loc) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(loc.feature_not_ready)));
  }

  void _showMoreActions(AppLocalizations loc) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(loc.report_issue),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showReportIssueSheet(loc);
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text(loc.action_cancel),
                onTap: () => Navigator.of(sheetContext).pop(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    if (_previousOverlayStyle != null) {
      SystemChrome.setSystemUIOverlayStyle(_previousOverlayStyle!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final loc = AppLocalizations.of(context)!;
    final organizer = event.organizer;
    final hostName = (organizer?.name.isNotEmpty ?? false)
        ? organizer!.name
        : _fallbackHost.name;
    final hostBio = (organizer?.bio?.isNotEmpty ?? false)
        ? organizer!.bio!
        : _fallbackHost.bio;
    final hostAvatar = (organizer?.avatarUrl?.isNotEmpty ?? false)
        ? organizer!.avatarUrl!
        : _fallbackHost.avatar;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9),
      extendBodyBehindAppBar: true,
      appBar: EventDetailAppBar(
        onBack: () => Navigator.pop(context),
        onShare: () => _showShareSheet(context),
        onMore: () => _showMoreActions(loc),
      ),
      bottomNavigationBar: EventDetailBottomBar(
        loc: loc,
        isFavorite: event.isFavorite,
        onFavorite: () => _showFeatureNotReadyMessage(loc),
        onRegister: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.registration_not_implemented)),
          );
        },
      ),
      floatingActionButton: _PlazaPostFab(
        label: loc.event_detail_publish_plaza,
        onPressed: () => showCreateMomentSheet(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: EventDetailBody(
        event: event,
        loc: loc,
        pageController: _pageCtrl,
        currentPage: _page,
        onPageChanged: (index) => setState(() => _page = index),
        hostName: hostName,
        hostBio: hostBio,
        hostAvatarUrl: hostAvatar,
        onTapHostProfile: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserProfilePage()),
          );
        },
        onToggleFollow: () async {
          // TODO: integrate backend follow logic
          setState(() => _following = !_following);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_following ? loc.followed : loc.unfollowed)),
          );
        },
        isFollowing: _following,
        onTapLocation: () => Navigator.pop(context, widget.event),
        heroTag: 'event-media-${event.id}',
      ),
    );
  }
}

class _PlazaPostFab extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PlazaPostFab({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: label,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: const CircleBorder(),
      child: const Icon(Icons.add),
    );
  }
}
