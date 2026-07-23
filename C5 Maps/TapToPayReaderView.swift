//
//  TapToPayReaderView.swift
//  C5 Maps
//
//  Created by Gibson Akwasi Opoku on 2026-07-09.
//

import SwiftUI

struct TapToPayReaderView: View {
    @Environment(\.dismiss) var dismiss
    @FocusState private var isAmountFocused: Bool
    @State private var isReady = true
    @State private var isProcessing = false
    @State private var showingSuccess = false
    @State private var lastPaymentAmount = ""
    @State private var lastPaymentTime = ""
    @State private var totalToday: Double = 0.0
    @State private var transactionCount: Int = 0
    @State private var paymentAmount = ""
    @State private var showTransactions = false
    
    // Sample transactions
    @State private var transactions: [Transaction] = [
        Transaction(amount: 24.50, time: "2:30 PM", status: .completed),
        Transaction(amount: 12.00, time: "1:15 PM", status: .completed),
        Transaction(amount: 8.75, time: "12:00 PM", status: .completed),
        Transaction(amount: 45.00, time: "11:30 AM", status: .completed),
        Transaction(amount: 18.50, time: "10:45 AM", status: .completed)
    ]
    
    struct Transaction: Identifiable {
        let id = UUID()
        let amount: Double
        let time: String
        let status: TransactionStatus
    }
    
    enum TransactionStatus {
        case completed
        case pending
        case failed
        
        var color: Color {
            switch self {
            case .completed: return .green
            case .pending: return .orange
            case .failed: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .completed: return "checkmark.circle.fill"
            case .pending: return "clock.fill"
            case .failed: return "xmark.circle.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background - Dark gradient like real reader
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.08),
                        Color(red: 0.1, green: 0.1, blue: 0.15),
                        Color(red: 0.05, green: 0.05, blue: 0.08)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .onTapGesture {
                    isAmountFocused = false
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text("Tap to Pay")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Circle()
                                .fill(isReady ? Color.green : Color.orange)
                                .frame(width: 10, height: 10)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        // Reader Device
                        VStack(spacing: 0) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.12, green: 0.12, blue: 0.18),
                                                Color(red: 0.08, green: 0.08, blue: 0.12)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(height: 400)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.1),
                                                        Color.clear,
                                                        Color.white.opacity(0.05)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                    .onTapGesture {
                                        isAmountFocused = false
                                    }
                                
                                // Reader Content - ALL CENTERED
                                VStack(spacing: 12) {
                                    // Status Header - Centered
                                    HStack {
                                        Spacer()
                                        
                                        Circle()
                                            .fill(isReady ? Color.green : Color.orange)
                                            .frame(width: 8, height: 8)
                                            .overlay(
                                                Circle()
                                                    .stroke(isReady ? Color.green : Color.orange, lineWidth: 1)
                                            )
                                        
                                        Text(isReady ? "READY TO ACCEPT PAYMENTS" : "PROCESSING...")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(isReady ? .green : .orange)
                                            .tracking(2)
                                        
                                        Spacer()
                                        
                                        if isProcessing {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                                .scaleEffect(0.7)
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.top, 16)
                                    
                                    // Amount Entry - FULLY CENTERED
                                    VStack(spacing: 4) {
                                        Text("ENTER AMOUNT")
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(.gray)
                                            .tracking(2)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                        
                                        HStack(alignment: .center, spacing: 2) {
                                            Spacer()
                                            
                                            Text("$")
                                                .font(.system(size: 42, weight: .bold))
                                                .foregroundColor(.white)
                                            
                                            TextField("0.00", text: $paymentAmount)
                                                .font(.system(size: 48, weight: .bold))
                                                .foregroundColor(.white)
                                                .keyboardType(.decimalPad)
                                                .multilineTextAlignment(.center)
                                                .frame(width: 160)
                                                .disabled(isProcessing)
                                                .focused($isAmountFocused)
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal, 8)
                                        
                                        if !paymentAmount.isEmpty && !isProcessing {
                                            Button(action: startPayment) {
                                                Text("Charge Customer")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(.white)
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 10)
                                                    .background(Color.blue)
                                                    .cornerRadius(10)
                                            }
                                            .padding(.horizontal, 40)
                                            .padding(.top, 4)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    
                                    // NFC / Tap Area - Centered
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.blue.opacity(0.15),
                                                        Color.purple.opacity(0.05)
                                                    ],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                Circle()
                                                    .stroke(
                                                        LinearGradient(
                                                            colors: [
                                                                Color.blue.opacity(0.3),
                                                                Color.purple.opacity(0.1)
                                                            ],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 2
                                                    )
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(
                                                        Color.white.opacity(0.05),
                                                        lineWidth: 1
                                                    )
                                                    .padding(4)
                                            )
                                        
                                        VStack(spacing: 6) {
                                            Image(systemName: isProcessing ? "arrow.triangle.2.circlepath" : "wave.3.right.circle.fill")
                                                .font(.system(size: 32))
                                                .foregroundColor(isProcessing ? .orange : .blue)
                                                .rotationEffect(.degrees(isProcessing ? 360 : 0))
                                                .animation(isProcessing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isProcessing)
                                            
                                            Text(isProcessing ? "Processing..." : "Tap or Hold")
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundColor(isProcessing ? .orange : .gray)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    
                                    Spacer(minLength: 8)
                                }
                            }
                            
                            // Reader Bottom - Card slot
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(height: 6)
                                    .cornerRadius(3)
                                
                                Spacer()
                                
                                Rectangle()
                                    .fill(Color.black.opacity(0.4))
                                    .frame(width: 60, height: 4)
                                    .cornerRadius(2)
                                
                                Spacer()
                                
                                Rectangle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(height: 6)
                                    .cornerRadius(3)
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 8)
                            .padding(.bottom, 12)
                        }
                        .padding(.horizontal, 20)
                        
