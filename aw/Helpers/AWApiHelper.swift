//
//  AWApiHelper.swift
//  aw
//
//  Created by Alex Kerney on 3/23/18.
//  Copyright © 2018 Alex Kerney. All rights reserved.
//

import CoreData
import Foundation
import UIKit

let baseURL = "https://www.americanwhitewater.org/content/"

let riverURL = baseURL + "River/search/.json"

struct AWReach: Codable {
    let difficulty: String
    let condition: String
    let id: Int
    let name: String
    let putInLat: String?
    let putInLon: String?
    let lastGageReading: String
    let section: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, section
        case difficulty = "class"
        case condition = "cond"
        case putInLat = "plat"
        case putInLon = "plon"
        case lastGageReading = "reading_formatted"
    }
}

struct Condition {
    let name: String
    let color: UIColor
}

struct AWApiHelper {
    static let shared = AWApiHelper()
    
    typealias ReachCallback = ([AWReach]?) -> Void
    
    func fetchReaches(callback: @escaping ReachCallback) {
        
        guard let url = URL(string: riverURL) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            let decoder = JSONDecoder()
            guard let data = data, let reaches = try? decoder.decode([AWReach].self, from: data) else { return }
            
            callback(reaches)
        }
        task.resume()
    }
    
    func conditionFromApi(condition: String) -> Condition {
        switch condition {
        case "low":
            return Condition(name: "Low", color: UIColor(named: "status_yellow")!)
        case "med":
            return Condition(name: "Runnable", color: UIColor(named: "status_green")!)
        case "high":
            return Condition(name: "High", color: UIColor(named: "status_red")!)
        default:
            return Condition(name: "No Info", color: UIColor(named: "status_grey")!)
        }
    }
    
    func createOrUpdateReach(newReach: AWReach, context: NSManagedObjectContext) {
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        context.persist {
            let reach = Reach(context: context)
            reach.section = newReach.section
            reach.putInLat = newReach.putInLat
            reach.putInLon = newReach.putInLon
            reach.name = newReach.name
            reach.lastGageReading = newReach.lastGageReading
            reach.id = Int16(newReach.id)
            reach.difficulty = newReach.difficulty
            reach.condition = newReach.condition
        }
    }
    
    func createOrUpdateReach(newReach: AWReach) {
        DispatchQueue.main.async {
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            
            let context = container.viewContext
            
            self.createOrUpdateReach(newReach: newReach, context: context)
            
            //container.performBackgroundTask { (context) in
            
            //}
        }
    }
    
    func updateReaches() {
        fetchReaches() { (reaches) in
            guard let reaches = reaches else { return }
            
            print("reaches fetched from API:", reaches.count)
            
            for reach in reaches {
                self.createOrUpdateReach(newReach: reach)
            }
        }
    }
}
