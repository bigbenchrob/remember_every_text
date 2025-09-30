/// Constants and helpers for the working database schema.

/// Supported service carrier values for identities and chats.
enum CarrierServiceType {
  iMessage('iMessage'),
  iMessageLite('iMessageLite'),
  sms('SMS'),
  rcs('RCS'),
  unknown('Unknown');

  const CarrierServiceType(this.value);

  /// String value stored in the database.
  final String value;
}

/// Ordered list of carrier service string values.
const carrierServiceValues = <String>[
  'iMessage',
  'iMessageLite',
  'SMS',
  'RCS',
  'Unknown',
];

/// Default service value when no carrier is specified.
const String carrierServiceUnknownValue = 'Unknown';

/// SQL constraint applied to service columns for identities and chats.
const String carrierServiceCheckConstraint =
    "NOT NULL DEFAULT 'Unknown' CHECK(service IN ('iMessage','iMessageLite','SMS','RCS','Unknown'))";
