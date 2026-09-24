import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import '../models/delivery_request.dart';
import '../services/mapbox_eta_service.dart';
import '../services/sound_service.dart';
import '../widgets/locate_me_button.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'bid_submit_screen.dart';
import 'active_delivery_screen.dart';
import 'wallet_screen.dart';
import 'earnings_screen.dart';
import 'rider_profile_screen.dart';
import 'kyc_upload_screen.dart';
import 'rate_customer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isTogglingOnline = false;
  // Rising-edge tracker for "I now have an active delivery I didn't have a
  // moment ago" — i.e. one of my bids just got accepted. Driven directly by
  // this screen's own live query below rather than the 'bid_accepted' FCM
  // push, which only fires while the app happens to be foregrounded at the
  // exact moment it arrives (same reliability fix already applied to the
  // customer app's bid-received/order-completed sounds).
  bool _hadActiveRequest = false;
  // Mirrors the live riderSnap-derived value purely so the timer below can
  // skip its work while offline without needing setState of its own — not
  // used anywhere UI-facing (see the "isOnline" local in build() for that).
  bool _isOnlineCache = false;
  StreamSubscription<Position>? _positionSubscription;
  GeoPoint? _myLastKnownLocation;
  mb.MapboxMap? _homeMapboxMap;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  // The backend flips an expired request's status away from "open" via a
  // scheduled function, but that can lag by up to a minute (and doesn't run
  // at all against the local emulator suite). Ticking a rebuild lets the
  // client-side biddingClosesAt filter below drop expired requests from the
  // feed without waiting on the backend. Every 5s (not every 1s) — bidding
  // windows are 60s, so second-level precision isn't needed, and this was
  // previously forcing a full-screen rebuild (three nested StreamBuilders,
  // plus a fresh ETA fetch per card) every single second, which is what made
  // the app feel slow. Also skipped entirely while offline, since the
  // request feed isn't even shown then.
  Timer? _expiryTicker;

  // Cache the ETA *Future itself* per request, not just its resolved value
  // (fetchEtaMinutesCached already caches the value) — otherwise calling it
  // inline in build() hands FutureBuilder a brand-new Future on every
  // rebuild, which briefly flashes the ETA text away and schedules pointless
  // microtasks even when the cached value comes back instantly. Cleared on
  // each expiry tick so ETAs still refresh periodically.
  final Map<String, Future<int?>> _etaFutures = {};

  // Vehicle types rarely change, so a one-time fetch (not a live stream) is
  // enough here — just needed to know whether this rider's vehicleType
  // requires a single personal-ID document or the full license+registration
  // set (see kyc_upload_screen.dart), for the KYC banner text below.
  Map<String, Map<String, dynamic>> _vehicleTypesCache = {};

  // Guards against re-pushing RateCustomerScreen for the same request every
  // time this StreamBuilder rebuilds (e.g. from an unrelated field changing)
  // while the rider is still on that screen — see _buildRatingPrompt below.
  String? _ratingPromptedForRequestId;

  // null until the open-requests feed's first snapshot — that first batch
  // is just "whatever's already open right now", not new arrivals, so it
  // must not play a sound. Every snapshot after that compares against this
  // to find genuinely new request ids.
  Set<String>? _seenRequestIds;

  @override
  void initState() {
    super.initState();
    _loadVehicleTypes();
    _expiryTicker = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_isOnlineCache) return;
      setState(() => _etaFutures.clear());
    });
  }

  Future<void> _loadVehicleTypes() async {
    final snap = await FirebaseFirestore.instance.collection('vehicleTypes').get();
    if (!mounted) return;
    setState(() => _vehicleTypesCache = {for (final d in snap.docs) d.id: d.data()});
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _expiryTicker?.cancel();
    super.dispose();
  }

  Future<void> _toggleOnline(bool goOnline) async {
    // This screen stays mounted underneath the profile screen while it's
    // pushed on top, so signing out there can still leave this method
    // reachable (e.g. via the auto-offline callback below reacting to the
    // now-permission-denied KYC/balance streams) — nothing to toggle for a
    // signed-out user, and writing to riders/{uid} at that point would just
    // throw.
    if (FirebaseAuth.instance.currentUser == null) return;

    setState(() => _isTogglingOnline = true);

    if (goOnline) {
      // Hard block: re-check both KYC status and balance fresh (not from a
      // possibly-stale stream snapshot) right before allowing a rider online.
      final results = await Future.wait([
        FirebaseFirestore.instance.collection('users').doc(_uid).get(),
        FirebaseFirestore.instance.collection('riders').doc(_uid).get(),
      ]);
      final userSnap = results[0];
      final riderSnap = results[1];

      final kycStatus = riderSnap.data()?['kycStatus'] as String?;
      if (kycStatus != 'approved') {
        setState(() => _isTogglingOnline = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.kycApprovalPendingError)),
          );
        }
        return;
      }

      final balance = (userSnap.data()?['walletBalance'] as num?)?.toDouble() ?? 0;
      if (balance <= 0) {
        setState(() => _isTogglingOnline = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.balanceDepletedError)),
          );
        }
        return;
      }

      // Defense in depth — the banner in build() already blocks this case,
      // but re-check fresh here too in case the switch is somehow reached
      // in a stale state.
      final vehicleType = riderSnap.data()?['vehicleType'] as String? ?? 'motorbike';
      final activeZone = riderSnap.data()?['activeZone'] as String? ?? 'atbara';
      final zonesSnap = await FirebaseFirestore.instance.collection('zones').get();
      for (final doc in zonesSnap.docs) {
        final data = doc.data();
        if ((data['name'] as String? ?? '').toLowerCase() != activeZone.toLowerCase()) continue;
        final allowed = (data['allowedVehicleTypes'] as List?)?.cast<String>();
        if (allowed != null && !allowed.contains(vehicleType)) {
          setState(() => _isTogglingOnline = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.vehicleZoneMismatchMessage)),
            );
          }
          return;
        }
        break;
      }

      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) {
        setState(() => _isTogglingOnline = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.locationPermissionRequiredError)),
          );
        }
        return;
      }
      _startLocationUpdates();
    } else {
      _positionSubscription?.cancel();
      _positionSubscription = null;
    }

    try {
      await FirebaseFirestore.instance.collection('riders').doc(_uid).update({'isOnline': goOnline});
    } catch (_) {
      // Most likely the user signed out in the moment between the guard
      // above and this write actually landing — nothing more to do here.
      return;
    }

    if (!mounted) return;
    // Not tracking the new online/offline value in local state here — the
    // riders/{uid} StreamBuilder in build() is the single source of truth
    // for it now (see the "isOnline" field pulled from riderSnap below).
    // This used to be a plain local bool that only ever changed via this
    // method, which meant it silently went stale — and back to its initial
    // `false` — the instant this State object was recreated for any reason
    // (most commonly Android reclaiming the app in the background between
    // deliveries), even though the backend still had the rider marked
    // online the whole time.
    setState(() => _isTogglingOnline = false);
  }

  Future<bool> _ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  void _startLocationUpdates() {
    const settings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 20);
    _positionSubscription = Geolocator.getPositionStream(locationSettings: settings).listen((position) {
      _myLastKnownLocation = GeoPoint(position.latitude, position.longitude);
      FirebaseFirestore.instance.collection('riders').doc(_uid).update({
        'currentLocation': GeoPoint(position.latitude, position.longitude),
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Checked first, before any of the normal home-screen chrome (header,
    // map strip, KYC/balance banners) — an active delivery takes over the
    // whole screen per the design, not just the space left over inside
    // this screen's own layout. Previously ActiveDeliveryScreen was
    // embedded underneath the header and map strip, which is why the rider
    // saw those on top of it instead of the clean full-screen view.
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('delivery_requests')
          .where('assignedRiderId', isEqualTo: _uid)
          .where('status', whereIn: ['assigned', 'picked_up'])
          .limit(1)
          .snapshots(),
      builder: (context, activeSnap) {
        if (activeSnap.hasData && activeSnap.data!.docs.isNotEmpty) {
          if (!_hadActiveRequest) {
            _hadActiveRequest = true;
            SoundService.bidAccepted();
          }
          final activeRequest = DeliveryRequest.fromFirestore(activeSnap.data!.docs.first);
          return _watchForUnratedDelivery(child: ActiveDeliveryScreen(request: activeRequest));
        }
        _hadActiveRequest = false;
        return _buildHomeScaffold(context, l10n);
      },
    );
  }

  Widget _buildHomeScaffold(BuildContext context, AppLocalizations l10n) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(_uid).snapshots(),
      builder: (context, userSnap) {
        final userData = userSnap.hasData && userSnap.data!.exists
            ? userSnap.data!.data() as Map<String, dynamic>
            : const <String, dynamic>{};
        final balance = (userData['walletBalance'] as num?)?.toDouble() ?? 0;
        final riderName = userData['name'] as String? ?? '';
        final riderRating = (userData['rating'] as num?)?.toDouble() ?? 0;
        final riderRatingCount = (userData['ratingCount'] as num?)?.toInt() ?? 0;
        final riderPhotoUrl = userData['photoUrl'] as String?;

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('riders').doc(_uid).snapshots(),
          builder: (context, riderSnap) {
            final kycStatus = riderSnap.hasData && riderSnap.data!.exists
                ? (riderSnap.data!.data() as Map<String, dynamic>)['kycStatus'] as String?
                : null;
            final kycDocs = riderSnap.hasData && riderSnap.data!.exists
                ? (riderSnap.data!.data() as Map<String, dynamic>)['kycDocs'] as Map<String, dynamic>?
                : null;
            final vehicleType = riderSnap.hasData && riderSnap.data!.exists
                ? (riderSnap.data!.data() as Map<String, dynamic>)['vehicleType'] as String? ?? 'motorbike'
                : 'motorbike';
            // personalIdOnly types (e.g. bicycle) only need a personal ID;
            // others need the full license + registration set — see
            // kyc_upload_screen.dart and vehicleTypes/{typeId}.kycDocType.
            final isPersonalIdOnly = _vehicleTypesCache[vehicleType]?['kycDocType'] == 'personalIdOnly';
            final hasSubmittedDocs = kycDocs != null &&
                (isPersonalIdOnly ? kycDocs['personalIdUrl'] != null : kycDocs['licenseFrontUrl'] != null);
            final kycRejectionReason = riderSnap.hasData && riderSnap.data!.exists
                ? (riderSnap.data!.data() as Map<String, dynamic>)['kycRejectionReason'] as String?
                : null;
            final isKycPending = kycStatus != 'approved';
            final isBalanceDepleted = balance <= 0;
            final activeZone = riderSnap.hasData && riderSnap.data!.exists
                ? (riderSnap.data!.data() as Map<String, dynamic>)['activeZone'] as String? ?? 'atbara'
                : 'atbara';
            // Derived from the live doc, not a locally-toggled field — see
            // _toggleOnline's comment for why that used to silently desync
            // from the backend.
            final isOnline = riderSnap.hasData && riderSnap.data!.exists
                ? (riderSnap.data!.data() as Map<String, dynamic>)['isOnline'] as bool? ?? false
                : false;
            _isOnlineCache = isOnline;

            // Resume location tracking if this rider is already marked
            // online but this State object is fresh (most commonly: the app
            // was killed and relaunched, or backgrounded and reclaimed by
            // Android, while still online) — otherwise the UI now correctly
            // shows "Online" (fixed above) but nothing is actually updating
            // riders/{uid}.currentLocation for customers tracking this rider.
            if (isOnline && _positionSubscription == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!mounted) return;
                if (await _ensureLocationPermission()) _startLocationUpdates();
              });
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('zones').snapshots(),
              builder: (context, zonesSnap) {
                // Missing zone data or an unset allowedVehicleTypes field
                // means "all types allowed" — same fallback submitBid.js
                // uses server-side; this is just an earlier, client-side warning.
                bool isVehicleZoneMismatch = false;
                GeoPoint? zoneCenter;
                if (zonesSnap.hasData) {
                  for (final doc in zonesSnap.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    if ((data['name'] as String? ?? '').toLowerCase() != activeZone.toLowerCase()) continue;
                    final allowed = (data['allowedVehicleTypes'] as List?)?.cast<String>();
                    if (allowed != null && !allowed.contains(vehicleType)) {
                      isVehicleZoneMismatch = true;
                    }
                    final centerLat = (data['centerLat'] as num?)?.toDouble();
                    final centerLng = (data['centerLng'] as num?)?.toDouble();
                    if (centerLat != null && centerLng != null) {
                      zoneCenter = GeoPoint(centerLat, centerLng);
                    }
                    break;
                  }
                }

                final isBlocked = isKycPending || isBalanceDepleted || isVehicleZoneMismatch;

                // If any condition just became true while this rider was
                // online, force them offline so the UI and backend agree.
                if (isBlocked && isOnline) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _toggleOnline(false);
                  });
                }

                return _buildScaffold(
                  l10n: l10n,
                  isOnline: isOnline,
                  isBlocked: isBlocked,
                  isKycPending: isKycPending,
                  isBalanceDepleted: isBalanceDepleted,
                  isVehicleZoneMismatch: isVehicleZoneMismatch,
                  kycStatus: kycStatus,
                  kycRejectionReason: kycRejectionReason,
                  hasSubmittedDocs: hasSubmittedDocs,
                  activeZone: activeZone,
                  zoneCenter: zoneCenter,
                  vehicleType: vehicleType,
                  riderName: riderName,
                  riderRating: riderRating,
                  riderRatingCount: riderRatingCount,
                  riderPhotoUrl: riderPhotoUrl,
                  balance: balance,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildScaffold({
    required AppLocalizations l10n,
    required bool isOnline,
    required bool isBlocked,
    required bool isKycPending,
    required bool isBalanceDepleted,
    required bool isVehicleZoneMismatch,
    required String? kycStatus,
    required String? kycRejectionReason,
    required bool hasSubmittedDocs,
    required String activeZone,
    required GeoPoint? zoneCenter,
    required String vehicleType,
    required String riderName,
    required double riderRating,
    required int riderRatingCount,
    required String? riderPhotoUrl,
    required double balance,
  }) {
    // The header below is always a full-bleed AppColors.ink block behind
    // the status bar, and nothing in this app ever sets the status bar's
    // icon brightness — it silently kept whatever the previous screen left
    // it at, making the clock/notification/signal icons invisible against
    // black. AnnotatedRegion switches to light icons while this screen is
    // on top and restores the previous region automatically once popped.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: _watchForUnratedDelivery(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
        children: [
          _buildInkHeader(
            l10n: l10n,
            isOnline: isOnline,
            isBlocked: isBlocked,
            riderName: riderName,
            riderRating: riderRating,
            riderRatingCount: riderRatingCount,
            riderPhotoUrl: riderPhotoUrl,
            balance: balance,
          ),
          _buildMapStrip(l10n, activeZone, zoneCenter),
          if (isKycPending)
            Container(
              width: double.infinity,
              color: AppColors.dangerTint,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(
                    kycStatus == 'rejected'
                        ? (kycRejectionReason != null && kycRejectionReason.trim().isNotEmpty
                            ? l10n.kycRejectedWithReasonMessage(kycRejectionReason)
                            : l10n.kycRejectedMessage)
                        : hasSubmittedDocs
                            ? l10n.kycDocsSubmittedMessage
                            : l10n.kycUploadPromptMessage,
                    textAlign: TextAlign.center,
                  ),
                  if (kycStatus != 'rejected' && !hasSubmittedDocs)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const KycUploadScreen()));
                        },
                        child: Text(l10n.uploadDocumentsButton),
                      ),
                    ),
                ],
              ),
            )
          else if (isBalanceDepleted)
            Container(
              width: double.infinity,
              color: AppColors.dangerTint,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l10n.balanceDepletedBannerMessage),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
                    },
                    child: Text(l10n.topUpButton),
                  ),
                ],
              ),
            )
          else if (isVehicleZoneMismatch)
            Container(
              width: double.infinity,
              color: AppColors.dangerTint,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l10n.vehicleZoneMismatchMessage),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RiderProfileScreen()));
                    },
                    child: Text(l10n.goToProfileButton),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildBody(activeZone, vehicleType, isOnline)),
        ],
        ),
      ),
      ),
    );
  }

  // Reactively pushes RateCustomerScreen the first time an unrated, just-
  // delivered request shows up for this rider — decoupled from the
  // completeDelivery() call itself, since that's a race with this same
  // stream update arriving first and tearing down whatever widget would
  // have pushed it inline (see active_delivery_screen.dart's _markDelivered,
  // which used to try that and lost the race often enough on real devices
  // that riders never saw the rating screen at all).
  Widget _watchForUnratedDelivery({required Widget child}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('delivery_requests')
          .where('assignedRiderId', isEqualTo: _uid)
          .where('status', isEqualTo: 'delivered')
          .where('ratedByRider', isEqualTo: false)
          .limit(1)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasData && snap.data!.docs.isNotEmpty) {
          final doc = snap.data!.docs.first;
          if (_ratingPromptedForRequestId != doc.id) {
            _ratingPromptedForRequestId = doc.id;
            final data = doc.data() as Map<String, dynamic>;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RateCustomerScreen(
                    requestId: doc.id,
                    collectedAmount: (data['agreedPrice'] as num?)?.toDouble(),
                  ),
                ),
              );
            });
          }
        }
        return child;
      },
    );
  }

  Widget _statTile({required IconData icon, required String label, required String value, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.caption(size: 11, color: AppColors.mutedOnDark)),
                    Text(value, style: AppTypography.amount(size: 15, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInkHeader({
    required AppLocalizations l10n,
    required bool isOnline,
    required bool isBlocked,
    required String riderName,
    required double riderRating,
    required int riderRatingCount,
    required String? riderPhotoUrl,
    required double balance,
  }) {
    return Container(
      width: double.infinity,
      color: AppColors.ink,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RiderProfileScreen())),
                  borderRadius: BorderRadius.circular(21),
                  child: CircleAvatar(
                    radius: 21,
                    backgroundColor: AppColors.accent,
                    backgroundImage: riderPhotoUrl != null ? NetworkImage(riderPhotoUrl) : null,
                    child: riderPhotoUrl == null
                        ? Text(
                            riderName.isNotEmpty ? riderName[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        riderName,
                        style: AppTypography.heading(size: 15, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          riderRatingCount > 0
                              ? l10n.riderRatingSummary(riderRating.toStringAsFixed(1), riderRatingCount)
                              : l10n.newRiderLabel,
                          style: const TextStyle(
                            fontFamily: AppTypography.monoFamily,
                            fontSize: 12,
                            color: AppColors.ratingOnDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _isTogglingOnline
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : InkWell(
                        onTap: isBlocked ? null : () => _toggleOnline(!isOnline),
                        borderRadius: BorderRadius.circular(11),
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isOnline ? AppColors.success : Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Text(
                            isOnline ? l10n.onlineLabel : l10n.offlineLabel,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('delivery_requests')
                      .where('assignedRiderId', isEqualTo: _uid)
                      .where('status', isEqualTo: 'delivered')
                      .where('deliveredAt', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                          DateTime.now().year, DateTime.now().month, DateTime.now().day)))
                      .snapshots(),
                  builder: (context, todaySnap) {
                    final todayEarnings = (todaySnap.data?.docs ?? []).fold<double>(
                      0,
                      (total, doc) => total + ((doc.data() as Map<String, dynamic>)['finalPrice'] as num? ?? 0),
                    );
                    return _statTile(
                      icon: Icons.receipt_long_outlined,
                      label: l10n.todayLabel,
                      value: todayEarnings.toStringAsFixed(0),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EarningsScreen())),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _statTile(
                  icon: Icons.account_balance_wallet_outlined,
                  label: l10n.balanceLabel,
                  value: balance.toStringAsFixed(0),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // A real live Mapbox view centered on the rider's own position. Safe to
  // always render now — this is only ever reached when there's no active
  // delivery (see build(), which returns ActiveDeliveryScreen full-screen
  // before this widget tree is built at all), so there's no risk of the
  // two-concurrent-Mapbox-surfaces black-screen bug documented in
  // customer_app's create_request_screen.dart.
  Widget _buildMapStrip(AppLocalizations l10n, String activeZone, GeoPoint? zoneCenter) {
    final center = _myLastKnownLocation ?? zoneCenter;
    return SizedBox(
      width: double.infinity,
      height: 220,
      child: center == null
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.ink, AppColors.background],
                ),
              ),
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 10),
              child: _ridersOnlineLabel(l10n, activeZone),
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: mb.MapWidget(
                    // Stable key — this is a small static preview, not a live
                    // tracking view, so it shouldn't tear down and recreate its
                    // native GL surface on every GPS update (distanceFilter:20
                    // in _startLocationUpdates fires often while online).
                    key: const ValueKey('homeMap'),
                    cameraOptions: mb.CameraOptions(
                      center: mb.Point(coordinates: mb.Position(center.longitude, center.latitude)),
                      zoom: 13.0,
                    ),
                    styleUri: mb.MapboxStyles.MAPBOX_STREETS,
                    onMapCreated: (mapboxMap) async {
                      _homeMapboxMap = mapboxMap;
                      unawaited(mapboxMap.location.updateSettings(
                        mb.LocationComponentSettings(enabled: true, pulsingEnabled: true),
                      ));
                      if (_myLastKnownLocation == null) return;
                      final manager = await mapboxMap.annotations.createCircleAnnotationManager();
                      await manager.create(
                        mb.CircleAnnotationOptions(
                          geometry: mb.Point(coordinates: mb.Position(_myLastKnownLocation!.longitude, _myLastKnownLocation!.latitude)),
                          circleColor: AppColors.accent.toARGB32(),
                          circleRadius: 8.0,
                          circleStrokeColor: Colors.white.toARGB32(),
                          circleStrokeWidth: 2.0,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 8,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.ink.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _ridersOnlineLabel(l10n, activeZone),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: LocateMeButton(mapboxMap: () => _homeMapboxMap),
                ),
              ],
            ),
    );
  }

  Widget _ridersOnlineLabel(AppLocalizations l10n, String activeZone) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('riders')
          .where('activeZone', isEqualTo: activeZone)
          .where('isOnline', isEqualTo: true)
          .snapshots(),
      builder: (context, ridersSnap) {
        final count = ridersSnap.data?.docs.length ?? 0;
        return Text(
          l10n.zoneRidersOnlineLabel(activeZone, count),
          style: AppTypography.caption(size: 12, color: AppColors.bodyText),
        );
      },
    );
  }

  // If this rider already has an active (assigned/picked_up) delivery, show
  // that screen instead of the request feed — a rider handles one delivery
  // at a time in this version.
  // An active delivery is handled up in build() (full-screen, before this
  // widget tree even gets built) — reaching this method at all already
  // means there is none, so this is just the online/offline feed state.
  Widget _buildBody(String activeZone, String vehicleType, bool isOnline) {
    final l10n = AppLocalizations.of(context)!;
    if (!isOnline) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: _dashedEmptyState(l10n.goOnlineToSeeRequestsMessage),
      );
    }

    return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('delivery_requests')
              .where('status', isEqualTo: 'open')
              .where('zone', isEqualTo: activeZone)
              // Price is vehicle-type-specific (see pricing_service.dart's
              // priceMultiplier in customer_app) — a request with no
              // matching vehicle type would just be rejected server-side by
              // submitBid.js anyway, so don't even show it. Requests from
              // before this field existed briefly disappear from every
              // feed, but their 60s bidding window expires on its own.
              .where('vehicleType', isEqualTo: vehicleType)
              // Sorted client-side below, not via .orderBy() here — a
              // compound where()+orderBy()-on-a-different-field query like
              // this one was observed to hang indefinitely (never emitting a
              // single snapshot) against the Firestore web client, the same
              // issue that made bid_list_screen.dart's bid feed never load
              // — see watchBids() in models/bid.dart for the full story.
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final now = Timestamp.now();
            // Bicycles have a much shorter practical range than motorized
            // vehicles — don't offer a request the rider has no realistic
            // way to reach in time. Same kycDocType lookup already used for
            // the KYC-docs banner above stands in for "is this a bicycle."
            final isPersonalIdOnly = _vehicleTypesCache[vehicleType]?['kycDocType'] == 'personalIdOnly';
            final maxOfferRadiusMeters = isPersonalIdOnly ? 2000.0 : 3000.0;
            final myLocation = _myLastKnownLocation;
            // status stays "open" in Firestore until the scheduled cleanup
            // function runs (which can lag, and never runs at all against
            // the local emulator) — so also drop anything past its own
            // bidding window here, rather than trusting status alone.
            final docs = (snapshot.data?.docs ?? []).where((d) {
              final data = d.data() as Map<String, dynamic>;
              final closesAt = data['biddingClosesAt'] as Timestamp?;
              if (closesAt != null && closesAt.compareTo(now) <= 0) return false;
              // Fail open if this rider's own location isn't known yet (just
              // went online, GPS fix still pending) or a request predates
              // the pickup.geopoint field — better to show it than hide
              // everything while location catches up.
              if (myLocation == null) return true;
              final pickupGeo = (data['pickup'] as Map<String, dynamic>?)?['geopoint'] as GeoPoint?;
              if (pickupGeo == null) return true;
              final distanceMeters = Geolocator.distanceBetween(
                myLocation.latitude,
                myLocation.longitude,
                pickupGeo.latitude,
                pickupGeo.longitude,
              );
              return distanceMeters <= maxOfferRadiusMeters;
            }).toList()
              ..sort((a, b) {
                final aCreated = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                final bCreated = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                if (aCreated == null || bCreated == null) return 0;
                return bCreated.compareTo(aCreated); // descending
              });
            if (docs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: _dashedEmptyState(l10n.noOpenRequestsDashedMessage),
              );
            }

            // Drop cached ETAs for any request no longer in the feed (bid on,
            // expired, cancelled) so these maps don't grow all session long.
            final activeIds = docs.map((d) => d.id).toSet();
            clearEtaCacheEntriesExcept(activeIds);
            _etaFutures.removeWhere((id, _) => !activeIds.contains(id));

            // No FCM push covers "a new request just opened in your zone" —
            // this feed is the only place a rider finds out, so play a sound
            // when one genuinely new id shows up. The very first snapshot is
            // "whatever's already open right now", not new arrivals, so it
            // only starts tracking rather than sounding an alert.
            if (_seenRequestIds != null && activeIds.difference(_seenRequestIds!).isNotEmpty) {
              SoundService.requestReceived();
            }
            _seenRequestIds = activeIds;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.openRequestsHeading, style: AppTypography.heading(size: 15)),
                      Text(
                        l10n.nearbyCountLabel(docs.length),
                        style: AppTypography.label(color: AppColors.accent),
                      ),
                    ],
                  );
                }
                final request = DeliveryRequest.fromFirestore(docs[index - 1]);
                return _buildRequestCard(request, index - 1);
              },
            );
          },
    );
  }

  // Flutter has no native dashed-border support — approximated with a solid
  // border, matching the same tradeoff already made in profile_setup_screen.dart.
  Widget _dashedEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderDashed),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message, textAlign: TextAlign.center, style: AppTypography.body(color: AppColors.mutedLight)),
    );
  }

  Widget _buildRequestCard(DeliveryRequest request, int index) {
    final l10n = AppLocalizations.of(context)!;
    {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderAlt),
                    boxShadow: const [
                      BoxShadow(color: Color.fromRGBO(16, 21, 32, 0.04), offset: Offset(0, 1), blurRadius: 2),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(request.packageDescription, style: AppTypography.heading(size: 14.5)),
                                const SizedBox(height: 4),
                                if (request.estimatedWeightKg != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentTint,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.accentBorder),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.scale_outlined, size: 13, color: AppColors.accent),
                                          const SizedBox(width: 4),
                                          Text(
                                            l10n.estimatedWeightLabel(request.estimatedWeightKg!.toStringAsFixed(0)),
                                            style: AppTypography.label(size: 12, color: AppColors.accent)
                                                .copyWith(fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (_myLastKnownLocation != null)
                                  FutureBuilder<int?>(
                                    future: _etaFutures.putIfAbsent(
                                      request.id,
                                      () => fetchEtaMinutesCached(request.id, _myLastKnownLocation!, request.pickup),
                                    ),
                                    builder: (context, etaSnap) {
                                      if (!etaSnap.hasData || etaSnap.data == null) {
                                        return const SizedBox.shrink();
                                      }
                                      return Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: Text(
                                          l10n.etaMinutesAwayLabel(etaSnap.data!),
                                          style: AppTypography.caption(color: AppColors.mutedLight),
                                        ),
                                      );
                                    },
                                  ),
                                if (request.purchaseBudget != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      l10n.bringCashToPickupLabel(request.purchaseBudget!.toStringAsFixed(0)),
                                      style: AppTypography.caption(color: AppColors.danger).copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (request.suggestedPrice != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(l10n.basePriceTag, style: AppTypography.label(color: AppColors.mutedLight)),
                                Text(
                                  request.suggestedPrice!.toStringAsFixed(0),
                                  style: AppTypography.amount(size: 17, color: AppColors.accent),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Container(
                              width: 9,
                              height: 9,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accent),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                request.pickupAddress,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption(size: 12, color: AppColors.bodyText),
                              ),
                            ),
                            const Icon(Icons.arrow_forward, size: 13, color: AppColors.mutedLight),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                request.dropoffAddress,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption(size: 12, color: AppColors.bodyText),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: index == 0
                            ? ElevatedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => BidSubmitScreen(request: request)),
                                ),
                                child: Text(l10n.bidButton),
                              )
                            : OutlinedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => BidSubmitScreen(request: request)),
                                ),
                                child: Text(l10n.bidButton),
                              ),
                      ),
                    ],
                  ),
                );
    }
  }
}
