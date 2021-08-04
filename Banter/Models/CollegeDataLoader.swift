//
//  CollegeDataLoader.swift
//  Banter
//
//  Created by Harris Kapoor on 8/3/21.
//  Copyright © 2021 Avidi Industries Inc. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

public class CollegeDataLoader {
    
    @Published var collegeData = [CollegeData]()
    
    init() {
        //immediately loads & sorts data without being called
        load()
        sort()
        
    }
    
    func load() {
        
        if let fileLocation = Bundle.main.url(forResource: "CollegeList", withExtension: "json")
        {
            //catch error in case data not found
            do {
                let data = try Data(contentsOf: fileLocation)
                let jsonDecoder = JSONDecoder()
                //get data from json and convert it to desired data type
                let dataFromJson = try jsonDecoder.decode([CollegeData].self, from: data)
                
                self.collegeData = dataFromJson
            } catch {
                    print(error)
                }
            }
        }
    
    func sort() {
        //sorts the data alphabetically
        self.collegeData = self.collegeData.sorted(by: {$0.LocationName < $1.LocationName})
        
    }
        
    }


