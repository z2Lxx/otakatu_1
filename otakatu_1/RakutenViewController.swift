//
//  ViewController.swift
//  otakatu_1
//
//  Created by clark on 2022/05/10.


import UIKit
import SafariServices




class RakutenViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate, UIViewControllerTransitioningDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 編集処理
        
        let editAction = UIContextualAction(style: .normal, title: "追加") { (action, view, completionHandler) in
            
            // 編集処理を記述
            print("追加がタップされた")
            
            // 実行結果に関わらず記述
            completionHandler(true)
            
            let modalVC = self.storyboard?.instantiateViewController(withIdentifier: "modal")
            modalVC!.modalPresentationStyle = .popover
                    modalVC!.transitioningDelegate = self
            self.present(modalVC!, animated: true, completion: nil)
        }
        
        editAction.backgroundColor = UIColor.green
        // 定義したアクションをセット
        return UISwipeActionsConfiguration(actions: [editAction])
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        searchText.delegate = self
        
        searchText.placeholder = "お探しの商品名を入力してください"
        
        tableView.dataSource = self
        
        tableView.delegate = self
        
    }
    
    @IBOutlet weak var searchText: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var otakatuList : [ProductParent] = []
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        view.endEditing(true)
        
        if let searchWord = searchBar.text {
            
            
            print(searchWord)
            
            searchOtakatu(keyword: searchWord)
        }
    }
    
    
    struct ResultJson: Codable {
        let Products: [ProductParent]?
    }
    
    struct ProductParent: Codable {
        let Product: Product
    }
    
    struct Product: Codable {
        let ProductDetails: [ProductDetails]
        
        let salesMaxPrice: Int
        
        let productUrlPC: URL
        
        let smallImageUrl: URL
        
        let productName :String
    
    }
    
    struct ProductDetails: Codable {
        let detail: Detail
    }
    
    struct Detail: Codable {
        
        let value: String?
    }


    
    func searchOtakatu(keyword: String) {
        
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        guard let req_url = URL(string: "https://app.rakuten.co.jp/services/api/Product/Search/20170426?applicationId=1086629371249816189&format=json&keyword=\(keyword_encode)") else {
            
            return
        }
        
        print(req_url)

        
        
        let req = URLRequest(url: req_url)
        
        let session = URLSession(configuration: .default, delegate: nil,delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: req, completionHandler: {
            (data , responese , error) in
            
            session.finishTasksAndInvalidate()
            
            do{
                
                let decoder = JSONDecoder()
                
                print(data)
                
                let str = String(decoding: data!, as: UTF8.self)
                
                print(str)
                
                let json = try decoder.decode(ResultJson.self, from: data!)
                
                print(json)
                
                if let items = json.Products{

                    self.otakatuList.removeAll()

                    self.otakatuList = json.Products ?? []
                    dump(self.otakatuList)

                    self.tableView.reloadData()

                }
            } catch(let error) {
                
                
                
                print(String(describing: error))
                print("エラーが出ました")
            }
        })
        
        task.resume()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return otakatuList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "otakatuCell", for: indexPath)
        
        cell.textLabel?.text = otakatuList[indexPath.row].Product.productName

        let imageURL = otakatuList[indexPath.row].Product.smallImageUrl

            let data = try? Data(contentsOf: imageURL)

            if let image = data{

                cell.imageView?.image = UIImage(data: image)

            }
            
            
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let safariViewController = SFSafariViewController(url: otakatuList[indexPath.row].Product.productUrlPC)
        
        safariViewController.delegate = self
        
        present(safariViewController, animated: true, completion: nil)
        
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
//        func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//            let swipeCellA = UITableViewRowAction(style: .default, title: "追加") { action, index in
//                self.swipeContentsTap(content: "otakatu2Cell", index: index.row)
//            }
//
//            func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//                return true
//            }
//
//        }
}
