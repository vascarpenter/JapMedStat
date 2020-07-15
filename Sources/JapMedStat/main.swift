// 日本医療統計のテキストを整形し入力しやすくするパッケージ
//
// あらかじめ nkf -u druglisting.txt >druglistutf8.txt
//
// .build/x86_64-apple-macosx/debug/JapMedStat druglistutf8.txt

import Cocoa
import Dispatch
import SwiftKuery
import SwiftKueryMySQL

// https://qiita.com/KikurageChan/items/807e84e3fa68bb9c4de6 からのコピペです

extension String {
    // 絵文字など(2文字分)も含めた文字数を返します
    var length: Int
    {
        let string_NS = self as NSString
        return string_NS.length
    }
    
    // 正規表現の検索をします
    func pregMatche(pattern: String, options: NSRegularExpression.Options = []) -> Bool
    {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else
        {
            return false
        }
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, length))
        return matches.count > 0
    }
    
    // 正規表現の検索結果を利用できます
    func pregMatche(pattern: String, options: NSRegularExpression.Options = [], matches: inout [String]) -> Bool
    {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else
        {
            return false
        }
        let targetStringRange = NSRange(location: 0, length: length)
        let results = regex.matches(in: self, options: [], range: targetStringRange)
        for i in 0 ..< results.count
        {
            for j in 0 ..< results[i].numberOfRanges
            {
                let range = results[i].range(at: j)
                matches.append((self as NSString).substring(with: range))
            }
        }
        return results.count > 0
    }
    
    // 正規表現の置換をします
    func pregReplace(pattern: String, with: String, options: NSRegularExpression.Options = []) -> String
    {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [], range: NSMakeRange(0, length), withTemplate: with)
    }
}

// for Swift-Kuery ORM
class japmedstat: Table
{
    let tableName = "japmedstat"
    let id = Column("id", Int32.self, primaryKey: true)
    let name = Column("name", String.self)
    let value = Column("value", String.self)
}

let args = CommandLine.arguments.dropFirst()

guard let file = args.first, !file.isEmpty else
{
    print("ERROR: please input filename")
    exit(1)
}

func findName(connection: Connection, name: String) -> String
{
    var match: Bool = false
    var matchstr: String = ""
    let t1 = japmedstat()
    let waitSemaphore = DispatchSemaphore(value: 0)
    let query = Select(t1.value, from: t1).where(t1.name == name)
    connection.execute(query: query) { queryResult in
        guard let resultSet = queryResult.asResultSet else
        {
            // not found
            match = false
            waitSemaphore.signal()
            return
        }
        
        resultSet.forEach { row, _ in
            if match
            {
                return
            }
            guard let row = row else
            {
                // Processed all results
                waitSemaphore.signal()
                return
            }
            matchstr = row[0] as? String ?? ""
            match = true
            waitSemaphore.signal()
            return
        }
    }
    waitSemaphore.wait()
    if match
    {
        return matchstr
    }
    else
    {
        return ""
    }
}

let fileName: String = "./" + file

let pool = MySQLConnection.createPool(host: "localhost", user: "oge", password: "hogehogeA00", database: "dchild", poolOptions: ConnectionPoolOptions(initialCapacity: 10, maxCapacity: 50))
pool.getConnection { connection, error in
    guard let connection = connection else
    {
        guard let error = error else
        {
            return print("Unknown error")
        }
        return print("Error when getting connection from pool: \(error.localizedDescription)")
    }
    
    var drugblock: Bool = false
    var dbstr: String = ""
    var assessblock: Bool = false
    var abstr: String = ""
    
    if let text = try? String(contentsOfFile: fileName, encoding: String.Encoding.utf8)
    {
        text.enumerateLines { line, _ in
            var ans: [String] = []
            let linex = line.trimmingCharacters(in: .whitespaces)
            
            if linex == "" || linex.hasPrefix("A)")
            {
                // skip
            }
            else if linex.hasPrefix("# ")
            {
                if drugblock
                {
                    // drug block end, starts assessment block
                    print(dbstr)
                    abstr = linex + "\n"
                    assessblock = true
                    drugblock = false
                }
                else
                {
                    abstr = abstr + linex + "\n"
                }
            }
            else if line.pregMatche(pattern: "^([0-9]+)y([0-9]+)m(.*)$",
                                    options: NSRegularExpression.Options.anchorsMatchLines,
                                    matches: &ans)
            {
                if assessblock
                {
                    // assessment block end, starts drug block
                    print(abstr)
                    dbstr = ""
                    drugblock = true
                    assessblock = false
                }
                // age
                print("\n" + ans[1] + "歳 " + ans[2] + "ヶ月  " + ans[3])
                drugblock = true
            }
            else if drugblock
            {
                var liney = linex
                if liney.contains("錠") ||
                    liney.contains("坐剤") ||
                    liney.contains("ガーグル") ||
                    liney.contains("シロップ") ||
                    liney.contains("cap") ||
                    liney.contains("mL") ||
                    liney.contains("個") ||
                    liney.contains("枚") ||
                    liney.contains("散") ||
                    liney.contains("粒") ||
                    liney.contains("テープ") ||
                    liney.contains("ＤＳ") ||
                    liney.contains("注")
                {
                    liney = liney.pregReplace(pattern: "（.*）", with: "")
                    if liney.pregMatche(pattern: "([ァ-ンＡ-Ｚー塩化酸・]+)(.*)", matches: &ans)
                    {
                        var matchstr: String = ""
                        
                        matchstr = findName(connection: connection, name: ans[1])
                        if matchstr != ""
                        {
                            dbstr = dbstr + liney + "  " + matchstr + "\n"
                        }
                        else
                        {
                            dbstr = dbstr + liney + "  ?\(ans[1])?\n"
                        }
                    }
                    else
                    {
                        dbstr = dbstr + liney + "\n"
                    }
                }
                else if assessblock
                {
                    if linex.hasPrefix("# ")
                    {
                        abstr = abstr + linex + "\n"
                    }
                }
            }
        }
        // flush blocks
        if drugblock
        {
            print(dbstr)
        }
        if assessblock
        {
            print(abstr)
        }
    }
    connection.closeConnection()
}

exit(0)
