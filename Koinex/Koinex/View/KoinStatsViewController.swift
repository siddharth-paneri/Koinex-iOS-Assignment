//
//  KoinStatsViewControllerswift
//  Koinex
//
//  Created by Siddharth Paneri on 22/02/19.
//  Copyright © 2019 Koinex. All rights reserved.
//

import UIKit

class KoinStatsViewController: SuperViewController {

    //MARK:-
    @IBOutlet weak var label_Price: UILabel!
    @IBOutlet weak var label_PercentageChange: UILabel!
    @IBOutlet weak var tableView: UITableView!
    //MARK:-
    var koinListViewModel: KoinListViewModel!
    var selectedKoin: String!
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup UI
        setupInitialUIAttributes()
        setupTableView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = koinListViewModel.koinViewModel(with: selectedKoin)?.shortName
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.refreshUI()
        self.setupViewModelObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeViewModelObservers()
    }
    
    //MARK:- SETUP VIEW
    
    /** setup Tableview delegate and data sources */
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    /** setup intial attributes of UI*/
    private func setupInitialUIAttributes() {
        label_Price.font = UIFont.systemFont(ofSize: Theme.FontSize.xxLarge.rawValue, weight: .medium)
        label_PercentageChange.font = UIFont.systemFont(ofSize: Theme.FontSize.large.rawValue, weight: .medium)
        
        label_Price.textColor = UIColor.white
        label_PercentageChange.textColor = UIColor.white
    }
    
    //MARK:- ADD/REMOVE OBSERVERS
    /** Setup view model observers */
    func setupViewModelObservers() {
        // when viewmodel is updated this block will be called
        koinListViewModel.didUpdate = { [weak self] in
            // refresh ui
            guard let strongSelf = self else {
                return
            }
            strongSelf.refreshUI()
        }
        
        // wehn view model did fail to fetch latest data, this block will be called
        koinListViewModel.didFail = { [weak self] (koinError) in
            // show error
            guard let error = koinError else {
                return
            }
            guard let strongSelf = self else {
                return
            }
            let tupple = error.tupple
            // show respective message on UI
            strongSelf.showError(withTitle: tupple.title, message: tupple.message)
        }
    }
    
    /** Remove view model observers when required */
    private func removeViewModelObservers() {
        koinListViewModel.didUpdate = nil
        koinListViewModel.didFail = nil
    }
    
    //MARK:- UPDATE VIEW
    
    /** Refresh UI when required */
    private func refreshUI() {
        DispatchQueue.main.async { [weak self] in
            // return if we do not have a reference to self
            guard let strongSelf = self else {
                return
            }
            // get koin view model
            guard let koinViewModel = strongSelf.koinListViewModel.koinViewModel(with: strongSelf.selectedKoin) else {
                return
            }
            // update labels
            strongSelf.label_Price.text = koinViewModel.formattedPrice
            strongSelf.label_PercentageChange.text = koinViewModel.formattedPercentageChange
            strongSelf.label_PercentageChange.textColor = koinViewModel.color
        }
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension KoinStatsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = koinListViewModel.koinViewModel(with: selectedKoin) else {
            return 0
        }
        // return supported stats as count
        return viewModel.supportedStats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StatsCell", for: indexPath) as? StatsCell else {
            return UITableViewCell(frame: CGRect.zero)
        }
        if let viewModel = koinListViewModel.koinViewModel(with: selectedKoin) {
            // configure cell based on view model
            cell.configureCell(with: viewModel, index: indexPath.row)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


//MARK:-
class StatsCell: UITableViewCell {
    
    @IBOutlet weak var label_Stat: UILabel!
    @IBOutlet weak var label_StatValue: UILabel!
    
    override func awakeFromNib() {
        // setup view atributes when a cell is loaded
        label_Stat.textColor = UIColor.white
        label_StatValue.textColor = UIColor.white
        
        label_Stat.font = UIFont.systemFont(ofSize: Theme.FontSize.medium.rawValue, weight: .regular)
        label_StatValue.font = UIFont.systemFont(ofSize: Theme.FontSize.medium.rawValue, weight: .medium)
    }
    
    /** configure cell using view model and index */
    func configureCell(with viewModel: KoinViewModel, index: Int) {
        let stat = viewModel.supportedStats[index]
        label_Stat.text = stat.value
        label_StatValue.text = viewModel.valueFor(stat: stat)
    }
}
