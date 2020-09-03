//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Павел Звеглянич on 29.06.2020.
//  Copyright © 2020 Павел Звеглянич. All rights reserved.
//

import UIKit

@IBDesignable class PlayingCardView: UIView {

    @IBInspectable var rank = 10 {didSet {setNeedsDisplay(); setNeedsLayout() } } //setNeedsDisplay - вызов drawrect для перерисовки, setNeedsLayout - обновление подпредставления (subviews)
    @IBInspectable var suit = "❤️" {didSet {setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable var isFaceUp: Bool = true {didSet {setNeedsDisplay(); setNeedsLayout() } }
    var faceCardScale: CGFloat = SizeRatio.faceCardImageSizeToBoundSize {didSet {setNeedsDisplay()} } //для картинки J Q K
    
    
    @objc func adjustFaceCardScale(byHandlingGestureRecognizedBy recognizer: UIPinchGestureRecognizer) {//обработчик для жестов для масштабирования
        switch recognizer.state {
        case .changed, .ended:
            faceCardScale *= recognizer.scale//масштабирование
            recognizer.scale = 1.0
        default:break
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: 4.0)// устанавливаем скругления и где
        roundedRect.addClip() // обрезаем
        UIColor.white.setFill() // делаем заливку
        roundedRect.fill() // заливаем
        
        if  isFaceUp {// указываем что рисовать в центре (или символы или брать картинку из проекта)
            if  let faceCardImage = UIImage(named: rankString+suit, in:  Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                faceCardImage.draw(in: bounds.zoom(by: faceCardScale))
            } else {
                drawPips()
            }
        } else {
            if  let cardBackImage = UIImage(named: "Cardback", in:  Bundle(for: self.classForCoder), compatibleWith: traitCollection) { // устанавливаем рубашку
                cardBackImage.draw(in: bounds)
            }
        }
        
    }
    
    private func drawPips()
       {
           let pipsPerRowForRank = [[0], [1], [1,1], [1,1,1], [2,2], [2,1,2], [2,2,2], [2,1,2,2], [2,2,2,2], [2,2,1,2,2], [2,2,2,2,2]]
           
           func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
               let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0)})
               let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.max() ?? 0, $0)})
               let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
               let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
               let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
               let probablyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize)
               if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                   return centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize /
                       (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
               } else {
                   return probablyOkayPipString
               }
           }
           
           if pipsPerRowForRank.indices.contains(rank) {
               let pipsPerRow = pipsPerRowForRank[rank]
               var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2)
               let pipString = createPipString(thatFits: pipRect)
               let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
               pipRect.size.height = pipString.size().height
               pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
               for pipCount in pipsPerRow {
                   switch pipCount {
                   case 1:
                       pipString.draw(in: pipRect)
                   case 2:
                       pipString.draw(in: pipRect.leftHalf)
                       pipString.draw(in: pipRect.righHalf)
                   default:
                       break
                   }
                   pipRect.origin.y += pipRowSpacing
               }
           }
       }
    
    
    
    private lazy var upperLeftCornerLabel = createCornerLabel() // верхняя левая угловая метка, денивый потому что не инициилизирован изначально
    private lazy var lowerRightCornerLabel = createCornerLabel() // нижняя правая угловая метка, денивый потому что не инициилизирован изначально

    private func createCornerLabel() -> UILabel { // создаем угловую метку вывода
        let label = UILabel() // создаем метку для вывода строки
        label.numberOfLines = 0 // добавляем число строк, 0 потому что мы сами вычисляем потом сколько строк нам необходимо вписывать при рисовании. если не добавить, не будет прорисовки
        addSubview(label) // добавляем метку как подпредставление (subview) самого себя
        return label
    }
    
    private  func configureCornerLabel (_ label: UILabel) { // функция конфигурации самой метки
        label.attributedText = cornerString // устанавливаем атрибуты текста (переносит на след строку, центрирует, подбирает грифт и др.)
        label.frame.size = CGSize.zero // устанавливаем нашу метку по установленному размеру 0, т.к. потом будет его расщирять по тексту, поэтому 0 чтобы он не расширялся по изначальному значению
        label.sizeToFit() //размер метки будет соответствовать ее содержимому (такой метод)
        label.isHidden = !isFaceUp//указываем полную прозрачность при условии если карта не дицом вверх для скрывания при переворачивании
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) { // выполняет код при изменении рзамера шрифта в настройках моментально
        setNeedsDisplay() //включаем методы для перерисования при перевороте
        setNeedsLayout()//включаем методы для перерисования при перевороте
    }
    
    override func layoutSubviews() { //переопределяем размещение слоя подпредставления, те указываем что мы будем рисовать. setNeedsDisplay и setNeedsLayout вызыывают это
        super.layoutSubviews()// ссылкаемся на суперслой
        
        configureCornerLabel(upperLeftCornerLabel)// создаем метку по верхнему левому углу
        upperLeftCornerLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)//устанавливаем верхнее левое положение по frame на границы (bounds) по углу смещения метки
        
        configureCornerLabel(lowerRightCornerLabel)// создаем метку по нижнему правому углу
        lowerRightCornerLabel.transform = CGAffineTransform.identity // CGAffineTransform позволяет переместить, машстабировать и повернуть.
            .translatedBy(x: lowerRightCornerLabel.frame.size.width, y: lowerRightCornerLabel.frame.size.height)//транфсформируем координату переноса на нижний правй угол
            .rotated(by: CGFloat.pi) //переворачиваем вверх ногами, на 180 градусов
        lowerRightCornerLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY)// устанавливаем метку в нижнем правом углу границы дна
            .offsetBy(dx: -cornerOffset, dy: -cornerOffset)// конфигурируем координату начала на правый нижний угол ожидаемого расположения метки (отступ)
            .offsetBy(dx: -lowerRightCornerLabel.frame.size.width, dy: -lowerRightCornerLabel.frame.size.height)// конфигурируем координату начала на левый верхний угол ожидаемого расположения метки (отступ)
    }
    
    
    
    
    
 
    private func centeredAttributedString (_  string: String, fontSize: CGFloat) -> NSAttributedString { //создаем функцию для вывода атрибутов строки
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)//создаем шрифт строки с размером
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)// делаем шрифт универсальным по размеру из настроек пользователя
        let paragraphStyle = NSMutableParagraphStyle()// создаем переменную для инкапсуляции строки в центр
        paragraphStyle.alignment = .center//устанавливаем выравнивание на центер
        return NSAttributedString(string: string, attributes: [.paragraphStyle: paragraphStyle, .font: font])// возвращаем атрибут строки с щрифтом и выравниванием
    }

    private var cornerString: NSAttributedString { //создаем переменную с атрибутами строки и переносом знаков на след строку
        return centeredAttributedString(rankString + "\n" + suit, fontSize: cornerFontSize)
    }
}

