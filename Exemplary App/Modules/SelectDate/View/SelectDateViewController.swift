//
//  SelectDateViewController.swift
//  Exemplary App
//
//  Created by Герман Иванилов on 28/10/2021.
//

import UIKit
import SnapKit

enum DateButtonChosen {
    case today, tomorrow, noDate, other
}

protocol SelectDateViewInput: AnyObject {
    func setCalendarDate(_ date: Date?)
    func setDateButtonChosen(_ choosen: DateButtonChosen)
    func setTimeButtonTitle(with text: String?)
    func showTimePicker(withRemoveButton: Bool)
}

class SelectDateViewController: UIViewController {
    
    var output: SelectDateViewOutput!
    
    private var buttonStackView = UIStackView()
    private var calendar = CalendarView()
    private var todayButton = ToggleButton()
    private var tomorrowButton = ToggleButton()
    private var noDateButton = ToggleButton()
    private var twoButtonBar = TwoButtonBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupLayout()
        
        output.viewIsReady()
    }
    
    private func setupViews() {
        view.backgroundColor = Theme.currentTheme.color.white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        buttonStackView.spacing = 10
        buttonStackView.axis = .vertical
        buttonStackView.distribution = .fill
        buttonStackView.alignment = .fill
        buttonStackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        buttonStackView.isLayoutMarginsRelativeArrangement = true
        
        calendar.delegate = self
        
        [todayButton, tomorrowButton, noDateButton].forEach { view in
            view.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            view.isChosen = false
        }
        
        todayButton.styledText = R.string.localizable.commonToday()
        tomorrowButton.styledText = R.string.localizable.commonTomorrow()
        noDateButton.styledText = R.string.localizable.commonNoDate()
        twoButtonBar.leftButton.styledText = R.string.localizable.selectDateButtonTitleAddTime()
        twoButtonBar.rightButton.styledText = R.string.localizable.commonSave()
        
        twoButtonBar.rightButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        twoButtonBar.leftButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    private func setupLayout() {
        view.addSubview(calendar)
        view.addSubview(buttonStackView)
        view.addSubview(twoButtonBar)
        
        buttonStackView.addArrangedSubview(todayButton)
        buttonStackView.addArrangedSubview(tomorrowButton)
        buttonStackView.addArrangedSubview(noDateButton)
        
        calendar.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(Constants.mediumMargin)
            make.trailing.equalToSuperview().offset(-Constants.mediumMargin)
            make.height.equalTo(260)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(calendar.snp.bottom).offset(Constants.smallMargin)
        }
        
        [todayButton, tomorrowButton, noDateButton].forEach { view in
            view.snp.makeConstraints { make in
                make.height.equalTo(40)
            }
        }
        
        twoButtonBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(buttonStackView.snp.bottom).offset(Constants.smallMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        switch sender {
        case todayButton:
            output.didTapToday()
        case tomorrowButton:
            output.didTapTomorrow()
        case noDateButton:
            output.didTapNoDate()
        case twoButtonBar.rightButton:
            output.didTapSave()
        case twoButtonBar.leftButton:
            output.didTapTime()
        default: break
        }
    }
}

extension SelectDateViewController: SelectDateViewInput {
    func setCalendarDate(_ date: Date?) {
        calendar.selectedDay = date
    }
    
    func setDateButtonChosen(_ chosen: DateButtonChosen) {
        [todayButton, tomorrowButton, noDateButton].forEach { button in
            button.isChosen = false
        }
        switch chosen {
        case .today:
            todayButton.isChosen = true
        case .tomorrow:
            tomorrowButton.isChosen = true
        case .noDate:
            noDateButton.isChosen = true
        case .other: break
        }
    }
    
    func setTimeButtonTitle(with text: String?) {
        twoButtonBar.leftButton.styledText = text ?? R.string.localizable.selectDateButtonTitleAddTime()
    }
    
    func showTimePicker(withRemoveButton: Bool) {
        let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alertView.view.tintColor = Theme.currentTheme.color.mainAccent
        
        let datePicker: UIDatePicker = UIDatePicker()
        
        datePicker.timeZone = .current
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .time
        
        let cancelActionTitle = withRemoveButton ?
        R.string.localizable.commonRemove() :
        R.string.localizable.commonCancel()
        
        let cancelAction = UIAlertAction(
            title: cancelActionTitle,
            style: .default) { [weak self] _ in
                if withRemoveButton {
                    self?.output.didRemoveTime()
                }
            }
        
        let okAction = UIAlertAction(
            title: R.string.localizable.commonOk(),
            style: .default) { [weak self] _ in
                self?.output.didChangeTime(newTime: datePicker.date)
            }
        
        alertView.view.addSubview(datePicker)
        alertView.addAction(cancelAction)
        alertView.addAction(okAction)
        
        datePicker.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(250)
        }
        
        alertView.view.snp.makeConstraints { make in
            make.height.equalTo(280)
        }
        
        present(alertView, animated: true)
    }
}

extension SelectDateViewController: CelendarViewDelegate {
    func didChangeDate(_ date: Date) {
        output.didChangeDay(newDay: date)
    }
}