import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:firebase_setup/demo_auth.dart';
import 'package:firebase_setup/main.dart';
import 'package:firebase_setup/social_media/create_post_sheet.dart';
import 'package:firebase_setup/social_media/post_card.dart';

class _TestHttpOverrides extends HttpOverrides {}

class _MockImagePickerPlatform extends ImagePickerPlatform {
  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    final bytes = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
      0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
      0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
      0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
      0x42, 0x60, 0x82,
    ]);
    return XFile.fromData(bytes, name: 'uploaded_photo.png', mimeType: 'image/png');
  }

  @override
  Future<XFile?> getImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    return getImageFromSource(source: source);
  }
}

void main() {
  setUp(() {
    HttpOverrides.global = _TestHttpOverrides();
    ImagePickerPlatform.instance = _MockImagePickerPlatform();
    DemoAuth.registeredUsername = null;
    DemoAuth.registeredPassword = null;
    DemoAuth.currentUsername = null;
  });

  testWidgets('Complete Lab Activity 14-Step Test Verification',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // 1. Open the application -> Login appears first
    await tester.pumpWidget(const StudentApp());
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // 2. Submit empty login fields -> Validation messages appear
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Enter your username.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);

    // 3. Enter incorrect credentials -> Login is rejected
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'), 'wrongUser');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'wrongPass');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Invalid username or password.'), findsOneWidget);

    // Clear SnackBar
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold)))
        .clearSnackBars();
    await tester.pump();

    // 4. Enter admin / admin123 -> Dashboard opens
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'), 'admin');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);

    // 5. Read the dashboard greeting -> Displays Welcome, admin!
    expect(find.text('Welcome, admin!'), findsOneWidget);

    // Navigation finders
    final navDashboard = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Dashboard'),
    );
    final navCalculator = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Calculator'),
    );
    final navSocial = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Social'),
    );
    final navProfile = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Profile'),
    );

    // 6. Open Calculator and calculate 10 + 5 -> Displays 15.0
    await tester.tap(navCalculator);
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'First Number'), '10');
    await tester.enterText(
        find.widgetWithText(TextField, 'Second Number'), '5');
    await tester.tap(find.widgetWithText(ElevatedButton, '+'));
    await tester.pump();

    expect(find.text('15.0'), findsOneWidget);

    // 7. Switch tabs and return to Calculator -> Inputs and result remain
    await tester.tap(navDashboard);
    await tester.pumpAndSettle();
    expect(find.text('Welcome, admin!'), findsOneWidget);

    await tester.tap(navCalculator);
    await tester.pumpAndSettle();
    expect(find.text('15.0'), findsOneWidget);

    // 8. Create a social post -> Post displays the logged-in username
    await tester.tap(navSocial);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Create Post'), findsOneWidget);

    // Upload photo
    await tester.tap(find.text('Tap to upload photo from device'));
    await tester.pumpAndSettle();

    final captionField = find.descendant(
      of: find.byType(CreatePostSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(captionField, 'First post by admin');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    expect(find.text('First post by admin'), findsOneWidget);
    expect(find.text('admin'), findsOneWidget);

    // 9. Like a post and add a comment -> Both interactions update correctly
    final firstPostLikeBtn = find.descendant(
      of: find.byType(PostCard).first,
      matching: find.widgetWithText(TextButton, 'Like'),
    );
    await tester.tap(firstPostLikeBtn);
    await tester.pump();
    expect(find.widgetWithText(TextButton, 'Liked'), findsOneWidget);

    final firstCommentField = find.descendant(
      of: find.byType(PostCard).first,
      matching: find.byType(TextField),
    );
    await tester.enterText(firstCommentField, 'Great application post!');
    final firstSendBtn = find.descendant(
      of: find.byType(PostCard).first,
      matching: find.byTooltip('Send comment'),
    );
    await tester.tap(firstSendBtn);
    await tester.pump();

    expect(find.text('1 Comments'), findsOneWidget);
    expect(find.text('Great application post!'), findsOneWidget);

    // 10. Switch tabs and return to Social -> Posts, likes, and comments remain
    await tester.tap(navDashboard);
    await tester.pumpAndSettle();
    expect(find.text('Welcome, admin!'), findsOneWidget);

    await tester.tap(navSocial);
    await tester.pumpAndSettle();
    expect(find.text('First post by admin'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Liked'), findsOneWidget);
    expect(find.text('1 Comments'), findsOneWidget);
    expect(find.text('Great application post!'), findsOneWidget);

    // 11. Open Profile -> Student information and username appear
    await tester.tap(navProfile);
    await tester.pumpAndSettle();

    expect(find.text('Student Profile'), findsOneWidget);
    expect(find.text('Logged in as: admin'), findsOneWidget);
    expect(find.text('James Bond'), findsOneWidget);
    expect(find.text('2026-00001'), findsOneWidget);
    expect(find.text('BSIT'), findsOneWidget);

    // 12. Tap Logout -> Login appears; Back does not reopen MainScreen
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(DemoAuth.currentUsername, isNull);

    // 13. Register a valid account and log in -> Dashboard displays the registered username
    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();

    expect(find.text('Create an Account'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'), 'mary_doe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'secret123');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'), 'secret123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    // Clear SnackBar
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold)))
        .clearSnackBars();
    await tester.pumpAndSettle();

    // Login with new account
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'), 'mary_doe');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'secret123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome, mary_doe!'), findsOneWidget);
    expect(DemoAuth.currentUsername, 'mary_doe');

    // 14. Create a post using the registered account -> Post displays the registered username
    final newNavSocial = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Social'),
    );
    await tester.tap(newNavSocial);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tap to upload photo from device'));
    await tester.pumpAndSettle();

    final userCaptionField = find.descendant(
      of: find.byType(CreatePostSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(userCaptionField, 'Hello from Mary Doe!');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Post'));
    await tester.pumpAndSettle();

    expect(find.text('mary_doe'), findsOneWidget);
    expect(find.text('Hello from Mary Doe!'), findsOneWidget);
  });
}
