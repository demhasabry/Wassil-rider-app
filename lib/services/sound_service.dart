import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

/// Short, fire-and-forget UI sound effects. A fresh AudioPlayer per call
/// (not a shared/reused instance) so two overlapping triggers don't cut
/// each other off — each disposes itself once playback finishes.
class SoundService {
  SoundService._();

  // stayAwake keeps playback going while the screen is locked or the app is
  // backgrounded (still running, not force-closed) — on Android this asks
  // for a PARTIAL_WAKE_LOCK; on iOS it needs the UIBackgroundModes "audio"
  // key already added to Info.plist. Without this, every sound below only
  // reliably played while the app was in the foreground.
  static final AudioContext _bgContext = AudioContextConfig(stayAwake: true).build();

  static Future<void> _play(String assetFileName) async {
    try {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.release);
      unawaited(
        player.play(AssetSource('sounds/$assetFileName'), ctx: _bgContext).catchError((_) {}),
      );
      player.onPlayerComplete.first.then((_) => player.dispose());
    } catch (_) {
      // Sound is a nice-to-have — never let a playback failure (missing
      // audio focus, a muted device, an unsupported platform) affect
      // anything else in the app.
    }
  }

  /// A push notification arrived while the app was in the foreground for an
  /// event that doesn't have its own distinct sound below (a rejected bid,
  /// etc.) — the OS only plays its own notification sound automatically in
  /// the background, so this fills the foreground gap the SnackBar fallback
  /// already covers visually.
  static Future<void> notification() => _play('notification.wav');

  /// A brand-new delivery request just landed in the open-requests feed
  /// while the rider is online — nothing sends an FCM push for this (only
  /// a live Firestore listener sees it), so this is the only alert a rider
  /// gets for a fresh job while the app is open.
  static Future<void> requestReceived() => _play('request_received.mp3');

  /// One of this rider's bids was just accepted — they won the job. Same
  /// sound file as the customer app's "you accepted a bid" — triggered
  /// directly off home_screen.dart's own active-request query, not the
  /// 'bid_accepted' FCM push (foreground-only).
  static Future<void> bidAccepted() => _play('bid_accepted.mp3');

  /// A ride (this rider backing out, or the customer cancelling) was
  /// cancelled.
  static Future<void> cancellation() => _play('cancellation.mp3');

  /// The delivery was marked complete.
  static Future<void> rideCompleted() => _play('ride_completed.mp3');

  /// Plays once on the splash screen.
  static Future<void> splash() => _play('splash.mp3');
}
