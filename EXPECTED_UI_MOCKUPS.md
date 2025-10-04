# Expected UI - Visual Mockups

This document shows what you should see when the WebRTC implementation is working correctly.

## 📱 Mobile App Screenshots (Text Mockups)

### 1. Home Screen - Before Creating Meeting

```
╔══════════════════════════════════════╗
║  Beauty LMS Live Courses        ☰ ═  ║
╠══════════════════════════════════════╣
║                                      ║
║  🎥 Create New Meeting               ║
║  ────────────────────────────────    ║
║                                      ║
║  Host Name:                          ║
║  ┌────────────────────────────────┐  ║
║  │ John Doe                       │  ║
║  └────────────────────────────────┘  ║
║                                      ║
║  Meeting Title:                      ║
║  ┌────────────────────────────────┐  ║
║  │ Team Standup                   │  ║
║  └────────────────────────────────┘  ║
║                                      ║
║  Description:                        ║
║  ┌────────────────────────────────┐  ║
║  │ Daily sync meeting             │  ║
║  └────────────────────────────────┘  ║
║                                      ║
║  ┌────────────────────────────────┐  ║
║  │    🚀 Create Meeting           │  ║
║  └────────────────────────────────┘  ║
║                                      ║
║  ────────────────────────────────    ║
║                                      ║
║  👥 Join Existing Meeting            ║
║  ────────────────────────────────    ║
║                                      ║
║  Meeting Code:                       ║
║  ┌────────────────────────────────┐  ║
║  │ ABC123                         │  ║
║  └────────────────────────────────┘  ║
║                                      ║
║  Your Name:                          ║
║  ┌────────────────────────────────┐  ║
║  │ Jane Smith                     │  ║
║  └────────────────────────────────┘  ║
║                                      ║
║  ┌────────────────────────────────┐  ║
║  │    🔗 Join Meeting             │  ║
║  └────────────────────────────────┘  ║
║                                      ║
╚══════════════════════════════════════╝
```

### 2. Permission Dialog - iOS

```
╔══════════════════════════════════════╗
║                                      ║
║                                      ║
║  "api_demo" Would Like to            ║
║  Access the Camera                   ║
║                                      ║
║  This app needs access to your       ║
║  camera for video conferencing       ║
║                                      ║
║  ┌────────────┐  ┌────────────────┐  ║
║  │Don't Allow │  │      OK        │  ║
║  └────────────┘  └────────────────┘  ║
║                                      ║
╚══════════════════════════════════════╝
```

### 3. Permission Dialog - Android

```
╔══════════════════════════════════════╗
║                                      ║
║  Allow api_demo to take pictures     ║
║  and record video?                   ║
║                                      ║
║  ┌────────────┐  ┌────────────────┐  ║
║  │   DENY     │  │    ALLOW       │  ║
║  └────────────┘  └────────────────┘  ║
║                                      ║
╚══════════════════════════════════════╝
```

### 4. Meeting Screen - Single Participant (Host Only)

```
╔══════════════════════════════════════╗
║ Team Standup       Code: ABC123  ⋮ ═ ║
║ 💬 🔔 👥 🚪                           ║
╠══════════════════════════════════════╣
║ Daily sync meeting                   ║
║ Host: John Doe • 1 participant       ║
║ 🟢 LIVE  Started: 14:30              ║
╠══════════════════════════════════════╣
║                                      ║
║  ╔════════════════════════════════╗  ║
║  ║                                ║  ║
║  ║    📹 LIVE CAMERA FEED         ║  ║
║  ║                                ║  ║
║  ║    [Your face visible here]    ║  ║
║  ║                                ║  ║
║  ║    Camera shows YOU in         ║  ║
║  ║    real-time, mirrored         ║  ║
║  ║                                ║  ║
║  ║                                ║  ║
║  ║  ┌──────────────────────────┐  ║  ║
║  ║  │ 🎤 John Doe   [HOST] 👑 │  ║  ║
║  ║  └──────────────────────────┘  ║  ║
║  ╚════════════════════════════════╝  ║
║                                      ║
╠══════════════════════════════════════╣
║  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐║
║  │  📹  │ │  🎤  │ │  🖥️  │ │  💬  │║
║  │Video │ │Audio │ │Share │ │Chat  │║
║  └──────┘ └──────┘ └──────┘ └──────┘║
║              ┌──────┐                ║
║              │  📞  │                ║
║              │Leave │                ║
║              └──────┘                ║
╚══════════════════════════════════════╝

Legend:
- Yellow border = Host
- Green mic icon = Audio ON
- Blue video button = Video ON
```

