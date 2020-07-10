//
//  ContentView.swift
//  WKDemo
//
//  Created by cml2 on 2020/7/9.
//  Copyright © 2020 cml2. All rights reserved.
//

import SwiftUI
import WebKit

public class SUIWebBrowserObject: WKWebView, WKNavigationDelegate, ObservableObject {
    private var observers: [NSKeyValueObservation?] = []

    private func subscriber<Value>(for keyPath: KeyPath<SUIWebBrowserObject, Value>) -> NSKeyValueObservation {
        observe(keyPath, options: [.prior]) { object, change in
            if change.isPrior {
                self.objectWillChange.send()
            }
        }
    }

    private func setupObservers() {
        observers = [
            subscriber(for: \.title),
            subscriber(for: \.url),
            subscriber(for: \.isLoading),
            subscriber(for: \.estimatedProgress),
            subscriber(for: \.hasOnlySecureContent),
            subscriber(for: \.serverTrust),
            subscriber(for: \.canGoBack),
            subscriber(for: \.canGoForward)
        ]
    }

    public override init(frame: CGRect = .zero, configuration: WKWebViewConfiguration = WKWebViewConfiguration()) {
        super.init(frame: frame, configuration: configuration)
        navigationDelegate = self
        setupObservers()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        navigationDelegate = self
        setupObservers()
    }
}

public struct SUIWebBrowserView: UIViewRepresentable {
    public typealias UIViewType = UIView

    private var browserObject: SUIWebBrowserObject

    public init(browserObject: SUIWebBrowserObject) {
        self.browserObject = browserObject
    }

    public func makeUIView(context: Self.Context) -> Self.UIViewType {
        browserObject
    }

    public func updateUIView(_ uiView: Self.UIViewType, context: Self.Context) {
        //
    }
}

struct WebBrowser: View {
    @ObservedObject var browser = SUIWebBrowserObject()

    init(address: String) {
        guard let a = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let u = URL(string: a) else { return }
        browser.load(URLRequest(url: u))
    }

    var body: some View {
        SUIWebBrowserView(browserObject: browser)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
