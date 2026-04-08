class FirebaseKeys {
  // Collections
  static const users = 'users';
  static const groups = 'groups';
  static const members = 'members';
  static const contributions = 'contributions';
  static const auctions = 'auctions';
  static const payouts = 'payouts';
  static const notifications = 'notifications';
  static const messages = 'messages';
  static const fraudAlerts = 'fraud_alerts';
  static const adminActionsLog = 'admin_actions_log';
  static const settings = 'settings';
  static const scoreHistory = 'scoreHistory';

  // Realtime DB paths
  static const rtdbAuctions = 'auctions';
  static const rtdbBids = 'bids';

  // Settings doc
  static const platformSettings = 'platform';

  // Roles
  static const roleMember = 'member';
  static const roleForeman = 'foreman';
  static const roleAdmin = 'admin';
  static const roleSuperAdmin = 'super_admin';

  // Statuses
  static const statusActive = 'active';
  static const statusSuspended = 'suspended';
  static const statusPending = 'pending';
  static const statusVerified = 'verified';
  static const statusSuccess = 'success';
  static const statusFailed = 'failed';
  static const statusOpen = 'open';
  static const statusClosed = 'closed';
  static const statusCompleted = 'completed';
  static const statusHeld = 'held';
  static const statusReleased = 'released';
}
