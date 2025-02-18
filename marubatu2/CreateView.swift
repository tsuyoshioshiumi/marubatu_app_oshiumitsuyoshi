import SwiftUI

struct CreateView: View {
    @Binding var quizzesArray: [Quiz]
    @AppStorage("quiz") private var quizData: Data = Data() // キーを統一
    var resetCurrentQuestion: () -> Void // ContentViewの currentQuestionNum をリセット

    @State private var questionText = ""
    @State private var selectedAnswer = "◯"
    let answers = ["◯", "×"]

    var body: some View {
        VStack {
            Text("問題文と解答を入力して、追加ボタンを押して下さい.")
                .foregroundStyle(.gray)
                .padding()

            TextField("問題文を入力して下さい", text: $questionText)
                .padding()
                .textFieldStyle(.roundedBorder)

            Picker("解答", selection: $selectedAnswer) {
                ForEach(answers, id: \.self) { answer in
                    Text(answer)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 300)
            .padding()

            Button {
                addQuiz(question: questionText, answer: selectedAnswer)
            } label: {
                Text("追加")
            }
            .padding()

            Button {
                deleteAllQuizzes()
            } label: {
                Text("全削除").foregroundColor(.red)
            }
            .padding()

            List {
                ForEach(quizzesArray) { quiz in
                    HStack {
                        Text("問題: \(quiz.question)")
                        Spacer()
                        Text("解答: \(quiz.answer ? "◯" : "×")")
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: deleteQuiz)
                .onMove(perform: moveQuiz)
            }
            .toolbar { // **Editボタンを追加**
                EditButton()
            }
        }
    }

    // クイズを追加する関数
    func addQuiz(question: String, answer: String) {
        guard !question.isEmpty, let savingAnswer = convertAnswerToBool(answer) else {
            print("適切な問題文または解答が入力されていません")
            return
        }

        var tempArray = quizzesArray
        tempArray.append(Quiz(question: question, answer: savingAnswer))

        if saveQuizzes(tempArray) {
            quizzesArray = tempArray
            resetCurrentQuestion() // 問題をリセット
            questionText = ""
        } else {
            print("データの保存に失敗しました")
        }
    }

    // クイズを削除する関数
    func deleteQuiz(at offsets: IndexSet) {
        var tempArray = quizzesArray
        tempArray.remove(atOffsets: offsets)

        if saveQuizzes(tempArray) {
            quizzesArray = tempArray
            resetCurrentQuestion() // 削除後に currentQuestionNum をリセット
        } else {
            print("データの保存に失敗しました")
        }
    }

    // クイズの並び替え
    func moveQuiz(from source: IndexSet, to destination: Int) {
        var tempArray = quizzesArray
        tempArray.move(fromOffsets: source, toOffset: destination)

        if saveQuizzes(tempArray) {
            quizzesArray = tempArray
            resetCurrentQuestion() // 並び替え後にリセット
        } else {
            print("データの保存に失敗しました")
        }
    }

    // クイズ全削除
    func deleteAllQuizzes() {
        quizzesArray.removeAll()
        quizData = Data() // キーを統一してデータ削除
        resetCurrentQuestion() // 全削除後にリセット
    }

    // ◯か×を true/false に変換する関数
    func convertAnswerToBool(_ answer: String) -> Bool? {
        return answer == "◯" ? true : answer == "×" ? false : nil
    }

    // クイズデータの保存処理
    @discardableResult
    func saveQuizzes(_ quizzes: [Quiz]) -> Bool {
        if let encoded = try? JSONEncoder().encode(quizzes) {
            quizData = encoded // @AppStorage に保存
            return true
        }
        return false
    }
}
