//
//  StripeWebView.swift
//  C5 Maps
//
//  Created by Gibson Akwasi Opoku on 2026-07-10.
//

import SwiftUI
import WebKit
import Combine 

struct StripeWebView: View {
    let url: URL
    @Environment(\.dismiss) var dismiss
    @StateObject private var webViewManager = StripeWebViewManager()
    @State private var webViewError = false
    @State private var isLoading = true
    
    var onComplete: ((String) -> Void)?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Header
                    HStack {
                        Button(action: {
                            webViewManager.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .padding(8)
                        }
                        
                        Spacer()
                        
                        Text("Connect Stripe")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Color.clear
                                .frame(width: 40)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 50)
                    .padding(.bottom, 12)
                    .background(Color.black)
                    
                    // WebView
                    if webViewError {
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                            
                            Text("Failed to Load")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Unable to load Stripe connection page. Please check your internet connection and try again.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 32)
                            
                            Button(action: {
                                webViewError = false
                                isLoading = true
                                webViewManager.reload()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Try Again")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.purple)
                                .cornerRadius(10)
                            }
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Go Back")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                    } else {
                        WebViewWrapper(
                            url: url,
                            onNavigationChange: { urlString in
                                webViewManager.handleNavigation(urlString: urlString)
                            },
                            onError: {
                                webViewError = true
                            },
                            onLoadStart: {
                                isLoading = true
                            },
                            onLoadEnd: {
                                isLoading = false
                            }
                        )
                        .ignoresSafeArea(edges: .bottom)
                    }
                }
            }
            .preferredColorScheme(.dark)
            .onReceive(webViewManager.$dismissWebView) { shouldDismiss in
                if shouldDismiss {
                    dismiss()
                }
            }
            .onReceive(webViewManager.$completionAccountId) { accountId in
                if let accountId = accountId {
                    onComplete?(accountId)
                }
            }
        }
    }
}

// MARK: - WebView Manager
class StripeWebViewManager: ObservableObject {
    @Published var dismissWebView = false
    @Published var completionAccountId: String?
    private var webView: WKWebView?
    
    func setWebView(_ webView: WKWebView) {
        self.webView = webView
    }
    
    func handleNavigation(urlString: String) {
        print("Navigation:", urlString)
        
        // Extract account ID from URL
        let urlComponents = URLComponents(string: urlString)
        let queryItems = urlComponents?.queryItems ?? []
        let accountId = queryItems.first(where: { $0.name == "account_id" || $0.name == "acct_id" })?.value
        
        // Check for onboarding completion
        if urlString.contains("onboarding=complete") {
            print("Onboarding completed!")
            if let accountId = accountId {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.completionAccountId = accountId
                }
            }
            return
        }
        
        // Check for success patterns
        let successPatterns = ["success", "return", "complete", "dashboard", "acct_"]
        let isSuccess = successPatterns.contains(where: { urlString.contains($0) }) && !urlString.contains("setup")
        
        if isSuccess {
            print("Success detected")
            let match = extractAccountId(from: urlString)
            if let accountId = match ?? accountId {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.completionAccountId = accountId
                }
            }
            return
        }
        
        // Check for cancellation
        let cancelPatterns = ["refresh", "cancel", "error", "declined"]
        let isCancel = cancelPatterns.contains(where: { urlString.contains($0) })
        
        if isCancel {
            print("Cancellation detected")
            DispatchQueue.main.async {
                self.dismissWebView = true
            }
        }
    }
    
    func dismiss() {
        dismissWebView = true
    }
    
    func reload() {
        webView?.reload()
    }
    
    private func extractAccountId(from url: String) -> String? {
        let pattern = "acct_[A-Za-z0-9]+"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)) {
            return String(url[Range(match.range, in: url)!])
        }
        return nil
    }
}

// MARK: - WebView Wrapper
struct WebViewWrapper: UIViewRepresentable {
    let url: URL
    let onNavigationChange: (String) -> Void
    let onError: () -> Void
    let onLoadStart: () -> Void
    let onLoadEnd: () -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.backgroundColor = .black
        webView.isOpaque = true
        
        if let url = URL(string: url.absoluteString) {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewWrapper
        
        init(_ parent: WebViewWrapper) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.onLoadStart()
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.onLoadEnd()
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.onError()
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.onError()
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                parent.onNavigationChange(url.absoluteString)
            }
            decisionHandler(.allow)
        }
    }
}
