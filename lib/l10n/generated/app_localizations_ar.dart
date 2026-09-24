// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'وصل - سائق';

  @override
  String get splashTagline => 'طلبك مجاب..لحد الباب';

  @override
  String get splashRiderRoleChip => 'السائق';

  @override
  String get riderSignInHeading => 'تسجيل دخول السائق';

  @override
  String get phoneLoginHeading => 'أدخل اسمك ورقم هاتفك';

  @override
  String get fullNameHint => 'الاسم الكامل';

  @override
  String get phoneHint => '09XXXXXXXX';

  @override
  String get sendCodeButton => 'إرسال الرمز';

  @override
  String get enterNameError => 'أدخل اسمك';

  @override
  String get enterPhoneError => 'أدخل رقم هاتفك';

  @override
  String get otpTitle => 'التحقق من الرمز';

  @override
  String otpCodeSentTo(String phone) {
    return 'تم إرسال الرمز إلى $phone';
  }

  @override
  String get otpHint => '123456';

  @override
  String get verifyButton => 'تحقق';

  @override
  String get enterSixDigitCode => 'أدخل الرمز المكون من 6 أرقام';

  @override
  String get invalidCodeError => 'رمز غير صحيح. حاول مرة أخرى.';

  @override
  String get verificationFailedError => 'فشل التحقق. حاول مرة أخرى.';

  @override
  String get profileTitle => 'ملفي الشخصي';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get saveChangesButton => 'حفظ التغييرات';

  @override
  String get faqButton => 'الأسئلة الشائعة';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get languageSystemDefault => 'لغة النظام';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get goOnlineLabel => 'الاتصال بالإنترنت';

  @override
  String get goOfflineLabel => 'قطع الاتصال';

  @override
  String get noOpenRequests => 'لا توجد طلبات متاحة الآن.';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get confirmButton => 'تأكيد';

  @override
  String get continueButton => 'متابعة';

  @override
  String get backButton => 'رجوع';

  @override
  String get reasonOther => 'أخرى';

  @override
  String get reportProblemTitle => 'الإبلاغ عن مشكلة';

  @override
  String get tellUsMoreHint => 'أخبرنا المزيد...';

  @override
  String get confirmCancellationButton => 'تأكيد الإلغاء';

  @override
  String get keepItButton => 'الاحتفاظ به';

  @override
  String get reasonLabel => 'السبب';

  @override
  String get additionalDetailsHint => 'تفاصيل إضافية (اختياري)';

  @override
  String get submitReportButton => 'إرسال البلاغ';

  @override
  String get reportSubmittedMessage => 'تم إرسال البلاغ. سيتابع فريقنا الأمر.';

  @override
  String get profileTooltip => 'الملف الشخصي';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي.';

  @override
  String get couldNotMarkPickedUpError => 'تعذر تعليم الطلب كمستلم.';

  @override
  String get couldNotMarkArrivedError => 'تعذر تسجيل الوصول.';

  @override
  String get couldNotStartWaitingFeeError => 'تعذر بدء رسوم الانتظار.';

  @override
  String get startWaitingFeeButton => 'فرض رسوم انتظار';

  @override
  String get waitingFeeActiveLabel => 'رسوم الانتظار مفعّلة';

  @override
  String get customerIsComingLabel => 'العميل في طريقه إليك';

  @override
  String waitingGracePeriodLabel(String remaining) {
    return 'الوقت المجاني المتبقي: $remaining';
  }

  @override
  String get enterDeliveryCodeTitle => 'أدخل رمز التوصيل';

  @override
  String get deliveryCodeInstruction =>
      'اطلب من العميل الرمز المكون من 4 أرقام الظاهر في شاشة التتبع الخاصة به.';

  @override
  String get deliveryCodeHint => '1234';

  @override
  String get couldNotCompleteDeliveryError => 'تعذر إكمال عملية التوصيل.';

  @override
  String get customerFallbackName => 'العميل';

  @override
  String get cancelDeliveryError => 'تعذر إلغاء هذا التوصيل.';

  @override
  String get couldNotOpenMapsError => 'تعذر فتح خرائط جوجل.';

  @override
  String get cancelDeliveryDialogTitle => 'هل تريد إلغاء هذا التوصيل؟';

  @override
  String get reasonVehicleIssue => 'مشكلة في المركبة';

  @override
  String get reasonPersonalEmergency => 'طارئ شخصي';

  @override
  String get reasonCustomerUnreachable => 'تعذر الوصول إلى العميل';

  @override
  String get reasonDistanceTooFar => 'المسافة بعيدة جدًا';

  @override
  String get reasonWrongAddress => 'عنوان خاطئ';

  @override
  String get reasonCustomerRefusedDelivery => 'رفض العميل استلام الطلب';

  @override
  String get reasonSafetyConcern => 'مخاوف تتعلق بالسلامة';

  @override
  String get activeDeliveryTitle => 'التوصيل النشط';

  @override
  String get dropoffLabel => 'التوصيل';

  @override
  String get pickupLabel => 'الاستلام';

  @override
  String get orderDetailTitle => 'تفاصيل التوصيل';

  @override
  String get customerLabel => 'العميل';

  @override
  String get contactPhoneLabel => 'رقم التواصل';

  @override
  String get priceLabel => 'السعر';

  @override
  String headingToLabel(String destination) {
    return 'متجه إلى $destination';
  }

  @override
  String get headingToWord => 'متجه إلى';

  @override
  String etaApproxMinutes(int minutes) {
    return '~$minutes دقيقة';
  }

  @override
  String packageLabel(String description) {
    return 'الطرد: $description';
  }

  @override
  String amountToCollectLabel(String amount) {
    return 'المبلغ الواجب تحصيله: $amount جنيه سوداني';
  }

  @override
  String get receiverContactLabel => 'المستلم: ';

  @override
  String get pickupContactLabel => 'جهة اتصال الاستلام: ';

  @override
  String get navigateWithGoogleMapsButton => 'التنقل عبر خرائط جوجل';

  @override
  String get markDeliveredButton => 'تعليم كموصّل';

  @override
  String get markPickedUpButton => 'تعليم كمستلم';

  @override
  String get markArrivedButton => 'لقد وصلت';

  @override
  String get enterValidPriceError => 'أدخل سعرًا صحيحًا';

  @override
  String maxAllowedBidError(String maxBid) {
    return 'الحد الأقصى للعرض المسموح به لهذه المسافة هو $maxBid جنيه سوداني';
  }

  @override
  String get bidSubmittedMessage => 'تم إرسال العرض! بانتظار رد العميل.';

  @override
  String get couldNotSubmitBidError => 'تعذر إرسال العرض.';

  @override
  String get placeYourBidTitle => 'قدّم عرضك';

  @override
  String pickupAddressLine(String address) {
    return 'الاستلام: $address';
  }

  @override
  String dropoffAddressLine(String address) {
    return 'التوصيل: $address';
  }

  @override
  String purchaseBudgetWarning(String amount) {
    return 'ستحتاج إلى دفع ~$amount جنيه سوداني عند الاستلام — أحضر هذا المبلغ نقدًا قبل تقديم عرضك.';
  }

  @override
  String basePriceLabel(String price) {
    return 'السعر الأساسي: $price جنيه سوداني';
  }

  @override
  String get basePriceTag => 'الأساسي';

  @override
  String get balanceLabel => 'الرصيد';

  @override
  String maxBidAllowedLabel(String maxBid) {
    return 'الحد الأقصى للعرض المسموح به: $maxBid جنيه سوداني';
  }

  @override
  String get yourPriceLabel => 'سعرك (جنيه سوداني)';

  @override
  String get etaAutoCalculatedNote =>
      'يتم حساب وقت وصولك تلقائيًا من موقعك الحالي.';

  @override
  String get submitBidButton => 'إرسال العرض';

  @override
  String get earningsTitle => 'الأرباح';

  @override
  String completedDeliveriesCount(int count) {
    return '$count عملية توصيل مكتملة';
  }

  @override
  String totalCollectedLabel(String amount) {
    return 'تم تحصيل $amount جنيه سوداني';
  }

  @override
  String commissionNetSummary(String commission, String net) {
    return 'تم دفع $commission جنيه سوداني كعمولة · صافي الربح $net جنيه سوداني';
  }

  @override
  String get noCompletedDeliveriesYet => 'لا توجد عمليات توصيل مكتملة بعد.';

  @override
  String get noDescriptionPlaceholder => '(بدون وصف)';

  @override
  String priceSdgLabel(String amount) {
    return '$amount جنيه سوداني';
  }

  @override
  String feeDeductedLabel(String amount) {
    return '-$amount رسوم';
  }

  @override
  String get faqTitle => 'الأسئلة الشائعة';

  @override
  String get faq1Question => 'لماذا لا يمكنني الاتصال بالإنترنت بعد؟';

  @override
  String get faq1Answer =>
      'تبقى الحسابات الجديدة معلقة حتى يراجع أحد المسؤولين مستندات التحقق الخاصة بك (صورة الهوية وصورة المركبة). أرسل هذه المستندات من الشريط الموجود في شاشتك الرئيسية — ستتمكن من الاتصال بالإنترنت بمجرد الموافقة عليها.';

  @override
  String get faq2Question => 'كيف يعمل رصيد المحفظة؟';

  @override
  String get faq2Answer =>
      'يتم خصم عمولة صغيرة من رصيد محفظتك في كل مرة تكمل فيها عملية توصيل. اشحن رصيدك عبر تحويل بنكي من شاشة المحفظة — إذا نفد رصيدك، لن تتمكن من الاتصال بالإنترنت حتى تعيد الشحن.';

  @override
  String get faq3Question => 'ماذا يحدث إذا غيّرت نوع مركبتي؟';

  @override
  String get faq3Answer =>
      'ترتبط موافقة التحقق الخاصة بك بالمركبة التي تم التحقق منها. التبديل إلى نوع مركبة مختلف يعيد حسابك إلى حالة الانتظار ويتطلب مستندات جديدة قبل أن تتمكن من الاتصال بالإنترنت مرة أخرى.';

  @override
  String get faq4Question => 'لماذا لا يمكنني تقديم عروض في بعض المناطق؟';

  @override
  String get faq4Answer =>
      'بعض المناطق تسمح فقط بأنواع معينة من المركبات (مثل مناطق الدراجات الهوائية فقط). إذا لم تكن مركبتك مسموحًا بها في منطقة ما، سيتم رفض عروضك هناك تلقائيًا.';

  @override
  String get faq5Question => 'كيف أكمل عملية توصيل؟';

  @override
  String get faq5Answer =>
      'اطلب من العميل رمز التأكيد المكون من 4 أرقام الظاهر في شاشة التتبع الخاصة به، ثم أدخله عند الضغط على \"تعليم كموصّل\". هذا الأمر مطلوب — فهو إثبات أنك أكملت عملية التوصيل فعليًا.';

  @override
  String get faq6Question => 'ماذا لو احتجت إلى الإلغاء بعد قبول عرض؟';

  @override
  String get faq6Answer =>
      'يمكنك الإلغاء قبل استلام الطرد — وهذا يعيد فتح الطلب لسائقين آخرين لتقديم عروضهم بدلاً من ترك العميل بلا حل. حاول تجنب ذلك قدر الإمكان، لأن العملاء يرون ذلك.';

  @override
  String get faq7Question => 'يحتاجني عميل لشراء شيء له — ماذا يجب أن أعرف؟';

  @override
  String get faq7Answer =>
      'إذا أظهر الطلب مبلغًا تقديريًا للشراء، أحضر على الأقل هذا المبلغ نقدًا قبل تقديم عرضك. احتفظ دائمًا بالإيصال للعميل.';

  @override
  String get kycApprovalPendingError => 'حسابك لا يزال بانتظار موافقة التحقق.';

  @override
  String get balanceDepletedError =>
      'رصيد عمولتك نفد. اشحن رصيدك للاتصال بالإنترنت.';

  @override
  String get locationPermissionRequiredError =>
      'إذن الموقع مطلوب للاتصال بالإنترنت';

  @override
  String get availableDeliveriesTitle => 'الطلبات المتاحة';

  @override
  String get earningsTooltip => 'الأرباح';

  @override
  String get commissionBalanceTooltip => 'رصيد العمولة';

  @override
  String get onlineLabel => 'متصل';

  @override
  String get offlineLabel => 'غير متصل';

  @override
  String get openRequestsHeading => 'الطلبات المفتوحة';

  @override
  String nearbyCountLabel(int count) {
    return '$count قريب';
  }

  @override
  String riderRatingSummary(String rating, int count) {
    return '★ $rating · $count';
  }

  @override
  String get newRiderLabel => 'جديد';

  @override
  String get todayLabel => 'اليوم';

  @override
  String zoneRidersOnlineLabel(String zone, int count) {
    return 'المنطقة: $zone · $count سائق متصل';
  }

  @override
  String get noOpenRequestsDashedMessage => 'لا توجد طلبات متاحة الآن.';

  @override
  String get kycRejectedMessage =>
      'تم رفض طلب التحقق الخاص بك. تواصل مع الدعم لمعرفة الخطوات التالية.';

  @override
  String kycRejectedWithReasonMessage(String reason) {
    return 'تم رفض طلب التحقق الخاص بك: $reason. تواصل مع الدعم لمعرفة الخطوات التالية.';
  }

  @override
  String get vehicleZoneMismatchMessage =>
      'نوع مركبتك غير مسموح به في منطقتك الحالية — قم بتحديث نوع مركبتك أو منطقتك من ملفك الشخصي قبل الاتصال بالإنترنت.';

  @override
  String get goToProfileButton => 'الذهاب إلى الملف الشخصي';

  @override
  String get kycDocsSubmittedMessage =>
      'تم إرسال المستندات — بانتظار مراجعة المسؤول.';

  @override
  String get kycUploadPromptMessage =>
      'قم بتحميل صورة هويتك وصورة مركبتك للحصول على الموافقة.';

  @override
  String get uploadDocumentsButton => 'تحميل المستندات';

  @override
  String get balanceDepletedBannerMessage =>
      'رصيد العمولة نفد — اشحن رصيدك للاتصال بالإنترنت وقبول الطلبات.';

  @override
  String get topUpButton => 'شحن الرصيد';

  @override
  String get goOnlineToSeeRequestsMessage =>
      'اتصل بالإنترنت لرؤية طلبات التوصيل القريبة.';

  @override
  String bringCashToPickupLabel(String amount) {
    return 'أحضر ~$amount جنيه سوداني للدفع عند الاستلام';
  }

  @override
  String estimatedWeightLabel(String weight) {
    return '≈$weight كجم من البضاعة';
  }

  @override
  String etaMinutesAwayLabel(int minutes) {
    return 'على بعد $minutes دقيقة';
  }

  @override
  String get bidButton => 'تقديم عرض';

  @override
  String get takeAllPhotosError => 'التقط جميع الصور المطلوبة قبل الإرسال';

  @override
  String get docsSubmittedSnackbarMessage =>
      'تم إرسال المستندات — بانتظار مراجعة المسؤول.';

  @override
  String get uploadFailedError => 'فشل الرفع. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get personalIdLabel => 'الهوية الشخصية (جواز سفر أو بطاقة وطنية)';

  @override
  String get licenseFrontLabel => 'رخصة القيادة — الوجه الأمامي';

  @override
  String get licenseBackLabel => 'رخصة القيادة — الوجه الخلفي';

  @override
  String get vehicleRegFrontLabel => 'استمارة المركبة — الوجه الأمامي';

  @override
  String get vehicleRegBackLabel => 'استمارة المركبة — الوجه الخلفي';

  @override
  String get kycVerificationTitle => 'التحقق من الهوية';

  @override
  String get kycInstructions =>
      'التقط صورة واضحة للمستندات المطلوبة لنوع مركبتك. سيراجع المسؤول هذه المستندات قبل أن تتمكن من بدء قبول الطلبات.';

  @override
  String get kycDocNoteBicycle =>
      'سائقو الدراجات الهوائية يحتاجون الهوية الشخصية فقط.';

  @override
  String get kycDocNoteOther =>
      'هذا النوع من المركبات يحتاج رخصة قيادة واستمارة المركبة، الوجه والظهر.';

  @override
  String get kycPendingTitle => 'قيد المراجعة';

  @override
  String get kycPendingBody =>
      'يقوم أحد المسؤولين بمراجعة مستنداتك الآن. عادة لا يستغرق هذا وقتًا طويلاً.';

  @override
  String get kycApprovedTitle => 'تمت الموافقة';

  @override
  String get kycApprovedBody =>
      'تمت الموافقة على مستنداتك — يمكنك الآن قبول طلبات التوصيل.';

  @override
  String get kycRejectedTitle => 'تم رفض المستندات';

  @override
  String get kycRejectedBody =>
      'تم رفض مستنداتك. يرجى إعادة تصويرها وإرسالها مجددًا.';

  @override
  String get docCapturedLabel => 'تم التصوير';

  @override
  String get docTapToCaptureLabel => 'اضغط للتصوير';

  @override
  String get submitForReviewButton => 'إرسال للمراجعة';

  @override
  String get tapStarToRateCustomerError => 'اضغط على نجمة لتقييم العميل';

  @override
  String get submitRatingError => 'تعذر إرسال التقييم.';

  @override
  String get deliveryCompleteTitle => 'اكتمل التوصيل';

  @override
  String collectedAmountLabel(String amount) {
    return 'تم تحصيل: $amount جنيه سوداني';
  }

  @override
  String get howWasCustomerTitle => 'كيف كان هذا العميل؟';

  @override
  String get optionalCommentAboutCustomerHint => 'تعليق اختياري عن هذا العميل';

  @override
  String get submitRatingButton => 'إرسال التقييم';

  @override
  String get skipButton => 'تخطي';

  @override
  String get newVehicleVerificationTitle =>
      'المركبة الجديدة تحتاج إلى تحقق جديد';

  @override
  String get newVehicleVerificationContent =>
      'تمت الموافقة على حسابك لمركبتك الحالية. التبديل إلى مركبة مختلفة سيتطلب منك إرسال مستندات تحقق جديدة قبل أن تتمكن من الاتصال بالإنترنت مرة أخرى.';

  @override
  String get vehicleUpdatedReverificationMessage =>
      'تم تحديث المركبة — قم بتحميل مستندات تحقق جديدة للاتصال بالإنترنت مرة أخرى.';

  @override
  String get couldNotUpdateVehicleError => 'تعذر تحديث نوع المركبة.';

  @override
  String get vehicleTypeLabel => 'نوع المركبة';

  @override
  String get plateNumberLabel => 'رقم اللوحة';

  @override
  String approvedForLabel(String vehicleType) {
    return 'تمت الموافقة لـ: $vehicleType';
  }

  @override
  String get operatingZoneLabel => 'منطقة العمل';

  @override
  String get commissionBalanceTitle => 'رصيد العمولة';

  @override
  String get balanceDepletedMessage =>
      'رصيدك نفد. اشحن رصيدك لمواصلة قبول الطلبات.';

  @override
  String get topUpViaBankakButton => 'شحن الرصيد';

  @override
  String get transactionHistoryTitle => 'سجل المعاملات';

  @override
  String get commissionDeductionNote =>
      'يتم خصم العمولة هنا تلقائيًا بعد كل عملية توصيل نقدية أو عبر تحويل بنكي تكملها.';

  @override
  String get noTransactionsYet => 'لا توجد معاملات بعد.';

  @override
  String get transactionCommissionLabel => 'عمولة';

  @override
  String get collectedWord => 'المبلغ المحصّل';

  @override
  String get netWord => 'الصافي';

  @override
  String get transactionTopUpLabel => 'شحن رصيد';

  @override
  String get autoDeductedLabel => 'خصم تلقائي';

  @override
  String viaMethodLabel(String method) {
    return 'عبر $method';
  }

  @override
  String get deductedLabel => 'تم الخصم';

  @override
  String get txStatusVerified => 'تم التحقق';

  @override
  String get txStatusRejected => 'مرفوض';

  @override
  String get txStatusPending => 'قيد الانتظار';

  @override
  String get enterValidAmountError => 'أدخل مبلغًا صحيحًا';

  @override
  String get enterReferenceCodeError => 'أدخل رمز المرجع من عملية التحويل';

  @override
  String get selectPaymentAccountError => 'اختر البنك الذي أرسلت إليه التحويل';

  @override
  String get topupSubmittedMessage =>
      'تم إرسال طلب الشحن. سيتم التحقق منه قريبًا.';

  @override
  String get topUpCommissionBalanceTitle => 'شحن رصيد العمولة';

  @override
  String get howToTopUpTitle => 'كيفية شحن الرصيد';

  @override
  String get topUpStep1 => '1. اختر بنكًا أدناه وأرسل المبلغ';

  @override
  String get topUpStep2 => '2. انسخ رمز مرجع المعاملة من تطبيق البنك';

  @override
  String get topUpStep3 => '3. أدخل المبلغ والرمز أدناه';

  @override
  String get topUpStep4 => '4. يتم تحديث رصيدك بمجرد تحقق أحد المسؤولين منه';

  @override
  String get noPaymentAccountsMessage =>
      'لا توجد حسابات دفع مُعدّة بعد — تواصل مع الدعم.';

  @override
  String get bankLabel => 'البنك';

  @override
  String get selectAccountToTransferLabel => 'اختر حسابًا للتحويل إليه';

  @override
  String get amountSdgLabel => 'المبلغ (جنيه سوداني)';

  @override
  String get bankakReferenceLabel => 'رمز مرجع المعاملة';

  @override
  String get submitTopUpRequestButton => 'إرسال طلب الشحن';

  @override
  String get profileSetupTitle => 'أكمل ملفك الشخصي';

  @override
  String get genderLabel => 'الجنس';

  @override
  String get genderMale => 'ذكر';

  @override
  String get genderFemale => 'أنثى';

  @override
  String get regionLabel => 'المنطقة';

  @override
  String get noRegionsAvailableMessage =>
      'لا توجد مناطق متاحة بعد — يمكنك تحديد ذلك لاحقًا من ملفك الشخصي.';

  @override
  String get addPhotoLabel => 'إضافة صورة شخصية';

  @override
  String get photoRequiredHint =>
      'مطلوبة — سيراها العملاء في عروضك وشاشة التتبع';

  @override
  String get takePhotoOption => 'التقاط صورة';

  @override
  String get chooseFromGalleryOption => 'الاختيار من المعرض';

  @override
  String get profileSetupError => 'تعذر حفظ ملفك الشخصي. حاول مرة أخرى.';

  @override
  String get commissionWaivedLabel => 'تم إعفاء العمولة';

  @override
  String get signInHeading => 'أدخل رقم هاتفك للمتابعة';

  @override
  String get phoneContinueButton => 'متابعة';

  @override
  String get checkPhoneError =>
      'تعذر التحقق من رقم الهاتف. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get passwordHint => 'كلمة المرور';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get forgotPasswordLink => 'نسيت كلمة المرور؟';

  @override
  String get wrongPasswordError => 'كلمة المرور غير صحيحة. حاول مرة أخرى.';

  @override
  String get setPasswordTitle => 'تعيين كلمة مرور';

  @override
  String get setPasswordInstruction =>
      'عيّن كلمة مرور لتسجيل الدخول بشكل أسرع في المرة القادمة دون انتظار رمز التحقق.';

  @override
  String get newPasswordHint => 'كلمة مرور جديدة';

  @override
  String get confirmPasswordHint => 'تأكيد كلمة المرور';

  @override
  String get showPasswordWord => 'إظهار';

  @override
  String get pwRuleLength => '6 أحرف على الأقل';

  @override
  String get pwRuleMatch => 'الحقلان متطابقان';

  @override
  String get passwordTooShortError =>
      'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';

  @override
  String get passwordsDontMatchError => 'كلمتا المرور غير متطابقتين';

  @override
  String get savePasswordButton => 'حفظ كلمة المرور';

  @override
  String get setPasswordError => 'تعذر حفظ كلمة المرور. حاول مرة أخرى.';

  @override
  String get forgotPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String forgotPasswordInstruction(String phone) {
    return 'سنرسل رمز تحقق عبر رسالة نصية إلى $phone';
  }

  @override
  String get logoutButton => 'تسجيل الخروج';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get logoutConfirmMessage =>
      'ستحتاج إلى رقم هاتفك وكلمة المرور لتسجيل الدخول مرة أخرى.';

  @override
  String get emailLabel => 'البريد الإلكتروني (اختياري)';

  @override
  String get invalidEmailError => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get contactSupportButton => 'تواصل مع الدعم';

  @override
  String get contactSupportTitle => 'تواصل مع الدعم';

  @override
  String get callSupportButton => 'اتصل بالدعم';

  @override
  String get whatsappSupportButton => 'واتساب الدعم';

  @override
  String get emailSupportButton => 'البريد الإلكتروني للدعم';

  @override
  String get supportMessageHint => 'صف مشكلتك...';

  @override
  String get submitSupportMessageButton => 'إرسال الرسالة';

  @override
  String get supportMessageSentMessage =>
      'تم إرسال الرسالة — سيتواصل معك فريقنا قريبًا.';

  @override
  String get supportMessageError => 'تعذر إرسال رسالتك. حاول مرة أخرى.';

  @override
  String get describeIssueError => 'صف مشكلتك قبل الإرسال';

  @override
  String get myTicketsHeading => 'رسائلك';

  @override
  String get ticketStatusOpen => 'بانتظار الرد';

  @override
  String get ticketStatusResolved => 'تم الحل';

  @override
  String get supportReplyLabel => 'الدعم';
}