### 5. Meeting Screen - Two Participants (Split View)

```
╔══════════════════════════════════════╗
║ Team Standup       Code: ABC123  ⋮ ═ ║
╠══════════════════════════════════════╣
║ Host: John • 2 participants          ║
║ 🟢 LIVE                              ║
╠══════════════════════════════════════╣
║                                      ║
║  ╔═══════════════╗  ╔══════════════╗ ║
║  ║  📹 LIVE      ║  ║  📹 LIVE     ║ ║
║  ║               ║  ║              ║ ║
║  ║  [John's      ║  ║  [Jane's     ║ ║
║  ║   Camera]     ║  ║   Camera]    ║ ║
║  ║               ║  ║              ║ ║
║  ║ ┌───────────┐ ║  ║ ┌──────────┐║ ║
║  ║ │🎤 John D. │ ║  ║ │🎤 Jane S.│║ ║
║  ║ │  [HOST]👑 │ ║  ║ │          │║ ║
║  ║ └───────────┘ ║  ║ └──────────┘║ ║
║  ╚═══════════════╝  ╚══════════════╝ ║
║                                      ║
╠══════════════════════════════════════╣
║    📹     🎤     🖥️     💬     📞    ║
╚══════════════════════════════════════╝

Host sees:
✅ Own video on left (mirrored)
✅ Participant video on right
✅ Both videos are LIVE feeds

Participant sees:
✅ Host video on left
✅ Own video on right (mirrored)
✅ Both videos are LIVE feeds
```

### 6. Meeting Screen - Four Participants (2x2 Grid)

```
╔══════════════════════════════════════╗
║ Team Standup       Code: ABC123  ⋮ ═ ║
╠══════════════════════════════════════╣
║ Host: John • 4 participants          ║
╠══════════════════════════════════════╣
║                                      ║
║  ╔═══════════╗  ╔═══════════╗        ║
║  ║ 📹 LIVE   ║  ║ 📹 LIVE   ║        ║
║  ║ [John's   ║  ║ [Jane's   ║        ║
║  ║  Camera]  ║  ║  Camera]  ║        ║
║  ║ 🎤 John   ║  ║ 🎤 Jane   ║        ║
║  ║   [HOST]👑║  ║           ║        ║
║  ╚═══════════╝  ╚═══════════╝        ║
║                                      ║
║  ╔═══════════╗  ╔═══════════╗        ║
║  ║ 📹 LIVE   ║  ║ 📹 LIVE   ║        ║
║  ║ [Mike's   ║  ║ [Sarah's  ║        ║
║  ║  Camera]  ║  ║  Camera]  ║        ║
║  ║ 🎤 Mike   ║  ║ 🎤 Sarah  ║        ║
║  ║           ║  ║           ║        ║
║  ╚═══════════╝  ╚═══════════╝        ║
║                                      ║
╠══════════════════════════════════════╣
║    📹     🎤     🖥️     💬     📞    ║
╚══════════════════════════════════════╝

All participants see:
✅ 4 live video feeds
✅ Grid auto-adjusts to 2x2 layout
✅ Own video included in grid
✅ Host has special border/badge
```

### 7. Media Controls - Video OFF State

```
╔══════════════════════════════════════╗
║                                      ║
║  ╔════════════════════════════════╗  ║
║  ║                                ║  ║
║  ║          👤                    ║  ║
║  ║          JD                    ║  ║
║  ║                                ║🚫║
║  ║    (Avatar with initials)      ║📹║
║  ║                                ║  ║
║  ║  ┌──────────────────────────┐  ║  ║
║  ║  │ 🎤 John Doe   [HOST] 👑 │  ║  ║
║  ║  └──────────────────────────┘  ║  ║
║  ╚════════════════════════════════╝  ║
║                                      ║
╠══════════════════════════════════════╣
║  ┌──────┐ ┌──────┐                  ║
║  │  📹  │ │  🎤  │                  ║
║  │Video │ │Audio │                  ║
║  └──────┘ └──────┘                  ║
║   (Gray)  (Blue)                    ║
╚══════════════════════════════════════╝

When video is OFF:
❌ No camera feed visible
✅ Avatar with initials shown
🚫 Red camera-off icon in corner
⚪ Video button turns gray/red
```

