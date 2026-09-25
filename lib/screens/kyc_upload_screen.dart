import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/generated/app_localizations.dart';
import '../utils/localized_vehicle_type.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_shadows.dart';

class KycUploadScreen extends StatefulWidget {
  const KycUploadScreen({super.key});

  @override
  State<KycUploadScreen> createState() => _KycUploadScreenState();
}

// One entry per required document. Keyed by the exact field name it
// eventually becomes in riders/{uid}.kycDocs, so upload/save code below
// can stay a simple loop instead of near-duplicate blocks per document.
class _KycDoc {
  final String key; // e.g. "licenseFrontUrl"
  final String fileName; // e.g. "license_front.jpg"
  File? photo;
  _KycDoc(this.key, this.fileName);
}

class _KycUploadScreenState extends State<KycUploadScreen> {
  final _picker = ImagePicker();
  bool _isUploading = false;
  bool _isLoadingVehicleType = true;
  String? _errorText;
  String _vehicleType = 'motorbike';
  String? _kycStatus;
  String? _kycRejectionReason;
  // Keyed by vehicleTypes doc id — admin-managed, same pattern as zones.
  Map<String, Map<String, dynamic>> _vehicleTypes = {};

  // Bicycle riders have no license/registration to show — just a personal
  // ID. Motorized riders need the full license + registration set. Kept as
  // separate maps (rather than always keeping all 5 keys around) so a
  // vehicle-type switch cleanly drops whichever photos no longer apply.
  final Map<String, _KycDoc> _bicycleDocs = {
    'personalId': _KycDoc('personalIdUrl', 'personal_id.jpg'),
  };
  final Map<String, _KycDoc> _motorizedDocs = {
    'licenseFront': _KycDoc('licenseFrontUrl', 'license_front.jpg'),
    'licenseBack': _KycDoc('licenseBackUrl', 'license_back.jpg'),
    'registrationFront': _KycDoc('registrationFrontUrl', 'registration_front.jpg'),
    'registrationBack': _KycDoc('registrationBackUrl', 'registration_back.jpg'),
  };

  bool get _isPersonalIdOnly => _vehicleTypes[_vehicleType]?['kycDocType'] == 'personalIdOnly';
  Map<String, _KycDoc> get _activeDocs => _isPersonalIdOnly ? _bicycleDocs : _motorizedDocs;

  @override
  void initState() {
    super.initState();
    _loadVehicleType();
  }

  Future<void> _loadVehicleType() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final riderDocFuture = FirebaseFirestore.instance.collection('riders').doc(uid).get();
    final typesSnapFuture = FirebaseFirestore.instance.collection('vehicleTypes').where('active', isEqualTo: true).get();
    final results = await Future.wait([riderDocFuture, typesSnapFuture]);
    final riderDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
    final typesSnap = results[1] as QuerySnapshot<Map<String, dynamic>>;
    if (!mounted) return;

