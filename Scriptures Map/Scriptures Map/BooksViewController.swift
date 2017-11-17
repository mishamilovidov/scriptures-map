//
//  BooksViewController.swift
//  Scriptures Map
//
//  Created by Misha Milovidov on 11/17/17.
//  Copyright © 2017 Misha Milovidov. All rights reserved.
//

import UIKit

class BooksViewController : UITableViewController {
    
    // MARK: - Constants
    
    public struct Storyboard {
        static let BookCellIdentifier = "BookCell"
        static let ChapterSegueIdentifier = "Show Scripture"
    }
    
    // MARK: - Properties
    
    var books: [Book]!
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.ChapterSegueIdentifier {
            if let destVC = segue.destination as? ScriptureViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    destVC.book = books[indexPath.row]
                    destVC.chapter = 2
                    destVC.title = "\(books[indexPath.row].fullName) 2"
                }
            }
        }
    }
    
    // MARK: - Data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.BookCellIdentifier, for: indexPath)
        
        cell.textLabel?.text = books[indexPath.row].fullName
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    // MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Storyboard.ChapterSegueIdentifier, sender: self)
    }
}
