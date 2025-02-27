//
//  MenuPresentAnimator.swift
//  CustomMenuSideBar
//
//  Created by Yuth Fight on 26/9/24.
//

import UIKit


class MenuPresentAnimator: NSObject {
    
    let interactor: MenuTransitionInteractor
    private var propertyAnimator: UIViewPropertyAnimator?
    init(interactor: MenuTransitionInteractor, propertyAnimator: UIViewPropertyAnimator? = nil) {
        self.interactor = interactor
        self.propertyAnimator = propertyAnimator
    }

}

extension MenuPresentAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return MenuHelper.animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let propertyAnimator = propertyAnimator {
            return propertyAnimator
        }
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVc = transitionContext.viewController(forKey: .to) else { fatalError() }
        
        let containerView = transitionContext.containerView
        
        toVc.view.frame.size.width = containerView.frame.width * MenuHelper.menuWidth
        if interactor.menuPosition == .right {
            toVc.view.frame.origin.x = containerView.frame.width - toVc.view.frame.width
        }
        
        guard let fromSnapshot = fromVC.view.snapshotView(afterScreenUpdates: false) else { fatalError() }
        guard let snapshot = toVc.view.snapshotView(afterScreenUpdates: true) else { fatalError() }
        
        fromSnapshot.tag = MenuHelper.presentingSnapshotTag
        
        containerView.addSubview(fromSnapshot)
        
        let overlayView = createOverlayView(with: fromSnapshot.bounds)
        fromSnapshot.addSubview(overlayView)
        
        snapshot.tag = MenuHelper.menuSnapshotTag
        snapshot.frame.origin.x = interactor.menuPosition == .left ? -snapshot.frame.width : containerView.frame.width
        containerView.addSubview(snapshot)
        toVc.view.isHidden = true
        containerView.insertSubview(toVc.view, aboveSubview: snapshot)
        
        var tapViewFrame: CGRect
        if interactor.menuPosition == .left {
            tapViewFrame = CGRect(x: toVc.view.frame.maxX, y: toVc.view.frame.minY, width: toVc.view.frame.width, height: toVc.view.frame.height)
        } else {
            tapViewFrame = CGRect(x: toVc.view.frame.minX - toVc.view.frame.width, y: toVc.view.frame.minY, width: toVc.view.frame.width, height: toVc.view.frame.height)
        }
        
        interactor.addTapView(to: containerView, with: tapViewFrame)
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), timingParameters: UICubicTimingParameters(animationCurve: .linear))
        animator.addAnimations { [weak self] in
            snapshot.frame.origin.x = self?.interactor.menuPosition == .left ? 0 : containerView.frame.width - toVc.view.frame.width
            fromSnapshot.frame.origin.x = self?.interactor.menuPosition == .left ? snapshot.frame.width : -snapshot.frame.width
            overlayView.alpha = 1
        }
        animator.addCompletion { _ in
            toVc.view.isHidden = false
            if !transitionContext.transitionWasCancelled {
                snapshot.removeFromSuperview()
                NotificationCenter.default.post(name: MenuHelper.menuDidShowNotification, object: nil)
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        self.propertyAnimator = animator
        return animator
    }
    
    @MainActor private func createOverlayView(with frame: CGRect) -> UIView {
        let overlayView = UIView(frame: frame)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        overlayView.alpha = 0
        return overlayView
    }
    
}
