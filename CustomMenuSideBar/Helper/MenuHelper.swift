//
//  MenuHelper.swift
//  CustomMenuSideBar
//
//  Created by Yuth Fight on 26/9/24.
//
import UIKit

enum MenuPanDirection {
    case up
    case down
    case left
    case right
}

enum SideMenuPosition {
    case left
    case right
}

@MainActor
struct MenuHelper {
    
    //1.
    /// Width of the side menu related to the width of the center view controller's view. Values are in range 0.0 - 1.0, where 0.0 is zero width and 1.0 is the width equal to the width of the view. Default is 0.8.
    internal static var menuWidth: CGFloat = MenuConstant.menWidth
    
    /// Indicates the minimum translation of the pan gesture related to the center view controller's view width required for gesture to be completed. Default is 0.2 (20 percent of the width).
    internal static var percentThreshold: CGFloat = MenuConstant.percentThreshold
    
    /// The duration of transition animation in seconds. Default is 0.3.
    internal static var animationDuration: TimeInterval = MenuConstant.animationDuration
    
    static let presentingSnapshotTag    = 123456
    static let menuSnapshotTag          = 654321
    
    public static let menuDidShowNotification = Notification.Name("LMC_SIDE_MENU_DID_SHOW_NOTIFICATION")
    public static let menuDidHideNotification = NSNotification.Name("LMC_SIDE_MENU_DID_HIDE_NOTIFICATION")
    
    static func set(menuWidth: CGFloat) {
        MenuHelper.menuWidth = menuWidth
    }
    
    static func set(menu: CGFloat) {
        MenuHelper.percentThreshold = percentThreshold
    }
    
    static func set(animationDuration: TimeInterval) {
        MenuHelper.animationDuration = animationDuration
    }
    
    static func calculateProgress(translationInView: CGPoint, viewBounds: CGRect, direction: MenuPanDirection) -> CGFloat {
        let pointOnAxis: CGFloat
        let axisLength: CGFloat
        
        switch direction {
        case .up, .down:
            pointOnAxis = translationInView.y
            axisLength = viewBounds.height
        case .left, .right:
            pointOnAxis = translationInView.x
            axisLength = viewBounds.width
        }
        
        let movement = pointOnAxis / axisLength
        let positiveMovement: Float
        let positiveMovementPercent: Float
        
        switch direction {
        case .right, .down:
            positiveMovement = fmaxf(Float(movement), 0)
            positiveMovementPercent = fminf(positiveMovement, 1)
            return CGFloat(positiveMovementPercent)
        case .up, .left:
            positiveMovement = fminf(Float(movement), 0)
            positiveMovementPercent = fmaxf(positiveMovement, -1)
            return CGFloat(-positiveMovementPercent)
        }
    }
    
    //MARK: Gesture
    static func map(gestureState: UIGestureRecognizer.State, to interactor: MenuTransitionInteractor?, progress: CGFloat, direction: MenuPanDirection, triggerAction: () -> Void) {
        guard let interactor = interactor else { return }
        switch gestureState {
        case .began:
            interactor.hasStarted = true
            triggerAction()
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish ? interactor.finish() : interactor.cancel()
        default:
            break
        }
    }
    
}
