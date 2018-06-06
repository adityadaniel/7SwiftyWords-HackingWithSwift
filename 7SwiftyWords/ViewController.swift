//
//  ViewController.swift
//  7SwiftyWords
//
//  Created by Daniel Aditya Istyana on 6/6/18.
//  Copyright © 2018 Daniel Aditya Istyana. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var currentAnswer: UITextField!
    @IBOutlet weak var cluesLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    var letterButtons = [UIButton]()
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var level = 1
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        for subview in view.subviews where subview.tag == 1001 {
            let btn = subview as! UIButton
            letterButtons.append(btn)
            btn.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
        }
        
        loadLevel()
    }
    
    func loadLevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        if let levelFilePath = Bundle.main.path(forResource: "level1", ofType: "txt") {
            if let levelContent = try? String(contentsOfFile: levelFilePath) {
                var lines = levelContent.components(separatedBy: "\n")
                lines = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: lines) as! [String]
                for (index, line) in lines.enumerated() {
                    let parts = line.components(separatedBy: ":")
                    let answer = parts[0]
                    let clue = parts[1]
                    clueString += "\(index + 1). \(clue)\n"
                    
                    let solutionsWord = answer.replacingOccurrences(of: "|", with: "")
                    solutionString += "\(solutionsWord.count) letters\n"
                    solutions.append(solutionsWord)
                    
                    let bits = answer.components(separatedBy: "|")
                    letterBits += bits
                }
            }
        }
        
        cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        answerLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        letterBits = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: letterBits) as! [String]
        if letterBits.count == letterButtons.count {
            for i in 0 ..< letterBits.count {
                letterButtons[i].setTitle(letterBits[i], for: .normal)
            }
        }
    }
    
    @objc func letterTapped(btn: UIButton) {
        currentAnswer.text = currentAnswer.text! + (btn.titleLabel?.text!)!
        activatedButtons.append(btn)
        btn.isHidden = true
        
    }
    
    func levelUp(action: UIAlertAction) {
        level += 1
        solutions.removeAll(keepingCapacity: true)
        
        loadLevel()
        
        for btn in letterButtons {
            btn.isHidden = false
        }
    }
    
    @IBAction func clearTapped(_ sender: UIButton) {
        for btn in activatedButtons {
            btn.isHidden = false
        }
        currentAnswer.text = ""
        activatedButtons.removeAll()
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        if let solutionPosition = solutions.index(of: currentAnswer.text!) {
            activatedButtons.removeAll()
            
            var splitAnswer = answerLabel.text!.components(separatedBy: "\n")
            splitAnswer[solutionPosition] = currentAnswer.text!
            answerLabel.text = splitAnswer.joined(separator: "\n")
            currentAnswer.text = ""
            score += 1
            
            if score % 7 == 0 {
                let ac = UIAlertController(title: "Are you ready for the next level?", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Let's go", style: .default, handler: nil))
                present(ac, animated: true)
            }
        }
    }
}

