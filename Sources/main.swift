import Foundation
import KituraNet

let url = URL(string: "https://steemd.steemit.com/")

// Not encoding this since it's always the same.
// It appears the path in the third "params" parameter array can actually be
// anything.
let initialBlockQuery = "{\"jsonrpc\":\"2.0\",\"method\":\"call\",\"params\": [\"database_api\", \"get_state\", [\"state\"]],\"id\":0}"

let options: [ClientRequest.Options] = [.method("post"), .schema("https"), .hostname("steemd.steemit.com")]

let req = HTTP.request(options, callback: { response in
    guard response != nil else {
        print("Error fetching status.")
        return
    }

    guard response!.statusCode == .OK else {
        print("Got status response but bad status code.")
        return
    }

    var data = Data()
    do {
        _ = try response!.readAllData(into: &data)
    }
    catch {
        print("Couldn't parse body")
        return
    }

    var foo: Dictionary<String, Any>

    do {
        try foo = JSONSerialization.jsonObject(with: data, options: []) as! Dictionary
    }
    catch {
        print("Couldn't deserialize JSON.")
        return
    }
    let result: Dictionary = foo["result"]! as! Dictionary<String, Any>
    let props: Dictionary = result["props"]! as! Dictionary<String, Any>
    let headBlockNum: UInt = props["head_block_number"]! as! UInt
    print("Head block is \(headBlockNum)")

    var currentBlockNum = headBlockNum

    repeat {
        print("Getting block \(currentBlockNum)")
        let blockQuery = "{\"jsonrpc\":\"2.0\",\"method\":\"call\",\"params\": [\"database_api\", \"get_block\", [\(currentBlockNum)]],\"id\":0}"

        let req = HTTP.request(options, callback: { response in
            guard response != nil else {
                print("Error fetching status.")
                return
            }

            guard response!.statusCode == .OK else {
                print("Got status response but bad status code.")
                return
            }

            var data = Data()
            do {
                _ = try response!.readAllData(into: &data)
            }
            catch {
                print("Couldn't parse body")
                return
            }

            var foo: Dictionary<String, Any>

            do {
                try foo = JSONSerialization.jsonObject(with: data, options: []) as! Dictionary
            }
            catch {
                print("Couldn't deserialize JSON.")
                return
            }

            guard let result = foo["result"] as? Dictionary<String, Any> else {
                print("Sleeping!")
                sleep(60)
                return
            }

            let transactions: Array = result["transactions"] as! Array<Dictionary<String, Any>>
            for transaction in transactions {
                let operations: Array = transaction["operations"] as! Array<Array<Any>>
                let type: String = operations[0][0] as! String
                if type == "comment" {
                    let data: Dictionary = operations[0][1] as! Dictionary<String, Any>
                    let author: String = data["author"] as! String
                    let permlink: String = data["permlink"] as! String
                    print("https://steemit.com/@\(author)/\(permlink)")
                }
            }
            print("Done with block \(currentBlockNum)")
            currentBlockNum = currentBlockNum + 1

        })
        req.end(blockQuery)

    } while true

})

req.end(initialBlockQuery)
