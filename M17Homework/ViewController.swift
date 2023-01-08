//
//  ViewController.swift
//  M17Homework
//
//  Created by Александра Угольнова on 04.12.2022.
//

import UIKit
import SnapKit
import Alamofire

class ViewController: UIViewController {
    
    let service = Service()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: CGRect(x: 220, y: 220, width: 140, height: 140))
        return view
    }()
    
    private let imageURLs = [
        "https://images.unsplash.com/photo-1504595403659-9088ce801e29?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=987&q=80",
        "https://images.unsplash.com/photo-1560743641-3914f2c45636?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=987&q=80",
        "https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=994&q=80",
        "https://images.unsplash.com/photo-1583511655826-05700d52f4d9?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=988&q=80",
        "https://images.unsplash.com/photo-1629740067905-bd3f515aa739?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=988&q=80"
    ]
    
    private var images = [UIImage]()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillEqually
        view.spacing = 20
        return view
    }()
    
    private lazy var downloadedImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        onLoad()
    }
    
    
    private func setupViews(){
        view.addSubview(stackView)
        stackView.snp.makeConstraints{make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.left.right.equalToSuperview()
        }
        stackView.addArrangedSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    private func onLoad() {
        let dispatchGroup = DispatchGroup()
        for _ in 0...4{
            dispatchGroup.enter()
            service.getImageURL { urlString, error in
                guard
                    let urlString = urlString
                else {
                    return
                }
                
                guard let image = self.service.loadImage(urlString: urlString) else {return}
  //              self.imageView.image = image
                self.images.append(image)

                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main){ [weak self] in
            guard let self = self else {return}
            self.activityIndicator.stopAnimating()
            self.stackView.removeArrangedSubview(self.activityIndicator)
            for i in 0...4{
                let img = UIImageView()
                img.contentMode = .scaleAspectFit
                img.image = self.images[i]
                self.stackView.addArrangedSubview(img)
            }
            
        }
    }
    
    
    private func asyncGroup(){
        let dispatchGroup = DispatchGroup()
        
       for i in 0...4{
            dispatchGroup.enter()
            asyncLoadImage(imageURL: URL(string: imageURLs[i])!,
                           runQueue: DispatchQueue.global(),
                           completionQueue: DispatchQueue.main)
            {
                result, error in
                guard let image1 = result else {return}
  //              self.images.append(image1)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main){ [weak self] in
            guard let self = self else {return}
            self.activityIndicator.stopAnimating()
            self.stackView.removeArrangedSubview(self.activityIndicator)
            for i in 0...4{
 //               self.addImage(data: self.images[i])
            }
            
        }
        
    }
    
    
}

    private extension ViewController{
        func asyncLoadImage(
            imageURL: URL,
            runQueue: DispatchQueue,
            completionQueue: DispatchQueue,
            completion: @escaping (Data?, Error?) -> ()
        ){
            runQueue.async {
                do{
                    let data = try Data(contentsOf: imageURL)
                    // sleep(arc4random() % 4)
                    completionQueue.async { completion(data, nil)}
                } catch let error {
                    completionQueue.async { completion(nil, error) }
                }
            }
        }
        
        func addImage(data: Data){
            let view = UIImageView(image: UIImage(data: data))
            view.contentMode = .scaleAspectFit
            self.stackView.addArrangedSubview(view)
        }
    }

