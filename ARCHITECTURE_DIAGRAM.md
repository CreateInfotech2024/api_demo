# Architecture Diagram - WebRTC Video Conferencing

## System Overview

```
┌────────────────────────────────────────────────────────────────────────┐
│                         Video Conferencing App                         │
└────────────────────────────────────────────────────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        │                           │                           │
        ▼                           ▼                           ▼
┌───────────────┐          ┌────────────────┐         ┌────────────────┐
│  Device A     │          │  WebSocket     │         │  Device B      │
│  (Host)       │◄────────►│  Server        │◄───────►│  (Participant) │
│               │          │  (Signaling)   │         │                │
└───────────────┘          └────────────────┘         └────────────────┘
        │                                                      │
        │            WebRTC P2P Media Streams                  │
        └──────────────────────────────────────────────────────┘
                    (Audio + Video Data)
```

## Component Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           Flutter Application                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────┐     │
│  │                      Presentation Layer                       │     │
│  │  ┌─────────────┐  ┌──────────────┐  ┌─────────────────────┐  │     │
│  │  │   Meeting   │  │  Participant │  │   Meeting Controls  │  │     │
│  │  │   Screen    │  │     Grid     │  │   (Video/Audio/Chat)│  │     │
│  │  └─────────────┘  └──────────────┘  └─────────────────────┘  │     │
│  └───────────────────────────────────────────────────────────────┘     │
│                                ↕                                        │
│  ┌───────────────────────────────────────────────────────────────┐     │
│  │                      Business Logic Layer                     │     │
│  │  ┌──────────────────────────────────────────────────────┐     │     │
│  │  │              App Provider (State Management)         │     │     │
│  │  │  • Meeting state                                     │     │     │
│  │  │  • Participant management                            │     │     │
│  │  │  • WebRTC signaling coordination                     │     │     │
│  │  │  • Media control state                               │     │     │
│  │  └──────────────────────────────────────────────────────┘     │     │
│  └───────────────────────────────────────────────────────────────┘     │
│                                ↕                                        │
│  ┌───────────────────────────────────────────────────────────────┐     │
│  │                         Service Layer                         │     │
│  │  ┌───────────┐  ┌─────────────┐  ┌──────────────────────┐    │     │
│  │  │  WebRTC   │  │  WebSocket  │  │   Permission Helper  │    │     │
│  │  │  Service  │  │   Service   │  │   (Camera/Mic)       │    │     │
│  │  └───────────┘  └─────────────┘  └──────────────────────┘    │     │
│  └───────────────────────────────────────────────────────────────┘     │
│                                ↕                                        │
│  ┌───────────────────────────────────────────────────────────────┐     │
│  │                    Platform/Plugin Layer                      │     │
│  │  ┌─────────────┐  ┌──────────────┐  ┌────────────────────┐   │     │
│  │  │ flutter_    │  │ socket_io_   │  │ permission_        │   │     │
│  │  │ webrtc      │  │ client       │  │ handler            │   │     │
│  │  └─────────────┘  └──────────────┘  └────────────────────┘   │     │
│  └───────────────────────────────────────────────────────────────┘     │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                ↕
┌─────────────────────────────────────────────────────────────────────────┐
│                         Device Hardware                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                 │
│  │   Camera     │  │  Microphone  │  │   Network    │                 │
│  └──────────────┘  └──────────────┘  └──────────────┘                 │
└─────────────────────────────────────────────────────────────────────────┘
```

## WebRTC Signaling Flow

```
Device A (Host)                   WebSocket Server              Device B (Participant)
     │                                    │                             │
     │─────── join-meeting ──────────────►│                             │
     │                                    │                             │
     │                                    │◄──── join-meeting ──────────│
     │                                    │                             │
     │◄───── participant-joined ──────────│                             │
     │                                    │──── participant-joined ────►│
     │                                    │                             │
     ├─── Create PeerConnection          │      Create PeerConnection ─┤
     │                                    │                             │
     │─── createOffer() ──►               │                             │
     │◄── SDP Offer ───────               │                             │
     │                                    │                             │
     │───── offer ───────────────────────►│───── offer ────────────────►│
     │                                    │                             │
     │                                    │              ───createAnswer()
     │                                    │              ◄── SDP Answer ─
     │                                    │                             │
     │◄──── answer ───────────────────────│◄──── answer ────────────────│
     │                                    │                             │
     │─ setRemoteDescription(answer)      │      setRemoteDescription(offer)
     │                                    │                             │
     │                                    │                             │
     ├─── ICE Gathering ────►             │             ◄─── ICE Gathering
     │                                    │                             │
     │─── ice-candidate ──────────────────►│─── ice-candidate ──────────►│
     │◄─── ice-candidate ──────────────────│◄─── ice-candidate ──────────│
     │                                    │                             │
     │─ addIceCandidate()                 │           addIceCandidate() ─│
     │                                    │                             │
     │                                    │                             │
     │══════════════════ P2P Connection Established ═══════════════════│
     │                                    │                             │
     │◄════════════════ Media Streams (Audio + Video) ═════════════════►│
     │                                    │                             │
