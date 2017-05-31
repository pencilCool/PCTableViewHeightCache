//
//  PCTableViewController.swift
//  SwiftTableViewHeightCache
//
//  Created by tangyuhua on 2017/5/29.
//  Copyright © 2017年 tangyuhua. All rights reserved.
//

import UIKit
enum PCSimulatedCacheMode:Int  {
    case noneCache = 0
    case cacheByIndexPath
    case cacheByKey
}
class PCTableViewController: UITableViewController {

    @IBOutlet weak var segementControl: UISegmentedControl!
    
    private var prototypeEntitiesFromJSON = [PCFeedEntity]()
    private var feedEntitySections = [Array<PCFeedEntity>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.pc_debugLogEnable = true
    
        self.segementControl.selectedSegmentIndex = PCSimulatedCacheMode.cacheByIndexPath.rawValue
        buildTestData {
            self.feedEntitySections.append(self.prototypeEntitiesFromJSON)
            self.tableView.reloadData()
        }
    }
    
    private func buildTestData(then: @escaping ()->()) {
        let queue = DispatchQueue(label: "com.pencilCool.TableViewHeightCache")
        queue.async {
            do {
                let path = Bundle.main.path(forResource: "data", ofType: "json")
                let url  = URL(fileURLWithPath: path!)
                let data = try! Data(contentsOf:url, options:.uncached)
                let rootDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                let feedDicts = rootDict["feed"] as! [[String:String]]
                
                var entities = [PCFeedEntity]()
                feedDicts.forEach{ (element) in
                    let entity = PCFeedEntity(dic: element)
                    entities.append(entity)
                }
                self.prototypeEntitiesFromJSON = entities
                DispatchQueue.main.async {
                    then()
                }

            } catch _ {}
            
        }
    }



    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return self.feedEntitySections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.feedEntitySections[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PCFeedCell", for: indexPath) as! PCFeedCell

        configure(cell, at: indexPath)
        return cell
    }
    
    func configure(_ cell:PCFeedCell, at indexPath: IndexPath) {
        
        cell.pc_enforeFrameLayout = false;
        if indexPath.row % 2 == 0 {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .checkmark
        }
        let entity = self.feedEntitySections[indexPath.section][indexPath.row]
        cell.titleLabel.text = entity.title
        cell.contentLabel.text = entity.content
        cell.usernameLabel.text = entity.username
        cell.timeLabel.text = entity.time
        cell.contentImageView.image =   UIImage(named:entity.imageName)// entity.imageName
        cell.timeLabel.text = entity.time
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          let index = self.segementControl.selectedSegmentIndex
          let model = PCSimulatedCacheMode(rawValue: index)!
        switch model {
        case .noneCache:
            return tableView.pc_heightForCell(withIdentifier: "PCFeedCell") { (cell) in
                configure(cell as! PCFeedCell , at: indexPath)
            }
        case .cacheByIndexPath:
            return tableView.pc_heightForCell(withIdentifier: "PCFeedCell", cacheBy: indexPath) {
                (cell) in
                configure(cell as! PCFeedCell , at: indexPath)
            }
        case .cacheByKey:
            return tableView.pc_heightForCell(withIdentifier: "PCFeedCell", cacheBy: indexPath) {
                (cell) in
                configure(cell as! PCFeedCell , at: indexPath)
            }
        }
    }
    
    @IBAction func action(_ sender: Any) {
       let controller  = UIAlertController(title: "Action", message: "", preferredStyle: .actionSheet)
        
        controller.addAction(UIAlertAction(title: "Insert a row", style: .default){ _ in
            self.insertRow()
        })
        controller.addAction(UIAlertAction(title: "Insert a section", style: .default){ _ in
            self.insertSection()
        })
        controller.addAction(UIAlertAction(title: "Delete a section", style: .default){ _ in
            self.deleteSection()
        })
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel){ _ in
            controller.dismiss(animated: true, completion: nil)
        })
        self.present(controller, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var mutableEntities = feedEntitySections[indexPath.section]
            mutableEntities.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func randomEntity() -> PCFeedEntity {
        let randomNumber = Int(arc4random_uniform(UInt32(prototypeEntitiesFromJSON.count)))
        let randomEntity = prototypeEntitiesFromJSON[randomNumber]
        return randomEntity
    }
    
    func insertSection() {
        feedEntitySections.insert([randomEntity()], at: 0)
        tableView.insertSections(IndexSet(), with: .automatic)
    }
    
    func insertRow() {
        if feedEntitySections.count == 0 {
            insertSection();
        } else {
            feedEntitySections[0].insert(randomEntity(), at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
    func deleteSection () {
        if feedEntitySections.count > 0 {
            feedEntitySections.remove(at: 0)
            tableView.deleteSections(IndexSet(), with: .automatic)
        }
    }
    
    
    
    
}


