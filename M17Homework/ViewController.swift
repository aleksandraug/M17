//
//  ViewController.swift
//  M17Homework
//
//  Created by Александра Угольнова on 04.12.2022.
//

import UIKit
import SnapKit


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
    
    
    
}

