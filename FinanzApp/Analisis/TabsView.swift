//
//  TabsView.swift
//  FinanzApp
//
//  Created by Uriel Candia on 07/12/23.
//

import Foundation
import UIKit

protocol TabsViewProtocol : AnyObject{
    func didSelectedOption(index : Int)
}

class TabsView : UIView{
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collection = UICollectionView(frame: frame, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collection.translatesAutoresizingMaskIntoConstraints = false
 
        
        
        collection.register(UINib(nibName: "\(OptionCell.self)", bundle: nil),forCellWithReuseIdentifier: "\(OptionCell.self)")
        
        
        return collection
    }()
    
    var selectedItem : IndexPath = IndexPath(item: 0, section: 0)
    
    
    
    required init? (coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        configCollectionView()
    }
    
    override init(frame : CGRect){
        super.init(frame: frame)
    }
    
    
    
    private var options: [String] = []
    weak private var delegate : TabsViewProtocol?
    
    func buildView(delegate: TabsViewProtocol, options : [String]){
        self.delegate = delegate
        self.options = options
        collectionView.reloadData()
    }
    
    private func configCollectionView(){
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
}

extension TabsView: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(OptionCell.self)", for: indexPath) as? OptionCell else{
            return UICollectionViewCell()
        }
        if indexPath.row == 0 {
            cell.highlightTitle(.white)
            cell.colorBackground(UIColor(named: "SelectedTab")!)
        }else{
            cell.isSelected = (selectedItem.item == indexPath.row)
        }
        cell.configCell(option: options[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        delegate?.didSelectedOption(index: indexPath.item)
    }
    
}

extension TabsView : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let label = UILabel()
        label.text = options[indexPath.item]
        label.font = UIFont.systemFont(ofSize: 11)
        
        let extraPadding : CGFloat = 30
        
        return CGSize(width: label.intrinsicContentSize.width+extraPadding, height: frame.height)
    }
}
