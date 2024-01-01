//
//  ChartInExViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 07/12/23.
//

import UIKit

enum ScrollDirection{
    case goingLeft
    case goingRight
}

protocol RootPageProtocol : AnyObject{
    func currentPage(_ index : Int)
    func scrollDetails(direction : ScrollDirection, percent: CGFloat , index: Int)
}

class ChartInExViewController: UIPageViewController {
    
    
    var subViewControllers = [UIViewController]()
    var currentIndex : Int = 0
    
    weak var delegateRoot : RootPageProtocol?
    
    var startOffset : CGFloat = 0.0
    var currentPage : Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        delegateRoot?.currentPage(0)
        setupViewControllers()
        setScrollViewDelegate()
        
    }
    
    private func setupViewControllers (){
        subViewControllers = [
            IncomeChartViewController(),
            ExpenseChartViewController()
        ]
        
        
        _ = subViewControllers.enumerated().map({$0.element.view.tag = $0.offset})
        setViewControllersFromIndex(index: 0, direction: .forward)
        
        
    }
    
    
    func setViewControllersFromIndex(index: Int, direction: NavigationDirection, animated: Bool = true){
        setViewControllers([subViewControllers[index]], direction: direction, animated: animated)
    }
    
    private func setScrollViewDelegate(){
        guard let scrollView = view.subviews.filter({$0 is UIScrollView}).first as? UIScrollView else {return}
        scrollView.delegate = self
    }
    
}

extension ChartInExViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return subViewControllers.count
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = subViewControllers.firstIndex(of: viewController) ?? 0
        if index <= 0{
            return nil
        }
        return subViewControllers[index-1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = subViewControllers.firstIndex(of: viewController) ?? 0
        if index >= (subViewControllers.count-1){
            return nil
        }
        return subViewControllers[index+1]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let index = pageViewController.viewControllers?.first?.view.tag{
            currentIndex = index
            delegateRoot?.currentPage(index)
        }
    }
    
    
}


extension ChartInExViewController : UIScrollViewDelegate{
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startOffset = scrollView.contentOffset.x
    
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var direction = 0
        if startOffset < scrollView.contentOffset.x{
           direction = 1
        }else if startOffset > scrollView.contentOffset.x{
            direction = -1
        }
        let positionFromStartOfCurrentPage = abs(startOffset - scrollView.contentOffset.x)
        let percent = positionFromStartOfCurrentPage / self.view.frame.width
        
        delegateRoot?.scrollDetails(direction: (direction == 1) ? .goingRight : .goingLeft, percent: percent, index: currentPage)

        
    }
}