extension PlayingCardView {
    private   struct SizeRatio { //создаем расширение констант для использования в структуре
        static   let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static   let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static   let cornerOffsetToCornerRadius: CGFloat = 0.33
        static   let faceCardImageSizeToBoundSize: CGFloat = 0.75
    }
    
    private var cornerRadius: CGFloat { // угловой радиус
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var cornerOffset: CGFloat  { // смещение в углу
        return cornerRadius *  SizeRatio.cornerOffsetToCornerRadius
    }
    private var cornerFontSize: CGFloat { // угловой размер шрифта
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    private var rankString: String { //стркоа ранга карты
        switch rank {
        case  1: return "A"
        case  2...10 : return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
}

extension CGRect  {
    var leftHalf:  CGRect { // левая половина
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    var righHalf: CGRect { // правая половина
        return CGRect(x: midX, y: midY, width: width/2, height: height)
    }
    func inset (by  size:   CGSize) -> CGRect { // вставка чего-то в прямоугольник
        return insetBy(dx: size.width, dy: size.height)
    }
    func   sized (to scale:  CGSize) -> CGRect { // изменение изначальных размеров
        return CGRect(origin: origin, size: size)
    }
    func zoom (by scale: CGFloat) -> CGRect {// масштабирование
        let newWidTH = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidTH)/2, dy: (height - newHeight)/2)
    }
}

extension CGPoint { //расщирение по перемещению точки на определенное количество, просто плюсует значения координат
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}
