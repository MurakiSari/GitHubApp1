//
//  UserRepositoryListViewController.swift
//  GitHubApp
//
//  Created by 岩永 彩里 on 2018/09/25.
//  Copyright © 2018年 岩永 彩里. All rights reserved.
//

import UIKit

class UserRepositoryListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var repoTableView: UITableView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var follower: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var reposCount: UILabel!

    var accessToken: String = ""
    var nameLabel: String?

    struct User: Codable {
        let name: String?
        let followers: Int?
        let following: Int?
        let avatarUrl: String?
    }

    struct Repositry: Codable {
        let name: String?
        let description: String?
        let language: String?
        let stargazers_count: Int?
        let clone_url: String
        let fork: Bool
    }

    var repositries: [Repositry] = [] {
        didSet {
            repoTableView.reloadData()
        }
    }
    var user: [String: Any] = [:] {
    //var user: [User] = []{
        didSet {
            repoTableView.reloadData()
        }
    }
    var selectedURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        repoTableView.delegate = self
        repoTableView.dataSource = self

        //セルの高さを自動で計算
        self.repoTableView.estimatedRowHeight = 135
        repoTableView.rowHeight = UITableView.automaticDimension
        //repoTableView.rowHeight = UITableViewAutomaticDimension

        fullname.numberOfLines = 0
        fullname.textColor = UIColor.white
        follower.textColor = UIColor.white
        following.textColor = UIColor.white
        name.text = nameLabel

        fetchAPI()
        //API通信処理

    }
    //通信処理(とデータ変換)
    //class GitHubAPI {
    func fetchAPI() {

        var req = URLRequest(url: URL(string: "https://api.github.com/users/\(nameLabel!)")!)
        req.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")

        var repoURL = URLRequest(url: URL(string: "https://api.github.com/users/\(nameLabel!)/repos")!)
        repoURL.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")

        //二つの非同期処理
        let dispatchGroup = DispatchGroup()
        let dispatchQueue1 = DispatchQueue(label: "user情報取得", attributes: .concurrent)
        let dispatchQueue2 = DispatchQueue(label: "repo情報取得", attributes: .concurrent)

        dispatchGroup.enter()
        dispatchQueue1.async(group: dispatchGroup) {
            [weak self] in
            self?.queue1() //処理１：user情報取得
        }

        dispatchQueue2.async(group: dispatchGroup) {
            [weak self] in
            self?.queue2() //処理２：repo情報取得
        }
        dispatchGroup.leave()
    }
    //}

    func queue1() {
        //上にも同じ処理書いてるからまとめれるかも
        var req = URLRequest(url: URL(string: "https://api.github.com/users/\(nameLabel!)")!)
        req.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")

            //let decoder: JSONDecoder = JSONDecoder()
        let task: URLSessionTask = URLSession.shared.dataTask(with: req, completionHandler: {data, response, error in
            if let response = response as? HTTPURLResponse {
                print("response.statusCode2 = \(response.statusCode)")
            }
            do {
                //let json: [User] = try JSONDecoder().decode([User].self, from: data!)

                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)as? [String: Any]

                DispatchQueue.main.async { () -> Void in
                    self.user = json!

                    let fullNameLabel = self.user["name"] as? String
                    self.fullname.text = fullNameLabel
                    let follower = self.user["followers"] as! Int
                    self.follower.text = "\(follower)"

                    let following = self.user["following"] as! Int
                    self.following.text = "\(following)"

                    let userImage = self.user["avatar_url"] as! String
                    let userImageURL: URL = URL(string: "\(userImage)")!
                    let imageData = try? Data(contentsOf: userImageURL)
                    self.imageView.image = UIImage(data: imageData!)
                }
            } catch {
              print(error)
            }
        })
        task.resume() //実行する
    }

    func queue2() {
        //上にも同じ処理書いてるからまとめれるかも
        var repoURL = URLRequest(url: URL(string: "https://api.github.com/users/\(nameLabel!)/repos")!)
        repoURL.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")

        let task2: URLSessionTask = URLSession.shared.dataTask(with: repoURL, completionHandler: {data, response, error in
            if let response = response as? HTTPURLResponse {
                print("response.statusCode3 = \(response.statusCode)")
            }
            do {
                let jsons: [Repositry] = try JSONDecoder().decode([Repositry].self, from: data!)
                //let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)as! [Any]

                //let articles = (json.map { (article) -> [String: Any] in
                    //return article as! [String: Any]
                //})

                DispatchQueue.main.async { () -> Void in
                    self.repositries = jsons.filter { repo in !(repo.fork) }
                    self.reposCount.text = String(self.repositries.count)
                    //print(self.repositries[0]["fork"] as! Bool)
                }
            } catch {
                print(error)
            }
        })
        task2.resume() //実行する
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.title = "Repository"
    }

    //行数の指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositries.count
    }
    //セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    //セルの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "myCell")
        let cell = repoTableView.dequeueReusableCell(withIdentifier: "userCell")!

        let repository = repositries[indexPath.row]

        let repoLabel = cell.viewWithTag(1) as? UILabel
        let description = cell.viewWithTag(2) as? UILabel
        let language = cell.viewWithTag(3) as? UILabel
        let star = cell.viewWithTag(4) as? UILabel

        let repoName = repository.name
        repoLabel?.text = repoName

        let repoDescription = repository.description
        description?.text = repoDescription

        let  repoLanguage = repository.language
        language?.text = repoLanguage

        let repoStar = repository.stargazers_count
        star?.text = "\(repoStar!)"

        return cell
    }

    //セル選択時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let repository = repositries[indexPath.row]
        selectedURL = repository.clone_url

        performSegue(withIdentifier: "toWebView", sender: IndexPath.self)

    }

    //次のページへ値の受け渡し
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let userWebViewController = segue.destination as? UserWebViewController
        userWebViewController?.webURL = selectedURL

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