    final types = {for (final d in typesSnap.docs) d.id: d.data()};
    final storedType = riderDoc.data()?['vehicleType'] as String? ?? 'motorbike';
    setState(() {
      _vehicleTypes = types;
      // Fall back to whichever type is actually available if the rider's
      // stored type has since been deactivated by an admin — same defensive
      // pattern as the zone dropdown in rider_profile_screen.dart.
      _vehicleType = types.containsKey(storedType) ? storedType : (types.keys.isNotEmpty ? types.keys.first : storedType);
      _kycStatus = riderDoc.data()?['kycStatus'] as String?;
      _kycRejectionReason = riderDoc.data()?['kycRejectionReason'] as String?;
      _isLoadingVehicleType = false;
    });
  }

  // Camera-only, deliberately — a live photo of the physical document is a
  // (weak but real) signal against uploading someone else's scanned/stolen
  // documents, which a gallery picker would make trivial.
  Future<void> _pickImage(String docId) async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked == null) return;
    setState(() => _activeDocs[docId]!.photo = File(picked.path));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_activeDocs.values.any((doc) => doc.photo == null)) {
      setState(() => _errorText = l10n.takeAllPhotosError);
      return;
    }

    setState(() {
      _isUploading = true;
      _errorText = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final storage = FirebaseStorage.instance;

      // Force a fresh ID token before uploading — the Storage SDK doesn't
      // refresh/attach tokens as eagerly as Auth/Firestore do, which caused
      // uploads to fail with storage/unauthorized on iOS despite a
      // perfectly valid session and correct rules (confirmed via a direct
      // authenticated REST call against the emulator).
      await FirebaseAuth.instance.currentUser?.getIdToken(true);

      final kycDocs = <String, String>{};
      for (final doc in _activeDocs.values) {
        final ref = storage.ref('kyc_documents/$uid/${doc.fileName}');
        await ref.putFile(doc.photo!);
        kycDocs[doc.key] = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('riders').doc(uid).update({
        'vehicleType': _vehicleType,
        'kycDocs': kycDocs,
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.docsSubmittedSnackbarMessage)),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorText = l10n.uploadFailedError;
      });
    }
  }

  Widget _photoTile(String label, File? photo, VoidCallback onTap, {required int index}) {
    final l10n = AppLocalizations.of(context)!;
    final captured = photo != null;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: captured ? AppColors.successTintAlt : AppColors.surfaceAlt,
        border: Border.all(color: captured ? AppColors.successBorder : AppColors.borderDashed),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: captured ? AppColors.success : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: captured ? null : Border.all(color: AppColors.borderDashed),
            ),
            child: captured
                ? Image.file(photo, fit: BoxFit.cover)
                : const Icon(Icons.camera_alt_outlined, color: AppColors.mutedLight),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.heading(size: 14)),
                const SizedBox(height: 2),
                Text(
                  captured ? l10n.docCapturedLabel : l10n.docTapToCaptureLabel,
                  style: AppTypography.caption(color: captured ? AppColors.successText : AppColors.mutedLight),
                ),
              ],
            ),
          ),
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.surfaceAlt, shape: BoxShape.circle),
            child: Text('$index', style: AppTypography.caption(size: 11, color: AppColors.muted)),
          ),
          const SizedBox(width: 4),
          IconButton(onPressed: onTap, icon: Icon(captured ? Icons.check_circle : Icons.camera_alt, color: captured ? AppColors.success : AppColors.accent)),
        ],
      ),
    );
  }

  // Matches against both doc id and English name — an admin-created vehicle
  // type's doc id isn't guaranteed to contain these substrings (matches the
  // same fix already applied in customer_app's create_request_screen.dart /
  // bid_list_screen.dart).
  IconData _vehicleTypeIcon(String typeId) {
    final id = '$typeId ${_vehicleTypes[typeId]?['name'] ?? ''}'.toLowerCase();
    // "motorbike" contains "bike" — excluding "motor" keeps that from
    // matching the bicycle branch (the admin dashboard's default vehicle
    // type doc id for motorcycles is literally "motorbike").
    if (id.contains('bicycle') || (id.contains('bike') && !id.contains('motor'))) return Icons.pedal_bike;
    if (id.contains('moto') || id.contains('scooter')) return Icons.two_wheeler;
    if (id.contains('tuk') || id.contains('rickshaw')) return Icons.electric_rickshaw;
    if (id.contains('truck') || id.contains('lorry')) return Icons.local_shipping;
    if (id.contains('car')) return Icons.directions_car;
    return Icons.local_shipping_outlined;
  }

  // Real photo art for tuk-tuk only, the original Twemoji glyphs for
  // everything else (matches customer_app's vehicle selector).
  Widget? _vehicleTypeChipIcon(String typeId, {required double size}) {
    final id = '$typeId ${_vehicleTypes[typeId]?['name'] ?? ''}'.toLowerCase();
    if (id.contains('tuk') || id.contains('rickshaw')) {
      return Image.asset('assets/vehicles/tuktuk.png', width: size, height: size, fit: BoxFit.contain);
    }
    if (id.contains('bicycle') || (id.contains('bike') && !id.contains('motor'))) {
      return SvgPicture.asset('assets/vehicles/bicycle.svg', width: size, height: size);
    }
    if (id.contains('moto') || id.contains('scooter')) {
      return SvgPicture.asset('assets/vehicles/motorcycle.svg', width: size, height: size);
    }
    if (id.contains('truck') || id.contains('lorry')) {
      return SvgPicture.asset('assets/vehicles/truck.svg', width: size, height: size);
    }
    return null;
  }

  Widget _buildVehicleTypeChips() {
    final entries = _vehicleTypes.entries.toList();
    return Row(
      children: entries.asMap().entries.map((indexed) {
        final index = indexed.key;
        final id = indexed.value.key;
        final data = indexed.value.value;
        final selected = _vehicleType == id;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index != entries.length - 1 ? 8 : 0),
            child: InkWell(
              onTap: () => setState(() => _vehicleType = id),
              borderRadius: BorderRadius.circular(9),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accentTint : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: selected ? AppColors.accent : AppColors.border, width: selected ? 1.5 : 1),
                ),
                child: Column(
                  children: [
                    _vehicleTypeChipIcon(id, size: 20) ??
                        Icon(_vehicleTypeIcon(id), size: 20, color: selected ? AppColors.accent : AppColors.bodyText),
                    const SizedBox(height: 6),
                    Text(
                      localizedVehicleTypeName(context, data),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(size: 11, color: selected ? AppColors.accent : AppColors.bodyText),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isBicycle = _isPersonalIdOnly;
    final allCaptured = _activeDocs.values.every((doc) => doc.photo != null);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.kycVerificationTitle)),
      body: _isLoadingVehicleType
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_kycStatus != null) ...[
                    _KycStatusPanel(status: _kycStatus!, rejectionReason: _kycRejectionReason),
                    const SizedBox(height: 20),
                  ],
                  if (_kycStatus != null) ...[
                    _StatusSegments(status: _kycStatus!),
                    const SizedBox(height: 20),
                  ],
                  Text(l10n.kycInstructions),
                  const SizedBox(height: 16),
                  Text(l10n.vehicleTypeLabel, style: AppTypography.label(color: AppColors.mutedLight)),
                  const SizedBox(height: 8),
                  _buildVehicleTypeChips(),
                  const SizedBox(height: 12),
                  Text(
                    isBicycle ? l10n.kycDocNoteBicycle : l10n.kycDocNoteOther,
                    style: AppTypography.caption(color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),
                  if (isBicycle)
                    _photoTile(
                      l10n.personalIdLabel,
                      _bicycleDocs['personalId']!.photo,
                      () => _pickImage('personalId'),
                      index: 1,
                    )
                  else ...[
                    _photoTile(l10n.licenseFrontLabel, _motorizedDocs['licenseFront']!.photo,
                        () => _pickImage('licenseFront'), index: 1),
                    const SizedBox(height: 12),
                    _photoTile(l10n.licenseBackLabel, _motorizedDocs['licenseBack']!.photo,
                        () => _pickImage('licenseBack'), index: 2),
                    const SizedBox(height: 12),
                    _photoTile(l10n.vehicleRegFrontLabel, _motorizedDocs['registrationFront']!.photo,
                        () => _pickImage('registrationFront'), index: 3),
                    const SizedBox(height: 12),
                    _photoTile(l10n.vehicleRegBackLabel, _motorizedDocs['registrationBack']!.photo,
                        () => _pickImage('registrationBack'), index: 4),
                  ],
                  if (_errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(_errorText!, style: const TextStyle(color: AppColors.danger)),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: (_isUploading || !allCaptured) ? null : _submit,
                    child: _isUploading
                        ? const SizedBox(
                            width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(l10n.submitForReviewButton),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Tri-state KYC status panel — pending/approved/rejected each get their own
/// icon, border, fill, and title per the design handoff.
class _KycStatusPanel extends StatelessWidget {
  final String status;
  final String? rejectionReason;
  const _KycStatusPanel({required this.status, this.rejectionReason});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    late final IconData icon;
    late final Color color;
    late final Color border;
    late final Color fill;
    late final String title;
    late final String body;

    switch (status) {
      case 'approved':
        icon = Icons.check_circle;
        color = AppColors.success;
        border = AppColors.successBorder;
        fill = AppColors.successTintAlt;
        title = l10n.kycApprovedTitle;
        body = l10n.kycApprovedBody;
      case 'rejected':
        icon = Icons.error;
        color = AppColors.danger;
        border = AppColors.dangerBorder;
        fill = AppColors.dangerTintAlt;
        title = l10n.kycRejectedTitle;
        body = rejectionReason ?? l10n.kycRejectedBody;
      default:
        icon = Icons.hourglass_top;
        color = AppColors.accent;
        border = AppColors.accentBorder;
        fill = AppColors.accentTint;
        title = l10n.kycPendingTitle;
        body = l10n.kycPendingBody;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: fill, border: Border.all(color: border), borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.heading(size: 15, color: color)),
                const SizedBox(height: 4),
                Text(body, style: AppTypography.body(size: 13, color: AppColors.bodyText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A read-only segmented indicator of which of the three KYC states applies
/// — status itself is server-controlled (admin review), so this is display
/// only, not a tab switcher.
class _StatusSegments extends StatelessWidget {
  final String status;
  const _StatusSegments({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final segments = [
      ('pending', l10n.kycPendingTitle),
      ('approved', l10n.kycApprovedTitle),
      ('rejected', l10n.kycRejectedTitle),
    ];
    final normalizedStatus = status == 'approved' || status == 'rejected' ? status : 'pending';
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(11)),
      child: Row(
        children: segments.map((segment) {
          final (value, label) = segment;
          final selected = value == normalizedStatus;
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: selected ? AppShadows.card : null,
              ),
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(size: 12.5, color: selected ? AppColors.ink : AppColors.mutedLight),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
