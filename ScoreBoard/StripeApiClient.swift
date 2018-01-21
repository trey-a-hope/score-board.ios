import Alamofire
import PromiseKit

class StripeAPIClient {
    private class var testSecretKey: String {
        return "sk_test_IM9ti8gurtw7BjCPCtm9hRar"
    }
    private class var testPublishableKey: String {
        return "pk_test_Dl5CsuVlvuAg3fG8vVCRrKbC"
    }
    private class var baseURL: String {
        return "http://es.tr3umphant-designs.com/assets/stripe"
    }
    
    //      ____                 _
    //     / ___|  _   _   ___  | |_    ___    _ __ ___     ___   _ __   ___
    //    | |     | | | | / __| | __|  / _ \  | '_ ` _ \   / _ \ | '__| / __|
    //    | |___  | |_| | \__ \ | |_  | (_) | | | | | | | |  __/ | |    \__ \
    //     \____|  \__,_| |___/  \__|  \___/  |_| |_| |_|  \___| |_|    |___/
    
    /// Creates a new customer object.
    /// - parameter email - String : Email of new customer.
    /// - returns: DataResponse<String> : Response from api call.
    /// - throws: No error.
    public static func createCustomer(email: String) -> Promise<DataResponse<String>> {
        return Promise{ fulfill, reject in
            let params = [
                "apiKey"    : testSecretKey,
                "email"     : email
            ]
            
            Alamofire.request(baseURL + "/customer/createCustomer.php", method: .post, parameters: params)
                .responseString  { response in
                    fulfill(response)
            }
        }
    }
    
    /// Retrieves the details of an existing customer. You need only supply the unique customer identifier that was returned upon customer creation.
    /// - parameter reject - String : Id of the customer.
    /// - returns: DataResponse<String> : Response from api call.
    /// - throws: No error.
    public static func retrieveCustomer(customerId: String) -> Promise<DataResponse<String>> {
        return Promise{ fulfill, reject in
            let params = [
                "apiKey"    : testSecretKey,
                "customerId": customerId
            ]
            
            Alamofire.request(baseURL + "/customer/retrieveCustomer.php", method: .post, parameters: params)
                .responseString  { response in
                    fulfill(response)
            }
        }
    }
    
    /// Returns a list of your customers. The customers are returned sorted by creation date, with the most recent customers appearing first.
    /// - returns: DataResponse<String> : Response from api call.
    /// - throws: No error.
    public static func listAllCustomers() -> Promise<DataResponse<String>> {
        return Promise{ fulfill, reject in
            let params = [
                "apiKey" : testSecretKey
            ]
            
            Alamofire.request(baseURL + "/customer/listAllCustomers.php", method: .post, parameters: params)
                .responseString  { response in
                    fulfill(response)
            }
        }
    }
    
    
    /// Permanently deletes a customer. It cannot be undone. Also immediately cancels any active subscriptions on the customer.
    /// - returns: DataResponse<String> : Response from api call.
    /// - throws: No error.
    public static func deleteCustomer(customerId: String) -> Promise<DataResponse<String>> {
        return Promise{ fulfill, reject in
            let params = [
                "apiKey"    : testSecretKey,
                "customerId": customerId
            ]
            
            Alamofire.request(baseURL + "/customer/deleteCustomer.php", method: .post, parameters: params)
                .responseString  { response in
                    fulfill(response)
            }
        }
    }
    
    /// Updates the specified customer by setting the values of the parameters passed.
    /// - returns: DataResponse<String> : Response from api call.
    /// - throws: No error.
    public static func updateCustomer(customerId: String, description: String, token: String) -> Promise<DataResponse<String>> {
        return Promise{ fulfill, reject in
            
            //NOTE: Any parameters left empty will not be changed.
            
            let params = [
                "apiKey"        : testSecretKey,
                "customerId"    : customerId,
                "description"   : description,
                "token"         : token
            ]
            
            Alamofire.request(baseURL + "/customer/updateCustomer.php", method: .post, parameters: params)
                .responseString  { response in
                    fulfill(response)
            }
        }
    }
    
