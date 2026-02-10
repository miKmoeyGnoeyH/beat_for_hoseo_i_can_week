enum EventType {
  walk("WALK"), qr("QR"), unknown("UNKNOWN");

  const EventType(this.value);

  static EventType stringToEventType(String? value) {
    return switch (value) {
      "WALK" => EventType.walk,
      "QR" => EventType.qr,
      _ => EventType.unknown,
    };
  }

  final String value;
}