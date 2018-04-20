//
//  MovieDetailViewController.swift
//  WATCHA
//
//  Created by Seo JaeHyeong on 09/04/2018.
//  Copyright © 2018 Seo Jaehyeong. All rights reserved.
//

import UIKit
import Alamofire

class MovieDetailViewController: UIViewController {
   
   //for test temporary toket
   //private let TOKEN = "token \(UserDefaults.standard.string(forKey: "user_Token")!)"
   private let TOKEN = "token b8999260f52f162dceee7e298b3bd9da44d30af7"
   
   var movie: MovieDetailInfo?
   
   @IBOutlet weak var actorCollectionView: UICollectionView!
   @IBOutlet weak var galleryCollectionView: UICollectionView!
   @IBOutlet weak var youtubeCollectionView: UICollectionView!
   @IBOutlet weak var commentTableView: UITableView!
   @IBOutlet weak var recommendCollectionView: UICollectionView!
   
   @IBOutlet weak var backgroundImageView: UIImageView!
   @IBOutlet weak var posterImageView: UIImageView!
   @IBOutlet weak var titleLabel: UILabel!
   @IBOutlet weak var infoLabel: UILabel!
   @IBOutlet weak var ratedPointLabel: UILabel!
   @IBOutlet weak var cosmosView: CosmosView!
   @IBOutlet weak var storyLabel: UILabel!
   
   var pkForMovie: Int = 0 {
      didSet {
         // TODO : 카테고리 pk를 가지고 서버에서 카테고리 영화정보를 읽어온다.
         print("======== start update movie Info ========")
         print("pkForMovie = ",pkForMovie)
         let userToken: HTTPHeaders = ["Authorization": TOKEN]
         let url = API.Movie.detail + "\(pkForMovie)/"
         Alamofire.request(url, method: .get, headers: userToken)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
               if let error = response.error {
                  dump(error)
                  return
               }
               
               do {
                  let data = try JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
                  let decoder: JSONDecoder = JSONDecoder()
                  self.movie = try decoder.decode(MovieDetailInfo.self, from: data)
                  self.setupUI()
               } catch {
                  print(error)
               }
         }
      }
   }
   
   
    override func viewDidLoad() {
      super.viewDidLoad()
      
      registerDelegate()
    }
   
   
   func setupUI() {
      let urlForBackground = URL(string: movie?.stillCuts?.first?.image ?? "")
      if let imageData = try? Data(contentsOf: urlForBackground!, options: []) {
         backgroundImageView.image = UIImage(data: imageData)
      }
      
      let urlForPoster = URL(string: movie?.posterImageWeb ?? "")
      if let imageData = try? Data(contentsOf: urlForPoster!, options: []) {
         posterImageView.image = UIImage(data: imageData)
      }
      
      guard let title = movie?.titleKorean else {return}
      titleLabel.text = title
      
      var year: String = ""
      if let yearTotal = movie?.year {
         year = String(yearTotal.prefix(4))
      }
      
      guard let nation = movie?.nation else {return}
      guard let genre = movie?.genre?.first?.name else {return}
      guard let time = movie?.playTime else {return}
      let infoText: String = "\(year)・\(nation)・\(genre)・\(time)분"
      infoLabel.text = infoText
      
      guard let point = movie?.averageRating else {return}
      ratedPointLabel.text = point
      cosmosView.settings.fillMode = .precise
      //cosmosView.rating = Double(point)!
      cosmosView.rating = 2.3
      
      guard let story = movie?.story else {return}
      guard let grade = movie?.filmRate else {return}
      guard let titleEn = movie?.titleEnglish else {return}
      storyLabel.text = """
      상세정보
      \(grade)・\(titleEn)
      \(infoText)
      \(story)
      """
      
      actorCollectionView.reloadData()
      galleryCollectionView.reloadData()
      youtubeCollectionView.reloadData()
   }
   
   
   
   func registerDelegate() {
      actorCollectionView.delegate = self
      actorCollectionView.dataSource = self
      
      galleryCollectionView.delegate = self
      galleryCollectionView.dataSource = self
      
      youtubeCollectionView.delegate = self
      youtubeCollectionView.dataSource = self
      
      commentTableView.delegate = self
      commentTableView.dataSource = self
      
      recommendCollectionView.delegate = self
      recommendCollectionView.dataSource = self
   }
   

   @IBAction func backButtonPressed(_ sender: UIButton) {
      navigationController?.popViewController(animated: true)
   }
   
   
   //보고싶어요 버튼 클릭시 액션 정의
   @IBAction func wantButtonPressed(_ sender: UIButton) {
   }
 
   
   //평가하기 버튼 클릭시 액션 정의
   @IBAction func rateButtonPressed(_ sender: UIButton) {
   }
   

   //코멘트 버튼 클릭시 액션 정의
   @IBAction func commentButtonPressed(_ sender: UIButton) {
   }
   
   
   //더보기 버튼 클릭시 액션 정의
   @IBAction func moreButtonPressed(_ sender: UIButton) {
   }
   
}



