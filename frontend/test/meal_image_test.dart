import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrify/core/widgets/meal_image.dart';

void main() {
  group('MealImage', () {
    testWidgets('renders Image.network for an http(s) path', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MealImage(imagePath: 'https://example.com/photo.jpg'),
        ),
      );
      expect(find.byType(Image), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<NetworkImage>());
    });

    testWidgets('renders Image.asset for an assets/ path', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MealImage(imagePath: 'assets/image1.png')),
      );
      expect(find.byType(Image), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<AssetImage>());
    });

    testWidgets('renders the fallback icon for an empty path', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MealImage(imagePath: '')),
      );
      expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });
}
