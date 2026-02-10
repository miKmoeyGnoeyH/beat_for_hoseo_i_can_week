abstract final class BEATAssets {
  BEATAssets._();

  static const svg = _Svgs._();
  static const images = _Images._();
}

class _Svgs {
  const _Svgs._();

  /// logo
  final String greenCampusLogoType1 = 'assets/svg/green_campus_logo_type1.svg';
  final String greenCampusLogoType2 = 'assets/svg/green_campus_logo_type2.svg';
  final String greenCampusLogoType3 = 'assets/svg/green_campus_logo_type3.svg';

  /// icons
  final String leaderboard = 'assets/svg/leaderboard.svg';
  final String notification = 'assets/svg/notification.svg';
  final String settings = 'assets/svg/settings.svg';
  final String home = 'assets/svg/home.svg';
  final String qr = 'assets/svg/qr.svg';
  final String profile = 'assets/svg/profile.svg';
  final String hori = 'assets/svg/hori.svg';
  final String footprint = 'assets/svg/footprint.svg';
}

class _Images {
  const _Images._();

  final String greenCampusPoint = 'assets/images/green_campus_point.png';
  final String greenCampusPoints = 'assets/images/green_campus_points.png';
}