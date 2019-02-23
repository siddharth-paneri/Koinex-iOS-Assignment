//
//  KoinListViewController.swift
//  Koinex
//
//  Created by Siddharth Paneri on 22/02/19.
//  Copyright © 2019 Koinex. All rights reserved.
//

import UIKit

class KoinListViewController: SuperViewController {

    //MARK:-
    @IBOutlet weak var tableView: UITableView!
    //MARK:-
    /** Koin list view model */
    var koinListViewModel: KoinListViewModel = KoinListViewModel()
    /** Selected koin, string because the order in the API may change */
    var selectedKoin: String?
    
    /** refresh control to be used for pull to refresh */
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        rc.tintColor = UIColor.white
        return rc
    }()
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup table view
        setupTableView()
        self.title = "KOINEX"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // setup observers
        setupViewModelObservers()
        // fetch data from view model
        fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // setup bar button for currency selection
        self.setupBarButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // remove observers since view wil no more be active
        removeViewModelObservers()
    }
    
    //MARK:- SETUP VIEW
    
    /** Setup bar button for currency selection */
    private func setupBarButton() {
        if self.navigationItem.rightBarButtonItem == nil {
            let rightBarButtonItem = UIBarButtonItem(title: koinListViewModel.currency.value, style: .plain, target: self, action: #selector(currencyButtonTapped))
            self.navigationItem.rightBarButtonItem = rightBarButtonItem
        }
    }
    
    /** Setup tableView */
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        // add refresh control to tableview
        tableView.addSubview(refreshControl)
    }
    
    //MARK:- UPDATE VIEW
    
    /** Update view model currency type */
    private func updateCurrenyType() {
        // switch the currency when tapped
        if koinListViewModel.currency == .inr {
            koinListViewModel.currency = .tusd
        } else {
            koinListViewModel.currency = .inr
        }
        
        //TODO:- we can support multiple currencies, we need a picker for this feature in future.
        
    }

    /** Refresh UI when required */
    private func refreshUI() {
        self.navigationItem.rightBarButtonItem?.title = koinListViewModel.currency.value
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }

    //MARK:- ADD/REMOVE OBSERVERS
    
    /** Setup view model observers */
    private func setupViewModelObservers() {
        print(#function)
        // this block will be execured when view model is updated
        koinListViewModel.didUpdate = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                print("refresh UI")
                strongSelf.refreshUI()
            }
        }
        
        // this block will be executed when view model fails to load data
        koinListViewModel.didFail = { [weak self] (koinError) in
            guard let error = koinError else {
                return
            }
            guard let strongSelf = self else {
                return
            }
            let tupple = error.tupple
            strongSelf.showError(withTitle: tupple.title, message: tupple.message)
        }
    }
    
    /** Remove view model observers */
    private func removeViewModelObservers() {
        koinListViewModel.didUpdate = nil
        koinListViewModel.didFail = nil
    }
    
    //MARK:-
    
    /** Fetch data from view model */
    private func fetchData() {
        koinListViewModel.fetchKoins()
    }

    //MARK:- ACTIONS
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        // fetch latest data
        fetchData()
    }
    
    /** Action for currency bar button */
    @objc private func currencyButtonTapped() {
        self.updateCurrenyType()
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            if identifier == "KoinStats" {
                guard let selectedValue = selectedKoin else {
                    return
                }
                guard let destination = segue.destination as? KoinStatsViewController else {
                    return
                }
                // assign koin  and list view model to KoinStatsViewControlle
                destination.selectedKoin = selectedValue
                destination.koinListViewModel = koinListViewModel
                
                //TODO:- we have assigned full list to KoinStatsViewController and not a specific view model so we can get polling updates on that screen as well, in future we have to implement websockets and pass just the view model that is required for stats
                
            }
        }
    }
}

//MARK:- UITableViewDelegate & UITableViewDataSource
extension KoinListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return koinListViewModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "KoinCell", for: indexPath) as? KoinCell else {
            return UITableViewCell(frame: CGRect.zero)
        }
        if let viewModel = koinListViewModel.koinViewModel(at: indexPath.row) {
            // configure cell
            cell.configureCell(with: viewModel)
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewModel = koinListViewModel.koinViewModel(at: indexPath.row) {
            selectedKoin = viewModel.shortName
            // perform segue and open KoinStats
            performSegue(withIdentifier: "KoinStats", sender: self)
        }
    }
    
}


//MARK:-
class KoinCell: UITableViewCell {
    @IBOutlet weak var label_KoinName: UILabel!
    @IBOutlet weak var label_KoinPrice: UILabel!
    
    /** Configure cell based on given view model */
    func configureCell(with viewModel: KoinViewModel) {
        
        // set attributed string in labels
        let nameAttributedText = NSMutableAttributedString()
        let shortAttr = NSAttributedString(string: viewModel.shortName, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: Theme.FontSize.large.rawValue, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.white])
        let fullAttr = NSAttributedString(string: "\n\(viewModel.name)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: Theme.FontSize.medium.rawValue, weight: .thin), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        nameAttributedText.append(shortAttr)
        nameAttributedText.append(fullAttr)
        label_KoinName.attributedText = nameAttributedText
        
        let priceAttributedText = NSMutableAttributedString()
        let priceAttr = NSAttributedString(string: viewModel.formattedPrice, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: Theme.FontSize.large.rawValue, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.white])
        let perChangeAttr = NSAttributedString(string: "\n\(viewModel.formattedPercentageChange)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: Theme.FontSize.medium.rawValue, weight: .medium), NSAttributedString.Key.foregroundColor: viewModel.color])
        priceAttributedText.append(priceAttr)
        priceAttributedText.append(perChangeAttr)
        label_KoinPrice.attributedText = priceAttributedText
    }
}
