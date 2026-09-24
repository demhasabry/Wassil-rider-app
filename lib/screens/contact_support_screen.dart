import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radii.dart';

// Placeholder contact details — replace with the real support line/inbox
// before shipping. Same account as customer_app; keep these in sync.
const String _supportPhone = '+249900000000';
const String _supportEmail = 'support@deliveryplatform.example';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _messageController = TextEditingController();
  bool _isSending = false;

  Future<void> _call() async {
    await launchUrl(Uri.parse('tel:$_supportPhone'));
  }

  Future<void> _whatsapp() async {
    final digits = _supportPhone.replaceAll(RegExp(r'[^0-9]'), '');
    await launchUrl(Uri.parse('https://wa.me/$digits'), mode: LaunchMode.externalApplication);
  }

  Future<void> _email() async {
    await launchUrl(Uri.parse('mailto:$_supportEmail'));
  }

  Future<void> _submitMessage() async {
    final l10n = AppLocalizations.of(context)!;
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.describeIssueError)));
      return;
    }

    setState(() => _isSending = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = userDoc.data();
      await FirebaseFirestore.instance.collection('supportTickets').add({
        'userId': uid,
        'role': data?['role'] ?? 'rider',
        'phone': data?['phone'],
        'email': data?['email'],
        'message': message,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.supportMessageSentMessage)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.supportMessageError)));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contactSupportTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [
          Row(
            children: [
              Expanded(
                child: _ContactActionCard(icon: Icons.call, label: l10n.callSupportButton, onTap: _call),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: _ContactActionCard(icon: Icons.chat_outlined, label: l10n.whatsappSupportButton, onTap: _whatsapp),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: _ContactActionCard(icon: Icons.email_outlined, label: l10n.emailSupportButton, onTap: _email),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: AppSpacing.s16),
          TextField(
            controller: _messageController,
            minLines: 4,
            maxLines: 4,
            style: AppTypography.body(size: 13.5, color: AppColors.ink),
            decoration: InputDecoration(hintText: l10n.supportMessageHint),
          ),
          const SizedBox(height: AppSpacing.s12),
          ElevatedButton(
            onPressed: _isSending ? null : _submitMessage,
            child: _isSending
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(l10n.submitSupportMessageButton),
          ),
          const SizedBox(height: AppSpacing.s22),
          Text(l10n.myTicketsHeading, style: AppTypography.heading(size: 15)),
          const SizedBox(height: AppSpacing.s10),
          _TicketList(),
        ],
      ),
    );
  }
}

/// A support message an admin can now reply to (see admin_dashboard's
/// Support tab) has nowhere else to surface that reply back to the user —
/// this screen is the only place they ever look at their own ticket again.
class _TicketList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      // Sorted client-side, not via .orderBy() — a compound where()+
      // orderBy()-on-a-different-field query was observed to hang
      // indefinitely against the Firestore web client elsewhere in this
      // codebase (see watchBids() in models/bid.dart), so this avoids the
      // same trap rather than needing a composite index.
      stream: FirebaseFirestore.instance
          .collection('supportTickets')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aCreated = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            final bCreated = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            if (aCreated == null || bCreated == null) return 0;
            return bCreated.compareTo(aCreated);
          });
        if (docs.isEmpty) return const SizedBox.shrink();
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final message = data['message'] as String? ?? '';
            final reply = data['reply'] as String?;
            final resolved = data['status'] == 'resolved';
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.s10),
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.cardRadius,
                border: Border.all(color: AppColors.borderAlt),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(message, style: AppTypography.body(size: 13.5, color: AppColors.ink))),
                      Text(
                        resolved ? l10n.ticketStatusResolved : l10n.ticketStatusOpen,
                        style: AppTypography.label(size: 11, color: resolved ? AppColors.success : AppColors.muted),
                      ),
                    ],
                  ),
                  if (reply != null) ...[
                    const SizedBox(height: AppSpacing.s8),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s10),
                      decoration: BoxDecoration(
                        color: AppColors.accentTint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.supportReplyLabel,
                              style: AppTypography.label(size: 11, color: AppColors.accent)),
                          const SizedBox(height: 2),
                          Text(reply, style: AppTypography.body(size: 13, color: AppColors.ink)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// One of the three equal call/WhatsApp/email cards from the design handoff:
/// a centred glyph over an 11.5px label, radius `AppRadii.card`.
class _ContactActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ContactActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadii.cardRadius,
      child: InkWell(
        borderRadius: AppRadii.cardRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s18),
          decoration: BoxDecoration(
            borderRadius: AppRadii.cardRadius,
            border: Border.all(color: AppColors.borderAlt),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.accent),
              const SizedBox(height: AppSpacing.s8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.label(size: 11.5, color: AppColors.bodyText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
