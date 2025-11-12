import 'package:crew_app/features/messages/data/chat_member.dart';
import 'package:crew_app/features/messages/presentation/chat_room/pages/chat_shared_media_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/sheets/report_sheet/report_sheet.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatRoomSettingsPage extends StatefulWidget {
  const ChatRoomSettingsPage({
    super.key,
    required this.title,
    required this.isGroup,
    required this.participants,
    required this.currentUser,
    this.partner,
  });

  final String title;
  final bool isGroup;
  final List<ChatMember> participants;
  final ChatMember currentUser;
  final ChatMember? partner;

  @override
  State<ChatRoomSettingsPage> createState() => _ChatRoomSettingsPageState();
}

/// 聊天设置页面相关常量和样式
class _ChatRoomSettingsConstants {
  // 按钮样式
  static ButtonStyle get filledButtonStyle => FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

  static ButtonStyle get outlinedButtonStyle => OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

  // 文本样式
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );

  static const TextStyle listTileTitleStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );

  static TextStyle listTileSubtitleStyle(ColorScheme colorScheme) => TextStyle(
        fontSize: 13,
        color: colorScheme.onSurfaceVariant,
        height: 1.4,
        letterSpacing: 0,
      );
}

class _ChatRoomSettingsPageState extends State<ChatRoomSettingsPage> {
  bool _notificationsEnabled = true;

  List<String> _reportTypes(AppLocalizations localization) {
    if (widget.isGroup) {
      return [
        localization.report_group_type_illegal,
        localization.report_group_type_hate,
        localization.report_group_type_spam,
        localization.report_group_type_fraud,
        localization.report_group_type_other,
      ];
    }

    return [
      localization.report_user_type_harassment,
      localization.report_user_type_impersonation,
      localization.report_user_type_inappropriate,
      localization.report_user_type_spam,
      localization.report_user_type_other,
    ];
  }

