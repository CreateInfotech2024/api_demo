class ApiConfig {
  // Update this with your Beauty LMS backend URL
  static const String baseUrl = 'https://krishnabarasiya.space'; // Development
  // static const String baseUrl = 'https://your-domain.com'; // Production
  
  static const String apiPath = '/api';
  static const String wsPath = ''; // Socket.IO path (empty for default)
  
  // API Endpoints
  static const String health = '/health';
  static const String liveCourses = '$apiPath/live_courses';
  static const String meetings = '$apiPath/meeting';
  static const String recordings = '$apiPath/recordings';
  static const String users = '$apiPath/users';
  
  // Socket.IO Events (matching Beauty LMS backend)
  // Course events
  static const String joinCourse = 'join-course';
  static const String leaveCourse = 'leave-course';
  static const String courseStarted = 'course-started';
  static const String courseEnded = 'course-ended';
  static const String participantJoined = 'participant-joined';
  static const String participantLeft = 'participant-left';
  
  // Meeting events
  static const String joinMeeting = 'joinMeeting';
  static const String leaveMeeting = 'leaveMeeting';
  static const String meetingStarted = 'meetingStarted';
  static const String meetingEnded = 'meetingEnded';
  static const String sendMessage = 'sendMessage';
  static const String receiveMessage = 'receiveMessage';
  
  // MediaSoup events
  static const String joinRoom = 'join-room';
  static const String leaveRoom = 'leave-room';
  static const String createTransport = 'create-transport';
  static const String connectTransport = 'connect-transport';
  static const String produce = 'produce';
  static const String consume = 'consume';
  static const String newProducer = 'newProducer';
  static const String producerClosed = 'producerClosed';
  
  // Connection settings
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration socketTimeout = Duration(seconds: 10);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}