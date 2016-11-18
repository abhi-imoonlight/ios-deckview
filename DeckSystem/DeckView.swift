//
//  DeckView.swift
//  DeckSystem
//
//  Created by Abhinash Khanal on 11/16/16.
//  Copyright © 2016 Moonlighting. All rights reserved.
//

import UIKit

class DeckView: UIView {

    private var _numberOfVisibleSlides = 3
    private var _scaleFactor: CGFloat = 0.95
    private var _translationDelta: CGFloat = 10.0

    var numberOfVisibleSlides: Int = 3 {
        willSet(newNumberOfSlides) {
            _numberOfVisibleSlides = newNumberOfSlides <= 5 ? newNumberOfSlides : 5
            _numberOfVisibleSlides = _numberOfVisibleSlides <= 1 ? 2 : _numberOfVisibleSlides
        }
    }

    var swipeThreshold = CGFloat(0.5)

    var lastTranslation: CGFloat = 0
    var bounceThreshold: CGFloat = 0

    var viewHolders: [UIView] = [UIView]()
    var views: [UIView] = [UIView]()

    var dataSource: DeckViewDataSource?
    var delegate: DeckViewDelegate?

    var data = [UIColor.red, UIColor.blue, UIColor.yellow, UIColor.green]
    
//    var data = [UIColor.red, UIColor.blue]


    func bind(to frame: CGRect) {
        self.frame = frame
        dataSource = self
        var upperBound = dataSource?.numberOfSlidesIn(self) ?? 0

        for var index in 0..<upperBound {
            if index >= _numberOfVisibleSlides {
                break
            }
            let viewHolder = UIView(frame: CGRect(x: 0, y: 0,
                                                  width: frame.width,
                                                  height: frame.height - 50))
            guard let view = dataSource?.slideFor(self, at: index) else {
                continue
            }

            viewHolders.append(viewHolder)
            views.append(view)
            viewHolder.addSubview(view)
            viewHolder.layer.masksToBounds = false
            viewHolder.layer.cornerRadius = 5.0
            viewHolder.clipsToBounds = true

        }

        upperBound = viewHolders.count

        for var index in 0..<upperBound {
            addSubview(viewHolders[upperBound - 1 - index])
        }


        restoreStack(with: 0.5)



        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        self.addGestureRecognizer(panGesture)
//
//        restoreStack(with: 0.5)

    }

    func revertStack() {
        if let viewHolder = viewHolders.first {
            UIView.animate(withDuration: 0.2, animations: {
                viewHolder.frame = CGRect(x: 0, y: 0,
                                          width: viewHolder.frame.width,
                                          height: viewHolder.frame.height)
            })
        }
    }

    func onPan(_ panGesture: UIPanGestureRecognizer) {

        switch panGesture.state {
        case .began:
            lastTranslation = 0
        case .changed:
            let tX = panGesture.translation(in: self).x
            let dX = tX - lastTranslation
            if let viewHolder = viewHolders.first {
                moveTopSlide(by: dX)
            }
            lastTranslation = tX
        default:
            if let viewHolder = viewHolders.first {
                let xPosition = viewHolder.frame.origin.x
                print("VH X: \(xPosition), VAL: \(swipeThreshold * viewHolder.frame.width)")
                if (xPosition >= 0 && xPosition < swipeThreshold * viewHolder.frame.width) ||
                    (xPosition < 0 && xPosition > -(swipeThreshold * viewHolder.frame.width)) {
                    revertStack()
                } else {
                    handleRecycle()
                }}
        }
    }

    func moveTopSlide(by x: CGFloat) {
        if let topViewHolder = viewHolders.first {
            topViewHolder.frame = CGRect(x: topViewHolder.frame.origin.x + x,
                                         y: topViewHolder.frame.origin.y,
                                         width: topViewHolder.frame.width,
                                         height: topViewHolder.frame.height)

            let multiplier = x / frame.width
            var scaleFactor: CGFloat = 1
            var translationDelta: CGFloat = 0
            for viewHolder in viewHolders {
//                var transform = viewHolder.layer.transform
                var transform = CATransform3DMakeScale(1 + multiplier * scaleFactor,
                                               1 + multiplier * scaleFactor,
                                               1)
                transform = CATransform3DTranslate(transform, 0,
                                                   viewHolder.frame.origin.x +
                                                    (multiplier * translationDelta),
                                                   0)
                viewHolder.layer.transform = transform
                scaleFactor = scaleFactor * ( 1 / _scaleFactor)
                translationDelta = translationDelta + self._translationDelta
            }
        }
    }

    func handleRecycle() {

    }

