# Rider App

## Screen flow
```
PhoneLoginScreen → OtpVerifyScreen → HomeScreen ⇄ BidSubmitScreen
                                          ↓ (when a bid is accepted)
                                    ActiveDeliveryScreen
```

- **phone_login_screen.dart / otp_verify_screen.dart** — same OTP pattern as the customer app, but creates a `role: "rider"` user plus a `riders/{uid}` profile document
- **home_screen.dart** — online/offline toggle (pushes live GPS to `riders/{uid}.currentLocation` while online via the `geolocator` package), and a live feed of open requests in the zone. If this rider already has an assigned delivery, it shows `ActiveDeliveryScreen` instead automatically.
- **bid_submit_screen.dart** — enter price + ETA, calls the real `submitBid` Cloud Function
- **active_delivery_screen.dart** — map toward pickup, then toward drop-off after tapping "Mark Picked Up"; "Mark Delivered" calls the real `completeDelivery` Cloud Function

## Important: auto-approved KYC for testing
`otp_verify_screen.dart` sets every new rider's `kycStatus` straight to `"approved"` so you can test immediately without an admin dashboard. **This must change before real riders sign up** — a real rider should start as `"pending"` and only become `"approved"` after the admin dashboard review we haven't built yet. There's a comment marking this exact spot in the code.

## Running two apps at once for real testing
Since Android supports multiple emulator instances, you can:
1. Run `customer_app` on one emulator (`flutter run -d emulator-5554`)
2. Run `rider_app` on a second emulator (`flutter run -d emulator-5556`)
3. Both connect to the same local Firebase emulators (same `10.0.2.2` host)
4. Create a request as the customer, watch it appear live in the rider app's feed, submit a real bid as the rider, accept it as the customer — the entire loop, no manual Firestore editing needed anymore

## Location permissions
The rider app needs location permission to go online. On Android this requires adding permissions to `AndroidManifest.xml` — see the setup steps I'll walk you through when you're ready to run this.

## Not yet built
- Earnings/wallet screen for riders
- Delivery history
- Push notification handling in foreground