### 8. Media Controls - Audio MUTED State

```
╔══════════════════════════════════════╗
║                                      ║
║  ╔════════════════════════════════╗  ║
║  ║                                ║  ║
║  ║    📹 LIVE CAMERA FEED         ║  ║
║  ║                                ║  ║
║  ║    [Camera feed visible]       ║  ║
║  ║                                ║  ║
║  ║  ┌──────────────────────────┐  ║  ║
║  ║  │ 🔇 John Doe   [HOST] 👑 │  ║  ║
║  ║  └──────────────────────────┘  ║  ║
║  ╚════════════════════════════════╝  ║
║                                      ║
╠══════════════════════════════════════╣
║  ┌──────┐ ┌──────┐                  ║
║  │  📹  │ │  🎤  │                  ║
║  │Video │ │Audio │                  ║
║  └──────┘ └──────┘                  ║
║   (Blue)  (Gray)                    ║
╚══════════════════════════════════════╝

When audio is MUTED:
✅ Camera feed still visible
❌ No audio transmitted
🔇 Red mic-off icon in overlay
⚪ Audio button turns gray/red
```

### 9. Chat Panel View

```
╔══════════════════════════════════════╗
║ Team Standup       Code: ABC123  ⋮ ═ ║
║ 💬 (selected) 🔔 👥 🚪               ║
╠══════════════════════════════════════╣
║ 💬 Chat Messages                     ║
║ ──────────────────────────────────   ║
║                                      ║
║ System: Jane joined the meeting      ║
║ 14:31                                ║
║                                      ║
║ John: Hi everyone! 👋                ║
║ 14:32                                ║
║                                      ║
║ Jane: Hello! Ready to start?         ║
║ 14:32                                ║
║                                      ║
║ John: Yes, let's begin               ║
║ 14:33                                ║
║                                      ║
║ System: Mike joined the meeting      ║
║ 14:33                                ║
║                                      ║
║ Mike: Sorry I'm late                 ║
║ 14:34                                ║
║                                      ║
║                                      ║
║ ──────────────────────────────────   ║
║ ┌──────────────────────────────────┐ ║
║ │ Type a message...                │ ║
║ └──────────────────────────────────┘ ║
║                                  📤  ║
╠══════════════════════════════════════╣
║    📹     🎤     🖥️     💬     📞    ║
╚══════════════════════════════════════╝
```

### 10. Participants List Modal

```
╔══════════════════════════════════════╗
║ Participants (3)                  ✕  ║
╠══════════════════════════════════════╣
║                                      ║
║ ┌────────────────────────────────┐   ║
║ │ 👤 John Doe      [HOST] 👑     │   ║
║ │ Joined: 14:30                  │   ║
║ │                   📹 ON  🎤 ON │   ║
║ └────────────────────────────────┘   ║
║                                      ║
║ ┌────────────────────────────────┐   ║
║ │ 👤 Jane Smith                  │   ║
║ │ Joined: 14:31                  │   ║
║ │                   📹 ON  🎤 ON │   ║
║ └────────────────────────────────┘   ║
║                                      ║
║ ┌────────────────────────────────┐   ║
║ │ 👤 Mike Johnson                │   ║
║ │ Joined: 14:33                  │   ║
║ │                   📹 OFF 🎤 ON │   ║
║ └────────────────────────────────┘   ║
║                                      ║
║ ┌────────────────────────────────┐   ║
║ │         Close                  │   ║
║ └────────────────────────────────┘   ║
║                                      ║
╚══════════════════════════════════════╝
```

### 11. Connection Status Indicators

```
Connected (Good):
┌────────────────────────────────────┐
│ 🟢 Connected • 3 participants      │
└────────────────────────────────────┘

Connecting:
┌────────────────────────────────────┐
│ 🟡 Connecting...                   │
└────────────────────────────────────┘

Disconnected:
┌────────────────────────────────────┐
│ 🔴 Disconnected • Reconnecting...  │
└────────────────────────────────────┘
```

## 🎨 Color Coding

### Button States
- 🟦 **Blue** = Active (Video/Audio ON)
- ⚪ **Gray/Red** = Inactive (Video/Audio OFF)
- 🟧 **Orange** = Screen Sharing Active
- 🟪 **Purple** = Chat Selected
- 🟥 **Red** = Leave Meeting (Warning)

