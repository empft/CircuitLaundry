import UIKit

enum HttpRequestError: Error {
    case JSONParsingError
    case InvalidResponseCode
    case DataReceiveError
    case UnknownError
}

extension URLSession {
    func dataTask(with url: URL,_ completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask {
        return dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if !((200...299).contains((response as! HTTPURLResponse).statusCode)) {
                completion(.failure(HttpRequestError.InvalidResponseCode))
                return
            }
            
            if let data = data {
                completion(.success(data))
                return
            }
            completion(.failure(HttpRequestError.UnknownError))
        })
    }
    
    func dataTask(with urlrequest: URLRequest,_ completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask {
        return dataTask(with: urlrequest, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if !((200...299).contains((response as! HTTPURLResponse).statusCode)) {
                completion(.failure(HttpRequestError.InvalidResponseCode))
                return
            }
            
            if let data = data {
                completion(.success(data))
                return
            }
            completion(.failure(HttpRequestError.UnknownError))
        })
    }
}

extension Result where Success == Data {
    //pass in struct here
    func jsondecode<T:Decodable>(using format: T.Type) throws -> T {
        let jsondata = try get()
        return try JSONDecoder().decode(format.self, from: jsondata)
    }
}

fileprivate struct FailureMessage: Decodable {
    let Message: String?
}

fileprivate struct CreateUserJson: Decodable {
    struct tokenvalue: Decodable {
        let Value: String
        let Expires: Int?
    }
    
    struct CreationData: Decodable {
        let AppUserId: Int
        let Token: tokenvalue
        let PrimaryLocation: String
        let AccountBalance: Double
        let InternalId: Int
        let ExternalKey: String
        let AccountName: String
        let AccountOperatorID: Int
        let AccountMinimumPurchaseAmount: Double
        let AccountLowBalanceIndicator: Double
        let AccountCurrencyTypeID: Int
        let AccountCurrencyUniCode: String
        let IsRoomViewAvailable: Bool
        let AccountWelcomeTitle: String
        let AccountWelcomeText: String
    }
    
    let Data: CreationData?
    let Success: Bool
    let Message: String
}

fileprivate struct GetBalanceJson: Decodable {
    struct MoneyLeft: Decodable {
        let AccountBalance: Double
    }
    
    let Data: MoneyLeft
    let Success: Bool
    let Message: String
}

fileprivate struct GetPromotionJson: Decodable {
    struct Promotion: Decodable {
        let PromotionId: Int
        let PromotionAccountId: Int
        let PromotionCreateDate: String
        let PromotionStartDate: String
        let PromotionEndDate: String
        let PromotionIsActive: Bool
        let PromotionName: String
        let PromotionDescription: String
        let PromotionCode: String
        let PromotionAmountRequired: Int
        let PromotionAmountGiven: Int
        let PromotionType: Int
        let PromotionImageURL: String?
    }
    
    let Data: [Promotion]?
    let Success: Bool
    let Message: String
}

fileprivate struct GetLaundryStatusJson: Decodable {
    struct UserStatus: Decodable {
        let MachineId: String
        let MachineInUseID: Int
        let Available: Bool
        let StatusDescription: String
        let Category: String
        let EstimatedCompletionTime: String
        let HighSuggestedCreditAmount: Int
        let LowSuggestedCreditAmount: Int
        let Make: String
        let Model: String
        let Name: String
        let Status: Int
        let StatusText: String
        let AccountExternalKey: String
        let LocationId: String
        let OperatorExternalKey: String
    }
    
    let Data: [UserStatus]?
    let Success: Bool
    let Message: String
}

fileprivate struct GetMachineInfoJson: Decodable {
    struct MachineInfo: Decodable {
        let MachineId: String
        let MachineInUseID: Int
        let Available: Bool
        let StatusDescription: String
        let Category: String
        let EstimatedCompletionTime: String
        let HighSuggestedCreditAmount: Int
        let LowSuggestedCreditAmount: Int
        let Make: String
        let Model: String
        let Name: String
        let Status: Int
        let StatusText: String
        let AccountExternalKey: String
        let LocationId: String
        let OperatorExternalKey: String
    }
    
    let Data: MachineInfo?
    let Success: Bool
    let Message: String
}

fileprivate struct UseMachineJson: Decodable {
    struct UseMachineResult: Decodable {
        let Succeeded: Bool
        let CardID: String
        let CardStatus: Int
        let CardStatusText: String
        let FailureMessage: String
    }
    
    let Data: UseMachineResult?
    let Success: Bool
    let Message: String
}

fileprivate struct AddMoneyJson: Decodable {
    struct RedirectURL: Decodable {
        let PaymentURL: String
    }
    
    let Data: RedirectURL?
    let Success: Bool
    let Message: String?
}

struct ApiWithoutSession {
    private let base = "https://phoneadmin.flashcashonline.com"
    fileprivate let session = URLSession.shared
    fileprivate var credential: [String:String] = [:]
    var machine: String? = nil
    
    init(email: String , password: String, machine:String? = nil) {
        self.credential["email"] = email.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!.replacingOccurrences(of: "+", with: "%2B")
        self.credential["password"] = password.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!.replacingOccurrences(of: "+", with: "%2B")
        self.machine = machine
    }
    
    func alert(_ message: String) {
        let alertcontroller = DBAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        alertcontroller.show()
    }
    
