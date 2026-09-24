import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fcm_service.dart';
import 'post_login_router.dart';
import '../screens/profile_setup_screen.dart';
import '../screens/set_password_screen.dart';

/// Everything that needs to happen once a [PhoneAuthCredential] is proven
/// valid — sign in, create the Firestore user/rider docs for a brand-new
/// account, register for push, and navigate on to SetPasswordScreen. There
/// are two ways a credential reaches this point: the rider types the
/// 6-digit code (otp_verify_screen.dart) or Android auto-retrieves it
/// without ever showing that screen (verificationCompleted, in
/// phone_login_screen.dart / forgot_password_screen.dart) — both must do
/// the exact same thing after, which is why this lives here instead of
/// being duplicated a third time. Previously the auto-retrieval path only
/// signed in and stopped, leaving the screen looking frozen while the
/// account was actually already authenticated underneath.
Future<void> completePhoneAuthSignIn({
  required BuildContext context,
  required PhoneAuthCredential credential,
  required bool isNewAccount,
  required String phoneNumber,
  String? name,
}) async {
  final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
  final uid = userCredential.user!.uid;

  if (isNewAccount) {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'phone': phoneNumber,
      'name': name,
      'role': 'rider',
      // Starts at 0, not a flattering default — ratingCount is also 0, so
      // every display site checks that before showing a star value at all.
      'rating': 0.0,
      'ratingCount': 0,
      'walletBalance': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Default to whichever zone happens to be active first — the rider can
    // change this anytime from their profile screen. Falls back to
    // "atbara" only if no zones have been configured in the admin
    // dashboard yet at all.
    final zonesSnap =
        await FirebaseFirestore.instance.collection('zones').where('active', isEqualTo: true).limit(1).get();
    final defaultZone =
        zonesSnap.docs.isNotEmpty ? (zonesSnap.docs.first.data()['name'] as String).toLowerCase() : 'atbara';

    await FirebaseFirestore.instance.collection('riders').doc(uid).set({
      'vehicleType': 'motorbike',
      // Starts pending — must be approved via the admin dashboard's Rider
      // KYC tab before this rider can see or bid on requests.
      'kycStatus': 'pending',
      'isOnline': false,
      'activeZone': defaultZone,
    });
  }

  // Deliberately NOT awaited — a real network call to Google's servers,
  // which can be slow or hang on an emulator; login should never wait on
  // it. If it fails, initForUser() catches its own errors internally.
  FcmService.initForUser(uid);

  if (!context.mounted) return;
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => SetPasswordScreen(
        phone: phoneNumber,
        onSuccess: isNewAccount
            ? (ctx) async => Navigator.of(ctx).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
                  (route) => false,
                )
            : (ctx) => routeAfterLogin(ctx, uid),
      ),
    ),
    (route) => false,
  );
}
