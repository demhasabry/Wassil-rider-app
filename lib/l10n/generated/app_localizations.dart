import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Wassil Rider'**
  String get appTitle;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your delivery, your price.'**
  String get splashTagline;

  /// No description provided for @splashRiderRoleChip.
  ///
  /// In en, this message translates to:
  /// **'RIDER'**
  String get splashRiderRoleChip;

  /// No description provided for @riderSignInHeading.
  ///
  /// In en, this message translates to:
  /// **'Rider Sign In'**
  String get riderSignInHeading;

  /// No description provided for @phoneLoginHeading.
  ///
  /// In en, this message translates to:
  /// **'Enter your name and phone number'**
  String get phoneLoginHeading;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameHint;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'09XXXXXXXX'**
  String get phoneHint;

  /// No description provided for @sendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCodeButton;

  /// No description provided for @enterNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterNameError;

  /// No description provided for @enterPhoneError.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneError;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get otpTitle;

  /// No description provided for @otpCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {phone}'**
  String otpCodeSentTo(String phone);

  /// No description provided for @otpHint.
  ///
  /// In en, this message translates to:
  /// **'123456'**
  String get otpHint;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// No description provided for @enterSixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get enterSixDigitCode;

  /// No description provided for @invalidCodeError.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Try again.'**
  String get invalidCodeError;

  /// No description provided for @verificationFailedError.
  ///
  /// In en, this message translates to:
  /// **'Verification failed. Try again.'**
  String get verificationFailedError;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesButton;

  /// No description provided for @faqButton.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqButton;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @goOnlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Go Online'**
  String get goOnlineLabel;

  /// No description provided for @goOfflineLabel.
  ///
  /// In en, this message translates to:
  /// **'Go Offline'**
  String get goOfflineLabel;

  /// No description provided for @noOpenRequests.
  ///
  /// In en, this message translates to:
  /// **'No open requests right now.'**
  String get noOpenRequests;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @reportProblemTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get reportProblemTitle;

  /// No description provided for @tellUsMoreHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us more...'**
  String get tellUsMoreHint;

  /// No description provided for @confirmCancellationButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancellation'**
  String get confirmCancellationButton;

  /// No description provided for @keepItButton.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepItButton;

  /// No description provided for @reasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reasonLabel;

  /// No description provided for @additionalDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Additional details (optional)'**
  String get additionalDetailsHint;

  /// No description provided for @submitReportButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReportButton;

  /// No description provided for @reportSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Report submitted. Our team will follow up.'**
  String get reportSubmittedMessage;

  /// No description provided for @profileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTooltip;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get profileUpdated;

  /// No description provided for @couldNotMarkPickedUpError.
  ///
  /// In en, this message translates to:
  /// **'Could not mark as picked up.'**
  String get couldNotMarkPickedUpError;

  /// No description provided for @couldNotMarkArrivedError.
  ///
  /// In en, this message translates to:
  /// **'Could not mark as arrived.'**
  String get couldNotMarkArrivedError;

  /// No description provided for @couldNotStartWaitingFeeError.
  ///
  /// In en, this message translates to:
  /// **'Could not start the waiting fee.'**
  String get couldNotStartWaitingFeeError;

  /// No description provided for @startWaitingFeeButton.
  ///
  /// In en, this message translates to:
  /// **'Charge Waiting Fee'**
  String get startWaitingFeeButton;

  /// No description provided for @waitingFeeActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Waiting fee active'**
  String get waitingFeeActiveLabel;

  /// No description provided for @customerIsComingLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer is on the way to you'**
  String get customerIsComingLabel;

  /// No description provided for @waitingForCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Waiting for customer'**
  String get waitingForCustomerLabel;

  /// No description provided for @freeWaitTimeLeftLabel.
  ///
  /// In en, this message translates to:
  /// **'Free wait time left'**
  String get freeWaitTimeLeftLabel;

  /// No description provided for @waitingFeeAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'{amount} SDG'**
  String waitingFeeAmountLabel(int amount);

  /// No description provided for @waitingFeeSoFarLabel.
  ///
  /// In en, this message translates to:
  /// **'so far'**
  String get waitingFeeSoFarLabel;

  /// No description provided for @waitingFeeCappedLabel.
  ///
  /// In en, this message translates to:
  /// **'maximum reached'**
  String get waitingFeeCappedLabel;

  /// No description provided for @enterDeliveryCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter delivery code'**
  String get enterDeliveryCodeTitle;

  /// No description provided for @deliveryCodeInstruction.
  ///
  /// In en, this message translates to:
  /// **'Ask the customer for the 4-digit code shown on their tracking screen.'**
  String get deliveryCodeInstruction;

  /// No description provided for @deliveryCodeHint.
  ///
  /// In en, this message translates to:
  /// **'1234'**
  String get deliveryCodeHint;

  /// No description provided for @couldNotCompleteDeliveryError.
  ///
  /// In en, this message translates to:
  /// **'Could not complete delivery.'**
  String get couldNotCompleteDeliveryError;

  /// No description provided for @customerFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerFallbackName;

  /// No description provided for @cancelDeliveryError.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel this delivery.'**
  String get cancelDeliveryError;

  /// No description provided for @couldNotOpenMapsError.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Maps.'**
  String get couldNotOpenMapsError;

  /// No description provided for @cancelDeliveryDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this delivery?'**
  String get cancelDeliveryDialogTitle;

  /// No description provided for @reasonVehicleIssue.
  ///
  /// In en, this message translates to:
  /// **'Vehicle issue'**
  String get reasonVehicleIssue;

  /// No description provided for @reasonPersonalEmergency.
  ///
  /// In en, this message translates to:
  /// **'Personal emergency'**
  String get reasonPersonalEmergency;

  /// No description provided for @reasonCustomerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Customer unreachable'**
  String get reasonCustomerUnreachable;

  /// No description provided for @reasonDistanceTooFar.
  ///
  /// In en, this message translates to:
  /// **'Distance too far'**
  String get reasonDistanceTooFar;

  /// No description provided for @reasonWrongAddress.
  ///
  /// In en, this message translates to:
  /// **'Wrong address'**
  String get reasonWrongAddress;

  /// No description provided for @reasonCustomerRefusedDelivery.
  ///
  /// In en, this message translates to:
  /// **'Customer refused delivery'**
  String get reasonCustomerRefusedDelivery;

  /// No description provided for @reasonSafetyConcern.
  ///
  /// In en, this message translates to:
  /// **'Safety concern'**
  String get reasonSafetyConcern;

  /// No description provided for @activeDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Delivery'**
  String get activeDeliveryTitle;

  /// No description provided for @dropoffLabel.
  ///
  /// In en, this message translates to:
  /// **'Drop-off'**
  String get dropoffLabel;

  /// No description provided for @pickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickupLabel;

  /// No description provided for @orderDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery details'**
  String get orderDetailTitle;

  /// No description provided for @customerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerLabel;

  /// No description provided for @contactPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact phone'**
  String get contactPhoneLabel;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @headingToLabel.
  ///
  /// In en, this message translates to:
  /// **'Heading to {destination}'**
  String headingToLabel(String destination);

  /// No description provided for @headingToWord.
  ///
  /// In en, this message translates to:
  /// **'Heading to'**
  String get headingToWord;

  /// No description provided for @etaApproxMinutes.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min'**
  String etaApproxMinutes(int minutes);

  /// No description provided for @packageLabel.
  ///
  /// In en, this message translates to:
  /// **'Package: {description}'**
  String packageLabel(String description);

  /// No description provided for @amountToCollectLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount to collect: {amount} SDG'**
  String amountToCollectLabel(String amount);

  /// No description provided for @receiverContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Receiver: '**
  String get receiverContactLabel;

  /// No description provided for @pickupContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup contact: '**
  String get pickupContactLabel;

  /// No description provided for @navigateWithGoogleMapsButton.
  ///
  /// In en, this message translates to:
  /// **'Navigate with Google Maps'**
  String get navigateWithGoogleMapsButton;

  /// No description provided for @markDeliveredButton.
  ///
  /// In en, this message translates to:
  /// **'Mark Delivered'**
  String get markDeliveredButton;

  /// No description provided for @markPickedUpButton.
  ///
  /// In en, this message translates to:
  /// **'Mark Picked Up'**
  String get markPickedUpButton;

  /// No description provided for @markArrivedButton.
  ///
  /// In en, this message translates to:
  /// **'I\'ve Arrived'**
  String get markArrivedButton;

  /// No description provided for @enterValidPriceError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price'**
  String get enterValidPriceError;

  /// No description provided for @maxAllowedBidError.
  ///
  /// In en, this message translates to:
  /// **'Max allowed bid for this distance is {maxBid} SDG'**
  String maxAllowedBidError(String maxBid);

  /// No description provided for @bidSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Bid submitted! Waiting for customer to respond.'**
  String get bidSubmittedMessage;

  /// No description provided for @couldNotSubmitBidError.
  ///
  /// In en, this message translates to:
  /// **'Could not submit bid.'**
  String get couldNotSubmitBidError;

  /// No description provided for @placeYourBidTitle.
  ///
  /// In en, this message translates to:
  /// **'Place Your Bid'**
  String get placeYourBidTitle;

  /// No description provided for @pickupAddressLine.
  ///
  /// In en, this message translates to:
  /// **'Pickup: {address}'**
  String pickupAddressLine(String address);

  /// No description provided for @dropoffAddressLine.
  ///
  /// In en, this message translates to:
  /// **'Drop-off: {address}'**
  String dropoffAddressLine(String address);

  /// No description provided for @purchaseBudgetWarning.
  ///
  /// In en, this message translates to:
  /// **'You will need to pay ~{amount} SDG at pickup — bring this cash before bidding.'**
  String purchaseBudgetWarning(String amount);

  /// No description provided for @basePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Base price: {price} SDG'**
  String basePriceLabel(String price);

  /// No description provided for @basePriceTag.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get basePriceTag;

  /// No description provided for @balanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceLabel;

  /// No description provided for @maxBidAllowedLabel.
  ///
  /// In en, this message translates to:
  /// **'Max bid allowed: {maxBid} SDG'**
  String maxBidAllowedLabel(String maxBid);

  /// No description provided for @yourPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Your price (SDG)'**
  String get yourPriceLabel;

  /// No description provided for @etaAutoCalculatedNote.
  ///
  /// In en, this message translates to:
  /// **'Your ETA is calculated automatically from your current location.'**
  String get etaAutoCalculatedNote;

  /// No description provided for @submitBidButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Bid'**
  String get submitBidButton;

  /// No description provided for @earningsTitle.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earningsTitle;

  /// No description provided for @completedDeliveriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} completed deliveries'**
  String completedDeliveriesCount(int count);

  /// No description provided for @totalCollectedLabel.
  ///
  /// In en, this message translates to:
  /// **'{amount} SDG collected'**
  String totalCollectedLabel(String amount);

  /// No description provided for @commissionNetSummary.
  ///
  /// In en, this message translates to:
  /// **'{commission} SDG paid in commission · {net} SDG net'**
  String commissionNetSummary(String commission, String net);

  /// No description provided for @noCompletedDeliveriesYet.
  ///
  /// In en, this message translates to:
  /// **'No completed deliveries yet.'**
  String get noCompletedDeliveriesYet;

  /// No description provided for @noDescriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'(no description)'**
  String get noDescriptionPlaceholder;

  /// No description provided for @priceSdgLabel.
  ///
  /// In en, this message translates to:
  /// **'{amount} SDG'**
  String priceSdgLabel(String amount);

  /// No description provided for @feeDeductedLabel.
  ///
  /// In en, this message translates to:
  /// **'-{amount} fee'**
  String feeDeductedLabel(String amount);

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// No description provided for @faq1Question.
  ///
  /// In en, this message translates to:
  /// **'Why can\'t I go online yet?'**
  String get faq1Question;

  /// No description provided for @faq1Answer.
  ///
  /// In en, this message translates to:
  /// **'New accounts start pending until an admin reviews your KYC documents (ID photo and vehicle photo). Submit these from the banner on your home screen — you\'ll be able to go online once approved.'**
  String get faq1Answer;

  /// No description provided for @faq2Question.
  ///
  /// In en, this message translates to:
  /// **'How does the wallet balance work?'**
  String get faq2Question;

  /// No description provided for @faq2Answer.
  ///
  /// In en, this message translates to:
  /// **'A small commission is deducted from your wallet balance each time you complete a delivery. Top up your balance via bank transfer from the Wallet screen — if it runs out, you won\'t be able to go online until you top up again.'**
  String get faq2Answer;

  /// No description provided for @faq3Question.
  ///
  /// In en, this message translates to:
  /// **'What happens if I change my vehicle type?'**
  String get faq3Question;

  /// No description provided for @faq3Answer.
  ///
  /// In en, this message translates to:
  /// **'Your KYC approval is tied to the vehicle you were verified with. Switching to a different vehicle type resets your account to pending and requires new documents before you can go online again.'**
  String get faq3Answer;

  /// No description provided for @faq4Question.
  ///
  /// In en, this message translates to:
  /// **'Why can\'t I bid in some zones?'**
  String get faq4Question;

  /// No description provided for @faq4Answer.
  ///
  /// In en, this message translates to:
  /// **'Some zones only allow certain vehicle types (for example, bicycle-only zones). If your vehicle isn\'t permitted in a zone, your bids there will be rejected automatically.'**
  String get faq4Answer;

  /// No description provided for @faq5Question.
  ///
  /// In en, this message translates to:
  /// **'How do I complete a delivery?'**
  String get faq5Question;

  /// No description provided for @faq5Answer.
  ///
  /// In en, this message translates to:
  /// **'Ask the customer for the 4-digit confirmation code shown on their tracking screen, then enter it when tapping \"Mark Delivered.\" This is required — it\'s proof you actually completed the delivery.'**
  String get faq5Answer;

  /// No description provided for @faq6Question.
  ///
  /// In en, this message translates to:
  /// **'What if I need to cancel after accepting a bid?'**
  String get faq6Question;

  /// No description provided for @faq6Answer.
  ///
  /// In en, this message translates to:
  /// **'You can cancel before picking up the package — this reopens the request for other riders to bid on rather than leaving the customer stranded. Try to avoid this when possible, as customers see it.'**
  String get faq6Answer;

  /// No description provided for @faq7Question.
  ///
  /// In en, this message translates to:
  /// **'A customer needs me to buy something for them — what should I know?'**
  String get faq7Question;

  /// No description provided for @faq7Answer.
  ///
  /// In en, this message translates to:
  /// **'If the request shows an estimated purchase amount, bring at least that much cash before bidding. Always keep the receipt for the customer.'**
  String get faq7Answer;

  /// No description provided for @kycApprovalPendingError.
  ///
  /// In en, this message translates to:
  /// **'Your account is still waiting on KYC approval.'**
  String get kycApprovalPendingError;

  /// No description provided for @balanceDepletedError.
  ///
  /// In en, this message translates to:
  /// **'Your commission balance is depleted. Top up to go online.'**
  String get balanceDepletedError;

  /// No description provided for @locationPermissionRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to go online'**
  String get locationPermissionRequiredError;

  /// No description provided for @availableDeliveriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Deliveries'**
  String get availableDeliveriesTitle;

  /// No description provided for @earningsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earningsTooltip;

  /// No description provided for @commissionBalanceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Commission Balance'**
  String get commissionBalanceTooltip;

  /// No description provided for @onlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineLabel;

  /// No description provided for @offlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineLabel;

  /// No description provided for @openRequestsHeading.
  ///
  /// In en, this message translates to:
  /// **'Open requests'**
  String get openRequestsHeading;

  /// No description provided for @nearbyCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} nearby'**
  String nearbyCountLabel(int count);

  /// No description provided for @riderRatingSummary.
  ///
  /// In en, this message translates to:
  /// **'★ {rating} · {count}'**
  String riderRatingSummary(String rating, int count);

  /// No description provided for @newRiderLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newRiderLabel;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @zoneRidersOnlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Zone: {zone} · {count} riders online'**
  String zoneRidersOnlineLabel(String zone, int count);

  /// No description provided for @noOpenRequestsDashedMessage.
  ///
  /// In en, this message translates to:
  /// **'No requests available right now.'**
  String get noOpenRequestsDashedMessage;

  /// No description provided for @kycRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your KYC was rejected. Contact support for next steps.'**
  String get kycRejectedMessage;

  /// No description provided for @kycRejectedWithReasonMessage.
  ///
  /// In en, this message translates to:
  /// **'Your KYC was rejected: {reason}. Contact support for next steps.'**
  String kycRejectedWithReasonMessage(String reason);

  /// No description provided for @vehicleZoneMismatchMessage.
  ///
  /// In en, this message translates to:
  /// **'Your vehicle type isn\'t permitted in your current zone — update your vehicle type or region in your profile before going online.'**
  String get vehicleZoneMismatchMessage;

  /// No description provided for @goToProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile'**
  String get goToProfileButton;

  /// No description provided for @kycDocsSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Documents submitted — waiting on admin review.'**
  String get kycDocsSubmittedMessage;

  /// No description provided for @kycUploadPromptMessage.
  ///
  /// In en, this message translates to:
  /// **'Upload your ID and vehicle photo to get approved.'**
  String get kycUploadPromptMessage;

  /// No description provided for @uploadDocumentsButton.
  ///
  /// In en, this message translates to:
  /// **'Upload Documents'**
  String get uploadDocumentsButton;

  /// No description provided for @balanceDepletedBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'Commission balance depleted — top up to go online and accept deliveries.'**
  String get balanceDepletedBannerMessage;

  /// No description provided for @topUpButton.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get topUpButton;

  /// No description provided for @goOnlineToSeeRequestsMessage.
  ///
  /// In en, this message translates to:
  /// **'Go online to see nearby delivery requests.'**
  String get goOnlineToSeeRequestsMessage;

  /// No description provided for @bringCashToPickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Bring ~{amount} SDG to pay at pickup'**
  String bringCashToPickupLabel(String amount);

  /// No description provided for @estimatedWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'≈{weight} kg cargo'**
  String estimatedWeightLabel(String weight);

  /// No description provided for @etaMinutesAwayLabel.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min away'**
  String etaMinutesAwayLabel(int minutes);

  /// No description provided for @bidButton.
  ///
  /// In en, this message translates to:
  /// **'Bid'**
  String get bidButton;

  /// No description provided for @takeAllPhotosError.
  ///
  /// In en, this message translates to:
  /// **'Take all required photos before submitting'**
  String get takeAllPhotosError;

  /// No description provided for @docsSubmittedSnackbarMessage.
  ///
  /// In en, this message translates to:
  /// **'Documents submitted — waiting for admin review.'**
  String get docsSubmittedSnackbarMessage;

  /// No description provided for @uploadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Check your connection and try again.'**
  String get uploadFailedError;

  /// No description provided for @personalIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal ID (Passport or National ID)'**
  String get personalIdLabel;

  /// No description provided for @licenseFrontLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s License — Front'**
  String get licenseFrontLabel;

  /// No description provided for @licenseBackLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s License — Back'**
  String get licenseBackLabel;

  /// No description provided for @vehicleRegFrontLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Registration — Front'**
  String get vehicleRegFrontLabel;

  /// No description provided for @vehicleRegBackLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Registration — Back'**
  String get vehicleRegBackLabel;

  /// No description provided for @kycVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'KYC Verification'**
  String get kycVerificationTitle;

  /// No description provided for @kycInstructions.
  ///
  /// In en, this message translates to:
  /// **'Take a clear photo of the required documents for your vehicle type. An admin will review these before you can start accepting deliveries.'**
  String get kycInstructions;

  /// No description provided for @kycDocNoteBicycle.
  ///
  /// In en, this message translates to:
  /// **'Bicycle riders only need to provide a personal ID.'**
  String get kycDocNoteBicycle;

  /// No description provided for @kycDocNoteOther.
  ///
  /// In en, this message translates to:
  /// **'This vehicle type needs a driver\'s license and vehicle registration, front and back.'**
  String get kycDocNoteOther;

  /// No description provided for @kycPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get kycPendingTitle;

  /// No description provided for @kycPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Your documents are being reviewed by an admin. This usually doesn\'t take long.'**
  String get kycPendingBody;

  /// No description provided for @kycApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get kycApprovedTitle;

  /// No description provided for @kycApprovedBody.
  ///
  /// In en, this message translates to:
  /// **'Your documents are approved — you\'re all set to accept deliveries.'**
  String get kycApprovedBody;

  /// No description provided for @kycRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents Rejected'**
  String get kycRejectedTitle;

  /// No description provided for @kycRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Your documents were rejected. Please retake them and submit again.'**
  String get kycRejectedBody;

  /// No description provided for @docCapturedLabel.
  ///
  /// In en, this message translates to:
  /// **'Captured'**
  String get docCapturedLabel;

  /// No description provided for @docTapToCaptureLabel.
  ///
  /// In en, this message translates to:
  /// **'Tap to capture'**
  String get docTapToCaptureLabel;

  /// No description provided for @submitForReviewButton.
  ///
  /// In en, this message translates to:
  /// **'Submit for Review'**
  String get submitForReviewButton;

  /// No description provided for @tapStarToRateCustomerError.
  ///
  /// In en, this message translates to:
  /// **'Tap a star to rate the customer'**
  String get tapStarToRateCustomerError;

  /// No description provided for @submitRatingError.
  ///
  /// In en, this message translates to:
  /// **'Could not submit rating.'**
  String get submitRatingError;

  /// No description provided for @deliveryCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery Complete'**
  String get deliveryCompleteTitle;

  /// No description provided for @collectedAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Collected: {amount} SDG'**
  String collectedAmountLabel(String amount);

  /// No description provided for @howWasCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'How was this customer?'**
  String get howWasCustomerTitle;

  /// No description provided for @optionalCommentAboutCustomerHint.
  ///
  /// In en, this message translates to:
  /// **'Optional comment about this customer'**
  String get optionalCommentAboutCustomerHint;

  /// No description provided for @submitRatingButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Rating'**
  String get submitRatingButton;

  /// No description provided for @skipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipButton;

  /// No description provided for @newVehicleVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'New vehicle needs new verification'**
  String get newVehicleVerificationTitle;

  /// No description provided for @newVehicleVerificationContent.
  ///
  /// In en, this message translates to:
  /// **'Your account was approved for your current vehicle. Switching to a different one will require you to submit new KYC documents before you can go online again.'**
  String get newVehicleVerificationContent;

  /// No description provided for @vehicleUpdatedReverificationMessage.
  ///
  /// In en, this message translates to:
  /// **'Vehicle updated — upload new KYC documents to go online again.'**
  String get vehicleUpdatedReverificationMessage;

  /// No description provided for @couldNotUpdateVehicleError.
  ///
  /// In en, this message translates to:
  /// **'Could not update vehicle type.'**
  String get couldNotUpdateVehicleError;

  /// No description provided for @vehicleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type'**
  String get vehicleTypeLabel;

  /// No description provided for @plateNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Plate number'**
  String get plateNumberLabel;

  /// No description provided for @approvedForLabel.
  ///
  /// In en, this message translates to:
  /// **'Approved for: {vehicleType}'**
  String approvedForLabel(String vehicleType);

  /// No description provided for @operatingZoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Operating zone'**
  String get operatingZoneLabel;

  /// No description provided for @commissionBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Commission Balance'**
  String get commissionBalanceTitle;

  /// No description provided for @balanceDepletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your balance is depleted. Top up to keep accepting deliveries.'**
  String get balanceDepletedMessage;

  /// No description provided for @topUpViaBankakButton.
  ///
  /// In en, this message translates to:
  /// **'Top Up Balance'**
  String get topUpViaBankakButton;

  /// No description provided for @transactionHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistoryTitle;

  /// No description provided for @commissionDeductionNote.
  ///
  /// In en, this message translates to:
  /// **'A commission is deducted here automatically after each cash/bank-transfer delivery you complete.'**
  String get commissionDeductionNote;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet.'**
  String get noTransactionsYet;

  /// No description provided for @transactionCommissionLabel.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get transactionCommissionLabel;

  /// No description provided for @collectedWord.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collectedWord;

  /// No description provided for @netWord.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get netWord;

  /// No description provided for @transactionTopUpLabel.
  ///
  /// In en, this message translates to:
  /// **'Top-Up'**
  String get transactionTopUpLabel;

  /// No description provided for @autoDeductedLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto-deducted'**
  String get autoDeductedLabel;

  /// No description provided for @viaMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'via {method}'**
  String viaMethodLabel(String method);

  /// No description provided for @deductedLabel.
  ///
  /// In en, this message translates to:
  /// **'deducted'**
  String get deductedLabel;

  /// No description provided for @txStatusVerified.
  ///
  /// In en, this message translates to:
  /// **'verified'**
  String get txStatusVerified;

  /// No description provided for @txStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'rejected'**
  String get txStatusRejected;

  /// No description provided for @txStatusPending.
  ///
  /// In en, this message translates to:
  /// **'pending'**
  String get txStatusPending;

  /// No description provided for @enterValidAmountError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmountError;

  /// No description provided for @enterReferenceCodeError.
  ///
  /// In en, this message translates to:
  /// **'Enter the reference code from your transfer'**
  String get enterReferenceCodeError;

  /// No description provided for @selectPaymentAccountError.
  ///
  /// In en, this message translates to:
  /// **'Select which bank you sent the transfer to'**
  String get selectPaymentAccountError;

  /// No description provided for @topupSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Top-up submitted. It will be verified shortly.'**
  String get topupSubmittedMessage;

  /// No description provided for @topUpCommissionBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Up Commission Balance'**
  String get topUpCommissionBalanceTitle;

  /// No description provided for @howToTopUpTitle.
  ///
  /// In en, this message translates to:
  /// **'How to top up'**
  String get howToTopUpTitle;

  /// No description provided for @topUpStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Choose a bank below and send the amount'**
  String get topUpStep1;

  /// No description provided for @topUpStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Copy the transaction reference code from your banking app'**
  String get topUpStep2;

  /// No description provided for @topUpStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Enter the amount and code below'**
  String get topUpStep3;

  /// No description provided for @topUpStep4.
  ///
  /// In en, this message translates to:
  /// **'4. Your balance updates once an admin verifies it'**
  String get topUpStep4;

  /// No description provided for @noPaymentAccountsMessage.
  ///
  /// In en, this message translates to:
  /// **'No payment accounts configured yet — contact support.'**
  String get noPaymentAccountsMessage;

  /// No description provided for @bankLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bankLabel;

  /// No description provided for @selectAccountToTransferLabel.
  ///
  /// In en, this message translates to:
  /// **'Select an account to transfer to'**
  String get selectAccountToTransferLabel;

  /// No description provided for @amountSdgLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (SDG)'**
  String get amountSdgLabel;

  /// No description provided for @bankakReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Transaction reference code'**
  String get bankakReferenceLabel;

  /// No description provided for @submitTopUpRequestButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Top-Up Request'**
  String get submitTopUpRequestButton;

  /// No description provided for @profileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get profileSetupTitle;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @regionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get regionLabel;

  /// No description provided for @noRegionsAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'No regions available yet — you can set this later from your profile.'**
  String get noRegionsAvailableMessage;

  /// No description provided for @addPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Add a profile photo'**
  String get addPhotoLabel;

  /// No description provided for @photoRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Required — customers will see this on your bids and tracking screen'**
  String get photoRequiredHint;

  /// No description provided for @takePhotoOption.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhotoOption;

  /// No description provided for @chooseFromGalleryOption.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGalleryOption;

  /// No description provided for @profileSetupError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your profile. Try again.'**
  String get profileSetupError;

  /// No description provided for @commissionWaivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Commission waived'**
  String get commissionWaivedLabel;

  /// No description provided for @signInHeading.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to continue'**
  String get signInHeading;

  /// No description provided for @phoneContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get phoneContinueButton;

  /// No description provided for @checkPhoneError.
  ///
  /// In en, this message translates to:
  /// **'Could not verify this phone number. Check your connection and try again.'**
  String get checkPhoneError;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordLink;

  /// No description provided for @wrongPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Try again.'**
  String get wrongPasswordError;

  /// No description provided for @setPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a password'**
  String get setPasswordTitle;

  /// No description provided for @setPasswordInstruction.
  ///
  /// In en, this message translates to:
  /// **'Set a password so you can sign in faster next time without waiting for a code.'**
  String get setPasswordInstruction;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordHint;

  /// No description provided for @showPasswordWord.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get showPasswordWord;

  /// No description provided for @pwRuleLength.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get pwRuleLength;

  /// No description provided for @pwRuleMatch.
  ///
  /// In en, this message translates to:
  /// **'Both fields match'**
  String get pwRuleMatch;

  /// No description provided for @passwordTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShortError;

  /// No description provided for @passwordsDontMatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatchError;

  /// No description provided for @savePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Save Password'**
  String get savePasswordButton;

  /// No description provided for @setPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your password. Try again.'**
  String get setPasswordError;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordInstruction.
  ///
  /// In en, this message translates to:
  /// **'We\'ll text a verification code to {phone}'**
  String forgotPasswordInstruction(String phone);

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need your phone number and password to sign back in.'**
  String get logoutConfirmMessage;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailLabel;

  /// No description provided for @invalidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmailError;

  /// No description provided for @contactSupportButton.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupportButton;

  /// No description provided for @contactSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupportTitle;

  /// No description provided for @callSupportButton.
  ///
  /// In en, this message translates to:
  /// **'Call Support'**
  String get callSupportButton;

  /// No description provided for @whatsappSupportButton.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Support'**
  String get whatsappSupportButton;

  /// No description provided for @emailSupportButton.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupportButton;

  /// No description provided for @supportMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your issue...'**
  String get supportMessageHint;

  /// No description provided for @submitSupportMessageButton.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get submitSupportMessageButton;

  /// No description provided for @supportMessageSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Message sent — our team will get back to you.'**
  String get supportMessageSentMessage;

  /// No description provided for @supportMessageError.
  ///
  /// In en, this message translates to:
  /// **'Could not send your message. Try again.'**
  String get supportMessageError;

  /// No description provided for @describeIssueError.
  ///
  /// In en, this message translates to:
  /// **'Describe your issue before sending'**
  String get describeIssueError;

  /// No description provided for @myTicketsHeading.
  ///
  /// In en, this message translates to:
  /// **'Your Messages'**
  String get myTicketsHeading;

  /// No description provided for @ticketStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Awaiting reply'**
  String get ticketStatusOpen;

  /// No description provided for @ticketStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get ticketStatusResolved;

  /// No description provided for @supportReplyLabel.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportReplyLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
