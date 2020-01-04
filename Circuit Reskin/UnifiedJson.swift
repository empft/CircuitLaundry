import Foundation

class UnifiedJson {
    let file = ManageFile()
    var json: JSON!
    
    init() {
        json = getNewJson()
    }
    
    func updateJsonValue() {
        json = getNewJson()
    }

    func getNewJson() -> JSON{
        var jsn = file.includedjson
        if let readjson = file.readFromFile() {
            let array = readjson["Laundrette"].arrayValue.map{$0["Name"].stringValue}
            for name in array {
                let index = array.firstIndex(of: name)!
                for (i0, i) in jsn["Location"].arrayValue.enumerated() {
                    for (i1,j) in i["Accommodation"].arrayValue.enumerated() {
                        for (i2, k) in j["LaundryRoom"].arrayValue.enumerated() {
                            if k["Name"].stringValue == name {
                                jsn["Location"][i0]["Accommodation"][i1]["LaundryRoom"][i2] = readjson["Laundrette"][index]
                            }
                        }
                    }
                }
                
            }
        }
        return jsn
        
    }
    
    func machineData(stringarray: [String]) -> (washer: [(number: Int, code: String?)], dryer: [(number: Int, code: String?)]) {
        let cfg = stringarray
        var washercelldata: [(number: Int, code: String?)] = []
        var dryercelldata: [(number: Int, code: String?)] = []
        let jsn = json["Location"][Int(cfg[3])!]["Accommodation"][Int(cfg[4])!]["LaundryRoom"][Int(cfg[5])!]
            for wash in jsn["Washer"].arrayValue {
                washercelldata += [(number: wash["Number"].intValue, code: wash["Code"].string)]
            }
            for dry in jsn["Dryer"].arrayValue {
                dryercelldata += [(number: dry["Number"].intValue, code: dry["Code"].string)]
            }
        
        return (washer: washercelldata, dryer: dryercelldata)
        }
    
}
