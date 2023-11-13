//
//  ContentView.swift
//  WordScrambleGame
//
//  Created by MARIOS PLIATSIKAS on 12.11.23.
//
import SwiftUI
import Combine

class WordScrambleGame: ObservableObject {
    let words = ["swift", "kotlin", "objectivec", "variable","xcode","editpc", "java", "mobile","hello", "docker"]
    @Published var currentWord = ""
    @Published var scrambledWord = ""
    @Published var score = 0
    @Published var remainingAttempts = 0
    @Published var gameOver = false

    init() {
        setRandomWord()
    }

    func setRandomWord() {
        currentWord = words.randomElement()!
        scrambledWord = String(currentWord.shuffled())
    }

    func checkGuess(_ guess: String) -> Bool {
        let isCorrect = guess.lowercased() == currentWord
        if isCorrect {
            score += 1
            setRandomWord()
        } else {
            remainingAttempts -= 1
            if remainingAttempts <= 0 {
                gameOver = true
            }
        }
        return isCorrect
    }

    func resetGame() {
        setRandomWord()
        score = 0
        remainingAttempts = 3
        gameOver = false
    }

    func setDifficulty(_ difficulty: String) {
        switch difficulty {
        case "Easy":
            remainingAttempts = 5
        case "Medium":
            remainingAttempts = 3
        case "Hard":
            remainingAttempts = 1
        default:
            remainingAttempts = 3
        }
    }
}
struct ContentView: View {
    @State private var game = WordScrambleGame()
    @State private var guess = ""
    @State private var guessResult = ""
    @State private var showResult = false
    @State private var difficulty = "Easy"

    var body: some View {
        let hour = Calendar.current.component(.hour, from: Date())
        let isDay = hour > 6 && hour < 18

        return ZStack {
            (isDay ? Color.white : Color.black)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                ProgressView(value: Double(game.score), total: 10)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color.green))
                    .padding()

                Picker("Difficulty", selection: $difficulty) {
                    Text("Easy").tag("Easy")
                    Text("Medium").tag("Medium")
                    Text("Hard").tag("Hard")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: difficulty) { newDifficulty in
                    game.setDifficulty(newDifficulty)
                }

                Text("Guess the word: \(game.scrambledWord)")
                    .font(.largeTitle)
                    .foregroundColor(isDay ? .black : .white)

                TextField("Enter your guess", text: $guess)
                    .font(.title)
                    .padding()
                    .foregroundColor(isDay ? .black : .white)
                Button(action: {
                    let isCorrect = game.checkGuess(guess)
                    if isCorrect {
                        guessResult = "Correct! The word was \(game.currentWord)."
                        game.setRandomWord()
                        guess = ""
                        showResult = true
                    } else {
                        guess = ""
                        guessResult = "Sorry, that's not correct."
                        showResult = true
                    }
                }) {
                    Text("Submit Guess")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    game.resetGame()
                    guess = ""
                    guessResult = ""
                    showResult = false
                }) {
                    Text("Reset Game")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                
                if showResult {
                    Text(guessResult)
                        .font(.title)
                        .padding()
                }
                Text("Score: \(game.score)")
                    .font(.title)
                    .padding()
            }
            .alert(isPresented: $game.gameOver) {
                Alert(
                    title: Text("Game Over"),
                    message: Text("You've run out of attempts. Your final score is \(game.score)."),
                    dismissButton: .default(Text("Start Over")) {
                        game.resetGame()
                        game.gameOver = false
                    }
                )
            }
        }
    }
}
