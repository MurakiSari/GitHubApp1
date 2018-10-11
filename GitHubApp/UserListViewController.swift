//
//  UserListViewController.swift
//  GitHubApp
//
//  Created by 岩永 彩里 on 2018/09/25.
//  Copyright © 2018年 岩永 彩里. All rights reserved.
//

import UIKit

class UserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userListTabelView: UITableView!

    struct User: Codable {
        let login: String
        let avatar_url: String
    }

    var users: [User] = [] {
        didSet {
            userListTabelView.reloadData()
        }
    }
    //var users: [[String: Any]] = []{
        //didSet {
            //userListTabelView.reloadData()
        //}
    //}

    var selectedUserName: String?
    var selectedUserFullName: String?
    var accessToken: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        userListTabelView.delegate = self
        userListTabelView.dataSource = self

        // ビューに表示
        fetchUsers { _, _ in
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "User"
    }

    //通信処理(とデータ変換)
    //class GitHubAPI {  これをつけるとaccessTokenが使えなかった。
         func fetchUsers(completion: (([User]?, Error?) -> Void)) {
            var req = URLRequest(url: URL(string: "https://api.github.com/users")!)
            req.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")

             //let task = URLSession.shared.dataTask(with: req) { data, _, error in
             let task: URLSessionTask = URLSession.shared.dataTask(with: req, completionHandler: {data, response, error in
                // エラー処理
                if let response = response as? HTTPURLResponse {
                    print("response.statusCode1 = \(response.statusCode)")
                }
                let decoder = JSONDecoder()
             do {
                let users: [User] = try decoder.decode([User].self, from: data!)

                DispatchQueue.main.async { () -> Void in
                    //self.users = articles
                    self.users = users
                }

             } catch {
                print(error)
                }
            })
            task.resume()
         }
    //}

    //行数の指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
     //セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
    return 1
    }
    //セルの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "myCell")

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "myCell")

        let article = users[indexPath.row]
        let userName = article.login
        let userImage = article.avatar_url
        let userImageURL: URL = URL(string: "\(userImage)")!
        let imageData = try? Data(contentsOf: userImageURL)

        cell.textLabel?.text = "\(userName)"
        cell.imageView?.image = UIImage(data: imageData!)

    return cell
    }
    //セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    //セル選択時
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let article = users[indexPath.row]
        selectedUserName = article.login

        performSegue(withIdentifier: "toUserRepositoryList", sender: IndexPath.self)
    }
    //次のページへ値の受け渡し
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let userRepositoryListViewController = segue.destination as?UserRepositoryListViewController
        userRepositoryListViewController?.nameLabel = selectedUserName
        userRepositoryListViewController?.accessToken = accessToken
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
