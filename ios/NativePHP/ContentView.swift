import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    static let dataStore = WKWebsiteDataStore.nonPersistent()

    let webView: WKWebView

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let logger = ConsoleLogger()

        let parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            // Intercept normal http/https links and open them in system default browser
            if url.scheme == "http" || url.scheme == "https" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }

        @objc func handleSwipeLeft(_ gesture: UISwipeGestureRecognizer) {
            if let webView = gesture.view as? WKWebView, webView.canGoForward {
                webView.goForward()
            }
        }

        @objc func handleSwipeRight(_ gesture: UISwipeGestureRecognizer) {
            if let webView = gesture.view as? WKWebView, webView.canGoBack {
                webView.goBack()
            }
        }
    }

    init() {
        // Initialize the custom scheme handler
        let schemeHandler = PHPSchemeHandler()

        // Configure WKWebView with the custom scheme handler
        let webConfiguration = WKWebViewConfiguration()

        webConfiguration.websiteDataStore = WebView.dataStore
        webConfiguration.setURLSchemeHandler(schemeHandler, forURLScheme: "php")

        webView = WKWebView(frame: .zero, configuration: webConfiguration)

    }

    func makeUIView(context: Context) -> WKWebView {
        #if DEBUG
        let userContentController = webView.configuration.userContentController
        let consoleLoggingScript = """
        (function() {
            function capture(type) {
                var old = console[type];
                console[type] = function() {
                    var message = Array.prototype.slice.call(arguments).join(" ");
                    window.webkit.messageHandlers.console.postMessage({ type: type, message: message });
                    old.apply(console, arguments);
                };
            }
            ['log', 'warn', 'error', 'debug'].forEach(capture);
        })();
        """

        let userScript = WKUserScript(source: consoleLoggingScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(userScript)
        userContentController.add(context.coordinator.logger, name: "console")

        webView.isInspectable = true
        #endif

        webView.navigationDelegate = context.coordinator

        webView.scrollView.bounces = false

        let fallbackPath = Bundle.main.path(forResource: "index", ofType: "html")
        let fallbackURL = URL(fileURLWithPath: fallbackPath!)

        // Load initial URL
        let startPage = URL(string: "php://127.0.0.1/")
        webView.load(URLRequest(url: startPage ?? fallbackURL))

        let swipeLeft = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSwipeLeft(_:)))
        swipeLeft.direction = .left
        webView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSwipeRight(_:)))
        swipeRight.direction = .right
        webView.addGestureRecognizer(swipeRight)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Handle updates if needed
    }

    func load(url: URL) {
        webView.load(URLRequest(url: url))
    }
}

struct ContentView: View {
    @State private var phpOutput = ""

    var body: some View {
        WebView()
            .edgesIgnoringSafeArea(.all)
    }
}

class ConsoleLogger: NSObject, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let body = message.body as? [String: Any],
           let type = body["type"] as? String,
           let logMessage = body["message"] as? String {
            print()
            print("JS \(type): \(logMessage)")
        }
    }
}
