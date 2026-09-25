import 'app_icon.dart';
enum NavDestination {
  dashboard('Dashboard', AppIcons.dashboard),
  shipments('Shipments', AppIcons.shipments),
  services('Our Services', AppIcons.services),
  notifications('Notifications', AppIcons.notifications),
  wallet('Wallet', AppIcons.wallet),
  addresses('My Addresses', AppIcons.addresses),
  invite('Invite & Earn', AppIcons.invite),
  help('Help Center', AppIcons.help);
  const NavDestination(this.label, this.icon);
  final String label;
  final AppIcons icon;
  String get pageTitle => switch (this) {
    NavDestination.dashboard => 'Invite & Earn',
    NavDestination.wallet => 'Wallet',
    NavDestination.notifications => 'Notifications',
    NavDestination.shipments => 'Shipments',
    NavDestination.services => 'Our Services',
    NavDestination.addresses => 'My Addresses',
    NavDestination.invite => 'Invite & Earn',
    NavDestination.help => 'Help Center',
  };
  String get pageSubtitle => switch (this) {
    NavDestination.dashboard => 'Keep track of your addresses, location '
        'updates. Edit, Delete, Update and see all your saved addresses',
    NavDestination.wallet =>
      'View your balance, account number and recent transactions.',
    NavDestination.notifications =>
      'Stay updated on your wallet and shipments.',
    NavDestination.shipments => 'Create and track your shipments in one place.',
    NavDestination.services => 'Everything SecurePay offers, in one place.',
    NavDestination.addresses => 'Save and manage the addresses you ship to.',
    NavDestination.invite => 'Refer friends and earn rewards on their shipments.',
    NavDestination.help => 'Answers to common questions about SecurePay.',
  };
}