```

## Media Stream Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            Device Camera                                │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     getUserMedia(constraints)                           │
│  • Request camera and microphone access                                 │
│  • Apply constraints (resolution, frame rate, etc.)                     │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         MediaStream (Local)                             │
│  ┌──────────────────┐              ┌──────────────────┐                │
│  │  Video Track     │              │  Audio Track     │                │
│  │  (Camera feed)   │              │  (Microphone)    │                │
│  └──────────────────┘              └──────────────────┘                │
└────────────────────┬────────────────────────────────────┬───────────────┘
                     │                                    │
           ┌─────────┴────────┐                  ┌────────┴─────────┐
           ▼                  ▼                  ▼                  ▼
    ┌──────────────┐   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
    │ RTCVideo     │   │ RTCPeer      │  │ RTCPeer      │  │ RTCPeer      │
    │ Renderer     │   │ Connection 1 │  │ Connection 2 │  │ Connection N │
    │ (Local View) │   │ (Participant)│  │ (Participant)│  │ (Participant)│
    └──────────────┘   └──────┬───────┘  └──────┬───────┘  └──────┬───────┘
                              │                 │                 │
                              ▼                 ▼                 ▼
                    ┌─────────────────────────────────────────────────┐
                    │         Network (Internet/LAN)                  │
                    └─────────────────────────────────────────────────┘
                              │                 │                 │
                              ▼                 ▼                 ▼
                    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
                    │ Remote       │  │ Remote       │  │ Remote       │
                    │ Participant  │  │ Participant  │  │ Participant  │
                    │ Device       │  │ Device       │  │ Device       │
                    └──────────────┘  └──────────────┘  └──────────────┘
```

## State Management Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            User Action                                  │
│  (Toggle Video/Audio, Join Meeting, Create Meeting)                    │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          Meeting Controls                               │
│  • Video button clicked → provider.toggleVideo()                        │
│  • Audio button clicked → provider.toggleAudio()                        │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           App Provider                                  │
│  • Update state (_isVideoEnabled = !_isVideoEnabled)                    │
│  • Call WebRTC service                                                  │
│  • Emit WebSocket event                                                 │
│  • notifyListeners()                                                    │
└───────┬────────────────────────────────────────────────────┬────────────┘
        │                                                    │
        ▼                                                    ▼
┌────────────────────┐                            ┌─────────────────────┐
│  WebRTC Service    │                            │  WebSocket Service  │
│  • toggleVideo()   │                            │  • emitMediaToggle()│
│  • Enable/disable  │                            │  • Send to server   │
│    video track     │                            │  • Broadcast event  │
└────────────────────┘                            └──────────┬──────────┘
        │                                                    │
        ▼                                                    ▼
┌────────────────────┐                            ┌─────────────────────┐
│  Video Track       │                            │  Other Participants │
│  • enabled = true  │                            │  • Receive event    │
│  • Visible on      │                            │  • Update UI        │
│    other devices   │                            │  • Show/hide video  │
└────────────────────┘                            └─────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                              UI Update                                  │
│  • Consumer<AppProvider> rebuilds                                       │
│  • Button color changes (blue → gray)                                   │
│  • Video tile shows/hides camera feed                                   │
│  • Other participants see updated state                                 │
└─────────────────────────────────────────────────────────────────────────┘
```

## Participant Grid Layout

```
Single Participant (1:1)
┌─────────────────────────────────────────┐
│                                         │
│    ┌───────────────────────────────┐    │
│    │                               │    │
│    │       HOST VIDEO STREAM       │    │
│    │       (Full Screen)           │    │
│    │                               │    │
│    │   ┌─────────────────────┐     │    │
│    │   │ 🎤 John Doe [HOST] │     │    │
│    │   └─────────────────────┘     │    │
│    └───────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘

Two Participants (2x1)
┌─────────────────────────────────────────┐
│  ┌────────────────┐  ┌────────────────┐ │
│  │    HOST        │  │  PARTICIPANT   │ │
│  │    VIDEO       │  │     VIDEO      │ │
│  │                │  │                │ │
│  │ 🎤 John D.     │  │ 🎤 Jane S.     │ │
│  │    [HOST]      │  │                │ │
│  └────────────────┘  └────────────────┘ │
└─────────────────────────────────────────┘

