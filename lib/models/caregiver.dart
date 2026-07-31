class Caregiver {
  const Caregiver({
    this.id,
    required this.name,
    this.email,
    this.whatsappNumber,
    this.messengerUsername,
  });

  final int? id;
  final String name;
  final String? email;

  /// Digits only (with optional leading country code), e.g. "68612345678".
  final String? whatsappNumber;

  /// A public Messenger username/id, e.g. "john.tabe" (used as `m.me/<this>`).
  final String? messengerUsername;

  Caregiver copyWith({
    int? id,
    String? name,
    String? email,
    String? whatsappNumber,
    String? messengerUsername,
  }) {
    return Caregiver(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      messengerUsername: messengerUsername ?? this.messengerUsername,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'whatsapp_number': whatsappNumber,
      'messenger_username': messengerUsername,
    };
  }

  factory Caregiver.fromMap(Map<String, dynamic> map) {
    return Caregiver(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String?,
      whatsappNumber: map['whatsapp_number'] as String?,
      messengerUsername: map['messenger_username'] as String?,
    );
  }
}
