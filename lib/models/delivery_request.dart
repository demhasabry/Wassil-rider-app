import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus { open, assigned, pickedUp, delivered, cancelled }

RequestStatus requestStatusFromString(String value) {
  switch (value) {
    case 'open':
      return RequestStatus.open;
    case 'assigned':
      return RequestStatus.assigned;
    case 'picked_up':
      return RequestStatus.pickedUp;
    case 'delivered':
      return RequestStatus.delivered;
    case 'cancelled':
      return RequestStatus.cancelled;
    default:
      throw ArgumentError('Unknown request status: $value');
  }
}

class DeliveryRequest {
  final String id;
  final String customerId;
  final String? customerName;
  final String? customerPhone;
  final String? customerPhotoUrl;
  final GeoPoint pickup;
  final String pickupAddress;
  final GeoPoint dropoff;
  final String dropoffAddress;
  final String packageDescription;
  final String sizeCategory; // small | medium | large
  // Only set for tuk-tuk/truck requests (customer_app requires it there) —
  // a loaded vehicle burns more fuel than an empty one, so this is shown to
  // the rider alongside the price so they can judge the job, not just a
  // number baked silently into suggestedPrice.
  final double? estimatedWeightKg;
  final double? purchaseBudget;
  final double? suggestedPrice;
  final RequestStatus status;
  final String? acceptedBidId;
  final String? assignedRiderId;
  final String zone;
  final DateTime createdAt;
  final DateTime biddingClosesAt;
  final int? etaToPickupMinutes;
  final int? etaToDropoffMinutes;
  final String? pickupContactPhone;
  final String? receiverContactPhone;
  final String? deliveryConfirmationCode;
  final double? agreedPrice;
  final bool hasArrived;
  final DateTime? arrivedAt;
  final DateTime? waitingFeeStartedAt;
  // Set once the customer taps "I'm Coming" on their own arrival notice
  // (see acknowledgeArrival.js) — lets the rider see the customer has
  // actually acknowledged, instead of just waiting blind.
  final DateTime? arrivalAcknowledgedAt;

  DeliveryRequest({
    required this.id,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerPhotoUrl,
    required this.pickup,
    required this.pickupAddress,
    required this.dropoff,
    required this.dropoffAddress,
    required this.packageDescription,
    required this.sizeCategory,
    this.estimatedWeightKg,
    this.purchaseBudget,
    this.suggestedPrice,
    required this.status,
    this.acceptedBidId,
    this.assignedRiderId,
    required this.zone,
    required this.createdAt,
    required this.biddingClosesAt,
    this.etaToPickupMinutes,
    this.etaToDropoffMinutes,
    this.pickupContactPhone,
    this.receiverContactPhone,
    this.deliveryConfirmationCode,
    this.agreedPrice,
    this.hasArrived = false,
    this.arrivedAt,
    this.waitingFeeStartedAt,
    this.arrivalAcknowledgedAt,
  });

  factory DeliveryRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeliveryRequest(
      id: doc.id,
      customerId: data['customerId'] as String,
      customerName: data['customerName'] as String?,
      customerPhone: data['customerPhone'] as String?,
      customerPhotoUrl: data['customerPhotoUrl'] as String?,
      pickup: data['pickup']['geopoint'] as GeoPoint,
      pickupAddress: data['pickup']['address'] as String,
      dropoff: data['dropoff']['geopoint'] as GeoPoint,
      dropoffAddress: data['dropoff']['address'] as String,
      packageDescription: data['packageInfo']['description'] as String,
      sizeCategory: data['packageInfo']['sizeCategory'] as String,
      estimatedWeightKg: (data['packageInfo']['estimatedWeightKg'] as num?)?.toDouble(),
      purchaseBudget: (data['packageInfo']['purchaseBudget'] as num?)?.toDouble(),
      suggestedPrice: (data['suggestedPrice'] as num?)?.toDouble(),
      status: requestStatusFromString(data['status'] as String),
      acceptedBidId: data['acceptedBidId'] as String?,
      assignedRiderId: data['assignedRiderId'] as String?,
      zone: data['zone'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      biddingClosesAt: (data['biddingClosesAt'] as Timestamp).toDate(),
      etaToPickupMinutes: (data['etaToPickupMinutes'] as num?)?.toInt(),
      etaToDropoffMinutes: (data['etaToDropoffMinutes'] as num?)?.toInt(),
      pickupContactPhone: data['pickupContactPhone'] as String?,
      receiverContactPhone: data['receiverContactPhone'] as String?,
      deliveryConfirmationCode: data['deliveryConfirmationCode'] as String?,
      agreedPrice: (data['agreedPrice'] as num?)?.toDouble(),
      hasArrived: data['hasArrived'] as bool? ?? false,
      arrivedAt: (data['arrivedAt'] as Timestamp?)?.toDate(),
      waitingFeeStartedAt: (data['waitingFeeStartedAt'] as Timestamp?)?.toDate(),
      arrivalAcknowledgedAt: (data['arrivalAcknowledgedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestoreCreate() {
    // Only the fields a customer is allowed to set on creation.
    // status/acceptedBidId/assignedRiderId are set server-side.
    return {
      'customerId': customerId,
      'pickup': {'geopoint': pickup, 'address': pickupAddress},
      'dropoff': {'geopoint': dropoff, 'address': dropoffAddress},
      'packageInfo': {
        'description': packageDescription,
        'sizeCategory': sizeCategory,
      },
      'suggestedPrice': suggestedPrice,
      'status': 'open',
      'zone': zone,
      'createdAt': FieldValue.serverTimestamp(),
      'biddingClosesAt': Timestamp.fromDate(
        DateTime.now().add(const Duration(seconds: 60)),
      ),
      'pickupContactPhone': pickupContactPhone,
      'receiverContactPhone': receiverContactPhone,
    };
  }
}
