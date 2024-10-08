import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController, UIWebViewDelegate,WKNavigationDelegate,WKUIDelegate {
    
    @IBOutlet weak var webviewPrivacypolicy: WKWebView!
    
    var webView: WKWebView!
    var refController:UIRefreshControl = UIRefreshControl()
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        self.webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        let url = URL(string: "https://www.privacypolicygenerator.info/")!
        webView.load(URLRequest(url: url))
    }
    
    @objc func backButtonTapped() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            
            navigationController?.popViewController(animated: true)
        }
    }
}
