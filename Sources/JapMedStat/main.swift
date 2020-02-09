// 日本医療統計のテキストを整形し入力しやすくするパッケージ
//
// あらかじめ nkf -u druglisting.txt >druglistutf8.txt
//
// .build/x86_64-apple-macosx/debug/JapMedStat druglistutf8.txt

import Cocoa

let ddef: [[String]] =
    [
        ["アーガメイトゼリー", "0926"],
        ["クエン酸", "1204"],
        ["エパルレスタット", "6911"],
        ["キネダック", "6911"],
        ["ボグリボース", "0836"],
        ["フロセミド", "2301"],
        ["サムスカ", "2301"],
        ["ラシックス", "2301"],
        ["ダイアート", "2301"],
        ["アーチスト", "2002"],
        ["カルベジロール", "2002"],
        ["ビソプロロール", "2002"],
        ["メインテート", "2002"],
        ["サンリズム", "2002"],
        ["ベラパミル", "2002"],
        ["シベノール", "2002"],
        ["ベラパミル塩酸塩", "2002"],
        ["タケルダ", "1911+0001"],
        ["アスパラカリウム", "0907"],
        ["ランソプラゾール", "0001"],
        ["タケキャブ", "0001"],
        ["オメプラール", "0001"],
        ["タケプロン", "0001"],
        ["ネキシウムカプセル", "0001"],
        ["モサプリドクエン酸塩", "0035"],
        ["セララ", "2312"],
        ["スピロノラクトン", "2312"],
        ["ジャディアンス", "0810"],
        ["ノボラピッド", "0810"],
        ["ノボリン", "0810"],
        ["トラゼンタ", "0810"],
        ["フォシーガ", "0810"],
        ["エクメット", "0810"],
        ["メトホルミン", "0810"],
        ["デベルザ", "0810"],
        ["メトグルコ", "0810"],
        ["マグネシウム", "0420"],
        ["アルダクトン", "2312"],
        ["シロスタゾール", "1911"],
        ["エフィエント", "1911"],
        ["アンプラーグ", "1911"],
        ["リマプロストアルファデクス", "2907"],
        ["クロピドグレル", "1911"],
        ["バイアスピリン", "1911"],
        ["テルミサルタン", "2201"],
        ["オルメサルタン", "2201"],
        ["アダラート", "2201"],
        ["カルデナリン", "2201"],
        ["エナラート", "2201"],
        ["ニフェジピン", "2201"],
        ["ペリンドプリルエルブミン", "2201"],
        ["ロサルタンカリウム", "2201"],
        ["ザクラス", "2201"],
        ["アムロジピン", "2201"],
        ["レザルタス", "2201"],
        ["オルメテック", "2201"],
        ["コバシル", "2201"],
        ["ユニシア", "2201"],
        ["アイトロール", "2601"],
        ["シグマート", "2601"],
        ["リクシアナ", "1001"],
        ["イグザレルト", "1001"],
        ["プラザキサ", "1001"],
        ["エリキュース", "1001"],
        ["ワーファリン", "1001"],
        ["クレストール", "1316"],
        ["シンバスタチン", "1316"],
        ["メバロチン", "1316"],
        ["リピトール", "1316"],
        ["ロスバスタチン", "1316"],
        ["アロプリノール", "6409"],
        ["フェブリク", "6409"],
        ["カルボシステイン", "8301"],
        ["アスベリン","8301"],
        ["カルボシステインＤＳ", "8301"],
        ["トピロリック", "6409"],
        ["トリアゾラム", "7304"],
        ["ブロチゾラム", "7304"],
        ["アメジニウムメチル", "2701"],
        ["ロゼレム", "7304"],
        ["アミティーザカプセル", "0416"],
        ["リンゼス", "0416"],
        ["ラックビー", "0726"],
        ["酸化マグネシウム", "0426"],
        ["塩化ナトリウム", "0907"],
        ["フェロ・グラデュメット", "1204"],
        ["ツロブテロールテープ", "8102"],
        ["アンヒバ", "7102"],
        ["ボルタレン", "7102"],
        ["カロナール", "7102"],
        ["ロキソニン", "7102"],
        ["リレンザ", "5302"],
        ["タミフル", "5302"],
        ["タミフルドライシロップ", "5302"],
        ["マーズレンＳ", "0035"],
        ["ＰＬ", "7145"],
        ["ポピヨドンガーグル","5501"],
        ["ＳＰトローチ","9132"],
        ["ジクロフェナクナトリウムテープ","7139"],
        ["フロモックス","5101"],
        ["ベタヒスチンメシル酸塩","0219"],
        ["ドンペリドン","0202"],
        
    ]

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

let args = CommandLine.arguments.dropFirst()

guard let file = args.first, !file.isEmpty else
{
    print("ERROR: please input filename")
    exit(1)
}

let fileName: String = "./" + file

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
                    var match: Bool = false
                    for ds in ddef
                    {
                        if ds[0] == ans[1]
                        {
                            dbstr = dbstr + liney + "  " + ds[1] + "\n"
                            match = true
                            break
                        }
                    }
                    if !match
                    {
                        dbstr = dbstr + liney + "  ?\(ans[1])?\n"
                    }
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

exit(0)