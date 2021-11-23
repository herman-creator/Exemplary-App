//
//  MainViewController.swift
//  Exemplary App
//
//  Created by Герман Иванилов on 29.08.2021.
//

import UIKit
import SnapKit
import CoreStore

protocol MainViewInput: AnyObject {
    func reloadData()
}

class MainViewController: UIViewController {
        
    var output: MainViewOutput!
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupLayout()
        
        let swipeGestureRecognizerDown = UISwipeGestureRecognizer(
            target: self, action: #selector(didSwipeToLeft(_:)))
        swipeGestureRecognizerDown.direction = .left
        view.addGestureRecognizer(swipeGestureRecognizerDown)
        
        output.viewIsReady()
    }
    
    @objc
    private func didSwipeToLeft(_ sender: UISwipeGestureRecognizer){
        output.didSwipeToLeft()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        output.viewDidDisappear()
    }
    
    private func setupViews() {
        view.backgroundColor = Theme.currentTheme.color.white
        
        navigationItem.title = R.string.localizable.mainTitle()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddButton))
        
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.reuseIdentifier)
        tableView.rowHeight = TaskTableViewCell.height
        tableView.estimatedRowHeight = TaskTableViewCell.estimatedHeight
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceVertical = true
        tableView.dataSource = self
        tableView.delegate = self
        
        output.viewIsReady()
    }
    
    private func setupLayout() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
        }
    }
    
    @objc
    private func didTapAddButton(){
        output.didTapAddButton()
    }
}

extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return output.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return output.numberOfViewModels(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseIdentifier,
                                                 for: indexPath) as? TaskTableViewCell
        cell?.viewModel = output.viewModel(at: indexPath)
        return cell ?? UITableViewCell()
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, _ in
            self?.output.didTapDeleteCell(at: indexPath)
        }
        
        action.image = R.image.button_delete()?.withSize(width: 30, height: 30)
        action.backgroundColor = Theme.currentTheme.color.secondRedLight
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, _ in
            self?.output.didTapDoneCell(at: indexPath)
        }
        
        action.image = R.image.button_check()?.withSize(width: 30, height: 30)
        action.backgroundColor = Theme.currentTheme.color.mainAccentLight
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        output.didTapCell(at: indexPath)
    }
}

extension MainViewController: MainViewInput {
    func reloadData() {
        tableView.reloadData()
    }
}
