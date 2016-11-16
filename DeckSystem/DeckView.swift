//
//  DeckView.swift
//  DeckSystem
//
//  Created by Abhinash Khanal on 11/16/16.
//  Copyright © 2016 Moonlighting. All rights reserved.
//

import UIKit

class DeckView: UIView {

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var midView: UIView!
    @IBOutlet weak var topView: UIView!

    let midScale = CGFloat(0.9)
    let bottomScale = CGFloat(0.8)
    let midTranslation = CGFloat(30.0)
    let bottomTranslation = CGFloat(60.0)
    let deltaScale = CGFloat(0.1)

    var lastTranslation = CGFloat(0)
    let margin = CGFloat(0.50)

    func bind(to frame: CGRect) {
        self.frame = frame

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        self.addGestureRecognizer(panGesture)
        print("DECK WIDTH: \(frame.width)")

        topView.frame = CGRect(x: 0, y: 0, width: frame.width, height: 199)
        bottomView.frame = CGRect(x: 0, y: 0, width: frame.width, height: 199)
        midView.frame = CGRect(x: 0, y: 0, width: frame.width, height: 199)

        restoreStack(with: 0.5)


    }

    func restoreStack(with duration: Double = 0.0) {
        UIView.animate(withDuration: duration, animations: {

            var midTransform = CATransform3DMakeScale(self.midScale, self.midScale, 1.0)
            midTransform = CATransform3DTranslate(midTransform, 0,
                                                  self.midTranslation,
                                                  0)
            var bottomTransform = CATransform3DMakeScale(self.bottomScale, self.bottomScale, 1.0)
            bottomTransform = CATransform3DTranslate(bottomTransform, 0,
                                                     self.bottomTranslation,
                                                     0)
            self.topView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 199)
            self.midView.layer.transform = midTransform
            self.bottomView.layer.transform = bottomTransform
        })

    }

    func resetStack() {
        var midTransform = CATransform3DMakeScale(self.midScale, self.midScale, 1.0)
        midTransform = CATransform3DTranslate(midTransform, 0,
                                              self.midTranslation,
                                              0)
        var bottomTransform = CATransform3DMakeScale(self.bottomScale, self.bottomScale, 1.0)
        bottomTransform = CATransform3DTranslate(bottomTransform, 0,
                                                 self.bottomTranslation,
                                                 0)
        self.topView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 199)
        self.midView.layer.transform = midTransform
        self.bottomView.layer.transform = bottomTransform

    }

    func onPan(_ panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .changed:
            let dx = panGesture.translation(in: self).x
            let dTranslation = CGFloat(dx) - lastTranslation
            let newX = topView.frame.origin.x + dTranslation
            lastTranslation = CGFloat(dx)
            print("dx: \(dx)")

            topViewMoved(to: newX)

        default:
            lastTranslation = 0.0

            print("ViewX: \(topView.frame.origin), DeckX: \(self.frame.width * margin)")

            if (topView.frame.origin.x < 0 && topView.frame.origin.x >= -(self.frame.width * margin)) ||
                (topView.frame.origin.x >= 0 && topView.frame.origin.x <= (self.frame.width * margin)) {
                restoreStack()
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    if self.topView.frame.origin.x >= 0 {
                        self.topViewMoved(to: self.frame.width)
                    } else {
                        self.topViewMoved(to: -self.frame.width)
                    }

                }, completion: {complete in
                    if complete {
                        self.handleRecycle()

                    }
                })
            }
        }
    }

    func handleRecycle() {

        let bg = topView.backgroundColor
        topView.backgroundColor = midView.backgroundColor
        midView.backgroundColor = bottomView.backgroundColor
        bottomView.backgroundColor = bg
        self.resetStack()
    }

    func topViewMoved(to x: CGFloat) {
        topView.frame = CGRect(x: x,
                               y: 0,
                               width: topView.frame.width,
                               height: topView.frame.height)

        let multiplier = abs(topView.frame.origin.x / frame.width)
        print("Multi: \(multiplier)")

        var midTransform = CATransform3DMakeScale(midScale + (multiplier * (1 - midScale)),
                                                  midScale + (multiplier * (1 - midScale)),
                                                  1)
        midTransform = CATransform3DTranslate(midTransform,
                                              0,
                                              midTranslation - multiplier * (midTranslation),
                                              0)
        midView.layer.transform = midTransform

        var bottomTransform = CATransform3DMakeScale(bottomScale + (multiplier * (1 - midScale)),
                                                     bottomScale + (multiplier * (1 - midScale)),
                                                     1)
        bottomTransform = CATransform3DTranslate(bottomTransform,
                                                 0,
                                                 bottomTranslation - multiplier * (midTranslation),
                                                 0)
        midView.layer.transform = midTransform
        bottomView.layer.transform = bottomTransform

    }

}

protocol DeckViewDataSource {

    func numberOfSlidesIn(_ deckView: DeckView) -> Int
    func slideFor(_ deckView: DeckView, at: Int) -> UIView

}

protocol DeckViewDelegate {
    
    func slideWillSwipeLeftIn(_ deckview: DeckView, at: Int) -> Bool
    func slideWillSwipeRightIn(_ deckView: DeckView, at: Int) -> Bool
    func slideSwipeWillCancelIn(_ deckView: DeckView, at: Int)
}

