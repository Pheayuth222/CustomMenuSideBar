//
//  MenuTransitionInteractor.swift
//  CustomMenuSideBar
//
//  Created by Yuth Fight on 26/9/24.
//

import UIKit

public class MenuTransitionInteractor: UIPercentDrivenInteractiveTransition {
    
    var hasStarted = false
    var shouldFinish = false
    
    var leftMenuController: UIViewController?
    var rightMenuController: UIViewController?
    
    var centerController: (UIViewController & LMCSideMenuCenterControllerProtocol)?
    
    var menuPosition: SideMenuPosition = .left
    
    private weak var tapView: UIView?
    
    public override init() {
        super.init()
    }
    
    func addTapView(to containerView: UIView, with frame: CGRect) {
        let tapView = UIView(frame: frame)
        containerView.addSubview(tapView)
        let tapGestureRecignizer = UIGestureRecognizer(target: self, action: #selector(handleTap))
        tapView.addGestureRecognizer(tapGestureRecignizer)
        let panGestureRcognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPan(_ :)))
        tapView.addGestureRecognizer(panGestureRcognizer)
        
        self.tapView = tapView
    }
    
    @objc private func handleTap() {
        if menuPosition == .left {
            leftMenuController?.dismiss(animated: true)
        } else {
            rightMenuController?.dismiss(animated: true)
        }
    }
    
    @objc func handleDismissPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: tapView)
        
        let direction: MenuPanDirection = menuPosition == .left ? .left : .right
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: tapView?.bounds ?? .zero, direction: direction)
        
        MenuHelper.map(gestureState: sender.state, to: self, progress: progress, direction: direction) { [weak self] in
            if self?.menuPosition == .left {
                self?.leftMenuController?.dismiss(animated: true)
            } else {
                self?.rightMenuController?.dismiss(animated: true)
            }
        }
        
    }
    
    internal func enableLeftMenuGesture(on view: UIView) {
        let leftEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleLeftEdgePan(_:)))
        leftEdgePanGestureRecognizer.edges = .left
        view.addGestureRecognizer(leftEdgePanGestureRecognizer)
    }
    
    internal func enableRightMenuGesture(on view: UIView) {
        let rightEdgepanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleRightEdgePan(_:)))
        rightEdgepanGestureRecognizer.edges = .right
        view.addGestureRecognizer(rightEdgepanGestureRecognizer)
    }
    
    @objc func handleLeftEdgePan(_ sender: UIScreenEdgePanGestureRecognizer) {
        handlePresentPan(direction: .right, sender: sender)
    }
    
    @objc func handleRightEdgePan(_ sender: UIScreenEdgePanGestureRecognizer) {
       handlePresentPan(direction: .left, sender: sender)
    }
    
    private func handlePresentPan(direction: MenuPanDirection, sender: UIScreenEdgePanGestureRecognizer) {
        guard let view  = sender.view else { return }
        let translation = sender.translation(in: view)
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: direction)
        MenuHelper.map(gestureState: sender.state, to: self, progress: progress, direction: direction) { [weak self] in
            direction == .left ? self?.centerController?.presentRightMenu() : self?.centerController?.presentLeftMenu()
            
        }
    }
    
}

extension MenuTransitionInteractor: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MenuPresentAnimator(interactor: self)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MenuDismissAnimator(interactor: self)
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.hasStarted ? self : nil
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.hasStarted ? self : nil
    }
    
}