  Future<void> _showReportSheet(AppLocalizations localization) async {
    final submission = await ReportSheet.show(
      context: context,
      title: localization.report_issue,
      description: localization.report_issue_description,
      typeLabel: localization.report_event_type_label,
      typeEmptyHint: localization.report_event_type_required,
      contentLabel: localization.report_event_content_label,
      contentHint: localization.report_event_content_hint,
      attachmentLabel: localization.report_event_attachment_label,
      attachmentOptional: localization.report_event_attachment_optional,
      attachmentAddLabel: localization.report_event_attachment_add,
      attachmentReplaceLabel: localization.report_event_attachment_replace,
      attachmentEmptyLabel: localization.report_event_attachment_empty,
      submitLabel: localization.report_event_submit,
      cancelLabel: localization.action_cancel,
      reportTypes: _reportTypes(localization),
      imagePicker: ImagePicker(),
    );

    if (!mounted || submission == null) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          widget.isGroup
              ? localization.report_group_submit_success
              : localization.report_direct_submit_success,
        ),
      ),
    );
  }

  void _showFeatureComingSoon(String label) {
    final loc = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(loc.chat_action_unavailable(label)),
        ),
      );
  }

  void _showConfirmationSheet({
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: Text(AppLocalizations.of(sheetContext)!.action_cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          onConfirm();
                        },
                        child: Text(confirmLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final participants = widget.participants;

    final overviewText = widget.isGroup
        ? loc.chat_settings_group_overview(
            loc.chat_members_count(participants.length),
          )
        : loc.chat_settings_direct_overview;

    final exitLabel = widget.isGroup
        ? loc.chat_settings_leave_group
        : loc.chat_settings_remove_friend;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.chat_settings_title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          _ChatSettingsHeader(
            title: widget.title,
            overviewText: overviewText,
            isGroup: widget.isGroup,
            partner: widget.partner,
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => _showFeatureComingSoon(loc.chat_settings_share),
                icon: const Icon(Icons.ios_share_outlined, size: 18),
                label: Text(
                  loc.chat_settings_share,
                  style: _ChatRoomSettingsConstants.buttonTextStyle,
                ),
                style: _ChatRoomSettingsConstants.filledButtonStyle,
              ),
              OutlinedButton.icon(
                onPressed: () {
                  final title = widget.isGroup
                      ? loc.chat_settings_leave_group_confirmation_title
                      : loc.chat_settings_remove_friend_confirmation_title;
                  final message = widget.isGroup
                      ? loc.chat_settings_leave_group_confirmation_message
                      : loc.chat_settings_remove_friend_confirmation_message;
                  _showConfirmationSheet(
                    title: title,
                    message: message,
                    confirmLabel: exitLabel,
                    onConfirm: () => _showFeatureComingSoon(exitLabel),
                  );
                },
                icon: Icon(
                  widget.isGroup
                      ? Icons.exit_to_app
                      : Icons.person_remove_alt_1_outlined,
                  size: 18,
                ),
                label: Text(
                  exitLabel,
                  style: _ChatRoomSettingsConstants.buttonTextStyle,
                ),
                style: _ChatRoomSettingsConstants.outlinedButtonStyle,
              ),
              OutlinedButton.icon(
                onPressed: () => _showReportSheet(loc),
                icon: const Icon(Icons.flag_outlined, size: 18),
                label: Text(
                  loc.chat_settings_report,
                  style: _ChatRoomSettingsConstants.buttonTextStyle,
                ),
                style: _ChatRoomSettingsConstants.outlinedButtonStyle,
              ),
            ],
          ),
          const SizedBox(height: 28),
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                  },
                  title: Text(
                    loc.chat_settings_notifications,
                    style: _ChatRoomSettingsConstants.listTileTitleStyle,
                  ),
                  subtitle: Text(
                    loc.chat_settings_notifications_subtitle,
                    style: _ChatRoomSettingsConstants.listTileSubtitleStyle(colorScheme),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                  title: Text(
                    loc.chat_settings_shared_files,
                    style: _ChatRoomSettingsConstants.listTileTitleStyle,
                  ),
                  subtitle: Text(
                    loc.chat_settings_shared_files_subtitle,
                    style: _ChatRoomSettingsConstants.listTileSubtitleStyle(colorScheme),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatSharedMediaPage(
                          chatTitle: widget.title,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            widget.isGroup
                ? loc.chat_settings_members_section
                : loc.chat_settings_contact_section,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  height: 1.3,
                  letterSpacing: -0.2,
                ),
          ),
          const SizedBox(height: 16),
          if (widget.isGroup)
            ...participants.map(
              (member) => _ChatMemberTile(
                member: member,
                colorScheme: colorScheme,
                subtitle: null,
                youLabel: loc.chat_you_label,
                isYou: member.isCurrentUser ||
                    member.id == widget.currentUser.id,
              ),
            )
          else if (widget.partner != null) ...[
            _ChatMemberTile(
              member: widget.partner!,
              colorScheme: colorScheme,
              subtitle: loc.chat_settings_contact_id(widget.partner!.id),
              youLabel: loc.chat_you_label,
              isYou: false,
            ),
            _ChatMemberTile(
              member: widget.currentUser,
              colorScheme: colorScheme,
              subtitle: loc.chat_settings_contact_id(widget.currentUser.id),
              youLabel: loc.chat_you_label,
              isYou: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _ChatSettingsHeader extends StatelessWidget {
  const _ChatSettingsHeader({
    required this.title,
    required this.overviewText,
    required this.isGroup,
    this.partner,
  });

  final String title;
  final String overviewText;
  final bool isGroup;
  final ChatMember? partner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;

    Widget avatarChild;
    if (isGroup) {
      avatarChild = Icon(Icons.groups_2, color: primary, size: 48);
    } else {
      final initials = (partner?.initials ??
              partner?.displayName.characters.take(2).toString() ??
              title.characters.take(2).toString())
          .toUpperCase();
      avatarChild = Text(
        initials,
        style: theme.textTheme.headlineMedium?.copyWith(
          color: primary,
          fontWeight: FontWeight.w700,
          fontSize: 32,
          height: 1.2,
          letterSpacing: -0.5,
        ),
      );
    }

    return Column(
      children: [
        CrewAvatar(
          radius: 48,
          backgroundColor: primary.withValues(alpha: .12),
          foregroundColor: primary,
          child: avatarChild,
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            height: 1.3,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          overviewText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
            height: 1.4,
            letterSpacing: 0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ChatMemberTile extends StatelessWidget {
  const _ChatMemberTile({
    required this.member,
    required this.colorScheme,
    required this.subtitle,
    required this.youLabel,
    required this.isYou,
  });

  final ChatMember member;
  final ColorScheme colorScheme;
  final String? subtitle;
  final String youLabel;
  final bool isYou;

  @override
  Widget build(BuildContext context) {
    final initials = (member.initials ??
            member.displayName.characters.take(2).toString())
        .toUpperCase();
    final avatarColor = Color(
      member.avatarColorValue ?? colorScheme.primary.toARGB32(),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CrewAvatar(
          radius: 22,
          backgroundColor: avatarColor.withValues(alpha: .12),
          foregroundColor: avatarColor,
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(
          member.displayName,
          style: _ChatRoomSettingsConstants.listTileTitleStyle,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: _ChatRoomSettingsConstants.listTileSubtitleStyle(colorScheme),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        trailing: isYou
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  youLabel,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    height: 1.3,
                    letterSpacing: 0,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
