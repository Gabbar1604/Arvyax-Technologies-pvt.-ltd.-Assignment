# 🧘‍♀️ How to Add New Yoga Sessions - Complete Guide

## 📖 Overview

This app is modular - you can add new yoga sessions without any code changes. Just add files and update the catalog!

---

## 🎯 Quick Summary

**Only 3 Simple Steps:**

1. ✅ Create JSON file
2. ✅ Add Images and Audio  
3. ✅ Update Catalog entry

**Result:** App will automatically detect and load your new session! 🎉

---

## 📁 Required Folder Structure

```text
yoga_session_app/
└── assets/
    ├── data/           ← JSON files go here
    ├── images/         ← Pose images go here  
    └── audio/          ← Audio files go here
```

---

## 🚀 STEP 1: Create Session JSON File

### 📝 File Location

Save your file as: `assets/data/YourSessionNameJson.json`

### 📋 JSON Template

```json
{
  "sessionName": "Your Session Name",
  "duration": 30,
  "difficulty": "Beginner",
  "description": "Session description", 
  "poses": [
    {
      "name": "Pose Name",
      "image": "YourImage.png",
      "duration": 5,
      "startTime": 0,
      "description": "How to perform this pose"
    },
    {
      "name": "Second Pose",
      "image": "YourImage2.png", 
      "duration": 8,
      "startTime": 5,
      "description": "Instructions for second pose"
    }
  ],
  "audioFile": "YourMainAudio.mp3",
  "introAudio": "YourIntro.mp3",
  "outroAudio": "YourOutro.mp3"
}
```

### ⚠️ Important Rules

- **Duration:** Total time of all poses = main audio length
- **StartTime:** When pose should start (in seconds)
- **File Names:** Must be exactly matching

---

## 🚀 STEP 2: Add Images and Audio

### 🖼️ Images (assets/images/ folder)

- **Format:** PNG recommended
- **Size:** 500x500px or larger
- **Quality:** Clear and high contrast
- **Names:** Exact names as mentioned in JSON

### 🎵 Audio Files (assets/audio/ folder)

- **IntroAudio:** Welcome message (5-10 seconds)
- **MainAudio:** Background music for entire session
- **OutroAudio:** Thank you message (5-10 seconds)
- **Format:** MP3 only
- **Length:** Must match JSON duration

---

## 🚀 STEP 3: Update Session Catalog

### 📂 File: `assets/data/session_catalog.json`

Open this file and add your new entry to the "sessions" array:

```json
{
  "id": "unique_id_here",
  "title": "Display Title", 
  "category": "strength",
  "difficulty": "beginner",
  "duration": 30,
  "description": "Short description",
  "thumbnail": "assets/images/YourThumbnail.png",
  "jsonFile": "YourSessionNameJson.json",
  "tags": ["tag1", "tag2", "tag3"],
  "instructor": "AI Yoga Guide",
  "isActive": true
}
```

### 🎨 Available Categories

- `spinal_mobility` - Spine exercises
- `vinyasa` - Flowing sequences  
- `pranayama` - Breathing exercises
- `strength` - Strength building
- `flexibility` - Stretching poses
- `relaxation` - Relaxation sessions
- `balance` - Balance poses

---

## ✅ Testing Your New Session

### Step 1: Check Files

```text
✅ JSON file: assets/data/YourSessionJson.json
✅ Images: assets/images/YourImages.png  
✅ Audio: assets/audio/YourAudio.mp3
✅ Catalog: Updated session_catalog.json
```

### Step 2: Test in App

1. **Hot Reload:** Press 'r' in terminal
2. **Home Screen:** Click Session Library button
3. **Library:** Your new session should appear
4. **Play:** Click session to test

---

## 🚨 Common Problems and Solutions

### ❌ Problem: Session not appearing

**Solutions:**
- ✅ Check `"isActive": true` in catalog
- ✅ JSON file name exactly matches catalog entry
- ✅ All required fields are filled

### ❌ Problem: Images not loading  

**Solutions:**
- ✅ Image file names exactly match JSON
- ✅ Images are in `assets/images/` folder
- ✅ Use PNG format

### ❌ Problem: Audio not playing

**Solutions:**
- ✅ Audio file names exactly match JSON  
- ✅ Audio files are in `assets/audio/` folder
- ✅ Use MP3 format
- ✅ Audio length matches JSON duration

---

## 🎯 Real Example

### Example JSON File: `MorningYogaJson.json`

```json
{
  "sessionName": "Morning Energizer",
  "duration": 20,
  "difficulty": "Beginner", 
  "description": "Start your day with energy",
  "poses": [
    {
      "name": "Sun Salutation",
      "image": "SunSalute.png",
      "duration": 10,
      "startTime": 0,
      "description": "Wake up your body"
    },
    {
      "name": "Tree Pose", 
      "image": "TreePose.png",
      "duration": 10,
      "startTime": 10,
      "description": "Find your balance"
    }
  ],
  "audioFile": "MorningMusic.mp3",
  "introAudio": "MorningIntro.mp3", 
  "outroAudio": "MorningOutro.mp3"
}
```

### Example Catalog Entry

```json
{
  "id": "morning_energizer",
  "title": "Morning Energizer",
  "category": "flexibility",
  "difficulty": "beginner",
  "duration": 20,
  "description": "Start your day with energy",
  "thumbnail": "assets/images/morning_thumb.png",
  "jsonFile": "MorningYogaJson.json", 
  "tags": ["morning", "energy", "beginner"],
  "instructor": "AI Yoga Guide",
  "isActive": true
}
```

---

## 🎉 Final Result

**Your app will automatically:**

- ✅ Detect new session
- ✅ Display in session library  
- ✅ Play with perfect audio-visual sync
- ✅ Handle all navigation

**🎯 Just add files, update catalog, and enjoy! No coding required!** 🧘‍♀️✨

---

## 📋 Quick Checklist

Before testing your new session:

- [ ] JSON file created in `assets/data/`
- [ ] All images added to `assets/images/`
- [ ] All audio files added to `assets/audio/`
- [ ] Session catalog updated with new entry
- [ ] `isActive: true` set in catalog
- [ ] All file names exactly match
- [ ] Audio duration matches JSON duration

**If all checkboxes are ✅, your session should work perfectly!**
