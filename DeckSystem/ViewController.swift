//
//  ViewController.swift
//  DeckSystem
//
//  Created by Abhinash Khanal on 11/14/16.
//  Copyright © 2016 Moonlighting. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DeckViewDataSource {

        var data = [UIColor.red, UIColor.blue, UIColor.yellow, UIColor.green]


//    var data = [UIColor.red, UIColor.blue, UIColor.black]
    //    var data = [UIColor.red, UIColor.blue]
//        var data = [UIColor.red]

    var decks = [DeckView]()


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deck: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let data2 = Data2()
        let data3 = Data2()
        let data4 = Data2()
        data2.tableView = tableView
        data3.tableView = tableView
        data4.tableView = tableView


        if let deck = UINib.init(nibName: "DeckView", bundle: Bundle.main)
            .instantiate(withOwner: nil, options: nil).first as? DeckView {

            deck.dataSource = self
            deck.numberOfVisibleSlides = 3

            print("VIEW WIDTH: \(view.frame.width)")

            decks.append(deck)
            
        }

        if let deck = UINib.init(nibName: "DeckView", bundle: Bundle.main)
            .instantiate(withOwner: nil, options: nil).first as? DeckView {

            deck.dataSource = data2
            deck.numberOfVisibleSlides = 3

            print("VIEW WIDTH: \(view.frame.width)")

            decks.append(deck)
            
        }

        if let deck = UINib.init(nibName: "DeckView", bundle: Bundle.main)
            .instantiate(withOwner: nil, options: nil).first as? DeckView {

            deck.dataSource = data3
            deck.numberOfVisibleSlides = 3

            print("VIEW WIDTH: \(view.frame.width)")

            decks.append(deck)
            
        }

        if let deck = UINib.init(nibName: "DeckView", bundle: Bundle.main)
            .instantiate(withOwner: nil, options: nil).first as? DeckView {

            deck.dataSource = data3
            deck.numberOfVisibleSlides = 3

            print("VIEW WIDTH: \(view.frame.width)")

            decks.append(deck)
            
        }


        tableView.rowHeight = 239
        tableView.dataSource = self
//        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSlidesIn(_ deckView: DeckView) -> Int {
        return data.count
    }

    func slideFor(_ deckView: DeckView, at position: Int) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.rowHeight - 50))
        view.backgroundColor = data[position]
        return view
    }


}

class Data2: DeckViewDataSource {

    var tableView: UITableView!
     var data2 = [ UIColor.blue, UIColor.red, UIColor.yellow, UIColor.green]

    func numberOfSlidesIn(_ deckView: DeckView) -> Int {
        return data2.count
    }

    func slideFor(_ deckView: DeckView, at position: Int) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.rowHeight - 50))
        view.backgroundColor = data2[position]
        return view
    }
}

extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? DeckCell {
            let deck = decks[indexPath.item]

            for view in cell.deck.subviews {
                view.isHidden = true
                view.removeFromSuperview()
            }

            deck.bind(to: CGRect(x: 0,
                                 y: 0,
                                 width: cell.deck.frame.width - 10,
                                 height: cell.deck.frame.height - 50))

            cell.addSubview(deck)
            return cell
        }

        return UITableViewCell()
    }
    
}

