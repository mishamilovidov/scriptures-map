//
//  ChaptersViewController.swift
//  Scriptures Map
//
//  Created by Misha Milovidov on 11/17/17.
//  Copyright © 2017 Misha Milovidov. All rights reserved.
//

import UIKit

class ChaptersViewController : UITableViewController {
    
    // MARK: - Constants
    
    public struct Storyboard {
        static let ChapterCellIdentifier = "ChapterCell"
        static let ScriptureSegueIdentifier = "Show Scripture"
    }
    
    // MARK: - Properties
    
    var book: Book!
    var chapter = 0
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.ScriptureSegueIdentifier {
            if let destVC = segue.destination as? ScriptureViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    destVC.book = book
                    destVC.chapter = indexPath.row + 1
                    destVC.title = "\(book.fullName) \(indexPath.row + 1)"
                }
            }
        }
    }
    
    // MARK: - Data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ChapterCellIdentifier, for: indexPath)
        
        if book.fullName == "Sections" {
            cell.textLabel?.text = "Section \(indexPath.row + 1)"
        } else {
            cell.textLabel?.text = "\(book.fullName) \(indexPath.row + 1)"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return book.numChapters!
    }
    
    // MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Storyboard.ScriptureSegueIdentifier, sender: self)
    }
}
