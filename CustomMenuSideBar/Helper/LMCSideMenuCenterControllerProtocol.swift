//
//  LMCSideMenuCenterControllerProtocol.swift
//  CustomMenuSideBar
//
//  Created by Yuth Fight on 26/9/24.
//

import UIKit

public protocol LMCSideMenuCenterControllerProtocol where Self: UIViewController {
    
    // MenuTransitionInteractor object that manages all transitions of menu controllers.
    var interactor: MenuTransitionInteractor { get set }
    
    /// Sets up Side menu with provided leftMenu and rightMenu
    ///
    /// - Parameters:
    ///   - leftMenu: The View Controller to be used as a left menu. Pass nil to disable left menu
    ///   - rightMenu: The View Controller to be used as a right menu. Pass nil to disable right menu
    func setupMenu(lefMenu: UIViewController?, rightMenu: UIViewController?)
    
    /// Presents left menu. Call this method when you need to present left menu programmatically, for example, on menu button tap.
    func presentLeftMenu()
    
    /// Presents right menu. Call this method when you need to present right menu programmatically, for example, on menu button tap.
    func presentRightMenu()
    
    /**
     Enables right screen edge gesture for presenting right menu.
     
     You may provide custom implementation to this method to override default UIScreenEdgePanGestureRecognizer setup.
     */
    func enableLeftMenuGesture()
    
    /**
     Enables right screen edge gesture for presenting right menu.
     
     You may provide custom implementation to this method to override default UIScreenEdgePanGestureRecognizer setup.
     */
    func enableRightMenuGesture()
    
}

public extension LMCSideMenuCenterControllerProtocol {
    
    func setupMenu(leftMenu: UIViewController?, rightMenu: UIViewController?) {
        interactor.leftMenuController = leftMenu
        interactor.rightMenuController = rightMenu
        interactor.centerController = self
        
        leftMenu?.transitioningDelegate = interactor
        rightMenu?.transitioningDelegate = interactor
    }
    
//    func enableLeftMenuGesture() {
//        interactor.enable
//    }
    
}