### Status Indicators
- 🟢 **Green** = Connected / Live / ON
- 🟡 **Yellow** = Host Indicator / Warning
- 🔴 **Red** = Disconnected / OFF / Error
- ⚫ **Gray** = Inactive / Disabled

### Icons
- 📹 = Video Camera
- 🎤 = Microphone
- 🖥️ = Screen Share
- 💬 = Chat
- 📞 = Phone/Leave
- 👥 = Participants
- 🔔 = Notifications
- 🚪 = Exit
- 👑 = Host Badge
- ✅ = Success
- ❌ = Error
- ⚠️ = Warning

## 📐 Layout Specs

### Grid Layouts by Participant Count

**1 Participant**: Full screen (16:9)
```
┌─────────────────────────┐
│                         │
│         1 TILE          │
│       (FULLSCREEN)      │
│                         │
└─────────────────────────┘
```

**2-4 Participants**: 2x2 Grid (4:3 per tile)
```
┌───────────┬───────────┐
│    1      │     2     │
├───────────┼───────────┤
│    3      │     4     │
└───────────┴───────────┘
```

**5-9 Participants**: 3x3 Grid (1:1 per tile)
```
┌──────┬──────┬──────┐
│  1   │  2   │  3   │
├──────┼──────┼──────┤
│  4   │  5   │  6   │
├──────┼──────┼──────┤
│  7   │  8   │  9   │
└──────┴──────┴──────┘
```

**10+ Participants**: 4x4 Grid (3:4 per tile)
```
┌────┬────┬────┬────┐
│ 1  │ 2  │ 3  │ 4  │
├────┼────┼────┼────┤
│ 5  │ 6  │ 7  │ 8  │
├────┼────┼────┼────┤
│ 9  │ 10 │ 11 │ 12 │
├────┼────┼────┼────┤
│ 13 │ 14 │ 15 │ 16 │
└────┴────┴────┴────┘
```

## ✨ Visual Enhancements

### Video Tile Features
- **Border**: Yellow for host, gray for others
- **Overlay**: Semi-transparent black background
- **Icons**: Mic/video status in overlay
- **Name**: Participant name with host badge
- **Corner Icon**: Camera-off indicator when disabled

### Animations (Expected)
- Smooth fade-in when video starts
- Smooth fade-out when video stops
- Grid layout transitions when participants join/leave
- Button press animations
- Modal slide-up/down animations

## 🎥 What Real Video Should Look Like

When working correctly:

1. **Local Video** (Your camera):
   - Shows live feed from your camera
   - Updates in real-time as you move
   - Mirrored (like looking in mirror)
   - Clear and smooth (15-30 fps)

2. **Remote Video** (Other participants):
   - Shows their live camera feed
   - Updates in real-time
   - NOT mirrored (you see them normally)
   - May have slight delay (100-500ms normal)

3. **Audio**:
   - Clear voice transmission
   - No echo (if using headphones)
   - Real-time (minimal latency)
   - Background noise reduced

## 📊 Performance Indicators

Good performance:
- Video: 15-30 FPS, smooth motion
- Audio: Clear, no crackling, no echo
- Latency: <500ms delay
- CPU: <50% usage
- Memory: <500MB

Poor performance signals:
- Video: Choppy, frozen frames
- Audio: Robotic, cutting out, echo
- Latency: >1s delay
- CPU: >80% usage
- High battery drain

---

## 💡 Tips for Taking Real Screenshots

When testing on physical devices:

1. **Good Lighting**: Ensures faces visible in screenshots
2. **Clear Background**: Easier to see what's happening
3. **Show UI Elements**: Capture buttons, overlays, indicators
4. **Different States**: Video on, video off, muted, etc.
5. **Multiple Devices**: Show both sides of connection
6. **Landscape + Portrait**: Test both orientations

## 🎬 Demo Scenario

For best screenshots:
1. Take selfie-style shot of video tile showing YOUR face
2. Position two devices side-by-side showing connection
3. Capture the grid with multiple participants
4. Show media controls in different states
5. Demonstrate chat panel with messages
6. Show participants list modal

These mockups represent the EXPECTED behavior when the WebRTC implementation is working correctly on physical devices.