//MARK: - UICollectionView Delegate, DataSource Methods
extension MovieDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
   
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      var counts = 0
      
      switch collectionView {
      case actorCollectionView:
         counts = movie?.actors.count ?? 0
      case galleryCollectionView:
         counts = movie?.stillCuts?.count ?? 0
      case youtubeCollectionView:
         counts = movie?.youtubeUrls?.count ?? 0
      case recommendCollectionView:
         counts = movie?.comments?.count ?? 0
      default:
         counts = 1
      }

      return counts
   }
   
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
      switch collectionView {
      case actorCollectionView:
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActorCell", for: indexPath) as! ActorCollectionViewCell
         
         let who = movie?.actors[indexPath.row]
         let urlForActor = URL(string: who?.actor.profileImage ?? "")
         if let imageData = try? Data(contentsOf: urlForActor!, options: []) {
            cell.actorImageView.image = UIImage(data: imageData)
         }
         
         let name = who?.actor.name ?? ""
         let type = who?.type ?? ""
         if var position = who?.position {
            position = "/" + position
         }
         cell.nameLabel.text = name
         cell.positionLabel.text = type
         
         return cell
      case galleryCollectionView:
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCollectionViewCell
         
         let urlForimage = URL(string: movie?.stillCuts?[indexPath.row].image ?? "")
         if let imageData = try? Data(contentsOf: urlForimage!, options: []) {
            cell.movieImage.image = UIImage(data: imageData)
         }
         
         return cell
      case youtubeCollectionView:
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YoutubeCell", for: indexPath) as! YoutubeCollectionViewCell
         
         let urlForThumbNail = URL(string: movie?.youtubeUrls?[indexPath.row].urlThumbNail ?? "")
         if let imageData = try? Data(contentsOf: urlForThumbNail!, options: []) {
            cell.thumbnailImage.image = UIImage(data: imageData)
         }
         
         return cell
      case recommendCollectionView:
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendCell", for: indexPath) as! RecommendCollectionViewCell
         return cell
      default:
         print("Fail Select Cell")
      }
      
      return UICollectionViewCell()
   }
   
}



//MARK: - UICollectionViewDelegateFlowLayout Methods
extension MovieDetailViewController: UICollectionViewDelegateFlowLayout {
   
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
      switch collectionView {
      case actorCollectionView:
         print("actorCollectionView")
         return CGSize(width: 90, height: 180)
      case galleryCollectionView:
         return CGSize(width: 130, height: 100)
      case youtubeCollectionView:
         return CGSize(width: 160, height: 90)
      default:
         print("Fail Select collectionView in UICollectionViewDelegateFlowLayout")
      }
      return CGSize()
   }
}




//MARK: - UITableView Delegate, DataSource Methods
extension MovieDetailViewController: UITableViewDelegate, UITableViewDataSource {
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return 3
   }
   
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = commentTableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
      
      return cell
   }
   
   
}


























