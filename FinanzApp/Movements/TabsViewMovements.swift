//
//  TabsViewMovements.swift
//  FinanzApp
//
//  Created by Uriel Candia on 08/12/23.
//

import UIKit

protocol TabsViewProtocolMovements : AnyObject{
    func didSelectedOptionMov(index : Int)
}

class TabsViewMovements: UIView {

    
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
        
        collection.register(UINib(nibName:"\(OptionCellMovements.self)", bundle: nil), forCellWithReuseIdentifier: "\(OptionCellMovements.self)")
        
        return collection
    }()
    
    var selectedIndex : IndexPath = IndexPath(item: 0, section: 0)
    
    required init? (coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        configCollectionView()
    }
    
    override init(frame : CGRect){
        super.init(frame: frame)
    }
    
    private var options: [String] = []
    weak private var delegate : TabsViewProtocolMovements?
    
    func buildView(delegate: TabsViewProtocolMovements, options : [String]){
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

extension TabsViewMovements : UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(OptionCellMovements.self)", for: indexPath) as? OptionCellMovements else{
            return UICollectionViewCell()
        }
        if indexPath.row == 0 {
            cell.highlightTitle(.white)
            cell.colorBackground(UIColor(named: "SelectedTab")!)
        }else{
            cell.isSelected = (selectedIndex.item == indexPath.row)
        }
        cell.configCell(option: options[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        delegate?.didSelectedOptionMov(index: indexPath.item)
    }
}

extension TabsViewMovements : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let label = UILabel()
        label.text = options[indexPath.item]
        label.font = UIFont.systemFont(ofSize: 11)
        
        let extraPadding : CGFloat = 30
        
        return CGSize(width: label.intrinsicContentSize.width+extraPadding, height: frame.height)
    }
}
