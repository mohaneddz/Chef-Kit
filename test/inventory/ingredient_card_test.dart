import 'dart:async';
import 'dart:typed_data';

import 'package:chefkit/views/widgets/inventory/ingredient_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestAssetBundle extends CachingAssetBundle {
  static final Uint8List _transparentImage = Uint8List.fromList(const <int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, //
    0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, //
    0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, //
    0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ]);
  static final ByteData _emptyManifest =
      const StandardMessageCodec().encodeMessage(<String, dynamic>{})!;

  @override
  Future<ByteData> load(String key) async => ByteData.view(_transparentImage.buffer);

  @override
  Future<T> loadStructuredBinaryData<T>(
    String key,
    FutureOr<T> Function(ByteData data) parser,
  ) async {
    if (key == 'AssetManifest.bin') {
      return parser(_emptyManifest);
    }
    return parser(ByteData(0));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async => '{}';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return DefaultAssetBundle(
      bundle: _TestAssetBundle(),
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  testWidgets(
    'IngredientCard displays data and responds to Add tap',
    (tester) async {
      var addPressed = false;

      await tester.pumpWidget(
        buildTestableWidget(
          IngredientCard(
            imageUrl: 'assets/images/ingredients/tomato.png',
            ingredientName: 'Tomato',
            ingredientType: 'Vegetable',
            addIngredient: true,
            onAdd: () => addPressed = true,
          ),
        ),
      );

      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('Vegetable'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);

      await tester.tap(find.text('Add'));
      await tester.pump();

      expect(addPressed, isTrue);
    },
  );
}