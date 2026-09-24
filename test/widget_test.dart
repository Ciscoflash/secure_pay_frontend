import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:securepay/app.dart';
import 'package:securepay/models/dashboard.dart';
import 'package:securepay/models/notification.dart';
import 'package:securepay/models/shipment.dart';
import 'package:securepay/models/user.dart';
import 'package:securepay/models/wallet.dart';
import 'package:securepay/services/api_client.dart';
import 'package:securepay/services/auth_service.dart';
import 'package:securepay/services/dashboard_service.dart';

const _user = AuthUser(
  id: 'u1',
  name: 'Ada Obi',
  firstName: 'Ada',
  lastName: 'Obi',
  email: 'ada@example.com',
  walletBalance: 300000028,
  emailVerified: true,
);

class FakeAuthService extends AuthService {
  bool rejectToken = false;

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    if (password != 'password123') {
      throw ApiException('Invalid email or password', statusCode: 401);
    }
    return const AuthResult(token: 'tok', user: _user);
  }

  @override
  Future<AuthUser> me(String token) async {
    if (rejectToken) throw ApiException('Token expired', statusCode: 401);
    return _user;
  }
}

Shipment _shipment(String id, {required bool paid}) => Shipment(
  id: id,
  trackingId: 'MAF-100-234-$id',
  sender: 'Bunmi Tanny',
  receiver: 'Mercy',
  pickUp: const Place('Lagos, Nigeria'),
  deliveryTo: const Place('Oyo Nigeria'),
  amount: 300000,
  status: paid ? ShipmentStatus.inTransit : ShipmentStatus.delayed,
  direction: ShipmentDirection.local,
  processingHours: 10,
  isPaid: paid,
);

class FakeDashboardService extends DashboardService {
  int balance = 300000028;
  int unread = 0;
  final items = [_shipment('291', paid: true), _shipment('292', paid: false)];

  @override
  Future<Overview> overview(String token, Period period) async => Overview(
    balance: balance,
    shipments: const StatValue(current: 34, previous: 4, changePct: 750),
    exports: const StatValue(current: 16, previous: 26, changePct: -38),
    imports: const StatValue(current: 12, previous: 0),
  );

  @override
  Future<Growth> growth(String token, Period range) async => Growth(
    labels: [for (var i = 1; i <= 12; i++) '$i'],
    values: const [28, 33, 30, 36, 34, 44, 32, 49, 33, 0, 0, 0],
  );

  @override
  Future<ShipmentPage> shipments(
    String token, {
    int page = 1,
    int limit = 3,
  }) async => ShipmentPage(items: List.of(items), total: items.length);

  @override
  Future<PaymentResult> payShipment(String token, String id) async {
    final paid = _shipment(id, paid: true);
    balance -= paid.amount;
    return PaymentResult(shipment: paid, balance: balance);
  }

  @override
  Future<int> fundWallet(String token, double amountNaira) async {
    balance += (amountNaira * 100).round();
    return balance;
  }

  @override
  Future<WalletAccount> wallet(String token) async => WalletAccount(
    balance: balance,
    accountNumber: '1234567890',
    bankName: 'SecurePay MFB',
    transactions: const [
      WalletTransaction(
        id: 't1',
        type: 'credit',
        amount: 5000000,
        balanceAfter: 305000028,
        description: 'Wallet top-up',
      ),
    ],
  );

  @override
  Future<NotificationPage> notifications(String token) async =>
      NotificationPage(items: [], unread: unread);

  @override
  Future<void> markNotificationRead(String token, String id) async {}

  @override
  Future<void> markAllNotificationsRead(String token) async {}
}