    //      ____   _
    //     / ___| | |__     __ _   _ __    __ _    ___   ___
    //    | |     | '_ \   / _` | | '__|  / _` |  / _ \ / __|
    //    | |___  | | | | | (_| | | |    | (_| | |  __/ \__ \
    //     \____| |_| |_|  \__,_| |_|     \__, |  \___| |___/
    //                                    |___/
    
    //Makes a charge against a token, (user card).
    class func createCharge(customerId: String, description: String, amount: Int) -> Promise<DataResponse<String>> {
        return Promise{ fulfill, reject in
            
            let params = [
                "apiKey"        : testSecretKey,
                "amount"        : amount * 100,
                "description"   : description,
                "customerId"    : customerId
                ] as [String : Any]
            
            Alamofire.request(baseURL + "/charges/createCharge.php", method: .post, parameters: params)
                .responseString  { response in
                    fulfill(response)
            }
        }
    }
    
    //Retrieves the details of a charge that has previously been created.
    class func retrieveCharge(chargeId: String) -> Promise<DataResponse<String>> {
        return Promise{ fulfill, reject in
            
            let params = [
                "apiKey"        : testSecretKey,
                "chargeId"      : chargeId
            ]
            
            Alamofire.request(baseURL + "/charges/retrieveCharge.php", method: .post, parameters: params)
                .responseString  { response in
                    fulfill(response)
            }
        }
    }
    
    //Capture the payment of an existing, uncaptured, charge.
    class func captureCharge(chargeId: String) -> Promise<DataResponse<String>> {
        return Promise{ fulfill, reject in
            
            let params = [
                "apiKey"        : testSecretKey,
                "chargeId"      : chargeId
            ]
            
            Alamofire.request(baseURL + "/charges/captureCharge.php", method: .post, parameters: params)
                .responseString  { response in
                    fulfill(response)
            }
        }
    }
    
    //Updates the specified charge by setting the values of the parameters passed. Any parameters not provided will be left unchanged.
    class func updateCharge(chargeId: String, description: String) -> Promise<DataResponse<String>> {
        return Promise{ fulfill, reject in
            
            let params = [
                "apiKey"        : testSecretKey,
                "chargeId"      : chargeId,
                "description"   : description
            ]
            
            Alamofire.request(baseURL + "/charges/updateCharge.php", method: .post, parameters: params)
                .responseString  { response in
                    fulfill(response)
            }
        }
    }
    
    //Returns a list of charges a customer created. The charges are returned in sorted order, with the most recent charges appearing first.
    class func listAllCharges(customerId: String) -> Promise<DataResponse<String>> {
        return Promise{ fulfill, reject in
            
            let params = [
                "apiKey"        : testSecretKey,
                "customerId"    : customerId
            ]
            
            Alamofire.request(baseURL + "/charges/listAllCharges.php", method: .post, parameters: params)
                .responseString  { response in
                    fulfill(response)
            }
        }
    }
    
    //      ____                      _
    //     / ___|   __ _   _ __    __| |  ___
    //    | |      / _` | | '__|  / _` | / __|
    //    | |___  | (_| | | |    | (_| | \__ \
    //     \____|  \__,_| |_|     \__,_| |___/
    /*
     You can delete cards from a customer or recipient.
     
     For customers: if you delete a card that is currently the default source, then the most recently added source will become the new default. If you delete a card that is the last remaining source on the customer then the default_source attribute will become null.
     
     For recipients: if you delete the default card, then the most recently added card will become the new default. If you delete the last remaining card on a recipient, then the default_card attribute will become null.
     
     Note that for cards belonging to customers, you may want to prevent customers on paid subscriptions from deleting all cards on file so that there is at least one default card for the next invoice payment attempt.
     */
    class func deleteCard(customerId: String, cardId: String) -> Promise<DataResponse<String>> {
        return Promise{ fulfill, reject in
            let params = [
                "apiKey"    : testSecretKey,
                "customerId": customerId,
                "cardId"    : cardId
            ]
            
            Alamofire.request(baseURL + "/cards/deleteCard.php", method: .post, parameters: params)
                .responseString  { response in
                    fulfill(response)
            }
        }
    }
}





