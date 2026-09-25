// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Wassil Rider';

  @override
  String get splashTagline => 'Your delivery, your price.';

  @override
  String get splashRiderRoleChip => 'RIDER';

  @override
  String get riderSignInHeading => 'Rider Sign In';

  @override
  String get phoneLoginHeading => 'Enter your name and phone number';

  @override
  String get fullNameHint => 'Full name';

  @override
  String get phoneHint => '09XXXXXXXX';

  @override
  String get sendCodeButton => 'Send code';

  @override
  String get enterNameError => 'Enter your name';

  @override
  String get enterPhoneError => 'Enter your phone number';

  @override
  String get otpTitle => 'Verify code';

  @override
  String otpCodeSentTo(String phone) {
    return 'Code sent to $phone';
  }

  @override
  String get otpHint => '123456';

  @override
  String get verifyButton => 'Verify';

  @override
  String get enterSixDigitCode => 'Enter the 6-digit code';

  @override
  String get invalidCodeError => 'Invalid code. Try again.';

  @override
  String get verificationFailedError => 'Verification failed. Try again.';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get faqButton => 'Frequently Asked Questions';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get goOnlineLabel => 'Go Online';

  @override
  String get goOfflineLabel => 'Go Offline';

  @override
  String get noOpenRequests => 'No open requests right now.';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get continueButton => 'Continue';

  @override
  String get backButton => 'Back';

  @override
  String get reasonOther => 'Other';

  @override
  String get reportProblemTitle => 'Report a Problem';

  @override
  String get tellUsMoreHint => 'Tell us more...';

  @override
  String get confirmCancellationButton => 'Confirm Cancellation';

  @override
  String get keepItButton => 'Keep it';

  @override
  String get reasonLabel => 'Reason';

  @override
  String get additionalDetailsHint => 'Additional details (optional)';

  @override
  String get submitReportButton => 'Submit Report';

  @override
  String get reportSubmittedMessage =>
      'Report submitted. Our team will follow up.';

  @override
  String get profileTooltip => 'Profile';

  @override
  String get profileUpdated => 'Profile updated.';

  @override
  String get couldNotMarkPickedUpError => 'Could not mark as picked up.';

  @override
  String get couldNotMarkArrivedError => 'Could not mark as arrived.';

  @override
  String get couldNotStartWaitingFeeError => 'Could not start the waiting fee.';

  @override
  String get startWaitingFeeButton => 'Charge Waiting Fee';

  @override
  String get waitingFeeActiveLabel => 'Waiting fee active';

  @override
  String get customerIsComingLabel => 'Customer is on the way to you';

  @override
  String get waitingForCustomerLabel => 'Waiting for customer';

  @override
  String get freeWaitTimeLeftLabel => 'Free wait time left';

  @override
  String waitingFeeAmountLabel(int amount) {
    return '$amount SDG';
  }

  @override
  String get waitingFeeSoFarLabel => 'so far';

  @override
  String get waitingFeeCappedLabel => 'maximum reached';

  @override
  String get enterDeliveryCodeTitle => 'Enter delivery code';

  @override
  String get deliveryCodeInstruction =>
      'Ask the customer for the 4-digit code shown on their tracking screen.';

  @override
  String get deliveryCodeHint => '1234';

  @override
  String get couldNotCompleteDeliveryError => 'Could not complete delivery.';

  @override
  String get customerFallbackName => 'Customer';

  @override
  String get cancelDeliveryError => 'Could not cancel this delivery.';

  @override
  String get couldNotOpenMapsError => 'Could not open Google Maps.';

  @override
  String get cancelDeliveryDialogTitle => 'Cancel this delivery?';

  @override
  String get reasonVehicleIssue => 'Vehicle issue';

  @override
  String get reasonPersonalEmergency => 'Personal emergency';

  @override
  String get reasonCustomerUnreachable => 'Customer unreachable';

  @override
  String get reasonDistanceTooFar => 'Distance too far';

  @override
  String get reasonWrongAddress => 'Wrong address';

  @override
  String get reasonCustomerRefusedDelivery => 'Customer refused delivery';

  @override
  String get reasonSafetyConcern => 'Safety concern';

  @override
  String get activeDeliveryTitle => 'Active Delivery';

  @override
  String get dropoffLabel => 'Drop-off';

  @override
  String get pickupLabel => 'Pickup';

  @override
  String get orderDetailTitle => 'Delivery details';

  @override
  String get customerLabel => 'Customer';

  @override
  String get contactPhoneLabel => 'Contact phone';

  @override
  String get priceLabel => 'Price';

  @override
  String headingToLabel(String destination) {
    return 'Heading to $destination';
  }

  @override
  String get headingToWord => 'Heading to';

  @override
  String etaApproxMinutes(int minutes) {
    return '~$minutes min';
  }

  @override
  String packageLabel(String description) {
    return 'Package: $description';
  }

  @override
  String amountToCollectLabel(String amount) {
    return 'Amount to collect: $amount SDG';
  }

  @override
  String get receiverContactLabel => 'Receiver: ';

  @override
  String get pickupContactLabel => 'Pickup contact: ';

  @override
  String get navigateWithGoogleMapsButton => 'Navigate with Google Maps';

  @override
  String get markDeliveredButton => 'Mark Delivered';

  @override
  String get markPickedUpButton => 'Mark Picked Up';

  @override
  String get markArrivedButton => 'I\'ve Arrived';

  @override
  String get enterValidPriceError => 'Enter a valid price';

  @override
  String maxAllowedBidError(String maxBid) {
    return 'Max allowed bid for this distance is $maxBid SDG';
  }

  @override
  String get bidSubmittedMessage =>
      'Bid submitted! Waiting for customer to respond.';

  @override
  String get couldNotSubmitBidError => 'Could not submit bid.';

  @override
  String get placeYourBidTitle => 'Place Your Bid';

  @override
  String pickupAddressLine(String address) {
    return 'Pickup: $address';
  }

  @override
  String dropoffAddressLine(String address) {
    return 'Drop-off: $address';
  }

  @override
  String purchaseBudgetWarning(String amount) {
    return 'You will need to pay ~$amount SDG at pickup — bring this cash before bidding.';
  }

  @override
  String basePriceLabel(String price) {
    return 'Base price: $price SDG';
  }

  @override
  String get basePriceTag => 'Base';

  @override
  String get balanceLabel => 'Balance';

  @override
  String maxBidAllowedLabel(String maxBid) {
    return 'Max bid allowed: $maxBid SDG';
  }

  @override
  String get yourPriceLabel => 'Your price (SDG)';

  @override
  String get etaAutoCalculatedNote =>
      'Your ETA is calculated automatically from your current location.';

  @override
  String get submitBidButton => 'Submit Bid';

  @override
  String get earningsTitle => 'Earnings';

  @override
  String completedDeliveriesCount(int count) {
    return '$count completed deliveries';
  }

  @override
  String totalCollectedLabel(String amount) {
    return '$amount SDG collected';
  }

  @override
  String commissionNetSummary(String commission, String net) {
    return '$commission SDG paid in commission · $net SDG net';
  }

  @override
  String get noCompletedDeliveriesYet => 'No completed deliveries yet.';

  @override
  String get noDescriptionPlaceholder => '(no description)';

  @override
  String priceSdgLabel(String amount) {
    return '$amount SDG';
  }

  @override
  String feeDeductedLabel(String amount) {
    return '-$amount fee';
  }

  @override
  String get faqTitle => 'Frequently Asked Questions';

  @override
  String get faq1Question => 'Why can\'t I go online yet?';

  @override
  String get faq1Answer =>
      'New accounts start pending until an admin reviews your KYC documents (ID photo and vehicle photo). Submit these from the banner on your home screen — you\'ll be able to go online once approved.';

  @override
  String get faq2Question => 'How does the wallet balance work?';

  @override
  String get faq2Answer =>
      'A small commission is deducted from your wallet balance each time you complete a delivery. Top up your balance via bank transfer from the Wallet screen — if it runs out, you won\'t be able to go online until you top up again.';

  @override
  String get faq3Question => 'What happens if I change my vehicle type?';

  @override
  String get faq3Answer =>
      'Your KYC approval is tied to the vehicle you were verified with. Switching to a different vehicle type resets your account to pending and requires new documents before you can go online again.';

  @override
  String get faq4Question => 'Why can\'t I bid in some zones?';

  @override
  String get faq4Answer =>
      'Some zones only allow certain vehicle types (for example, bicycle-only zones). If your vehicle isn\'t permitted in a zone, your bids there will be rejected automatically.';

  @override
  String get faq5Question => 'How do I complete a delivery?';

  @override
  String get faq5Answer =>
      'Ask the customer for the 4-digit confirmation code shown on their tracking screen, then enter it when tapping \"Mark Delivered.\" This is required — it\'s proof you actually completed the delivery.';

  @override
  String get faq6Question => 'What if I need to cancel after accepting a bid?';

  @override
  String get faq6Answer =>
      'You can cancel before picking up the package — this reopens the request for other riders to bid on rather than leaving the customer stranded. Try to avoid this when possible, as customers see it.';

  @override
  String get faq7Question =>
      'A customer needs me to buy something for them — what should I know?';

  @override
  String get faq7Answer =>
      'If the request shows an estimated purchase amount, bring at least that much cash before bidding. Always keep the receipt for the customer.';

  @override
  String get kycApprovalPendingError =>
      'Your account is still waiting on KYC approval.';

  @override
  String get balanceDepletedError =>
      'Your commission balance is depleted. Top up to go online.';

  @override
  String get locationPermissionRequiredError =>
      'Location permission is required to go online';

  @override
  String get availableDeliveriesTitle => 'Available Deliveries';

  @override
  String get earningsTooltip => 'Earnings';

  @override
  String get commissionBalanceTooltip => 'Commission Balance';

  @override
  String get onlineLabel => 'Online';

  @override
  String get offlineLabel => 'Offline';

  @override
  String get openRequestsHeading => 'Open requests';

  @override
  String nearbyCountLabel(int count) {
    return '$count nearby';
  }

  @override
  String riderRatingSummary(String rating, int count) {
    return '★ $rating · $count';
  }

  @override
  String get newRiderLabel => 'New';

  @override
  String get todayLabel => 'Today';

  @override
  String zoneRidersOnlineLabel(String zone, int count) {
    return 'Zone: $zone · $count riders online';
  }

  @override
  String get noOpenRequestsDashedMessage => 'No requests available right now.';

  @override
  String get kycRejectedMessage =>
      'Your KYC was rejected. Contact support for next steps.';

  @override
  String kycRejectedWithReasonMessage(String reason) {
    return 'Your KYC was rejected: $reason. Contact support for next steps.';
  }

  @override
  String get vehicleZoneMismatchMessage =>
      'Your vehicle type isn\'t permitted in your current zone — update your vehicle type or region in your profile before going online.';

  @override
  String get goToProfileButton => 'Go to Profile';

  @override
  String get kycDocsSubmittedMessage =>
      'Documents submitted — waiting on admin review.';

  @override
  String get kycUploadPromptMessage =>
      'Upload your ID and vehicle photo to get approved.';

  @override
  String get uploadDocumentsButton => 'Upload Documents';

  @override
  String get balanceDepletedBannerMessage =>
      'Commission balance depleted — top up to go online and accept deliveries.';

  @override
  String get topUpButton => 'Top Up';

  @override
  String get goOnlineToSeeRequestsMessage =>
      'Go online to see nearby delivery requests.';

  @override
  String bringCashToPickupLabel(String amount) {
    return 'Bring ~$amount SDG to pay at pickup';
  }

  @override
  String estimatedWeightLabel(String weight) {
    return '≈$weight kg cargo';
  }

  @override
  String etaMinutesAwayLabel(int minutes) {
    return '$minutes min away';
  }

  @override
  String get bidButton => 'Bid';

  @override
  String get takeAllPhotosError => 'Take all required photos before submitting';

  @override
  String get docsSubmittedSnackbarMessage =>
      'Documents submitted — waiting for admin review.';

  @override
  String get uploadFailedError =>
      'Upload failed. Check your connection and try again.';

  @override
  String get personalIdLabel => 'Personal ID (Passport or National ID)';

  @override
  String get licenseFrontLabel => 'Driver\'s License — Front';

  @override
  String get licenseBackLabel => 'Driver\'s License — Back';

  @override
  String get vehicleRegFrontLabel => 'Vehicle Registration — Front';

  @override
  String get vehicleRegBackLabel => 'Vehicle Registration — Back';

  @override
  String get kycVerificationTitle => 'KYC Verification';

  @override
  String get kycInstructions =>
      'Take a clear photo of the required documents for your vehicle type. An admin will review these before you can start accepting deliveries.';

  @override
  String get kycDocNoteBicycle =>
      'Bicycle riders only need to provide a personal ID.';

  @override
  String get kycDocNoteOther =>
      'This vehicle type needs a driver\'s license and vehicle registration, front and back.';

  @override
  String get kycPendingTitle => 'Under Review';

  @override
  String get kycPendingBody =>
      'Your documents are being reviewed by an admin. This usually doesn\'t take long.';

  @override
  String get kycApprovedTitle => 'Approved';

  @override
  String get kycApprovedBody =>
      'Your documents are approved — you\'re all set to accept deliveries.';

  @override
  String get kycRejectedTitle => 'Documents Rejected';

  @override
  String get kycRejectedBody =>
      'Your documents were rejected. Please retake them and submit again.';

  @override
  String get docCapturedLabel => 'Captured';

  @override
  String get docTapToCaptureLabel => 'Tap to capture';

  @override
  String get submitForReviewButton => 'Submit for Review';

  @override
  String get tapStarToRateCustomerError => 'Tap a star to rate the customer';

  @override
  String get submitRatingError => 'Could not submit rating.';

  @override
  String get deliveryCompleteTitle => 'Delivery Complete';

  @override
  String collectedAmountLabel(String amount) {
    return 'Collected: $amount SDG';
  }

  @override
  String get howWasCustomerTitle => 'How was this customer?';

  @override
  String get optionalCommentAboutCustomerHint =>
      'Optional comment about this customer';

  @override
  String get submitRatingButton => 'Submit Rating';

  @override
  String get skipButton => 'Skip';

  @override
  String get newVehicleVerificationTitle =>
      'New vehicle needs new verification';

  @override
  String get newVehicleVerificationContent =>
      'Your account was approved for your current vehicle. Switching to a different one will require you to submit new KYC documents before you can go online again.';

  @override
  String get vehicleUpdatedReverificationMessage =>
      'Vehicle updated — upload new KYC documents to go online again.';

  @override
  String get couldNotUpdateVehicleError => 'Could not update vehicle type.';

  @override
  String get vehicleTypeLabel => 'Vehicle type';

  @override
  String get plateNumberLabel => 'Plate number';

  @override
  String approvedForLabel(String vehicleType) {
    return 'Approved for: $vehicleType';
  }

  @override
  String get operatingZoneLabel => 'Operating zone';

  @override
  String get commissionBalanceTitle => 'Commission Balance';

  @override
  String get balanceDepletedMessage =>
      'Your balance is depleted. Top up to keep accepting deliveries.';

  @override
  String get topUpViaBankakButton => 'Top Up Balance';

  @override
  String get transactionHistoryTitle => 'Transaction History';

  @override
  String get commissionDeductionNote =>
      'A commission is deducted here automatically after each cash/bank-transfer delivery you complete.';

  @override
  String get noTransactionsYet => 'No transactions yet.';

  @override
  String get transactionCommissionLabel => 'Commission';

  @override
  String get collectedWord => 'Collected';

  @override
  String get netWord => 'Net';

  @override
  String get transactionTopUpLabel => 'Top-Up';

  @override
  String get autoDeductedLabel => 'Auto-deducted';

  @override
  String viaMethodLabel(String method) {
    return 'via $method';
  }

  @override
  String get deductedLabel => 'deducted';

  @override
  String get txStatusVerified => 'verified';

  @override
  String get txStatusRejected => 'rejected';

  @override
  String get txStatusPending => 'pending';

  @override
  String get enterValidAmountError => 'Enter a valid amount';

  @override
  String get enterReferenceCodeError =>
      'Enter the reference code from your transfer';

  @override
  String get selectPaymentAccountError =>
      'Select which bank you sent the transfer to';

  @override
  String get topupSubmittedMessage =>
      'Top-up submitted. It will be verified shortly.';

  @override
  String get topUpCommissionBalanceTitle => 'Top Up Commission Balance';

  @override
  String get howToTopUpTitle => 'How to top up';

  @override
  String get topUpStep1 => '1. Choose a bank below and send the amount';

  @override
  String get topUpStep2 =>
      '2. Copy the transaction reference code from your banking app';

  @override
  String get topUpStep3 => '3. Enter the amount and code below';

  @override
  String get topUpStep4 => '4. Your balance updates once an admin verifies it';

  @override
  String get noPaymentAccountsMessage =>
      'No payment accounts configured yet — contact support.';

  @override
  String get bankLabel => 'Bank';

  @override
  String get selectAccountToTransferLabel => 'Select an account to transfer to';

  @override
  String get amountSdgLabel => 'Amount (SDG)';

  @override
  String get bankakReferenceLabel => 'Transaction reference code';

  @override
  String get submitTopUpRequestButton => 'Submit Top-Up Request';

  @override
  String get profileSetupTitle => 'Complete your profile';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get regionLabel => 'Region';

  @override
  String get noRegionsAvailableMessage =>
      'No regions available yet — you can set this later from your profile.';

  @override
  String get addPhotoLabel => 'Add a profile photo';

  @override
  String get photoRequiredHint =>
      'Required — customers will see this on your bids and tracking screen';

  @override
  String get takePhotoOption => 'Take photo';

  @override
  String get chooseFromGalleryOption => 'Choose from gallery';

  @override
  String get profileSetupError => 'Could not save your profile. Try again.';

  @override
  String get commissionWaivedLabel => 'Commission waived';

  @override
  String get signInHeading => 'Enter your phone number to continue';

  @override
  String get phoneContinueButton => 'Continue';

  @override
  String get checkPhoneError =>
      'Could not verify this phone number. Check your connection and try again.';

  @override
  String get passwordHint => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get forgotPasswordLink => 'Forgot password?';

  @override
  String get wrongPasswordError => 'Incorrect password. Try again.';

  @override
  String get setPasswordTitle => 'Set a password';

  @override
  String get setPasswordInstruction =>
      'Set a password so you can sign in faster next time without waiting for a code.';

  @override
  String get newPasswordHint => 'New password';

  @override
  String get confirmPasswordHint => 'Confirm password';

  @override
  String get showPasswordWord => 'Show';

  @override
  String get pwRuleLength => 'At least 6 characters';

  @override
  String get pwRuleMatch => 'Both fields match';

  @override
  String get passwordTooShortError => 'Password must be at least 6 characters';

  @override
  String get passwordsDontMatchError => 'Passwords don\'t match';

  @override
  String get savePasswordButton => 'Save Password';

  @override
  String get setPasswordError => 'Could not save your password. Try again.';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String forgotPasswordInstruction(String phone) {
    return 'We\'ll text a verification code to $phone';
  }

  @override
  String get logoutButton => 'Logout';

  @override
  String get logoutConfirmTitle => 'Log out?';

  @override
  String get logoutConfirmMessage =>
      'You\'ll need your phone number and password to sign back in.';

  @override
  String get emailLabel => 'Email (optional)';

  @override
  String get invalidEmailError => 'Enter a valid email address';

  @override
  String get contactSupportButton => 'Contact Support';

  @override
  String get contactSupportTitle => 'Contact Support';

  @override
  String get callSupportButton => 'Call Support';

  @override
  String get whatsappSupportButton => 'WhatsApp Support';

  @override
  String get emailSupportButton => 'Email Support';

  @override
  String get supportMessageHint => 'Describe your issue...';

  @override
  String get submitSupportMessageButton => 'Send Message';

  @override
  String get supportMessageSentMessage =>
      'Message sent — our team will get back to you.';

  @override
  String get supportMessageError => 'Could not send your message. Try again.';

  @override
  String get describeIssueError => 'Describe your issue before sending';

  @override
  String get myTicketsHeading => 'Your Messages';

  @override
  String get ticketStatusOpen => 'Awaiting reply';

  @override
  String get ticketStatusResolved => 'Resolved';

  @override
  String get supportReplyLabel => 'Support';
}
