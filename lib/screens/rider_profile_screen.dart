import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_upload.dart';
import '../services/callable_function.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../utils/localized_zone_name.dart';
import '../utils/localized_vehicle_type.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_radii.dart';
import 'faq_screen.dart';
import 'contact_support_screen.dart';
import 'phone_login_screen.dart';
import 'wallet_screen.dart';
import 'kyc_upload_screen.dart';

class RiderProfileScreen extends StatefulWidget {
  const RiderProfileScreen({super.key});

  @override
  State<RiderProfileScreen> createState() => _RiderProfileScreenState();
}

class _RiderProfileScreenState extends State<RiderProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _picker = ImagePicker();
  bool _isUploadingPhoto = false;
  String _vehicleType = 'motorbike';
  String? _approvedVehicleType;
  String? _kycStatus;
  // Keyed by vehicleTypes doc id — admin-managed, same pattern as _zoneData.
  Map<String, Map<String, dynamic>> _vehicleTypes = {};
  String? _activeZone;
  List<String> _zoneNames = [];
  // Keyed by zone name (same casing as _zoneNames) — used to warn if the
  // selected vehicle type isn't permitted in the selected zone, mirroring
  // the same allowedVehicleTypes check submitBid.js already enforces
  // server-side (this is just an earlier, friendlier warning).
  Map<String, Map<String, dynamic>> _zoneData = {};
  bool _isLoading = true;
  bool _isSavingField = false;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    final riderDoc = await FirebaseFirestore.instance.collection('riders').doc(_uid).get();
    final zonesSnap = await FirebaseFirestore.instance.collection('zones').where('active', isEqualTo: true).get();
    final vehicleTypesSnap =
        await FirebaseFirestore.instance.collection('vehicleTypes').where('active', isEqualTo: true).get();

    _nameController.text = userDoc.data()?['name'] as String? ?? '';
    _emailController.text = userDoc.data()?['email'] as String? ?? '';
    _vehicleTypes = {for (final d in vehicleTypesSnap.docs) d.id: d.data()};
    final storedVehicleType = riderDoc.data()?['vehicleType'] as String? ?? 'motorbike';
    // Fall back to whichever type is actually available if the rider's
    // stored type has since been deactivated by an admin — same defensive
    // pattern as _activeZone below.
    _vehicleType = _vehicleTypes.containsKey(storedVehicleType)
        ? storedVehicleType
        : (_vehicleTypes.keys.isNotEmpty ? _vehicleTypes.keys.first : storedVehicleType);
    _approvedVehicleType = riderDoc.data()?['approvedVehicleType'] as String?;
    _kycStatus = riderDoc.data()?['kycStatus'] as String?;
    _zoneNames = zonesSnap.docs.map((d) => d.data()['name'] as String).toList();
    _zoneData = {for (final d in zonesSnap.docs) d.data()['name'] as String: d.data()};

    final storedZone = riderDoc.data()?['activeZone'] as String?;
    // activeZone is stored lowercased; match it back to the properly-cased
    // name from the zones collection so the picker selection lines up.
    _activeZone = _zoneNames.firstWhere(
      (name) => name.toLowerCase() == storedZone?.toLowerCase(),
      orElse: () => _zoneNames.isNotEmpty ? _zoneNames.first : '',
    );
    if (_activeZone!.isEmpty) _activeZone = null;

    if (mounted) setState(() => _isLoading = false);
  }

  bool _isZoneVehicleMismatch(String zone, String vehicleType) {
    final allowed = (_zoneData[zone]?['allowedVehicleTypes'] as List?)?.cast<String>();
    // Missing zone data or an unset allowedVehicleTypes field means "all
    // types allowed" — same fallback submitBid.js uses server-side.
    return allowed != null && !allowed.contains(vehicleType);
  }

  Future<void> _changeVehicleType(String newType) async {
    if (newType == _vehicleType) return;
    Navigator.pop(context); // close the picker sheet first

    // Changing to a vehicle type different from the one your KYC was
    // approved for requires new documents — warn before doing it, since
    // it also takes the rider offline until an admin re-reviews.
    final isChangingApprovedVehicle = _approvedVehicleType != null && _approvedVehicleType != newType;
    if (isChangingApprovedVehicle) {
      final l10n = AppLocalizations.of(context)!;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.newVehicleVerificationTitle),
          content: Text(l10n.newVehicleVerificationContent),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancelButton)),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.continueButton)),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    if (_activeZone != null && _isZoneVehicleMismatch(_activeZone!, newType)) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.vehicleZoneMismatchMessage),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancelButton))],
        ),
      );
      return;
    }

    setState(() => _isSavingField = true);
    try {
      final result = await callFunction('changeVehicleType', {'newVehicleType': newType});
      final requiresReverification = result.data['requiresReverification'] == true;
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(requiresReverification ? l10n.vehicleUpdatedReverificationMessage : l10n.profileUpdated)),
      );
      await _loadProfile();
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() => _isSavingField = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? AppLocalizations.of(context)!.couldNotUpdateVehicleError)),
      );
    }
  }

  Future<void> _changeZone(String newZone) async {
    Navigator.pop(context); // close the picker sheet first
    if (newZone == _activeZone) return;

    if (_isZoneVehicleMismatch(newZone, _vehicleType)) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.vehicleZoneMismatchMessage),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancelButton))],
        ),
      );
      return;
    }

    setState(() => _isSavingField = true);
    await FirebaseFirestore.instance.collection('riders').doc(_uid).update({'activeZone': newZone.toLowerCase()});
    if (!mounted) return;
    setState(() {
      _activeZone = newZone;
      _isSavingField = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdated)),
    );
  }

  // Name is intentionally not editable here — it's set by the admin from
  // the KYC review tab (matching it against the rider's submitted ID),
  // rather than self-reported. This dialog now only handles email.
  Future<void> _editEmail() async {
    final l10n = AppLocalizations.of(context)!;
    final emailController = TextEditingController(text: _emailController.text);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.emailLabel),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(labelText: l10n.emailLabel),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancelButton)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.saveChangesButton)),
        ],
      ),
    );
    if (saved != true || !mounted) return;

    final email = emailController.text.trim();
    if (email.isNotEmpty && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invalidEmailError)));
      return;
    }
    setState(() => _isSavingField = true);
    await FirebaseFirestore.instance.collection('users').doc(_uid).update({
      'email': email.isEmpty ? null : email,
    });
    if (!mounted) return;
    setState(() {
      _emailController.text = email;
      _isSavingField = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileUpdated)));
  }

  // Photo is required once, at signup (profile_setup_screen.dart), but
  // riders should be able to change it later — this reuses the exact same
  // storage path, so a new upload simply replaces the old photo.
  Future<void> _editPhoto() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.takePhotoOption),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.chooseFromGalleryOption),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked == null || !mounted) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final photoUrl =
          await uploadToStorage(file: File(picked.path), storagePath: 'profile_pictures/$_uid/photo.jpg');
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({'photoUrl': photoUrl});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileUpdated)));
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancelButton)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.logoutButton)),
        ],
      ),
    );
    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    // Not popUntil(isFirst) — that only works once SplashScreen's own
    // authStateChanges() listener has already rebuilt the root route to show
    // PhoneLoginScreen, and that rebuild isn't reliably reflected on screen
    // until the next full repaint (e.g. backgrounding and reopening the app
    // forces one; simply popping back to the stale root route doesn't).
    // Navigating to a known destination directly sidesteps that timing
    // entirely.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
      (route) => false,
    );
  }

  // Also persisted to Firestore (not just the local pref) — Cloud Functions
  // read users/{uid}.languagePreference to send a single-language push
  // instead of a bilingual one (see localizeNotification.js). Best-effort,
  // not awaited — a slow/failed write shouldn't hold up switching the
  // in-app language, which localeController.setLocale already applies
  // synchronously from local prefs.
  void _setLanguage(Locale? locale) {
    localeController.setLocale(locale);
    FirebaseFirestore.instance.collection('users').doc(_uid).update({
      'languagePreference': locale?.languageCode,
    });
  }

  void _showOptionPicker({
    required String title,
    required List<MapEntry<String, String>> options, // value -> display label
    required String? selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: AppTypography.heading(size: 16)),
            ),
            ...options.map((entry) => RadioListTile<String>(
                  title: Text(entry.value),
                  value: entry.key,
                  groupValue: selectedValue,
                  activeColor: AppColors.accent,
                  onChanged: (v) => onSelected(v!),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // The header below paints full-bleed AppColors.ink (near-black) behind
    // the status bar — nothing elsewhere in this app ever sets the status
    // bar's icon brightness, so it silently kept whatever the previous
    // screen left it at (usually dark icons), making the clock/notification
    // /signal icons invisible against black. AnnotatedRegion switches to
    // light icons while this screen is on top and restores the previous
    // region automatically when it's popped.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isLoading ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildHeader(l10n),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadii.cardRadius,
                          border: Border.all(color: AppColors.borderAlt),
                        ),
                        child: Column(
                          children: [
                            _settingsRow(
                              label: l10n.vehicleTypeLabel,
                              value: _vehicleTypes[_vehicleType] != null
                                  ? localizedVehicleTypeName(context, _vehicleTypes[_vehicleType]!)
                                  : _vehicleType,
                              onTap: () => _showOptionPicker(
                                title: l10n.vehicleTypeLabel,
                                selectedValue: _vehicleType,
                                options: _vehicleTypes.entries
                                    .map((e) => MapEntry(e.key, localizedVehicleTypeName(context, e.value)))
                                    .toList(),
                                onSelected: _changeVehicleType,
                              ),
                            ),
                            if (_zoneNames.isNotEmpty)
                              _settingsRow(
                                label: l10n.operatingZoneLabel,
                                value: _activeZone != null
                                    ? localizedZoneName(context, _zoneData[_activeZone] ?? {'name': _activeZone})
                                    : '—',
                                onTap: () => _showOptionPicker(
                                  title: l10n.operatingZoneLabel,
                                  selectedValue: _activeZone,
                                  options: _zoneNames
                                      .map((name) => MapEntry(name, localizedZoneName(context, _zoneData[name] ?? {'name': name})))
                                      .toList(),
                                  onSelected: _changeZone,
                                ),
                              ),
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance.collection('users').doc(_uid).snapshots(),
                              builder: (context, snapshot) {
                                final balance = snapshot.hasData && snapshot.data!.exists
                                    ? ((snapshot.data!.data() as Map<String, dynamic>)['walletBalance'] as num?)?.toDouble() ?? 0
                                    : 0.0;
                                return _settingsRow(
                                  label: l10n.commissionBalanceTooltip,
                                  value: balance.toStringAsFixed(0),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
                                );
                              },
                            ),
                            _settingsRow(
                              label: l10n.kycVerificationTitle,
                              value: _kycStatusLabel(l10n),
                              valueColor: _kycStatusColor(),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KycUploadScreen())),
                            ),
                            _settingsRow(
                              label: l10n.emailLabel,
                              value: _emailController.text.isEmpty ? '—' : _emailController.text,
                              onTap: _editEmail,
                            ),
                            AnimatedBuilder(
                              animation: localeController,
                              builder: (context, _) {
                                final current = localeController.overrideLocale?.languageCode;
                                final label = switch (current) {
                                  'en' => l10n.languageEnglish,
                                  'ar' => l10n.languageArabic,
                                  _ => l10n.languageSystemDefault,
                                };
                                return _settingsRow(
                                  label: l10n.languageLabel,
                                  value: label,
                                  onTap: () => _showOptionPicker(
                                    title: l10n.languageLabel,
                                    selectedValue: current,
                                    options: [
                                      MapEntry('system', l10n.languageSystemDefault),
                                      MapEntry('en', l10n.languageEnglish),
                                      MapEntry('ar', l10n.languageArabic),
                                    ],
                                    onSelected: (v) {
                                      Navigator.pop(context);
                                      _setLanguage(v == 'system' ? null : Locale(v));
                                    },
                                  ),
                                );
                              },
                            ),
                            _settingsRow(
                              label: l10n.faqButton,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
                            ),
                            _settingsRow(
                              label: l10n.contactSupportButton,
                              onTap: () =>
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactSupportScreen())),
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _logout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.dangerBorder),
                        ),
                        child: Text(l10n.logoutButton),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

  String _kycStatusLabel(AppLocalizations l10n) => switch (_kycStatus) {
        'approved' => l10n.kycApprovedTitle,
        'rejected' => l10n.kycRejectedTitle,
        _ => l10n.kycPendingTitle,
      };

  Color _kycStatusColor() => switch (_kycStatus) {
        'approved' => AppColors.success,
        'rejected' => AppColors.danger,
        _ => AppColors.accent,
      };

  Widget _settingsRow({required String label, String? value, Color? valueColor, required VoidCallback onTap, bool isLast = false}) {
    return InkWell(
      onTap: _isSavingField ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTypography.body(size: 14.5, color: AppColors.ink).copyWith(fontWeight: FontWeight.w600))),
            if (value != null) ...[
              Text(value, style: AppTypography.body(size: 14, color: valueColor ?? AppColors.mutedLight)),
              const SizedBox(width: 6),
            ],
            Icon(
              Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left : Icons.chevron_right,
              size: 18,
              color: AppColors.mutedLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(_uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.hasData && snapshot.data!.exists ? snapshot.data!.data() as Map<String, dynamic> : const {};
        final name = (data['name'] as String?) ?? _nameController.text;
        final rating = (data['rating'] as num?)?.toDouble() ?? 0;
        final ratingCount = (data['ratingCount'] as num?)?.toInt() ?? 0;
        final photoUrl = data['photoUrl'] as String?;
        return Container(
          width: double.infinity,
          color: AppColors.ink,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.maybePop(context),
                      borderRadius: BorderRadius.circular(21),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Directionality.of(context) == TextDirection.rtl ? Icons.arrow_forward : Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(l10n.profileTitle, style: AppTypography.title(size: 20, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _isUploadingPhoto ? null : _editPhoto,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 31,
                            backgroundColor: AppColors.accent,
                            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                            child: _isUploadingPhoto
                                ? const SizedBox(
                                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : photoUrl == null
                                    ? Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22),
                                      )
                                    : null,
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                                border: Border.fromBorderSide(BorderSide(color: AppColors.ink, width: 2)),
                              ),
                              child: const Icon(Icons.camera_alt, size: 11, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: AppTypography.heading(size: 18, color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  ratingCount > 0 ? '★ ${rating.toStringAsFixed(1)}' : l10n.newRiderLabel,
                                  style: const TextStyle(
                                    fontFamily: AppTypography.monoFamily,
                                    fontSize: 13,
                                    color: AppColors.ratingOnDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _kycStatusColor().withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${_kycStatusLabel(l10n)} · ${_vehicleTypes[_vehicleType] != null ? localizedVehicleTypeName(context, _vehicleTypes[_vehicleType]!) : _vehicleType}',
                                  style: AppTypography.label(size: 11, color: _kycStatusColor()),
                                ),
                              ),
                            ],
                          ),
                        ],
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
}
