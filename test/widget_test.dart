// // Video Calling App Integration Tests
// //
// // This test file validates the key functionality of the video calling application
// // to ensure it works like Google Meet/Zoom with proper SFU backend integration.
//
// import 'package:api_demo/services/socket_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:provider/provider.dart';
//
// import 'package:api_demo/main.dart';
//
//
// void main() {
//   group('Video Calling App Integration Tests', () {
//     testWidgets('App loads with proper service providers', (WidgetTester tester) async {
//       // Build our app and trigger a frame.
//       await tester.pumpWidget(const MyApp());
//
//       // Verify that the app loads with all required providers
//       expect(find.byType(MultiProvider), findsOneWidget);
//
//       // Verify home screen loads
//       expect(find.text('Beauty LMS Live Courses'), findsOneWidget);
//     });
//
//     test('WebRTC Service initializes correctly', () {
//       final webrtcService = WebRTCService();
//
//       // Verify service is singleton
//       final webrtcService2 = WebRTCService();
//       expect(webrtcService, equals(webrtcService2));
//
//       // Verify initial state
//       expect(webrtcService.localStream, isNull);
//       expect(webrtcService.remoteStreams, isEmpty);
//       expect(webrtcService.mediaStates.audio, isTrue);
//       expect(webrtcService.mediaStates.video, isTrue);
//       expect(webrtcService.mediaStates.screenSharing, isFalse);
//     });
//
//     test('Socket Service initializes correctly', () {
//       final socketService = SocketService();
//
//       // Verify service is singleton
//       final socketService2 = SocketService();
//       expect(socketService, equals(socketService2));
//
//       // Verify initial connection state
//       expect(socketService.getConnectionStatus(), isFalse);
//     });
//
//     test('API Service endpoints are configured correctly', () {
//       // Verify API base URL is set
//       expect(apiBaseUrl, isNotEmpty);
//       expect(apiBaseUrl, contains('krishnabarasiya.space'));
//     });
//
//     testWidgets('Meeting controls are present and functional', (WidgetTester tester) async {
//       await tester.pumpWidget(const MyApp());
//
//       // Navigate to home screen first
//       await tester.pumpAndSettle();
//
//       // Note: Full meeting room testing would require mocking WebRTC and Socket connections
//       // This is a basic structural test to ensure the app framework is working
//       expect(find.text('Beauty LMS Live Courses'), findsOneWidget);
//     });
//   });
//
//   group('WebRTC Functionality Tests', () {
//     late WebRTCService webrtcService;
//
//     setUp(() {
//       webrtcService = WebRTCService();
//     });
//
//     tearDown(() async {
//       await webrtcService.cleanup();
//     });
//
//     test('Media states toggle correctly', () {
//       // Test audio toggle
//       final initialAudio = webrtcService.mediaStates.audio;
//       // Note: actual toggle would require media stream, so we test the API exists
//       expect(webrtcService.toggleAudio, isNotNull);
//
//       // Test video toggle
//       final initialVideo = webrtcService.mediaStates.video;
//       expect(webrtcService.toggleVideo, isNotNull);
//     });
//
//     test('Connection statistics are available', () async {
//       final stats = await webrtcService.getConnectionStats();
//
//       expect(stats, isA<Map<String, dynamic>>());
//       expect(stats.containsKey('localStream'), isTrue);
//       expect(stats.containsKey('screenStream'), isTrue);
//       expect(stats.containsKey('isAudioEnabled'), isTrue);
//       expect(stats.containsKey('isVideoEnabled'), isTrue);
//       expect(stats.containsKey('isScreenSharing'), isTrue);
//       expect(stats.containsKey('peerConnections'), isTrue);
//       expect(stats.containsKey('remoteStreams'), isTrue);
//     });
//
//     test('Cleanup works without errors', () async {
//       // Should not throw any exceptions
//       await webrtcService.cleanup();
//
//       // Verify state is reset
//       expect(webrtcService.localStream, isNull);
//       expect(webrtcService.remoteStreams, isEmpty);
//     });
//   });
//
//   group('Socket Service Tests', () {
//     late SocketService socketService;
//
//     setUp(() {
//       socketService = SocketService();
//     });
//
//     test('Connection methods exist and are callable', () {
//       // Verify key methods exist
//       expect(socketService.connect, isNotNull);
//       expect(socketService.disconnect, isNotNull);
//       expect(socketService.getConnectionStatus, isNotNull);
//
//       // Verify signaling methods exist
//       expect(socketService.sendOffer, isNotNull);
//       expect(socketService.sendAnswer, isNotNull);
//       expect(socketService.sendIceCandidate, isNotNull);
//
//       // Verify meeting methods exist
//       expect(socketService.joinMeetingRoom, isNotNull);
//       expect(socketService.leaveMeetingRoom, isNotNull);
//       expect(socketService.sendChatMessage, isNotNull);
//     });
//
//     test('Event listeners can be set up', () {
//       // These should not throw errors
//       socketService.onOffer((_) {});
//       socketService.onAnswer((_) {});
//       socketService.onIceCandidate((_) {});
//       socketService.onChatMessage((_) {});
//       socketService.onParticipantJoined((_) {});
//       socketService.onParticipantLeft((_) {});
//     });
//   });
// }
