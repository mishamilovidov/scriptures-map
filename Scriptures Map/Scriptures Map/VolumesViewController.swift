//
//  VolumesViewController.swift
//  Scriptures Map
//
//  Created by Misha Milovidov on 11/17/17.
//  Copyright © 2017 Misha Milovidov. All rights reserved.
//

import UIKit

class VolumesViewController : UITableViewController {
    
    // MARK: - Constants
    
    public struct Storyboard {
        static let VolumeSegueIdentifier = "Show Books"
        static let VolumeCellIdentifier = "VolumeCell"
    }
    
    // MARK: - Properties
    
    var volumes = GeoDatabase.sharedGeoDatabase.volumes()
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.VolumeSegueIdentifier {
            if let destVC = segue.destination as? BooksViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    destVC.books = GeoDatabase.sharedGeoDatabase.booksForParentId(indexPath.row + 1)
                    destVC.title = volumes[indexPath.row]
                }
            }
        }
    }
    
    // MARK: - Data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.VolumeCellIdentifier, for: indexPath)
        
        cell.textLabel?.text = volumes[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return volumes.count
    }
}
