import SwiftUI

struct AIAssistantView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var userQuestion = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(role: "assistant", content: "Hi! I'm your C5 Maps AI assistant. I can help you with:\n\n• Keyword suggestions for your business\n• Bid amount recommendations\n• Budget optimization strategies\n• Apple Maps ad best practices\n\nWhat would you like to know?")
    ]
    @State private var isThinking = false
    @State private var scrollProxy: ScrollViewProxy?
    @State private var showingUpgrade = false
    @FocusState private var isInputFocused: Bool
    
    private let apiURL = "https://c5-dev.com/api/map"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                // MARK: - Subscription Check
                if !authManager.hasSubscription {
                    // Upgrade Required View
                    VStack(spacing: 24) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        
                        Text("Upgrade Required")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("AI Assistant is a premium feature. Upgrade your plan to get AI-powered help for your business.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 32)
                        
                        Button(action: {
                            showingUpgrade = true
                        }) {
                            HStack {
                                Image(systemName: "crown.fill")
                                Text("Upgrade Plan")
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .padding(.horizontal, 32)
                        }
                        .sheet(isPresented: $showingUpgrade) {
                            UpgradePlanView(onComplete: {
                                showingUpgrade = false
                                authManager.setSubscriptionActive(true)
                            })
                            .environmentObject(authManager)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 20)
                    
                } else {
                    // MARK: - Full Content (Active Subscription)
                    VStack(spacing: 0) {
                        // Header with Navigation Bar
                        VStack(spacing: 8) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.blue)
                            
                            Text("AI Assistant")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Powered by DeepSeek AI")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 16)
                        
                        // Messages Area
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 12) {
                                    ForEach(messages) { message in
                                        MessageBubble(message: message)
                                            .id(message.id)
                                    }
                                    
                                    if isThinking {
                                        HStack {
                                            TypingIndicator()
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                        .id("typing")
                                    }
                                }
                                .padding()
                            }
                            .scrollIndicators(.hidden)
                            .onAppear {
                                scrollProxy = proxy
                            }
                            .onChange(of: messages.count) { _ in
                                scrollToBottom()
                            }
                            .onChange(of: isThinking) { _ in
                                scrollToBottom()
                            }
                            .onTapGesture {
                                isInputFocused = false
                            }
                        }
                        
                        // Input Area
                        VStack(spacing: 0) {
                            Divider()
                            
                            HStack(spacing: 12) {
                                TextField("Ask about keywords, bids, or ads...", text: $userQuestion)
                                    .textFieldStyle(.plain)
                                    .padding(12)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(20)
                                    .focused($isInputFocused)
                                    .disabled(isThinking)
                                
                                Button(action: sendMessage) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(userQuestion.isEmpty || isThinking ? .secondary : .blue)
                                }
                                .disabled(userQuestion.isEmpty || isThinking)
                            }
                            .padding()
                        }
                        .background(Color(.systemBackground))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private func scrollToBottom() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                if let lastMessage = messages.last {
                    scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
                } else if isThinking {
                    scrollProxy?.scrollTo("typing", anchor: .bottom)
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !userQuestion.isEmpty else { return }
        
        let question = userQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
        messages.append(ChatMessage(role: "user", content: question))
        userQuestion = ""
        isInputFocused = false
        isThinking = true
        
        callAPI(question: question)
    }
    
    private func callAPI(question: String) {
        guard let url = URL(string: apiURL) else {
            fallbackResponse(question: question)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["question": question]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isThinking = false
                
                if let error = error {
                    print("API Error: \(error.localizedDescription)")
                    fallbackResponse(question: question)
                    return
                }
                
                guard let data = data else {
                    fallbackResponse(question: question)
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let answer = json["answer"] as? String {
                        messages.append(ChatMessage(role: "assistant", content: answer))
                    } else {
                        fallbackResponse(question: question)
                    }
                } catch {
                    print("Parse Error: \(error)")
                    fallbackResponse(question: question)
                }
            }
        }.resume()
    }
    
    private func fallbackResponse(question: String) {
        let lowerQuestion = question.lowercased()
        
        if lowerQuestion.contains("keyword") {
            messages.append(ChatMessage(role: "assistant", content: "Try '[service] near me' ($0.60), 'best [service] in [city]' ($0.75). Start with 5-10 keywords. Need bid amounts?"))
        } else if lowerQuestion.contains("bid") {
            messages.append(ChatMessage(role: "assistant", content: "Start bids at $0.40-$0.80 for low competition, $0.80-$1.50 for high. Increase 20% if no taps after 3 days."))
        } else if lowerQuestion.contains("budget") {
            messages.append(ChatMessage(role: "assistant", content: "Start with $10-20/day. Increase by 20% if profitable. What's your monthly ad budget?"))
        } else {
            messages.append(ChatMessage(role: "assistant", content: "Run a Maps ad campaign targeting 'near me' keywords. Start with $10/day. Want keyword suggestions for your business type?"))
        }
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let role: String
    let content: String
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.role == "assistant" {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundColor(.blue)
                    )
                
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color(.systemGray4).opacity(0.3), radius: 2, x: 0, y: 1)
                
                Spacer()
            } else {
                Spacer()
                
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                
                Circle()
                    .fill(Color.blue)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                    )
            }
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animationOffset = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 8, height: 8)
                    .offset(y: animationOffset == index ? -4 : 0)
                    .animation(
                        Animation.easeInOut(duration: 0.4)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animationOffset
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 2, x: 0, y: 1)
        .onAppear {
            animationOffset = 2
        }
    }
}

#Preview {
    AIAssistantView()
        .environmentObject(AuthManager())
}
