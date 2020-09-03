//
//  ViewController.swift
//  PlayingCard
//
//  Created by Павел Звеглянич on 24.06.2020.
//  Copyright © 2020 Павел Звеглянич. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var desk = PlayingCardDesk()
    
    @IBOutlet weak var PlayingCardView: PlayingCardView! { // создание свайп
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))// создаем свайп, селф - для ссылки самого на себя, влием на модель же у себя
            swipe.direction = [.left, .right]// установка какие свайпы будут
            PlayingCardView.addGestureRecognizer(swipe)// добавляем свайп
            let pinch = UIPinchGestureRecognizer(target: PlayingCardView, action: #selector(PlayingCardView.adjustFaceCardScale(byHandlingGestureRecognizedBy:)))// создаем дест масштабирования
            PlayingCardView.addGestureRecognizer(pinch)
        }
    }
    
    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {//жест переворота
        switch sender.state {
        case .ended:
            PlayingCardView.isFaceUp = !PlayingCardView.isFaceUp
        default: break
        }
        
    }
    
    @objc func nextCard() {
        if let card = desk.draw() {//рисуем из колоды
            PlayingCardView.rank = card.rank.order// берем карты из колоды и передаем в PlayingCardView
            PlayingCardView.suit = card.suit.rawValue// берем карты из колоды и передаем в PlayingCardView
        }
    }
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 1...10 {
            if let card = desk.draw() {
                print ("\(card)")
            }
        }
    }


}

