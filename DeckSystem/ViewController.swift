//
//  ViewController.swift
//  DeckSystem
//
//  Created by Abhinash Khanal on 11/14/16.
//  Copyright © 2016 Moonlighting. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DeckViewDataSource {

    //    var data = [UIColor.red, UIColor.blue, UIColor.yellow, UIColor.green]

//    var data = [UIColor.red, UIColor.blue, UIColor.black]
    //    var data = [UIColor.red, UIColor.blue]
        var data = [UIColor.red]


    @IBOutlet weak var deck: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let deck = UINib.init(nibName: "DeckView", bundle: Bundle.main)
            .instantiate(withOwner: nil, options: nil).first as? DeckView {

            deck.dataSource = self

            print("VIEW WIDTH: \(view.frame.width)")

            deck.bind(to: CGRect(x: 0, y: 0, width: self.deck.frame.width, height: 239))

            self.deck.addSubview(deck)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSlidesIn(_ deckView: DeckView) -> Int {
        return data.count
    }

    func slideFor(_ deckView: DeckView, at position: Int) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: deck.frame.width, height: deck.frame.height - 50))
        view.backgroundColor = data[position]
        return view
    }


}