                        // Instructions
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Accept payments")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 16) {
                                InstructionStep(number: "1", text: "Enter the payment amount")
                                InstructionStep(number: "2", text: "Customer holds card or phone near reader")
                                InstructionStep(number: "3", text: "Payment is processed automatically")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .onTapGesture {
                            isAmountFocused = false
                        }
                        
                        // Today's Total
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Today's Total")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                Text("$\(String(format: "%.2f", totalToday))")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Transactions")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                Text("\(transactionCount)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .onTapGesture {
                            isAmountFocused = false
                        }
                        
                        // Recent Transactions - HIDDEN by default
                        VStack(alignment: .leading, spacing: 8) {
                            Button(action: {
                                withAnimation(.spring()) {
                                    showTransactions.toggle()
                                    isAmountFocused = false
                                }
                            }) {
                                HStack {
                                    Text("Recent Transactions")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(transactions.count)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                    
                                    Image(systemName: showTransactions ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                            }
                            
                            if showTransactions {
                                ForEach(transactions) { transaction in
                                    HStack {
                                        Image(systemName: transaction.status.icon)
                                            .foregroundColor(transaction.status.color)
                                            .font(.system(size: 14))
                                        
                                        Text("$\(String(format: "%.2f", transaction.amount))")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Text(transaction.time)
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                        
                                        Text(transaction.status == .completed ? "Completed" : "Pending")
                                            .font(.system(size: 11))
                                            .foregroundColor(transaction.status.color)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(transaction.status.color.opacity(0.15))
                                            .cornerRadius(4)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.03))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Simulate Payment Button
                        Button(action: simulatePayment) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Learn More")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .disabled(isProcessing)
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.bottom, 20)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationBarHidden(true)
            .overlay(
                Group {
                    if showingSuccess {
                        PaymentReceivedOverlay(amount: lastPaymentAmount) {
                            withAnimation {
                                showingSuccess = false
                                isReady = true
                                isProcessing = false
                                paymentAmount = ""
                            }
                        }
                    }
                }
            )
        }
    }
    
    // MARK: - Functions
    private func startPayment() {
        guard let amount = Double(paymentAmount), amount > 0 else { return }
        guard !isProcessing else { return }
        
        isAmountFocused = false
        
        withAnimation {
            isReady = false
            isProcessing = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            let timeString = timeFormatter.string(from: Date())
            
            withAnimation {
                lastPaymentAmount = String(format: "%.2f", amount)
                lastPaymentTime = timeString
                totalToday += amount
                transactionCount += 1
                isProcessing = false
                
                let newTransaction = Transaction(
                    amount: amount,
                    time: timeString,
                    status: .completed
                )
                transactions.insert(newTransaction, at: 0)
                
                showingSuccess = true
            }
        }
    }
    
    private func simulatePayment() {
        guard !isProcessing else { return }
        
        isAmountFocused = false
        
        let amount = Double.random(in: 5.00...75.00)
        paymentAmount = String(format: "%.2f", amount)
        
        withAnimation {
            isReady = false
            isProcessing = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            let timeString = timeFormatter.string(from: Date())
            
            withAnimation {
                lastPaymentAmount = String(format: "%.2f", amount)
                lastPaymentTime = timeString
                totalToday += amount
                transactionCount += 1
                isProcessing = false
                
                let newTransaction = Transaction(
                    amount: amount,
                    time: timeString,
                    status: .completed
                )
                transactions.insert(newTransaction, at: 0)
                
                showingSuccess = true
            }
        }
    }
}

// MARK: - Instruction Step
struct InstructionStep: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 24, height: 24)
                .overlay(
                    Text(number)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.blue)
                )
            
            Text(text)
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Payment Received Overlay
struct PaymentReceivedOverlay: View {
    let amount: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                }
                
                Text("Payment Received!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("$\(amount)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Funds will appear in your account shortly")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Button(action: onDismiss) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
            )
            .padding(24)
        }
    }
}

// MARK: - Preview
#Preview {
    TapToPayReaderView()
}


