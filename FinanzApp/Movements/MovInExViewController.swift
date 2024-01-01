//
//  ChartInExViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 07/12/23.
//

import UIKit

enum ScrollDirectionMovements{
    case goingLeft
    case goingRight
}

protocol RootPageProtocolMovements : AnyObject{
    func currentPage(_ index : Int)
    func scrollDetails(direction : ScrollDirection, percent: CGFloat , index: Int)
}

class MovInExViewController: UIPageViewController {
    
    
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
        if let incomeNavController = storyboard?.instantiateViewController(withIdentifier: "IncomeNavigationController") as? UINavigationController,
                   let expenseNavController = storyboard?.instantiateViewController(withIdentifier: "ExpenseNavigationController") as? UINavigationController {
                    
                    incomeNavController.view.tag = 0
                    expenseNavController.view.tag = 1
                    
                    subViewControllers = [incomeNavController, expenseNavController]
                    
                    setViewControllers([subViewControllers[0]], direction: .forward, animated: true, completion: nil)
                }
        
        
    }
    
    
    func setViewControllersFromIndexMov(index: Int, direction: NavigationDirection, animated: Bool = true) {
            setViewControllers([subViewControllers[index]], direction: direction, animated: animated)
        }
    
    private func setScrollViewDelegate() {
        for view in view.subviews where view is UIScrollView {
            let scrollView = view as? UIScrollView
            scrollView?.isScrollEnabled = false 
            scrollView?.delegate = self
        }
    }
    
}

extension MovInExViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = subViewControllers.firstIndex(of: viewController), viewControllerIndex > 0 else {
                return nil
            }
            return subViewControllers[viewControllerIndex - 1]
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = subViewControllers.firstIndex(of: viewController), viewControllerIndex < subViewControllers.count - 1 else {
                return nil
            }
            return subViewControllers[viewControllerIndex + 1]
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed, let visibleViewController = pageViewController.viewControllers?.first, let index = subViewControllers.firstIndex(of: visibleViewController) {
                currentIndex = index
                delegateRoot?.currentPage(currentIndex)
            }
        }
    
    
}


extension MovInExViewController : UIScrollViewDelegate{
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
