//
//  ViewController.swift
//  Flashcards
//
//  Created by Moises Limon on 2/11/20.
//  Copyright © 2020 Moises Limon. All rights reserved.
//

import UIKit

struct Flashcard {
    var question: String
    var answer: String
}

class ViewController: UIViewController {
    
    
    @IBOutlet weak var frontLabel: UILabel!
    @IBOutlet weak var backLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var card: UIView!
    
    //Array to hold our flashcards
    var flashcards = [Flashcard]()
    
    //Current flashcard index
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Read saved flashcards
        readSavedFlashcards()
        
        //Adding our initial flashcard if needed
        if flashcards.count == 0 {
            updateFlashcard(question: "What's the capital of Brazil?", answer: "Brasilia")
        } else{
            updateLabels()
            updateNextPrevButtons()
        }
    }
    
    @IBAction func didTapOnFlashcard(_ sender: Any) {
        flipFlashcard()
    }
    
    func flipFlashcard() {
        
        UIView.transition(with: card, duration: 0.3, options: .transitionFlipFromRight, animations: {
            if self.frontLabel.isHidden == false {
                self.frontLabel.isHidden = true
            }
            else {
                self.frontLabel.isHidden = false
            }
        })
    }
    
    func animateNextCardOut() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.card.transform = CGAffineTransform.identity.translatedBy(x: -300.0, y: 0.0)
        }, completion: {
            finished in
                   
             //update labels
            self.updateLabels()
             
             //Updates buttons
            self.updateNextPrevButtons()
            
            self.animateNextCardIn()
        })
    }
    
    func animateNextCardIn() {
       
        //Start on the right side
        card.transform = CGAffineTransform.identity.translatedBy(x: 300.0, y: 0.0)
        
        //Animate card going back to its original postion
        
        UIView.animate(withDuration: 0.3, animations: {
            self.card.transform = CGAffineTransform.identity
        })
    }
    
    @IBAction func didTapOnNext(_ sender: Any) {
        
        //increment current index
        currentIndex = currentIndex + 1
        
        // call the animation between flashcards
        animateNextCardOut()
    }
    
    func animatePrevCardOut() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.card.transform = CGAffineTransform.identity.translatedBy(x: 300.0, y: 0.0)
        }, completion: {
            finished in
                   
             //update labels
            self.updateLabels()
             
             //Updates buttons
            self.updateNextPrevButtons()
            
            self.animatePrevCardIn()
        })
    }
    
    func animatePrevCardIn() {
       
        //Start on the right side
        card.transform = CGAffineTransform.identity.translatedBy(x: -300.0, y: 0.0)
        
        //Animate card going back to its original postion
        
        UIView.animate(withDuration: 0.3, animations: {
            self.card.transform = CGAffineTransform.identity
        })
    }
    
    @IBAction func didTapOnPrev(_ sender: Any) {
        //decrement current index
        currentIndex = currentIndex - 1
        
         // call the animation between flashcards
               animatePrevCardOut()
    }
    
    @IBAction func didTapOnDelete(_ sender: Any) {
        
        //show confirmation
        let alert = UIAlertController(title: "Delete flashcard", message: "Are you sure you want to delete it?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
            action in self.deleteCurrentFlashcard()
        }
        
        alert.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func deleteCurrentFlashcard(){
        //Delete current
        flashcards.remove(at: currentIndex)
        
        //Special case: Check if last card was deleted
        
        if currentIndex > flashcards.count - 1 {
            currentIndex = flashcards.count - 1
        }
        
        updateNextPrevButtons()
        updateLabels()
        saveAllFlashcardsToDisk()
    }
    
    func updateFlashcard(question: String, answer: String) {
        
        let flashcard = Flashcard(question: question, answer: answer)
        //Adding flashcard into the flashcards array
        
        flashcards.append(flashcard)
        
        //logging to console
        print("Added new flashcard (: ")
        print("We now have \(flashcards.count) flashcard(s)")
        currentIndex = flashcards.count - 1
        print("The current index is \(currentIndex)")
        
        // updates buttons
        updateNextPrevButtons()
        
        // updates labels
        updateLabels()
        
        //Saving flashcards to disk
        saveAllFlashcardsToDisk()
        
    }
    
    func updateNextPrevButtons() {
        // Disables next button if at end
        if currentIndex == flashcards.count - 1 {
            nextButton.isEnabled = false
            
        } else{
            nextButton.isEnabled = true
        }
        // Disables prev button if at beginning
        if currentIndex == 0 {
            prevButton.isEnabled = false
            
        } else{
            prevButton.isEnabled = true
        }
        
    }
    
    func updateLabels(){
        
        //gets current flashcard
        let currentFlashcard = flashcards[currentIndex]
        
        //updates the labels
        frontLabel.text = currentFlashcard.question
        backLabel.text = currentFlashcard.answer
    }
    
    func saveAllFlashcardsToDisk(){
        
        //From flashcard array to dictionary array
        
        let dictionaryArray = flashcards.map { (card) -> [String: String] in
            return ["question": card.question, "answer": card.answer]
        }
        //Save array on disk using UserDefaults
        UserDefaults.standard.set(dictionaryArray, forKey: "flashcards")
        
        //Log it
        print("Flashcards saved to UserDefaults")
    }
    
    func readSavedFlashcards() {
        if let dictionaryArray = UserDefaults.standard.array(forKey: "flashcards") as? [[String: String]]{
            
            //In here we know for sure we have a dictionary
            let savedCards = dictionaryArray.map{ dictionary -> Flashcard in
                return Flashcard(question: dictionary["question"]!, answer: dictionary["answer"]!)
            }
            
            //Put all these cards in our flashcard array
            flashcards.append(contentsOf: savedCards)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        let navigationController = segue.destination as! UINavigationController
        // Pass the selected object to the new view controller.
        let creationController = navigationController.topViewController as! CreationViewController
        creationController.flashcardsController = self
        
    }
}

