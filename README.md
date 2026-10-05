# Roast Pong

![Godot](https://img.shields.io/badge/Godot-4.x-478CBF?style=for-the-badge&logo=godot-engine&logoColor=white)
![GDScript](https://img.shields.io/badge/GDScript-000000?style=for-the-badge&logo=godot-engine&logoColor=white)
![Gemini](https://img.shields.io/badge/Gemini%20API-4285F4?style=for-the-badge&logo=google&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-In%20Development-orange?style=for-the-badge)

## Preview

<img width="1280" height="900" alt="Screenshot 2026-10-05 142920" src="https://github.com/user-attachments/assets/caa8218a-f606-44bb-a57b-c2bff576cd43" />

## 🇩🇪 Deutsch

### Was ist Roast Pong?

Roast Pong ist ein Pong-Spiel mit einem Twist: Zwei CPU-gesteuerte Paddles spielen gegeneinander – und wer einen Punkt verliert, wird vom Gegner geroastet. Die Roasts werden live von der **Google Gemini API** generiert und bewertet. Der Verlierer kontert automatisch. Das Spiel läuft komplett autonom, die KI sorgt für die Unterhaltung.

### Features

- 🏓 Klassisches Pong – CPU vs. CPU
- 🤖 KI-generierte Roasts via Google Gemini 2.0 Flash
- 🔥 Automatische Roasts nach jedem Punkt, live generiert
- 💢 Automatischer KI-Konter vom Verlierer
- 🧠 Roast-Scoring durch die KI (1–10) basierend auf Kürze, Schärfe, Kreativität und Überraschungseffekt
- 📡 Fallback auf lokale Roast-Liste bei fehlender Internetverbindung
- 🎮 Hauptmenü mit einstellbarer Schwierigkeit und Punktelimit
- 🏆 Game Over Screen mit Rematch-Option
- 😱 Xolonium Font für eine klare, spielgerechte Darstellung

### Gemini API

Das Spiel nutzt **Google Gemini 2.0 Flash** um Roasts live zu generieren und zu bewerten.

**Bewertungskriterien (Score 1–10):**

| Kriterium         | Beschreibung                                | Punkte |
| ----------------- | ------------------------------------------- | ------ |
| Kürze             | Unter 6 Wörter = 3, unter 9 = 2, länger = 1 | 1–3    |
| Schärfe           | Persönlicher Angriff = 3, generisch = 1     | 1–3    |
| Kreativität       | Unerwartete Metapher = 2, simpel = 1        | 1–2    |
| Überraschungsende | Unerwartetes Ende = 2                       | 0–2    |

**Gemini antwortet als JSON:**

```json
{ "roast": "Even my grandma paddles faster.", "score": 9, "emoji": "😱" }
```

**Fallback:** Bei fehlender Verbindung oder API-Fehler greift das Spiel automatisch auf eine lokale Roast-Liste zurück.

### Setup

1. API-Key bei [Google AI Studio](https://aistudio.google.com) erstellen
2. Datei `scripts/Config.gd` anlegen:
   ```gdscript
   extends Node
   const GEMINI_KEY: String = "dein-key-hier"
   ```
3. `Config.gd` in `.gitignore` eintragen:
   ```
   scripts/Config.gd
   ```

### Projektstruktur

```
res://
├── assets/
│   ├── font/
│   │   └── Xolonium-Regular.ttf
│   └── sounds/
├── scenes/
│   ├── main_menu.tscn
│   ├── main.tscn
│   └── game_over.tscn
└── scripts/
	├── main.gd
	├── ball.gd
	├── cpu.gd
	├── cpu2.gd
	├── roast_overlay.gd
	├── roast_scorer.gd
	├── roasts.gd
	├── game_settings.gd
	├── Config.gd          ← nicht ins Git!
	├── main_menu.gd
	└── game_over.gd
```

### Autoloads

| Name           | Datei              | Funktion                                    |
| -------------- | ------------------ | ------------------------------------------- |
| `Config`       | `Config.gd`        | Gemini API-Key                              |
| `GameSettings` | `game_settings.gd` | Schwierigkeit, Ballspeed, Score-Limit       |
| `RoastScorer`  | `roast_scorer.gd`  | Fallback: Roast bewerten + gewichtet ziehen |
| `Roasts`       | `roasts.gd`        | Fallback: lokale Roast- und Konter-Liste    |

### Installation

1. Repository klonen:
   ```bash
   git clone https://github.com/TranceMeli/roast-pong.git
   ```
2. Projekt in **Godot 4.x** öffnen
3. `Config.gd` mit eigenem Gemini API-Key anlegen (siehe Setup)
4. `main_menu.tscn` als Hauptszene setzen
5. Starten mit **F5**

### Steuerung

Das Spiel läuft vollautomatisch – einfach zuschauen und die KI-Roasts genießen.

---

## 🇬🇧 English

### What is Roast Pong?

Roast Pong is a Pong game with a twist: two CPU-controlled paddles play against each other – and whoever loses a point gets roasted by the opponent. Roasts are generated and rated live by the **Google Gemini API**. The loser automatically claps back. The game runs fully autonomously while the AI provides the entertainment.

### Features

- 🏓 Classic Pong – CPU vs. CPU
- 🤖 AI-generated roasts via Google Gemini 2.0 Flash
- 🔥 Automatic roasts after every point, generated live
- 💢 Automatic AI counter from the loser
- 🧠 Roast scoring by the AI (1–10) based on brevity, harshness, creativity and surprise ending
- 📡 Fallback to local roast list when offline
- 🎮 Main menu with adjustable difficulty and score limit
- 🏆 Game over screen with rematch option
- 😱 Xolonium Font for clean, game-appropriate typography

### Gemini API

The game uses **Google Gemini 2.0 Flash** to generate and rate roasts in real time.

**Scoring criteria (score 1–10):**

| Criterion       | Description                                | Points |
| --------------- | ------------------------------------------ | ------ |
| Brevity         | Under 6 words = 3, under 9 = 2, longer = 1 | 1–3    |
| Harshness       | Personal attack = 3, generic = 1           | 1–3    |
| Creativity      | Unexpected metaphor = 2, plain = 1         | 1–2    |
| Surprise ending | Unexpected ending = 2                      | 0–2    |

**Gemini responds as JSON:**

```json
{ "roast": "Even my grandma paddles faster.", "score": 9, "emoji": "😱" }
```

**Fallback:** If the connection fails or the API returns an error, the game automatically falls back to a local roast list.

### Setup

1. Create an API key at [Google AI Studio](https://aistudio.google.com)
2. Create the file `scripts/Config.gd`:
   ```gdscript
   extends Node
   const GEMINI_KEY: String = "your-key-here"
   ```
3. Add `Config.gd` to `.gitignore`:
   ```
   scripts/Config.gd
   ```

### Project Structure

```
res://
├── assets/
│   ├── font/
│   │   └── Xolonium-Regular.ttf
│   └── sounds/
├── scenes/
│   ├── main_menu.tscn
│   ├── main.tscn
│   └── game_over.tscn
└── scripts/
	├── main.gd
	├── ball.gd
	├── cpu.gd
	├── cpu2.gd
	├── roast_overlay.gd
	├── roast_scorer.gd
	├── roasts.gd
	├── game_settings.gd
	├── Config.gd          ← do not commit!
	├── main_menu.gd
	└── game_over.gd
```

### Autoloads

| Name           | File               | Purpose                                  |
| -------------- | ------------------ | ---------------------------------------- |
| `Config`       | `Config.gd`        | Gemini API key                           |
| `GameSettings` | `game_settings.gd` | Difficulty, ball speed, score limit      |
| `RoastScorer`  | `roast_scorer.gd`  | Fallback: score and weighted pick roasts |
| `Roasts`       | `roasts.gd`        | Fallback: local roast and counter list   |

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/TranceMeli/roast-pong.git
   ```
2. Open the project in **Godot 4.x**
3. Create `Config.gd` with your own Gemini API key (see Setup)
4. Set `main_menu.tscn` as the main scene
5. Run with **F5**

### Controls

The game runs fully automatically – just sit back and enjoy the AI roasts.

---

## Credits

Made by [TranceMeli](https://github.com/TranceMeli)

Font: [Xolonium](https://fontlibrary.org/en/font/xolonium) by Severin Meyer – SIL Open Font License

Powered by [Google Gemini API](https://aistudio.google.com)
