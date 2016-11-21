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
                    restoreStack(with: 0.2)
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
            var scaleFactor = multiplier / _scaleFactor
            var translationDelta = multiplier * _translationDelta
            for index in 0..<viewHolders.count {

                if index == 0 {
                    continue
                }


                let viewHolder = viewHolders[index]

                print("SCALE FACTOR: \(scaleFactor + 1)")

                var transform = viewHolder.layer.transform
                transform = CATransform3DScale(transform,
                                               1 + scaleFactor,
                                               1 + scaleFactor,
                                               1)
                transform = CATransform3DTranslate(transform,
                                                   0,
                                                   translationDelta,
                                                   0)
                viewHolder.layer.transform = transform
            }
        }
    }

    func handleRecycle() {

        if let viewHolder = viewHolders.first {
            var newX = CGFloat(viewHolder.frame.width)
            if viewHolder.frame.origin.x < 0 {
                newX = CGFloat(-viewHolder.frame.width)
            }
            UIView.animate(withDuration: 0.2, animations: {
                viewHolder.frame = CGRect(x: newX,
                                          y: 0,
                                          width: viewHolder.frame.width,
                                          height: viewHolder.frame.height)
            }, completion: { complete in
                if complete {
                    if viewHolder.frame.origin.x == viewHolder.frame.width {
                        self.moveTopSlide(by: viewHolder.frame.width)
                    } else {
                        self.moveTopSlide(by: -viewHolder.frame.width)
                    }
                }
            })
        }



    }

    func restoreStack(with duration: Double) {
        UIView.animate(withDuration: duration) {
            var scaleFactor: CGFloat = 1.0
            var translateFactor: CGFloat = 0.0
            for var index in 0..<self.viewHolders.count {
                let viewHolder = self.viewHolders[index]
                if index == 0 {
                    viewHolder.frame = CGRect(x: 0, y: 0,
                                              width: viewHolder.frame.width,
                                              height: viewHolder.frame.height)
                }
//                var transform = viewHolder.layer.transform
                var transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1)
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

