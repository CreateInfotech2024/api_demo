// Application configuration for different environments
// This file contains environment-specific settings for the video calling app

class AppConfig {
  // Environment detection
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';

  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://krishnabarasiya.space/api',
  );

  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'https://krishnabarasiya.space',
  );

  // WebRTC Configuration
  static const List<Map<String, dynamic>> stunServers = [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
    {'urls': 'stun:stun.relay.metered.ca:80'},
  ];

  static const List<Map<String, dynamic>> turnServers = [
    {
      'urls': 'turn:global.relay.metered.ca:80',
      'username': String.fromEnvironment('TURN_USERNAME', defaultValue: 'api_demo_user'),
      'credential': String.fromEnvironment('TURN_PASSWORD', defaultValue: 'temp_password'),
    },
    {
      'urls': 'turn:global.relay.metered.ca:443',
      'username': String.fromEnvironment('TURN_USERNAME', defaultValue: 'api_demo_user'),
      'credential': String.fromEnvironment('TURN_PASSWORD', defaultValue: 'temp_password'),
    },
  ];

  // Feature Flags
  static const bool enableScreenSharing = bool.fromEnvironment(
    'ENABLE_SCREEN_SHARING',
    defaultValue: true,
  );

  static const bool enableRecording = bool.fromEnvironment(
    'ENABLE_RECORDING',
    defaultValue: false,
  );

  static const bool enableChat = bool.fromEnvironment(
    'ENABLE_CHAT',
    defaultValue: true,
  );

  static const bool enableMobileOptimizations = bool.fromEnvironment(
    'ENABLE_MOBILE_OPTIMIZATIONS',
    defaultValue: true,
  );

  // Performance Settings
  static const int maxParticipants = int.fromEnvironment(
    'MAX_PARTICIPANTS',
    defaultValue: 12,
  );

  static const int maxParticipantsOnMobile = int.fromEnvironment(
    'MAX_PARTICIPANTS_MOBILE',
    defaultValue: 6,
  );

  // Quality Settings
  static const int defaultVideoWidth = int.fromEnvironment(
    'DEFAULT_VIDEO_WIDTH',
    defaultValue: 640,
  );

  static const int defaultVideoHeight = int.fromEnvironment(
    'DEFAULT_VIDEO_HEIGHT',
    defaultValue: 480,
  );

  static const int mobileVideoWidth = int.fromEnvironment(
    'MOBILE_VIDEO_WIDTH',
    defaultValue: 480,
  );

  static const int mobileVideoHeight = int.fromEnvironment(
    'MOBILE_VIDEO_HEIGHT',
    defaultValue: 360,
  );

  // Timeout Settings
  static const int connectionTimeout = int.fromEnvironment(
    'CONNECTION_TIMEOUT',
    defaultValue: 15000,
  );

  static const int mobileConnectionTimeout = int.fromEnvironment(
    'MOBILE_CONNECTION_TIMEOUT',
    defaultValue: 20000,
  );

  // Debug Settings
  static const bool enableDebugLogging = bool.fromEnvironment(
    'ENABLE_DEBUG_LOGGING',
    defaultValue: true,
  );

  static const bool enablePerformanceMonitoring = bool.fromEnvironment(
    'ENABLE_PERFORMANCE_MONITORING',
    defaultValue: false,
  );

  // App Information
  static const String appName = 'Beauty LMS Live Courses';
  static const String version = '1.0.0';
  static const String buildNumber = String.fromEnvironment(
    'BUILD_NUMBER',
    defaultValue: '1',
  );

  // Error Reporting
  static const bool enableErrorReporting = bool.fromEnvironment(
    'ENABLE_ERROR_REPORTING',
    defaultValue: isProduction,
  );

  static const String errorReportingUrl = String.fromEnvironment(
    'ERROR_REPORTING_URL',
    defaultValue: '',
  );

  // Analytics
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: isProduction,
  );

  static const String analyticsKey = String.fromEnvironment(
    'ANALYTICS_KEY',
    defaultValue: '',
  );

  // Security Settings
  static const bool enforceHttps = bool.fromEnvironment(
    'ENFORCE_HTTPS',
    defaultValue: isProduction,
  );

  static const bool enablePermissionChecks = bool.fromEnvironment(
    'ENABLE_PERMISSION_CHECKS',
    defaultValue: true,
  );

  // Get complete WebRTC configuration
  static Map<String, dynamic> getWebRTCConfig() {
    return {
      'iceServers': [
        ...stunServers,
        if (environment != 'development') ...turnServers,
      ],
      'iceCandidatePoolSize': isDevelopment ? 5 : 10,
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
      'iceTransportPolicy': 'all',
    };
  }

  // Get Socket.IO configuration
  static Map<String, dynamic> getSocketConfig() {
    return {
      'transports': ['websocket', 'polling'],
      'timeout': connectionTimeout,
      'forceNew': !isDevelopment,
      'reconnection': true,
      'reconnectionAttempts': isDevelopment ? 3 : 10,
      'reconnectionDelay': isDevelopment ? 500 : 1000,
      'maxReconnectionAttempts': isDevelopment ? 5 : 15,
    };
  }

  // Get media constraints based on environment
  static Map<String, dynamic> getMediaConstraints({bool isMobile = false}) {
    return {
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
        if (!isDevelopment) ...{
          'googEchoCancellation': true,
          'googNoiseSuppression': true,
          'googAutoGainControl': true,
        }
      },
      'video': {
        'mandatory': {
          'minWidth': isMobile ? '240' : '320',
          'minHeight': isMobile ? '180' : '240',
          'maxWidth': isMobile ? mobileVideoWidth.toString() : defaultVideoWidth.toString(),
          'maxHeight': isMobile ? mobileVideoHeight.toString() : defaultVideoHeight.toString(),
          'minFrameRate': isMobile ? '10' : '15',
          'maxFrameRate': isMobile ? '20' : '30',
        },
        'facingMode': 'user',
      }
    };
  }

  // Logging configuration
  static void printConfig() {
    if (enableDebugLogging) {
      print('=== App Configuration ===');
      print('Environment: $environment');
      print('API Base URL: $apiBaseUrl');
      print('Socket URL: $socketUrl');
      print('Screen Sharing: $enableScreenSharing');
      print('Recording: $enableRecording');
      print('Chat: $enableChat');
      print('Mobile Optimizations: $enableMobileOptimizations');
      print('Max Participants: $maxParticipants');
      print('Debug Logging: $enableDebugLogging');
      print('Performance Monitoring: $enablePerformanceMonitoring');
      print('========================');
    }
  }

  // Validate configuration
  static bool validateConfig() {
    final issues = <String>[];

    if (apiBaseUrl.isEmpty) {
      issues.add('API Base URL is empty');
    }

    if (socketUrl.isEmpty) {
      issues.add('Socket URL is empty');
    }

    if (!apiBaseUrl.startsWith('http')) {
      issues.add('API Base URL must start with http/https');
    }

    if (!socketUrl.startsWith('http')) {
      issues.add('Socket URL must start with http/https');
    }

    if (isProduction && !enforceHttps) {
      if (!apiBaseUrl.startsWith('https') || !socketUrl.startsWith('https')) {
        issues.add('Production environment should use HTTPS');
      }
    }

    if (maxParticipants < 2) {
      issues.add('Max participants must be at least 2');
    }

    if (connectionTimeout < 5000) {
      issues.add('Connection timeout should be at least 5 seconds');
    }

    if (issues.isNotEmpty) {
      print('Configuration validation failed:');
      for (final issue in issues) {
        print('- $issue');
      }
      return false;
    }

    return true;
  }

  // Environment-specific URLs for testing
  static String get testMeetingCode => isDevelopment ? 'TEST123' : '';
  static String get testUserId => isDevelopment ? 'test_user_123' : '';
  static String get testUserName => isDevelopment ? 'Test User' : '';

  // Feature availability based on environment
  static Map<String, bool> getFeatureFlags() {
    return {
      'screenSharing': enableScreenSharing,
      'recording': enableRecording,
      'chat': enableChat,
      'mobileOptimizations': enableMobileOptimizations,
      'debugTools': isDevelopment,
      'performanceMonitoring': enablePerformanceMonitoring,
      'errorReporting': enableErrorReporting,
      'analytics': enableAnalytics,
      'advancedControls': !isMobile || isDevelopment,
      'qualitySettings': isDevelopment || isStaging,
    };
  }

  // Get user-friendly environment name
  static String get environmentDisplayName {
    switch (environment) {
      case 'production':
        return 'Production';
      case 'staging':
        return 'Staging';
      case 'development':
        return 'Development';
      default:
        return 'Unknown';
    }
  }
}