//
//  AdviceViewController.swift
//  FinanzApp
//
//  Created by Uriel Candia on 16/12/23.
//

import UIKit

class AdvicePageViewController: UIPageViewController, UIPageViewControllerDataSource {

    lazy var orderedViewControllers: [UIViewController] = {
        return [Advice1ViewController(),
                Advice2ViewController(),
                Advice3ViewController()]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self

        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }

    // MARK: UIPageViewControllerDataSource methods

    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
                return nil
            }

            let previousIndex = viewControllerIndex - 1
            if previousIndex < 0 {
                // Si es el primer controlador, regresa al último
                return orderedViewControllers.last
            } else {
                // De lo contrario, regresa al controlador anterior
                return orderedViewControllers[previousIndex]
            }
        }

        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
                return nil
            }

            let nextIndex = viewControllerIndex + 1
            if nextIndex >= orderedViewControllers.count {
                // Si es el último controlador, regresa al primero
                return orderedViewControllers.first
            } else {
                // De lo contrario, regresa al controlador siguiente
                return orderedViewControllers[nextIndex]
            }
        }

    // Puedes implementar otros métodos de UIPageViewControllerDataSource y UIPageViewControllerDelegate si es necesario
}
