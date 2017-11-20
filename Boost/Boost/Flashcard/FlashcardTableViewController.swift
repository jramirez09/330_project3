//
//  FlashcardTableViewController.swift
//  Boost
//
//  Created by Kelly Herron on 11/14/17.
//  Copyright © 2017 Kelly Herron. All rights reserved.
//

import UIKit

class FlashcardTableViewController: UITableViewController {
    
    //MARK: Properties
    var flashcardGroup: FlashcardGroup!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = flashcardGroup.title
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flashcardGroup.group.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "FlashcardTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FlashcardTableViewCell else { fatalError("The dequeued cell is not an instance of FlashcardTableViewCell.")
        }
        
        let flashcard = flashcardGroup.group[indexPath.row]
        
        cell.frontLabel.text = flashcard.front
        
        return cell
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            flashcardGroup.group.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "AddItem":
            print("Add Item")
        case "ShowDetail":
            guard let flashcardDetailViewController = segue.destination as? FlashcardViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedFlashcardCell = sender as? FlashcardTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedFlashcardCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedFlashcard = flashcardGroup.group[indexPath.row]
            flashcardDetailViewController.flashcard = selectedFlashcard
        default:
            fatalError("Unexpected Segue Identifier: \(String(describing: segue.identifier))")
        }
    }
    
    //MARK: Actions
    @IBAction func unwindToFlashcardList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? FlashcardViewController, let flashcard = sourceViewController.flashcard {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                //update existing flashcard
                flashcardGroup.group[selectedIndexPath.row] = flashcard
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                //add new flashcard
                let newIndexPath = IndexPath(row: 0, section: 0)
                flashcardGroup.group.insert(flashcard, at: 0)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if editButton.style == .plain {
            beginEditing()
        } else if editButton.style == .done {
            endEditing()
        }
    }
    @IBAction func renameDeck(_ sender: UIBarButtonItem) {
        //adapted from: https://www.simplifiedios.net/ios-dialog-box-with-input/
        //TODO: disable enter button if same name or empty string
        let alert = UIAlertController(title: "Rename Deck", message: "Enter the new name of the deck", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Enter", style: .default) {
            (_) in
            let name = alert.textFields?[0].text
            self.flashcardGroup.title = name!
            self.navigationItem.title = name
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alert.addTextField{ (textField) in
            textField.placeholder = "Enter Name"
        }
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Private methods
    private func endEditing() {
        self.tableView.setEditing(false, animated: true)
        editButton.title = "Edit"
        editButton.style = .plain
    }
    
    private func beginEditing() {
        self.tableView.setEditing(true, animated: true)
        editButton.title = "Done"
        editButton.style = .done
    }
}