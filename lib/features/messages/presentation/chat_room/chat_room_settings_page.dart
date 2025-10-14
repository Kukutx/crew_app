import 'package:crew_app/features/messages/data/chat_participant.dart';
import 'package:crew_app/features/messages/presentation/chat_room/chat_shared_media_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/report_sheet.dart';
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
  final List<ChatParticipant> participants;
  final ChatParticipant currentUser;
  final ChatParticipant? partner;

  @override
  State<ChatRoomSettingsPage> createState() => _ChatRoomSettingsPageState();
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
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        children: [
          _ChatSettingsHeader(
            title: widget.title,
            overviewText: overviewText,
            isGroup: widget.isGroup,
            partner: widget.partner,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => _showFeatureComingSoon(loc.chat_settings_share),
                icon: const Icon(Icons.ios_share_outlined),
                label: Text(loc.chat_settings_share),
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
                ),
                label: Text(exitLabel),
              ),
              OutlinedButton.icon(
                onPressed: () => _showReportSheet(loc),
                icon: const Icon(Icons.flag_outlined),
                label: Text(loc.chat_settings_report),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                  },
                  title: Text(loc.chat_settings_notifications),
                  subtitle: Text(loc.chat_settings_notifications_subtitle),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(loc.chat_settings_shared_files),
                  subtitle: Text(loc.chat_settings_shared_files_subtitle),
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
          const SizedBox(height: 24),
          const SizedBox(height: 32),
          Text(
            widget.isGroup
                ? loc.chat_settings_members_section
                : loc.chat_settings_contact_section,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (widget.isGroup)
            ...participants.map(
              (participant) => _ChatParticipantTile(
                participant: participant,
                colorScheme: colorScheme,
                subtitle: null,
                youLabel: loc.chat_you_label,
                isYou: participant.isCurrentUser ||
                    participant.id == widget.currentUser.id,
              ),
            )
          else if (widget.partner != null) ...[
            _ChatParticipantTile(
              participant: widget.partner!,
              colorScheme: colorScheme,
              subtitle: loc.chat_settings_contact_id(widget.partner!.id),
              youLabel: loc.chat_you_label,
              isYou: false,
            ),
            _ChatParticipantTile(
              participant: widget.currentUser,
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
  final ChatParticipant? partner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;

    Widget avatarChild;
    if (isGroup) {
      avatarChild = Icon(Icons.groups_2, color: primary, size: 42);
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
        ),
      );
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: primary.withValues(alpha: .12),
          child: avatarChild,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          overviewText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ChatParticipantTile extends StatelessWidget {
  const _ChatParticipantTile({
    required this.participant,
    required this.colorScheme,
    required this.subtitle,
    required this.youLabel,
    required this.isYou,
  });

  final ChatParticipant participant;
  final ColorScheme colorScheme;
  final String? subtitle;
  final String youLabel;
  final bool isYou;

  @override
  Widget build(BuildContext context) {
    final initials = (participant.initials ??
            participant.displayName.characters.take(2).toString())
        .toUpperCase();
    final avatarColor = Color(
      participant.avatarColorValue ?? colorScheme.primary.toARGB32(),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: avatarColor.withValues(alpha: .12),
          child: Text(
            initials,
            style: TextStyle(
              color: avatarColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(participant.displayName),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: isYou
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  youLabel,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