void main() {
  late FakeAuthService auth;
  late FakeDashboardService dashboard;

  setUp(() {
    auth = FakeAuthService();
    dashboard = FakeDashboardService();
  });

  tearDown(Get.reset);

  Future<void> pumpApp(
    WidgetTester tester, {
    Map<String, Object> stored = const {},
  }) async {
    tester.view
      ..physicalSize = const Size(1440, 2200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // A stored token is only enough for guests; dashboard tests also need the
    // cached (verified) profile so the initial route is /dashboard.
    final session = Map<String, Object>.of(stored);
    if (session.containsKey('auth_token') && !session.containsKey('auth_user')) {
      session['auth_user'] = jsonEncode(_user.toJson());
    }
    SharedPreferences.setMockInitialValues(session);
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      SecurePayApp(
        prefs: prefs,
        authService: auth,
        dashboardService: dashboard,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> signIn(WidgetTester tester, String password) async {
    await tester.enterText(find.byType(TextFormField).at(0), 'ada@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), password);
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
  }

  /// Lets any open snackbar finish so no timers are left pending.
  Future<void> settleSnackbars(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  }

  testWidgets('signed-out users land on sign in and see validation', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Sign in to your account'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Enter your email address'), findsOneWidget);
  });

  testWidgets('sign up screen renders all fields', (tester) async {
    await pumpApp(tester);
    Get.toNamed('/sign-up');
    await tester.pumpAndSettle();

    expect(find.text('Create an account'), findsOneWidget);
    for (final label in [
      'First name',
      'Last name',
      'Email',
      'Phone Number',
      'Password',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('+234'), findsOneWidget);
  });

  testWidgets('sign up checks the phone per country and shows strength', (
    tester,
  ) async {
    await pumpApp(tester);
    Get.toNamed('/sign-up');
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(3), '1234567');
    await tester.enterText(fields.at(4), 'password');
    await tester.pump();
    expect(find.text('Weak'), findsOneWidget);

    await tester.tap(find.text('Create account'));
    await tester.pump();
    expect(
      find.text('Enter a valid Nigeria number, e.g. 8012345678'),
      findsOneWidget,
    );
    expect(find.textContaining('Password needs:'), findsOneWidget);

    await tester.enterText(fields.at(3), '08012345678');
    await tester.enterText(fields.at(4), 'Str0ng!Passphrase');
    await tester.pump();
    expect(find.text('Strong'), findsOneWidget);
    expect(find.textContaining('valid Nigeria number'), findsNothing);
    expect(find.textContaining('Password needs:'), findsNothing);
  });

  testWidgets('wrong password shows the server error', (tester) async {
    await pumpApp(tester);
    await signIn(tester, 'wrong-password');

    expect(find.text('Invalid email or password'), findsOneWidget);
    expect(find.text('Sign in to your account'), findsOneWidget);
    await settleSnackbars(tester);
  });

  testWidgets('sign in loads the dashboard from the API', (tester) async {
    await pumpApp(tester);
    await signIn(tester, 'password123');

    expect(find.text('N3,000,000.28'), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('750%'), findsOneWidget);
    expect(find.text('38%'), findsOneWidget); // exports went down
    expect(find.text('MAF-100-234-291'), findsOneWidget);
    expect(find.text('N3,000'), findsNWidgets(2));
  });

  testWidgets('pay now deducts from the wallet and marks it paid', (
    tester,
  ) async {
    await pumpApp(tester, stored: {'auth_token': 'tok'});
    expect(find.text('Pay Now'), findsOneWidget);

    await tester.ensureVisible(find.text('Pay Now'));
    await tester.tap(find.text('Pay Now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pay now')); // confirm dialog
    await tester.pumpAndSettle();

    expect(find.text('Pay Now'), findsNothing);
    expect(find.text('Paid'), findsNWidgets(2));
    expect(find.text('N2,997,000.28'), findsOneWidget);
    await settleSnackbars(tester);
  });

  testWidgets('fund wallet adds to the balance', (tester) async {
    await pumpApp(tester, stored: {'auth_token': 'tok'});

    await tester.tap(find.text('Fund Wallet'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '2500.50');
    await tester.tap(find.text('Add funds'));
    await tester.pumpAndSettle();

    expect(find.text('N3,002,500.78'), findsOneWidget);
    await settleSnackbars(tester);
  });

  testWidgets('collapsing a shipment hides its details', (tester) async {
    await pumpApp(tester, stored: {'auth_token': 'tok'});

    final before = find.text('Pick Up From').evaluate().length;
    await tester.ensureVisible(find.byTooltip('Collapse').first);
    await tester.tap(find.byTooltip('Collapse').first);
    await tester.pumpAndSettle();
    expect(find.text('Pick Up From').evaluate().length, before - 1);
  });

  testWidgets('an expired stored session returns to sign in', (tester) async {
    auth.rejectToken = true;
    await pumpApp(tester, stored: {'auth_token': 'expired'});

    expect(find.text('Sign in to your account'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('auth_token'), isNull);
    await settleSnackbars(tester);
  });

  testWidgets('logout clears the session', (tester) async {
    await pumpApp(tester, stored: {'auth_token': 'tok'});

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in to your account'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('auth_token'), isNull);
  });

  testWidgets('wallet page shows the account number and transactions', (
    tester,
  ) async {
    await pumpApp(tester, stored: {'auth_token': 'tok'});

    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();

    expect(find.text('SecurePay MFB'), findsOneWidget);
    expect(find.text('1 234 567 890'), findsOneWidget);
    expect(find.text('Copy number'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Wallet top-up'), findsOneWidget);
    expect(find.text('+N50,000'), findsOneWidget);
  });

  testWidgets('wallet account number copies to the clipboard', (
    tester,
  ) async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await pumpApp(tester, stored: {'auth_token': 'tok'});
    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Copy number'));
    await tester.pumpAndSettle();

    expect(find.text('Copied'), findsWidgets);
    expect(
      calls.any(
        (c) =>
            c.method == 'Clipboard.setData' &&
            c.arguments.toString().contains('1234567890'),
      ),
      isTrue,
    );
    await settleSnackbars(tester);
  });

  testWidgets('notifications page shows the empty state', (tester) async {
    await pumpApp(tester, stored: {'auth_token': 'tok'});

    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();

    expect(find.text('No notifications yet'), findsOneWidget);
  });

  testWidgets('unread notifications show a sidebar badge', (tester) async {
    dashboard.unread = 3;
    await pumpApp(tester, stored: {'auth_token': 'tok'});

    expect(find.text('3'), findsOneWidget);
  });
}
