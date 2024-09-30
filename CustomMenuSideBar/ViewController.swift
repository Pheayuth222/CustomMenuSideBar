//
//  ViewController.swift
//  CustomMenuSideBar
//
//  Created by Yuth Fight on 26/9/24.
//

import SwiftUI
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
    }


}

class LeftVieController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}


//MARK: - Preview Screen

struct ViewController_Preview: PreviewProvider {
    static var previews: some View {
        PreviewContainer {
            ViewController()
        }
    }
}

// Preview : UIViewController
struct PreviewContainer<T: UIViewController>: UIViewControllerRepresentable {
    
    let viewControllerBuider : T
    
    init(_ viewControllerBuilder: @escaping () -> T) {
        
        self.viewControllerBuider = viewControllerBuilder()
    }
    
    // MARK: - UIViewControllerRepresentable
    func makeUIViewController(context: Context) -> T {
        return viewControllerBuider
    }
    
    func updateUIViewController(_ uiViewController: T, context: Context) {
        
    }
    
}
