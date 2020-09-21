//
//  HomePageViewController.swift
//  iROID_Test
//
//  Created by Athira on 18/09/20.
//  Copyright © 2020 iOS. All rights reserved.
//

import UIKit
import ImageSlideshow

class HomePageViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    var bannersArray : [Banner]!
    var categoriesArray : [Category]!
    var freshProductsArray : [FreshProduct]!

    @IBOutlet weak var categoryListCollectionView: UICollectionView!
    @IBOutlet weak var newProductsCollectionView: UICollectionView!
    @IBOutlet weak var slideshow: ImageSlideshow!
    

    let localSource = [BundleImageSource(imageString: "img1"), BundleImageSource(imageString: "img2"), BundleImageSource(imageString: "img3"), BundleImageSource(imageString: "img4")]
    
    //MARK: - ViewDidload
    //---------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPageDetails()
        
        slideshow.slideshowInterval = 5.0
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill

        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.black
        slideshow.pageIndicator = pageControl

        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    //MARK:- CollectionView Delegate
    //-------------------------------

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryListCollectionView{
            return categoriesArray.count
        }else{
            return freshProductsArray.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let categoryCell : CategoryListCollectionViewCell
        let newProductCell : NewProductsListCollectionViewCell

        if collectionView == categoryListCollectionView{
            categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryListCollectionViewCell", for: indexPath) as! CategoryListCollectionViewCell
            categoryCell.layer.borderWidth = 0.5
            categoryCell.layer.borderColor = UIColor.lightGray.cgColor
            let imageUrl = URL(string: categoriesArray[indexPath.row].image)
            if imageUrl != nil{
                let imageData = try? Data(contentsOf: imageUrl!)
                categoryCell.categoryIconImageView.image = UIImage(data: imageData!)
            }
            categoryCell.categoryTitleLabel.text = categoriesArray[indexPath.row].name
            return categoryCell
        }else{
            newProductCell = collectionView.dequeueReusableCell(withReuseIdentifier: "newProductsListCollectionViewCell", for: indexPath) as! NewProductsListCollectionViewCell
            let imageUrl = URL(string: freshProductsArray[indexPath.row].image)
            if imageUrl != nil{
                let imageData = try? Data(contentsOf: imageUrl!)
                newProductCell.productImageView.image = UIImage(data: imageData!)
            }
            newProductCell.productTitleLabel.text = freshProductsArray[indexPath.row].name
            newProductCell.productPriceLabel.text = "₹ " +  freshProductsArray[indexPath.row].price

            return newProductCell
        }
        

    }
    
    
    //MARK:- API Calling for Fetch Home Details
    //------------------------------------------
    
    func getPageDetails()
    {
        APIHandler.sharedInstance.doAPIPostCallForMethodGET(APIHandler.Constants.apiUrl, view: self.view, authorization: "" , callback:  { [weak self] (success, responseDict, error) in
            guard let _ = self else{return  }
                let resultStatus = "\(String(describing: responseDict["status"]!))"
                switch resultStatus
                {
                    case "success":
                        do
                        {
                            let jsonData = try? JSONSerialization.data(withJSONObject: responseDict, options: .prettyPrinted)
                            if let homePageResponseModel = try? JSONDecoder().decode(HomePageResponseModel.self,from:jsonData!)
                            {
                                self!.bannersArray           =      homePageResponseModel.data.banners
                                self!.categoriesArray        =      homePageResponseModel.data.categories
                                self!.freshProductsArray     =      homePageResponseModel.data.freshProducts
                                
                                self!.sliderShowLoadImage()

                                if self!.categoriesArray.count != 0{
                                    self!.categoryListCollectionView.dataSource = self
                                    self!.categoryListCollectionView.delegate = self
                                    self!.categoryListCollectionView.reloadData()
                                }
                                if self!.freshProductsArray.count != 0{
                                    self!.newProductsCollectionView.dataSource = self
                                    self!.newProductsCollectionView.delegate = self
                                    self!.newProductsCollectionView.reloadData()
                                }
                                print("1111111111")
                                print(self!.bannersArray)
                                print(self!.freshProductsArray)
                                print("1111111111")

                            }
                        
                        } catch
                        {
                            print(error.localizedDescription)
                        }
                        break
                    case "failed":
                      //  self?.alertCalling(title: "", message: (String(describing: responseDict["message"]!)))
                        break
                    case "2":
                        switch (String(describing: responseDict["message"]!))
                        {
                        case "Please check your internet connection":
                            let alert = UIAlertController(title: "", message: "Please check your internet connection", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler:
                            {
                            action in
                                self!.getPageDetails()
                            }))
                            self!.present(alert, animated: true, completion: nil)
                            break
                        case "Time Out" :
                           // self?.alertCalling(title: "", message: (String(describing: responseDict["message"]!)))
                            break
                        case "Internal Server Error":
                           // self?.alertCalling(title: "", message: (String(describing: responseDict["message"]!)))
                            break
                        default:
                            break
                        }
                     break
                        default:
                        break
                        }
                })
    }
    
    //MARK: - Banner SlideShow
    func sliderShowLoadImage(){
        
        let afNetworkingSource = [AFURLSource(urlString: bannersArray[0].image)!, AFURLSource(urlString: bannersArray[1].image)!, AFURLSource(urlString:bannersArray[2].image)!]
        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        slideshow.setImageInputs(afNetworkingSource)
    }
}
extension HomePageViewController: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}
