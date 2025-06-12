//
//  UIDevice+.swift
//  ImageEditor
//
//  Created by BingBing on 2025/6/12.
//

import UIKit

extension UIDevice {
    var hasIPhoneXNotch: Bool {
        // Only phones have notch
        guard !isIPad else { return false }

        switch UIScreen.main.nativeBounds.height {
        case 960:
            //  iPad in iPhone compatibility mode (using old iPhone 4 screen size)
            return false
        case 1136:
            // iPhone 5 or 5S or 5C
            return false
        case 1334:
            // iPhone 6/6S/7/8
            return false
        case 1792:
            // iPhone XR
            return true
        case 1920, 2208:
            // iPhone 6+/6S+/7+/8+//
            return false
        case 2340:
            // iPhone 12 Mini
            return true
        case 2436:
            // iPhone X, iPhone XS
            return true
        case 2532:
            // iPhone 12 Pro
            return true
        case 2556:
            // iPhone 14 Pro
            // iPhone 16
            return true
        case 2622:
            // iPhone 16 Pro
            return true
        case 2688:
            // iPhone X Max
            return true
        case 2778:
            // iPhone 12 Pro Max
            return true
        case 2796:
            // iPhone 14 Pro Max
            // iPhone 16 Plus
            return true
        case 2868:
            // iPhone 16 Pro Max
            return true
        default:
            // Verify all our IOS_DEVICE_CONSTANT tags make sense when adding a new device size.
            debugPrint("unknown device format")
            return false
        }
    }
    
    var isPlusSizePhone: Bool {
        guard !isIPad else { return false }

        switch UIScreen.main.nativeBounds.height {
        case 960:
            //  iPad in iPhone compatibility mode (using old iPhone 4 screen size)
            return false
        case 1136:
            // iPhone 5 or 5S or 5C
            return false
        case 1334:
            // iPhone 6/6S/7/8
            return false
        case 1792:
            // iPhone XR
            return true
        case 1920, 2208:
            // iPhone 6+/6S+/7+/8+//
            return true
        case 2340:
            // iPhone 12 Mini
            return false
        case 2436:
            // iPhone X, iPhone XS
            return false
        case 2532:
            // iPhone 12 Pro
            return false
        case 2556:
            // iPhone 14 Pro
            // iPhone 16
            return false
        case 2622:
            // iPhone 16 Pro
            return false
        case 2688:
            // iPhone X Max
            return true
        case 2778:
            // iPhone 12 Pro Max
            return true
        case 2796:
            // iPhone 14 Pro Max
            // iPhone 16 Plus
            return true
        case 2868:
            // iPhone 16 Pro Max
            return true
        default:
            // Verify all our IOS_DEVICE_CONSTANT tags make sense when adding a new device size.
            debugPrint("unknown device format")
            return false
        }
    }

    var isNarrowerThanIPhone6: Bool {
        return UIScreen.main.bounds.width < 375
    }

    var isIPhone5OrShorter: Bool {
        return UIScreen.main.bounds.height <= 568
    }

    var isShorterThaniPhoneX: Bool {
        return UIScreen.main.bounds.height < 812
    }

    @objc
    var isIPad: Bool {
        return userInterfaceIdiom == .pad
    }

    var isFullScreen: Bool {
        true
    }

    @objc
    var defaultSupportedOrientations: UIInterfaceOrientationMask {
        return isIPad ? .all : .allButUpsideDown
    }
}
