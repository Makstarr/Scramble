//
//  ContentView.swift
//  scramble
//
//  Created by Максим on 10.02.2020.
//  Copyright © 2020 Максим. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var usedWords = [String]()
    @State var newWord = ""
    @State var taskWord = ""
    @State var score = 0
    @State var goal = 20
    @State var level = 1
    @State var swichWordScore = 5
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    var body: some View {
        NavigationView{
            VStack{
                HStack{
                    Text("Current goal is \(goal)")
                    .padding()
                    Text("Level \(level)")
                    .fontWeight(.bold)
                    .padding()
                }
                Text("Your score is \(score)")
                .padding()
                TextField("Введите слово", text:$newWord, onCommit: addWord)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                List(usedWords, id:\.self){
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                
                Button(action:{
                    self.score-=2
                    self.startGame()
                    
                }){Text("Skip word for 2 points")}
                .padding()
                .clipShape(RoundedRectangle(cornerRadius: 200))
                .overlay(RoundedRectangle(cornerRadius: 200).stroke(Color.black,lineWidth:2))
                .padding()
                    
                    
                .onAppear(perform: startGame)
                .navigationBarTitle(taskWord)
                .navigationBarItems(trailing:
                    Button(action:{
                        self.score=0
                        self.goal = 20
                        self.level = 1
                        self.swichWordScore = 5
                        self.startGame()
                        self.usedWords = [String]()
                                       
                                   }){Text("Restart game")})
            }
            .alert(isPresented: $showingError){
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
        
    }
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                taskWord = allWords.randomElement() ?? "Maximka"
                return
            }
        }
        else{fatalError("Не удалось открыть список слов")}
    }
    func addWord()
    {
        let word = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard word.count > 0 else{
            return
        }
        guard isOriginal(word: word) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isValid(word: word) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }

        guard isReal(word: word) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }
        usedWords.insert(word, at: 0)
        newWord = ""
        guard score < goal else{
            goal += 20
            level += 1
            startGame()
            wordError(title: "Amaizing!", message: "Keep pushing on!")
            return
        }
        guard score < swichWordScore  else{
            swichWordScore+=5
            startGame()
            return
        }
       
    }
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    func isValid(word: String) -> Bool{
        var typedWord = taskWord
        for letter in word{
            if let letterIndex = typedWord.firstIndex(of: letter){
                typedWord.remove(at: letterIndex)
            } else {return false}
        }
            return true
            
    }
    func isReal(word: String) -> Bool{
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = UITextChecker().rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        guard word != taskWord else {
            wordError(title: "Task word not count", message: "Be more original")
            return false
        }
        if word.count<=3 && misspelledRange.location == NSNotFound{
            score+=1
        }
        if word.count>3 && misspelledRange.location == NSNotFound{
            score+=word.count
        }
        return misspelledRange.location == NSNotFound
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
