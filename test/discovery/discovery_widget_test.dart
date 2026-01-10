import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:chefkit/blocs/discovery/discovery_bloc.dart';
import 'package:chefkit/blocs/discovery/discovery_state.dart';
import 'package:chefkit/blocs/discovery/discovery_events.dart';
import 'package:chefkit/blocs/notifications/notifications_bloc.dart';
import 'package:chefkit/blocs/notifications/notifications_event.dart';
import 'package:chefkit/blocs/notifications/notifications_state.dart';
import 'package:chefkit/views/screens/discovery/discovery_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chefkit/l10n/app_localizations.dart';

class MockDiscoveryBloc extends MockBloc<DiscoveryEvent, DiscoveryState>
    implements DiscoveryBloc {}

class MockNotificationsBloc
    extends MockBloc<NotificationsEvent, NotificationsState>
    implements NotificationsBloc {}

void main() {
  late MockDiscoveryBloc mockDiscoveryBloc;
  late MockNotificationsBloc mockNotificationsBloc;

  setUp(() {
    mockDiscoveryBloc = MockDiscoveryBloc();
    mockNotificationsBloc = MockNotificationsBloc();
    when(() => mockNotificationsBloc.state).thenReturn(NotificationsInitial());
  });

  Widget buildWidget(DiscoveryState state) {
    when(() => mockDiscoveryBloc.state).thenReturn(state);
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: MultiBlocProvider(
        providers: [
          BlocProvider<DiscoveryBloc>.value(value: mockDiscoveryBloc),
          BlocProvider<NotificationsBloc>.value(value: mockNotificationsBloc),
        ],
        child: const RecipeDiscoveryScreen(),
      ),
    );
  }

  group('RecipeDiscoveryScreen', () {
    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(buildWidget(DiscoveryState(loading: true)));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state with retry button', (tester) async {
      await tester.pumpWidget(
        buildWidget(DiscoveryState(error: 'Network error')),
      );
      await tester.pump();
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