Four Participants (2x2)
┌─────────────────────────────────────────┐
│  ┌─────────┐  ┌─────────┐              │
│  │ HOST    │  │ USER 1  │              │
│  │ [VIDEO] │  │ [VIDEO] │              │
│  │ 🎤 John │  │ 🎤 Jane │              │
│  └─────────┘  └─────────┘              │
│                                         │
│  ┌─────────┐  ┌─────────┐              │
│  │ USER 2  │  │ USER 3  │              │
│  │ [VIDEO] │  │ [VIDEO] │              │
│  │ 🎤 Mike │  │ 🎤 Sarah│              │
│  └─────────┘  └─────────┘              │
└─────────────────────────────────────────┘

Nine Participants (3x3)
┌─────────────────────────────────────────┐
│ ┌────┐ ┌────┐ ┌────┐                   │
│ │[V] │ │[V] │ │[V] │                   │
│ │🎤1 │ │🎤2 │ │🎤3 │                   │
│ └────┘ └────┘ └────┘                   │
│ ┌────┐ ┌────┐ ┌────┐                   │
│ │[V] │ │[V] │ │[V] │                   │
│ │🎤4 │ │🎤5 │ │🎤6 │                   │
│ └────┘ └────┘ └────┘                   │
│ ┌────┐ ┌────┐ ┌────┐                   │
│ │[V] │ │[V] │ │[V] │                   │
│ │🎤7 │ │🎤8 │ │🎤9 │                   │
│ └────┘ └────┘ └────┘                   │
└─────────────────────────────────────────┘
```

## Data Flow Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                      User Interaction                          │
└────────────────┬───────────────────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────────────────┐
│                      UI Layer (Widgets)                        │
│  • MeetingScreen                                               │
│  • ParticipantGrid                                             │
│  • MeetingControls                                             │
└────────────────┬───────────────────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────────────────┐
│                  State Management (Provider)                   │
│  • Meeting state                                               │
│  • Participant list                                            │
│  • Media states (video/audio enabled)                          │
│  • Local/remote streams                                        │
└──────┬─────────────────────────┬───────────────────────────────┘
       │                         │
       ▼                         ▼
┌──────────────────┐    ┌─────────────────────┐
│  WebRTC Service  │    │  WebSocket Service  │
│  • Media capture │    │  • Signaling        │
│  • Peer conns    │    │  • Events           │
│  • Streams       │    │  • Messages         │
└──────┬───────────┘    └────────┬────────────┘
       │                         │
       ▼                         ▼
┌──────────────────┐    ┌─────────────────────┐
│  Device Hardware │    │  Network/Server     │
│  • Camera        │    │  • WebSocket conn   │
│  • Microphone    │    │  • Signaling msgs   │
└──────────────────┘    └─────────────────────┘
```

## Security & Privacy

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Security Layers                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────┐     │
│  │  1. Permission Layer                                          │     │
│  │     • Explicit user permission required                       │     │
│  │     • Camera/microphone access controlled                     │     │
│  │     • Can be revoked by user anytime                          │     │
│  └───────────────────────────────────────────────────────────────┘     │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────┐     │
│  │  2. WebRTC Security                                           │     │
│  │     • DTLS-SRTP encryption for media                          │     │
│  │     • End-to-end encrypted by default                         │     │
│  │     • Peer authentication via signaling                       │     │
│  └───────────────────────────────────────────────────────────────┘     │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────┐     │
│  │  3. Signaling Security                                        │     │
│  │     • WebSocket over TLS (wss://)                             │     │
│  │     • Meeting codes for access control                        │     │
│  │     • Participant verification                                │     │
│  └───────────────────────────────────────────────────────────────┘     │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────┐     │
│  │  4. Application Security                                      │     │
│  │     • No media stored locally (ephemeral)                     │     │
│  │     • Streams disposed on disconnect                          │     │
│  │     • Meeting codes expire after meeting ends                 │     │
│  └───────────────────────────────────────────────────────────────┘     │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Performance Considerations

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      Performance Optimization                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Media Constraints                                                      │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │ • 720p max resolution (balance quality/bandwidth)              │    │
│  │ • 15-30 fps (adaptive based on device)                         │    │
│  │ • Echo cancellation & noise suppression                        │    │
│  │ • Auto gain control for audio                                  │    │
│  └────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  Network Optimization                                                   │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │ • STUN servers for NAT traversal                               │    │
│  │ • P2P direct connections (low latency)                         │    │
│  │ • ICE candidate optimization                                   │    │
│  │ • Connection state monitoring                                  │    │
│  └────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  UI Optimization                                                        │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │ • Efficient widget rebuilds (Consumer pattern)                 │    │
│  │ • Renderer lifecycle management                                │    │
│  │ • Lazy loading of remote streams                               │    │
│  │ • Adaptive grid layout                                         │    │
│  └────────────────────────────────────────────────────────────────┘    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

This architecture provides a scalable, secure, and performant video conferencing solution using WebRTC technology.
