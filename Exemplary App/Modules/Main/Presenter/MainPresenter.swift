//
//  MainPresenter.swift
//  Exemplary App
//
//  Created by Герман Иванилов on 29.08.2021.
//

import Foundation
import CoreStore

protocol MainViewOutput {
    func viewIsReady()
    func viewDidDisappear()
    func didTapAddButton()
    func didTapCell(at indexPath: IndexPath)
    func didTapDeleteCell(at indexPath: IndexPath)
    func didTapDoneCell(at indexPath: IndexPath)
    func didSwipeToLeft()
    func numberOfSections() -> Int
    func numberOfViewModels(in section: Int) -> Int
    func viewModel(at indexPath: IndexPath) -> Task
}

class MainPresenter {

    weak var view: MainViewInput?
    
    private let router: MainRouter.Routes
    private let service: MainService
        
    init(router: MainRouter.Routes, service: MainService) {
        self.router = router
        self.service = service
    }
}

extension MainPresenter: MainViewOutput {
    func viewIsReady() {
        service.monitor.addObserver(self)
        view?.reloadData()
    }
    
    func viewDidDisappear() {
    }
    
    func didTapAddButton() {
        router.openCreateTaskModule(mode: .create)
    }
    
    func didTapCell(at indexPath: IndexPath) {
        router.openCreateTaskModule(mode: .edit(task: service.viewModel(at: indexPath)))
    }
    
    
    func didTapDeleteCell(at indexPath: IndexPath) {
        service.removeTask(at: indexPath)
    }
    
    func didTapDoneCell(at indexPath: IndexPath) {
        service.updateTask(at: indexPath)
    }
    
    func didSwipeToLeft() {
        router.openCompletedTasksModule()
    }
    
    func numberOfSections() -> Int {
        1
    }
    
    func numberOfViewModels(in section: Int) -> Int {
        service.taskCount
    }
    
    func viewModel(at indexPath: IndexPath) -> Task {
        service.viewModel(at: indexPath)
    }
}

extension MainPresenter: ListObserver {
    typealias ListEntityType = Task

    func listMonitorDidChange(_ monitor: ListMonitor<Task>) {
        view?.reloadData()
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<Task>) {
        view?.reloadData()
    }
}