    func createUser() {
        var connect = "/API/User/CreateUser?email=\(credential["email"]!)&password=\(credential["password"]!)&machineId="
        if let machineId = machine {
            connect += machineId
        } else {
            connect += "LKPMKSZ0"
        }
        let url = URL(string:base + connect)!
        
        let task = session.dataTask(with: url, { result in
            DispatchQueue.main.async {
            switch result {
                case .success:
                    do {
                        let decodedjson = try result.jsondecode(using: CreateUserJson.self)
                        if decodedjson.Success {
                            UserDefaults.standard.set(decodedjson.Data!.Token.Value, forKey: "token")
                            let mainstoryboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeScreen")
                            let appdelegate = UIApplication.shared.delegate as! AppDelegate
                            appdelegate.window?.rootViewController = mainstoryboard
                        } else {
                            self.alert("Email Already Exists")
                        }
                    } catch {
                        print(error)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        })
        task.resume()
    }
    
    func userLogin() {
        let connect = "/API/User/authenticate?Email=\(credential["email"]!)&Password=\(credential["password"]!)"
        let url = URL(string: base + connect)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = session.dataTask(with: request, { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    do {
                        let decodedjson = try result.jsondecode(using: CreateUserJson.self)
                        if decodedjson.Success {
                            UserDefaults.standard.set(decodedjson.Data!.Token.Value, forKey: "token")
                            let mainstoryboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeScreen")
                            let appdelegate = UIApplication.shared.delegate as! AppDelegate
                            appdelegate.window?.rootViewController = mainstoryboard
                        } else {
                            self.alert("Invalid Email/Password")
                        }
                    } catch {
                        print(error)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        })
        task.resume()
    }
}

struct ApiWithSession {
    private let base = "https://phoneadmin.flashcashonline.com"
    fileprivate let token: String = UserDefaults.standard.string(forKey: "token")!
    fileprivate let session = URLSession.shared

    
    func alert(_ message: String) {
        let alertcontroller = DBAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertcontroller.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        alertcontroller.show()
    }
    
    func getBalance(completion: @escaping (_ amount: Double) ->Void) {
        let connect = "/API/User/ReconcileCards"
        let url = URL(string: base + connect)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    do {
                        let decodedjson = try   result.jsondecode(using: GetBalanceJson.self)
                        if decodedjson.Success {
                            completion(decodedjson.Data.AccountBalance)
                        
                        } else {
                            self.alert("Unable to Retrieve Balance")
                        }
                    } catch {
                        print(error)
                    }
                    case .failure(let error):
                        print(error)
                    }
                }
            })
            task.resume()
        
    }
    func getPromotion() {
        let connect = "/API/User/GetPromotionList"
        let url = URL(string: base + connect)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, { result in
            switch result {
            case .success:
                do {
                    let decodedjson = try result.jsondecode(using: GetPromotionJson.self)
                    if decodedjson.Success {
                        //Format the promotions
                    } else {
                       print("Unable to Retrieve Promotion")
                    }
                } catch {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        })
        task.resume()
        
    }
    
    func getLaundryStatus() {
        let connect = "/API/User/LaundryStatus"
        let url = URL(string: base + connect)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, { result in
            switch result {
            case .success:
                do {
                    let decodedjson = try result.jsondecode(using: GetLaundryStatusJson.self)
                    if decodedjson.Success {
                        //format User Laundry Status - may not be necessary
                    } else {
                        print("Unable to Retrieve User Laundry")
                    }
                } catch {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        })
        task.resume()
        
    }
    
    func secLeft(_ string: String) -> TimeInterval? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
        let machinetime = formatter.date(from: string)
        let currenttime = Date()
        if let machinetime = machinetime {
            let timeinterval = currenttime.timeIntervalSince(machinetime)
            return -timeinterval
        } else {
            return nil
        }
    }
    
    func getMachineInfo(of machine: String, completion: @escaping(_  available: Bool, _ time: TimeInterval?) -> Void) {
        let connect = "/API/User/GetMachineInfo/?MachineId=" + machine
        guard let url = URL(string: base + connect) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, { result in
            switch result {
            case .success:
                do {
                    let decodedjson = try result.jsondecode(using: GetMachineInfoJson.self)
                    if decodedjson.Success {
                        
                        if decodedjson.Data!.EstimatedCompletionTime != "" {
                            let sec = self.secLeft(decodedjson.Data!.EstimatedCompletionTime)
                            completion(decodedjson.Data!.Available, sec)
                        } else {
                            completion(decodedjson.Data!.Available, nil)
                        }
                    } else {
                        print("Unable to Retrieve Machine Info")
                    }
                } catch {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        })
        task.resume()
    }
    
    func useMachine(of machine: String, completion: @escaping (_ time: TimeInterval?) -> Void) {
        let connect = "/API/User/CreateVirtualCard?MachineId=" + machine
        let url = URL(string: base + connect)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    
        
        let task = session.dataTask(with: request, { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    do {
                        let decodedjson = try result.jsondecode(using: UseMachineJson.self)
                        if decodedjson.Success {
                            let failure = decodedjson.Data!.FailureMessage
                            if failure != "" {
                                self.alert(failure)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
                                self.getMachineInfo(of: machine, completion: { available, time in
                                    if available == false && time != nil {
                                        completion(time)
                                    }
                                })
                            }
                        } else {
                            self.alert("Unable to Use Machine")
                        }
                    } catch {
                        print(error)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        })
        task.resume()
    }
    
    func addMoney(with amount: String, completion: @escaping (_ url: String) -> Void) {
        let connect = "/API/User/RequestPurchase?amount=" + amount //check > 5 in controller
        let url = URL(string: base + connect)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    do {
                        let decodedjson = try result.jsondecode(using: AddMoneyJson.self)
                        if decodedjson.Success {
                            let redirecturl = decodedjson.Data!.PaymentURL
                            completion(redirecturl)
                        } else {
                            print("Unable to add money")
                        }
                    } catch {
                        print(error)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        })
        task.resume()
    }
}

