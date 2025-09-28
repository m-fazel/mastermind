# Mastermind CLI Game 🎮

A command-line interface version of the classic Mastermind code-breaking game, built with Swift and integrated with the [Mastermind API](https://mastermind.darkube.app).

## 🎯 Overview

Mastermind is a classic code-breaking game where you try to guess a secret code within a limited number of attempts. This CLI implementation allows you to play the game directly in your terminal using numeric codes, with real-time API integration for code validation and scoring.

## ✨ Features

- **⌨️ Command-Line Interface**: Play directly in your terminal
- **🌐 Real API Integration**: Uses mastermind.darkube.app for game logic
- **🔢 Numeric Gameplay**: Uses digits 1-6 instead of colors
- **📊 Live Feedback**: Instant validation with B (black) and W (white) pegs
- **⚡ Fast & Lightweight**: No GUI dependencies, runs anywhere Swift is supported
- **🎯 Simple Rules**: Easy to learn, challenging to master

## 🛠️ Requirements

- **Swift 5.3+**
- **macOS** or **Linux** with Swift support
- **Internet connection** (for API calls)

## 🚀 Installation & Usage

### 1. Clone the Repository
```bash
git clone https://github.com/m-fazel/mastermind.git
cd mastermind
```

### 2. Build the Project
```bash
swift build
```

### 3. Run the Game
```bash
swift run
```

### Or Build for Release
```bash
swift build -c release
./.build/release/mastermind
```

## 🎮 How to Play

### Game Rules
- The API generates a secret 4-digit code using numbers 1-6
- You have unlimited attempts to guess the code
- After each guess, you receive feedback:
  - **B** : Correct digit in correct position
  - **W** : Correct digit in wrong position

### Game Flow
1. The game starts automatically and connects to the API
2. Enter your 4-digit guesses using numbers 1-6 (e.g., "1234")
3. Receive immediate feedback with B and W indicators
4. Continue until you solve the code

### Valid Input
- **4 digits** exactly
- **Numbers 1-6 only** (no letters or other characters)
- Example valid guesses: `1234`, `6543`, `1111`, `2626`

## 🔗 API Integration

The game uses the Mastermind API at `https://mastermind.darkube.app`:

- **POST /game** - Creates a new game session
- **POST /guess** - Submits a guess and gets feedback
- **DELETE /game/{id}** - Cleans up game session

### Custom Server
You can use a different server by setting the environment variable:
```bash
export MASTERMINDSERVER="https://your-mastermind-server.com"
swift run
```

## 🎯 Example Game Session

```
===============================
🎯 Mastermind Game (Terminal)
Server: https://mastermind.darkube.app
Rules:
- Enter a 4-digit guess (digits 1–6).
- B = correct digit in correct place.
- W = correct digit in wrong place.
- Type 'exit' anytime to quit.
===============================

Creating new game...
✅ Game created. ID: abc123-def456

Enter your guess (e.g. 1234) or 'exit': 1234
Result: BW

Enter your guess (e.g. 1234) or 'exit': 1256
Result: BBW

Enter your guess (e.g. 1234) or 'exit': 1265
Result: BBBB

🎉 You guessed the code!
Done.
```

## 🔍 Understanding Feedback

- **B** = Correct number in correct position
- **W** = Correct number in wrong position
- **No letter** = Number not in code

**Example:**
- Secret code: `1265`
- Your guess: `1234` → `BW` (1 and 2 correct, but 2 is in wrong position)
- Your guess: `1256` → `BBW` (1, 2, 5 correct, but 6 is in wrong position)
- Your guess: `1265` → `BBBB` (all correct!)

## 🐛 Troubleshooting

### Common Issues

1. **API Connection Failed**
   ```
   ❌ Game creation failed: Connection refused
   ```
   **Solution**: Check your internet connection and verify `https://mastermind.darkube.app` is accessible

2. **Invalid Guess Error**
   ```
   ⚠️ Invalid guess. Must be 4 digits between 1–6.
   ```
   **Solution**: Enter exactly 4 digits using only numbers 1-6

3. **Build Errors on Linux**
   ```
   error: missing dependency 'FoundationNetworking'
   ```
   **Solution**: On Linux, ensure you have all required Swift foundation libraries

### Debug Mode
Run with verbose logging:
```bash
swift run --verbose
```

## 🎲 Game Strategy Tips

1. **Start with diverse numbers** like `1234` to test many digits
2. **Use B feedback** to lock in correct positions
3. **Use W feedback** to identify correct numbers in wrong positions
4. **Eliminate possibilities** systematically
5. **Common patterns**: Try sequences like `1122`, `3344`, etc.

## 🤝 Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Open a Pull Request

### Potential Enhancements
- Difficulty levels (code length, digit range)
- Game statistics and history
- Colorized output
- Hint system
- Timer and score tracking

## 👥 Author

- **Mohammad Fazel Samavati** - [m-fazel](https://github.com/m-fazel)

## 🙏 Acknowledgments

- **Mastermind API** - [mastermind.darkube.app](https://mastermind.darkube.app) for providing the backend service
- **Swift Community** - For excellent command-line tools and libraries

## 🆘 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Ensure you have Swift 5.3+ installed
3. Verify internet connectivity for API calls
4. Check the GitHub issues for similar problems

---

**Ready to challenge your code-breaking skills? Start playing now!** 🎉

```bash
swift run
```
