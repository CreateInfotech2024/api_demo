// Mobile-specific optimizations for video calling
// This file contains platform-specific configurations and optimizations
// for better video calling experience on mobile devices

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class MobileOptimizations {
  // Detect platform
  static bool get isMobile => !kIsWeb && (Platform.isIOS || Platform.isAndroid);
  static bool get isIOS => !kIsWeb && Platform.isIOS;  
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isWeb => kIsWeb;
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  // Media constraints optimized for mobile devices
  static Map<String, dynamic> getMobileOptimizedMediaConstraints() {
    if (isMobile) {
      return {
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
          // Mobile-specific audio optimizations
          'googEchoCancellation': true,
          'googExperimentalEchoCancellation': true,
          'googAutoGainControl': true,
          'googExperimentalAutoGainControl': true,
          'googNoiseSuppression': true,
          'googExperimentalNoiseSuppression': true,
          'googHighpassFilter': true,
          'googTypingNoiseDetection': true,
        },
        'video': {
          'mandatory': {
            'minWidth': '240',
            'minHeight': '180',
            'maxWidth': '854', // Reduced for mobile
            'maxHeight': '480', // Reduced for mobile
            'minFrameRate': '10',
            'maxFrameRate': '20', // Reduced for mobile battery
          },
          'facingMode': 'user',
          'optional': [
            {'googCpuOveruseDetection': true},
            {'googPayloadPadding': false},
            {'googLeakyBucket': true},
          ],
        }
      };
    } else {
      // Desktop constraints with higher quality
      return {
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': {
          'mandatory': {
            'minWidth': '320',
            'minHeight': '240',
            'maxWidth': '1280',
            'maxHeight': '720',
            'minFrameRate': '15',
            'maxFrameRate': '30',
          },
          'facingMode': 'user',
        }
      };
    }
  }

  // Screen sharing constraints with mobile fallbacks
  static List<Map<String, dynamic>> getScreenSharingConstraints() {
    if (isMobile) {
      return [
        // Mobile optimized - lower quality for better performance
        {
          'video': {
            'mediaSource': 'screen',
            'width': {'max': 854, 'ideal': 640},
            'height': {'max': 480, 'ideal': 360},
            'frameRate': {'max': 10, 'ideal': 8},
          },
          'audio': false, // Often problematic on mobile
        },
        // Basic mobile fallback
        {
          'video': {
            'mediaSource': 'screen',
            'frameRate': {'max': 8},
          },
          'audio': false,
        },
        // Final mobile fallback
        {
          'video': true,
          'audio': false,
        },
      ];
    } else {
      return [
        // Desktop - high quality
        {
          'video': {
            'mediaSource': 'screen',
            'width': {'max': 1920, 'ideal': 1280},
            'height': {'max': 1080, 'ideal': 720},
            'frameRate': {'max': 30, 'ideal': 15},
          },
          'audio': {
            'echoCancellation': false,
            'noiseSuppression': false,
          },
        },
        // Desktop medium quality
        {
          'video': {
            'mediaSource': 'screen',
            'width': {'max': 1280, 'ideal': 854},
            'height': {'max': 720, 'ideal': 480},
            'frameRate': {'max': 15, 'ideal': 10},
          },
          'audio': false,
        },
        // Desktop basic
        {
          'video': {
            'mediaSource': 'screen',
            'frameRate': {'max': 10},
          },
          'audio': false,
        },
        // Final fallback
        {
          'video': true,
          'audio': false,
        },
      ];
    }
  }

  // WebRTC configuration optimized for mobile
  static Map<String, dynamic> getWebRTCConfiguration() {
    return {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
        {'urls': 'stun:stun.relay.metered.ca:80'},
        // TURN servers for mobile connectivity (NAT traversal)
        {
          'urls': 'turn:global.relay.metered.ca:80',
          'username': 'api_demo_user',
          'credential': 'temp_password'
        },
        {
          'urls': 'turn:global.relay.metered.ca:443',
          'username': 'api_demo_user',
          'credential': 'temp_password'
        }
      ],
      // Mobile-optimized settings
      'iceCandidatePoolSize': isMobile ? 5 : 10, // Lower for mobile to save battery
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
      // Mobile-specific optimizations
      if (isMobile) ...{
        'iceTransportPolicy': 'all', // Use both STUN and TURN
        'continualGatheringPolicy': 'gather_continually',
      }
    };
  }

  // Socket.IO configuration for mobile
  static Map<String, dynamic> getSocketConfiguration() {
    return {
      'transports': ['websocket', 'polling'],
      'timeout': isMobile ? 20000 : 15000, // Longer timeout for mobile
      'forceNew': true,
      'reconnection': true,
      'reconnectionAttempts': isMobile ? 10 : 5, // More attempts for mobile
      'reconnectionDelay': isMobile ? 2000 : 1000, // Longer delay for mobile
      'maxReconnectionAttempts': isMobile ? 15 : 10,
      // Mobile-specific settings
      if (isMobile) ...{
        'upgrade': true,
        'rememberUpgrade': true,
      }
    };
  }

  // Get user-friendly error messages for mobile-specific issues
  static String getMobileErrorMessage(String error) {
    if (error.contains('NotAllowedError') || error.contains('permission denied')) {
      if (isMobile) {
        return 'Please go to Settings > ${isIOS ? 'Privacy & Security > Camera/Microphone' : 'Apps > Chrome > Permissions'} and allow access.';
      }
      return 'Please allow camera and microphone access in your browser settings.';
    }
    
    if (error.contains('NotSupportedError')) {
      if (isMobile) {
        return 'This feature is not supported on your device. Try updating your browser or using a different device.';
      }
      return 'This feature is not supported in your browser. Try using Chrome, Firefox, or Safari.';
    }
    
    if (error.contains('screen') && isMobile) {
      return 'Screen sharing on mobile devices has limited support. For best results, use a desktop browser.';
    }
    
    if (error.contains('network') || error.contains('connection')) {
      return 'Network connection issues. Check your internet connection and try again.';
    }
    
    return 'An error occurred. Please try again or contact support.';
  }

  // Get platform-specific UI adjustments
  static Map<String, dynamic> getUIAdjustments() {
    return {
      'controlBarHeight': isMobile ? 80.0 : 60.0,
      'participantThumbnailSize': isMobile ? 100.0 : 120.0,
      'minimumButtonSize': isMobile ? 48.0 : 36.0,
      'chatPanelWidth': isMobile ? double.infinity : 300.0,
      'useMobileLayout': isMobile,
      'showAdvancedControls': !isMobile, // Hide complex controls on mobile
      'enableHapticFeedback': isMobile,
    };
  }

  // Performance optimizations
  static Map<String, dynamic> getPerformanceSettings() {
    return {
      'maxParticipantsInGrid': isMobile ? 4 : 9, // Fewer participants on mobile
      'enableVideoWhenMany': isMobile ? 6 : 12, // Disable video for many participants on mobile
      'audioOnlyMode': false, // Can be enabled for very low-end devices
      'reducedMotion': false, // Can be enabled to save battery
      'autoAdjustQuality': isMobile, // Auto-adjust quality based on performance
    };
  }

  // Battery optimization settings
  static Map<String, dynamic> getBatteryOptimizations() {
    if (!isMobile) return {};
    
    return {
      'reducedFrameRate': true,
      'lowerResolution': true,
      'disableVideoWhenInBackground': true,
      'muteWhenInBackground': false, // Keep audio for notifications
      'pauseVideoWhenNotVisible': true,
    };
  }

  // Permission handling helpers
  static List<String> getRequiredPermissions() {
    if (isMobile) {
      return [
        'camera',
        'microphone',
        'storage', // For recording/screenshots if implemented
        if (isAndroid) 'android.permission.RECORD_AUDIO',
        if (isAndroid) 'android.permission.CAMERA',
        if (isIOS) 'NSCameraUsageDescription',
        if (isIOS) 'NSMicrophoneUsageDescription',
      ];
    }
    return ['camera', 'microphone'];
  }

  // Feature availability based on platform
  static Map<String, bool> getFeatureAvailability() {
    return {
      'screenSharing': isDesktop || (isWeb && !isMobile),
      'backgroundBlur': isDesktop, // Usually requires more processing power
      'virtualBackground': isDesktop,
      'recording': true, // Can be supported on all platforms
      'chat': true,
      'fileSharing': true,
      'reactions': true,
      'breakoutRooms': isDesktop, // Complex feature, better on desktop
      'whiteboard': isDesktop,
      'screenshotCapture': !isIOS, // iOS has restrictions
    };
  }
}