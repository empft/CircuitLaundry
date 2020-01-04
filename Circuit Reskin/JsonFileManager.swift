import Foundation


//File is saved in following structure
struct LaundretteList: Codable {
    var Laundrette: [laundrette]
    
    struct laundrette: Codable {
        let WebId: Int
        let Name: String
        let Washer: [washer]
        let Dryer: [dryer]
    }

    struct washer: Codable {
        let Number: Int
        let Code: String?
    }
    
    struct dryer: Codable {
        let Number: Int
        let Code: String?
    }
}

class ManageFile {
    let includedjson = try! JSON(data:(try! Data(contentsOf: Bundle.main.url(forResource: "MachineData", withExtension: "json")!)))
    let fileurl = (try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)).appendingPathComponent("LocalMachines.json")
    
    func saveToFile(input: JSON) {
        let formattedinput = formatJsonBeforeSaving(input: input)
        do {
            let data = try formattedinput.rawData()
            try data.write(to: fileurl)
        } catch {
            print("Error while saving to file")
        }
    }
    
    func readFromFile() -> JSON? {
        if fileurl.isFileURL {
            do {
                let data = try Data(contentsOf: fileurl)
                let machinearray = try JSON(data: data)
                return machinearray
            } catch {
                print("Cannot convert from File")
                return nil
            }
        } else {
            return nil
        }
    }
    
    func formatJsonBeforeSaving(input: JSON) -> JSON {
        if let readjson = readFromFile() {
            let array = readjson["Laundrette"].arrayValue
            var formattedinput = readjson
            for i in 0..<array.count {
                if array[i]["Name"] == input["Laundrette"][0]["Name"] {
                    formattedinput["Laundrette"].arrayObject?.remove(at: i)
                }
            }
            formattedinput["Laundrette"].arrayObject?.append(input["Laundrette"][0])
            return formattedinput
        } else {
            return input
        }
    }
    
    func deleteFromFile(input: JSON) {
        if let readjson = readFromFile() {
            let array = readjson["Laundrette"].arrayValue
            var formattedinput = readjson
            for i in 0..<array.count {
                if array[i]["Name"] == input["Laundrette"][0]["Name"] {
                    formattedinput["Laundrette"].arrayObject?.remove(at: i)
                }
            }
            do {
                let data = try formattedinput.rawData()
                try data.write(to: fileurl)
            } catch {
                print("Error while deleting from file")
            }
        }
    }
}