    func restoreStack(with duration: Double) {
        UIView.animate(withDuration: duration) {
            var scaleFactor: CGFloat = 1.0
            var translateFactor: CGFloat = 0.0
            for var viewHolder in self.viewHolders {
                var transform = viewHolder.layer.transform
                transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1)
                transform = CATransform3DTranslate(transform, 0, translateFactor, 0)

                viewHolder.layer.transform = transform
                scaleFactor *= self._scaleFactor
                translateFactor += self._translationDelta
            }
        }
    }

    func deQueueSlideFor(_ deckView: DeckView, at position: Int) -> UIView {
        return views.last ?? UIView()
    }

//    func restoreStack(with duration: Double = 0.0) {
//        UIView.animate(withDuration: duration, animations: {
//
//            var midTransform = CATransform3DMakeScale(self.midScale, self.midScale, 1.0)
//            midTransform = CATransform3DTranslate(midTransform, 0,
//                                                  self.midTranslation,
//                                                  0)
//            var bottomTransform = CATransform3DMakeScale(self.bottomScale, self.bottomScale, 1.0)
//            bottomTransform = CATransform3DTranslate(bottomTransform, 0,
//                                                     self.bottomTranslation,
//                                                     0)
//            self.topView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 199)
//            self.midView.layer.transform = midTransform
//            self.bottomView.layer.transform = bottomTransform
//        })
//
//    }
//
//    func resetStack() {
//        var midTransform = CATransform3DMakeScale(self.midScale, self.midScale, 1.0)
//        midTransform = CATransform3DTranslate(midTransform, 0,
//                                              self.midTranslation,
//                                              0)
//        var bottomTransform = CATransform3DMakeScale(self.bottomScale, self.bottomScale, 1.0)
//        bottomTransform = CATransform3DTranslate(bottomTransform, 0,
//                                                 self.bottomTranslation,
//                                                 0)
//        self.topView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 199)
//        self.midView.layer.transform = midTransform
//        self.bottomView.layer.transform = bottomTransform
//
//    }
//
//    func onPan(_ panGesture: UIPanGestureRecognizer) {
//        switch panGesture.state {
//        case .changed:
//            let dx = panGesture.translation(in: self).x
//            let dTranslation = CGFloat(dx) - lastTranslation
//            let newX = topView.frame.origin.x + dTranslation
//            lastTranslation = CGFloat(dx)
//            print("dx: \(dx)")
//
//            topViewMoved(to: newX)
//
//        default:
//            lastTranslation = 0.0
//
//            print("ViewX: \(topView.frame.origin), DeckX: \(self.frame.width * margin)")
//
//            if (topView.frame.origin.x < 0 && topView.frame.origin.x >= -(self.frame.width * margin)) ||
//                (topView.frame.origin.x >= 0 && topView.frame.origin.x <= (self.frame.width * margin)) {
//                restoreStack()
//            } else {
//                UIView.animate(withDuration: 0.2, animations: {
//                    if self.topView.frame.origin.x >= 0 {
//                        self.topViewMoved(to: self.frame.width)
//                    } else {
//                        self.topViewMoved(to: -self.frame.width)
//                    }
//
//                }, completion: {complete in
//                    if complete {
//                        self.handleRecycle()
//
//                    }
//                })
//            }
//        }
//    }

//    func handleRecycle() {
//
//        let bg = topView.backgroundColor
//        topView.backgroundColor = midView.backgroundColor
//        midView.backgroundColor = bottomView.backgroundColor
//        bottomView.backgroundColor = bg
//        self.resetStack()
//    }
//
//    func topViewMoved(to x: CGFloat) {
//        topView.frame = CGRect(x: x,
//                               y: 0,
//                               width: topView.frame.width,
//                               height: topView.frame.height)
//
//        let multiplier = abs(topView.frame.origin.x / frame.width)
//        print("Multi: \(multiplier)")
//
//        var midTransform = CATransform3DMakeScale(midScale + (multiplier * (1 - midScale)),
//                                                  midScale + (multiplier * (1 - midScale)),
//                                                  1)
//        midTransform = CATransform3DTranslate(midTransform,
//                                              0,
//                                              midTranslation - multiplier * (midTranslation),
//                                              0)
//        midView.layer.transform = midTransform
//
//        var bottomTransform = CATransform3DMakeScale(bottomScale + (multiplier * (1 - midScale)),
//                                                     bottomScale + (multiplier * (1 - midScale)),
//                                                     1)
//        bottomTransform = CATransform3DTranslate(bottomTransform,
//                                                 0,
//                                                 bottomTranslation - multiplier * (midTranslation),
//                                                 0)
//        midView.layer.transform = midTransform
//        bottomView.layer.transform = bottomTransform
//
//    }

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

extension DeckView: DeckViewDataSource {

    func numberOfSlidesIn(_ deckView: DeckView) -> Int {
        return data.count
    }

    func slideFor(_ deckView: DeckView, at: Int) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height - 50))
        view.backgroundColor = data[at]
        return view
    }
}

