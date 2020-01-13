//
//  StudentController.swift
//  Students
//
//  Created by Ben Gohlke on 6/17/19.
//  Copyright © 2019 Lambda Inc. All rights reserved.
//

import Foundation

enum TrackType: Int {
    case none
    case iOS
    case Web
    case UX
}

enum SortOptions: Int {
    case firstName
    case lastName
}

class StudentController {
    
    private var persistentFileURL: URL? {
        guard let filePath = Bundle.main.path(forResource: "students", ofType: "json") else { return nil }
        return URL(fileURLWithPath: filePath)
    }
    
    var students: [Student] = []
    
    func loadFromPersistentStore(completion: @escaping ([Student]?, Error?) -> Void) {
        let bgQueue = DispatchQueue(label: "studentQueue", attributes: .concurrent)
        bgQueue.async {
            let fm = FileManager.default
            guard let url = self.persistentFileURL,
                fm.fileExists(atPath: url.path) else {
                    return
            }
            
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let students = try decoder.decode([Student].self, from: data)
                self.students = students
                completion(students, nil)
            } catch {
                print("Error loading student data: \(error)")
            }
        }
    }
    
    func filter(with trackType: TrackType, sortedBy sorter: SortOptions, completion: @escaping ([Student]) -> Void) {
        var updatedStudent: [Student]
        
        switch trackType {
        case .iOS:
            updatedStudent = students.filter { $0.course == "iOS"}
        case .Web:
            updatedStudent = students.filter { $0.course == "Web"}
        case .UX:
            updatedStudent = students.filter { $0.course == "UX"}
        default:
            // filter for none, or another track type
            updatedStudent = students
        }
        
        if sorter == .firstName {
            updatedStudent = updatedStudent.sorted { $0.firstName < $1.firstName }
        } else {
            updatedStudent = updatedStudent.sorted { $0.lastName < $1.firstName }
        }
        
        completion(updatedStudent)
    }
}

