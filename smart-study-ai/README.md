# 🎓 StudyAI – Smart Study Assistant

> **Google Solution Challenge 2026 Prototype**  
> An AI-powered web app that transforms any text into summaries, key concepts, and quiz questions using Google Gemini.

---

## 🚀 What It Does

| Step | Input | AI Action | Output |
|------|-------|-----------|--------|
| 1 | User pastes study material or types a topic | Gemini processes the text | Summary, Key Concepts, Quiz Questions |
| 2 | User clicks an option in the quiz | App reveals correct/wrong answer | Instant feedback |

---

## ✨ Features

- **📄 AI Summary** – Get a concise 3–5 sentence summary of any topic
- **💡 Key Concepts** – Extract 5 important terms with one-line explanations
- **🧠 Interactive Quiz** – 3 multiple-choice questions with instant answer reveal
- **⚡ Quick Topic Buttons** – One-click prompts for common study topics
- **🔒 Secure** – API key stored locally in the browser, never sent to any server
- **📋 Copy to Clipboard** – Export any result with one click

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | HTML5, Vanilla CSS, Vanilla JavaScript |
| AI | Google Gemini 2.0 Flash API (via Google AI Studio) |
| Hosting | Firebase Hosting (or any static host) |

---

## 🏁 How to Run

### Option A – Open Directly (No Server Needed)
1. Open `index.html` in any modern browser (Chrome recommended)
2. Enter your Gemini API key from [Google AI Studio](https://aistudio.google.com/apikey)
3. Paste any text or click a quick topic → click **Analyze with AI**

### Option B – Firebase Hosting
```bash
npm install -g firebase-tools
firebase login
firebase init hosting   # Point public directory to this folder
firebase deploy
```

---

## 🔑 Getting a Gemini API Key

1. Visit [https://aistudio.google.com/apikey](https://aistudio.google.com/apikey)
2. Click **Create API Key**
3. Copy the key and paste it into the app's API key field

---

## 🎯 Core AI Flow

```
User Input (text/topic)
        ↓
  Gemini 2.0 Flash API
  (Structured prompt with section labels)
        ↓
  Parse SUMMARY / KEY_CONCEPTS / QUIZ sections
        ↓
  Render interactive cards in the UI
```

---

## 📁 Project Structure

```
smart-study-ai/
├── index.html   # App structure & layout
├── style.css    # Premium dark UI styles
├── app.js       # Gemini API logic + rendering
└── README.md    # This file
```

---

## 🌟 Edge Cases Handled

- Empty or very short input → button disabled
- Missing API key → banner shown with input field
- API errors → toast notification with error message
- Quiz with no options parsed → falls back to raw text display
- `maxlength=5000` on textarea to stay within token limits

---

## 🏆 Solution Challenge Details

- **Problem**: Students struggle to quickly extract key information from large amounts of study material
- **User**: Students and self-learners of any age
- **AI Feature**: Gemini-powered intelligent content structuring into summaries, concepts, and quizzes
- **Impact**: Reduces study time and improves retention through active recall (quiz feature)

---

*Built with ❤️ using Google Gemini AI*
