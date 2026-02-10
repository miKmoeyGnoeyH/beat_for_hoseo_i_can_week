
enum Period {
  daily("DAILY"), weekly("WEEKLY"), monthly("MONTYLY"), unknown("UNKNOWN");

  const Period(this.value);

  static Period stringToPeriod(String? value) {
    return switch (value) {
      "DAILY" => Period.daily,
      "WEEKLY" => Period.weekly,
      "MONTHYLY" => Period.monthly,
      _ => Period.unknown,
    };
  }

  static int periodToActualDays(Period period) {
    return switch (period) {
      Period.daily => 1,
      Period.weekly => 7,
      Period.monthly => 30,
      Period.unknown => 0,
    };
  }

  final String value;
}