import SwiftUI
import WebKit



struct WebView: UIViewControllerRepresentable {
    let url: URL
    @Binding var isNetworkAvailable: Bool
    func makeUIViewController(context: Context) -> WKWebViewController {
        let controller = WKWebViewController()
        controller.url = url
        return controller
    }
    
    
    func updateUIViewController(_ uiViewController: WKWebViewController, context: Context) {
    }
}

class WKWebViewController: UIViewController {
    var url: URL?
    private var webView: WKWebView!
    
    var netWorkStatusHandler: ((Bool) -> Void)?
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView(frame: view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        startNetworkMonitoring()
        view.addSubview(webView)
        
        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        webView.navigationDelegate = self
    }
    
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else {return}
            if path.status == .satisfied {
                self.netWorkStatusHandler?(true)
                                
                if let url = self.url {
                    DispatchQueue.main.async {
                        let request = URLRequest(url: url)
                        self.webView.load(request)
                        
                    }
                }
            } else {
                self.netWorkStatusHandler?(false)
            }
        }
        monitor.start(queue: queue)
        }
    deinit {
        monitor.cancel()
    }
}

extension WKWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let darkModeCSS = """
            @media (prefers-color-scheme: dark) {
                body {
                    background-color: #181A20 !important;
                    color: white !important;
                }
                a {
                    color: #bb86fc !important;
                }
            }
        """
        
        let js = """
            var style = document.createElement('style');
            style.innerHTML = `\(darkModeCSS)`;
            document.head.appendChild(style);
        """
        
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
}
