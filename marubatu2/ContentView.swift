//
//  ContentView.swift
//  Marubatu
//
//  Created by 鴛海剛 on 2025/02/15.
//

import SwiftUI

// Quizの構造体
struct Quiz: Identifiable, Codable {
    var id = UUID()       // それぞれの設問を区別するID
    var question: String  // 問題文
    var answer: Bool      // 解答
}

struct ContentView: View {
    @AppStorage("quiz") var quizzesData = Data() // UserDefaultsから問題を読み込む
    @State var quizzesArray: [Quiz] = [] // 問題を入れておく配列
    @State var currentQuestionNum = 0 // 今、何問目の数字
    @State var showingAlert = false // アラートの表示・非表示を制御
    @State var alertTitle = "" // "正解" か "不正解" の文字を入れる

    init() {
        if let decodedQuizzes = try? JSONDecoder().decode([Quiz].self, from: quizzesData) {
            _quizzesArray = State(initialValue: decodedQuizzes)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack {
                    Text(showQuestion()) // 問題文を表示
                        .padding()
                        .frame(width: geometry.size.width * 0.85, alignment: .leading)
                        .font(.system(size: 25))
                        .fontDesign(.rounded)
                        .background(.yellow)

                    Spacer()

                    HStack {
                        // ◯ボタン
                        Button {
                            checkAnswer(yourAnswer: true)
                        } label: {
                            Text("◯")
                        }
                        .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                        .font(.system(size: 100, weight: .bold))
                        .background(.red)
                        .foregroundStyle(.white)

                        // Xボタン
                        Button {
                            checkAnswer(yourAnswer: false)
                        } label: {
                            Text("Ｘ")
                        }
                        .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                        .font(.system(size: 100, weight: .bold))
                        .background(.blue)
                        .foregroundStyle(.white)
                    }
                }
                .padding()
                .navigationTitle("マルバツクイズ")
                .alert(alertTitle, isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            CreateView(quizzesArray: $quizzesArray, resetCurrentQuestion: resetQuestion)
                                .navigationTitle("問題を作ろう")
                        } label: {
                            Image(systemName: "plus")
                                .font(.title)
                        }
                    }
                }
            }
        }
    }

    // 問題文を表示する関数
    func showQuestion() -> String {
        guard !quizzesArray.isEmpty, currentQuestionNum < quizzesArray.count else {
            return "問題がありません"
        }
        return quizzesArray[currentQuestionNum].question
    }

    // 回答をチェックする関数
    func checkAnswer(yourAnswer: Bool) {
        guard !quizzesArray.isEmpty else { return }

        let quiz = quizzesArray[currentQuestionNum]
        alertTitle = yourAnswer == quiz.answer ? "正解" : "不正解"

        if alertTitle == "正解" {
            currentQuestionNum = (currentQuestionNum + 1) % quizzesArray.count
        }

        showingAlert = true
    }

    // **問題リセット（CreateView から呼び出し）**
    func resetQuestion() {
        currentQuestionNum = 0
    }
}

#Preview {
    ContentView()
}
