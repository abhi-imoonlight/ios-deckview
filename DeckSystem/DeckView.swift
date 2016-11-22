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

    var widthFactor: CGFloat = 10
    var translateFactor: CGFloat = 5

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


    var position = 0



    func bind(to frame: CGRect) {
        self.frame = frame
        var upperBound = dataSource?.numberOfSlidesIn(self) ?? 0

        if views.count > 0 {
            return
        }

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
                if let dataSource = dataSource {
                    if dataSource.numberOfSlidesIn(self) <= 1 {
                        restoreStack(with: 0.2)
                        return
                    }
                }
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

            let multiplier = abs(topViewHolder.frame.origin.x / topViewHolder.frame.width)

            for index in 0..<viewHolders.count {

                if index == 0 {
                    continue
                }


                let viewHolder = viewHolders[index]

                print("MULTIPLIER FACTOR: \(multiplier)")

                viewHolder.frame = CGRect(x: (CGFloat(index) * self.translateFactor) - (CGFloat(multiplier) * self.translateFactor),
                       y: (CGFloat(index) * 3 * self.translateFactor) - (CGFloat(multiplier) * 3 * self.translateFactor),
                       width: topViewHolder.frame.width - (CGFloat(index) * self.widthFactor) + (CGFloat(multiplier) * self.widthFactor),
                       height: topViewHolder.frame.height - (CGFloat(index) * self.widthFactor) + (CGFloat(multiplier) * self.widthFactor))

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
                    self.position += 1
                    if let dataSource = self.dataSource {
                        if self.position >= dataSource.numberOfSlidesIn(self) {
                            self.position = 0
                        }
                    }
                    self.updateSlides()
                    self.restoreStack()
                }
            })
        }

    }

    func reloadData() {
        updateSlides()
        restoreStack()
    }

    func updateSlides() {
        if let dataSource = dataSource {
            for var index in 0..<viewHolders.count {
                views[index] = dataSource.slideFor(self, at:(position + index) % dataSource.numberOfSlidesIn(self))
            }
        }

    }

    func restoreStack(with duration: Double) {

        UIView.animate(withDuration: duration) {

            self.restoreStack()
        }
    }

    func restoreStack() {
        if let topViewHolder = self.viewHolders.first {
            for var index in 0..<self.viewHolders.count {
                let viewHolder = self.viewHolders[index]
                self.views[index].removeFromSuperview()
                self.viewHolders[index].addSubview(self.views[index])
                if index == 0 {
                    viewHolder.frame = CGRect(x: 0, y: 0,
                                              width: viewHolder.frame.width,
                                              height: viewHolder.frame.height)
                }

                viewHolder.frame = CGRect(x: topViewHolder.frame.origin.x + (CGFloat(index) * self.translateFactor),
                                          y: topViewHolder.frame.origin.y + (CGFloat(index) * 3 * self.translateFactor),
                                          width: topViewHolder.frame.width - (CGFloat(index) * self.widthFactor),
                                          height: topViewHolder.frame.height - (CGFloat(index) * self.widthFactor))
            }
        }
    }


}

protocol DeckViewDataSource {

    func numberOfSlidesIn(_ deckView: DeckView) -> Int
    func slideFor(_ deckView: DeckView, at: Int) -> UIView

}

protocol DeckViewDelegate {
    
    func slideWillSwipeLeftIn(_ deckview: DeckView, at position: Int) -> Bool
    func slideWillSwipeRightIn(_ deckView: DeckView, at position: Int) -> Bool
    func slideSwipeWillCancelIn(_ deckView: DeckView, at position: Int)
}


