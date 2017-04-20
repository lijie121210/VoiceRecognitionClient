//
//  MainViewController.swift
//  VGClient
//
//  Created by viwii on 2017/4/14.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK - Outlet
    
    /// 背景图片
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    /// 表示正在聆听的按钮
    @IBOutlet weak var listeningButton: PulsingHaloButton!
    
    /// 主滚动视图
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var measurementContainer: UIView!
    
    /// 切换大棚按钮
    @IBOutlet weak var housesContainer: RectCornerView!
    
    @IBOutlet weak var housesButton: UIButton!
    
    /// 设置按钮
    @IBOutlet weak var settingContainer: RectCornerView!
    
    @IBOutlet weak var settingButton: UIButton!
    
    /// 刷新
    @IBOutlet weak var refreshContainer: RectCornerView!
   
    @IBOutlet weak var refreshButton: UIButton!
    
    
    /// 监测数据显示
    @IBOutlet weak var measurementInfoLabel: UILabel!
    
    @IBOutlet weak var measurementCollectionView: UICollectionView!

    @IBOutlet weak var measurementRefreshContainer: RectCornerView!
    
    @IBOutlet weak var measurementRefresh: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /// 绘图显示
    @IBOutlet weak var curveContainer: UIView!
    
    @IBOutlet weak var curveInfoLabel: UILabel!
    
    @IBOutlet weak var analysisContainer: RectCornerView!
    
    @IBOutlet weak var analysisButton: UIButton!
    
    @IBOutlet weak var chartContainer: RectCornerView!
    
    @IBOutlet weak var chartTitleLabel: UILabel!
    
    @IBOutlet weak var chartPromptLabel: UILabel!
    
    @IBOutlet weak var lineChart: LineChartView!
    
    
    /// 附件操作与显示
    @IBOutlet weak var accessoryContainer: UIView!
    
    @IBOutlet weak var accessoryLabel: UILabel!
    
    @IBOutlet weak var accessoryEditContainer: RectCornerView!

    @IBOutlet weak var accessoryEditButton: UIButton!
    
    @IBOutlet weak var accessoryAddContainer: RectCornerView!
    
    @IBOutlet weak var accessoryAddButton: UIButton!
    
    @IBOutlet weak var accessoryCollectionView: UICollectionView!
    
    
    // MARK - Properties
    
    var isShowingViewController: Bool = false
    
    var latestMeasurements: [MeasurementData] {
        return MeasurementManager.default.dataSource.latest
    }
    
    
    // MARK - View controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// `Note`: 一定要在layout之前设置代理.
        ///
        /// 用于计算每个cell的高度.
        if let layout = accessoryCollectionView.collectionViewLayout as? AlternateLayout {
            layout.delegate = self
        }
        
        /// Register MeasurementCCell.xib
        measurementCollectionView.register(MeasurementCCell.nib, forCellWithReuseIdentifier: MeasurementCCell.reuseid)
        accessoryCollectionView.register(AccessoryCell.nib, forCellWithReuseIdentifier: AccessoryCell.reuseid)
        accessoryCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        
        /// Read Settings
        updateViewFromSettings()
        
        /// Default status
        initialViewStatus()
    }
    
    /// 这些方法都可能调用多次
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        
        /// 显示了其他视图后返回该页面，什么也不需要做
        if isShowingViewController {
            return
        }
        
        measurementRefreshContainer.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        /// 显示了其他视图后返回该页面，改变标记。
        if isShowingViewController {
            isShowingViewController = false
            return
        }
        
        /// 加载数据
        loadData(before: beforeLoading, after: afterLoading)
        
        /// 接受开始录音的通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(recordDidBegin),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// 移除接受通知
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIApplicationWillEnterForeground,
                                                  object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    
    // MARK: - Views
    
    func initialViewStatus() {
        measurementInfoLabel.text = "环境状态"
        measurementRefresh.setTitle("载入错误，再试一次", for: .normal)
        curveInfoLabel.text = "最近变化曲线"
        chartTitleLabel.text = " -- "
        chartPromptLabel.text = "无数据"
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        /// 准备 编辑／添加 设备
        if let des = segue.destination as? AccessoryViewController {
            /// 设置控制器代理
            des.delegate = self
            /// 添加
            guard
                let id = segue.identifier, id == "Accessory",
                let sender = sender as? [String:Any],
                let editing = sender["editing"] as? Bool, editing == true else {
                    return
            }
            des.currentIndexPath = sender["indexPath"] as? IndexPath
            des.currentAccessory = sender["data"] as? AccessoryData
        }
        
        /// 注册为设置界面的代理
        if let id = segue.identifier, id == "Setting", let des = segue.destination as? SettingViewController {
            des.delegate = self
        }
        
        if let id = segue.identifier, id == "Listen", let des = segue.destination as? ListenViewController {
            des.delegate = self
        }
    }
    
    
    // MARK: - User Interaction
    
    @IBAction func didTapHouses(_ sender: Any) {
        warning(duration: 2.0, message: "只有一个大棚，无法切换")
    }
    
    @IBAction func didTapSetting(_ sender: Any) {
        /// segue Setting
    }
    
    /// 刷新按钮
    @IBAction func didTapRefresh(_ sender: Any) {
        loadData(before: beforeRefresh, after: afterLoading)
    }
    
    /// 重试按钮
    @IBAction func didTapMeasurementRefresh(_ sender: Any) {
        loadData(before: beforeLoading, after: afterLoading)
    }
    
    @IBAction func didTapAnalysis(_ sender: Any) {
        /// segue Analysis
        isShowingViewController = true
    }
    
    @IBAction func didTapAccessoryEditButton(_ sender: Any) {
        /// 开始编辑
        let startEditing = {
            self.isEditing = true
            self.accessoryAddButton.isEnabled = false
            self.accessoryEditButton.setImage(UIImage(named: "done"), for: .normal)
            
            /// 除了在这里修改，还要在CollectionView数据源代理方法里面做判断
            self.accessoryCollectionView.visibleCells.forEach { $0.alpha = 0.6 }
        }
        /// 编辑完成
        let endEditing = {
            self.isEditing = false
            self.accessoryAddButton.isEnabled = true
            self.accessoryEditButton.setImage(UIImage(named: "edit"), for: .normal)
            self.accessoryCollectionView.visibleCells.forEach { $0.alpha = 1.0 }
        }
        
        isEditing ? endEditing() : startEditing()
    }
    
    @IBAction func didTapAccessoryAddButton(_ sender: Any) {
        /// segue Accessory
    }
    
    
    // MARK: - Helper

    /// 跳转申请权限的界面
    func requestPermission() {
        guard let authority = UIStoryboard(name: "Authority", bundle: nil).instantiateInitialViewController() else {
            return
        }
        show(authority, sender: nil)
    }
    
    /// 开始录音时广播通知的回调函数
    /// 之所以使用通知是因为，一旦应用进入一次后台，再打开，波纹效果就不见了，只能每次都添加。
    @objc func recordDidBegin() {
        listeningButton.pulsing()
    }
    
    
    /// 可以显示视图了，首先加载数据
    /// - parameter before: 请求前执行的代码
    /// - parameter after: 请求后执行的代码
    func loadData(before: () -> Void, after: @escaping (Bool) -> Void) {
        before()
        MeasurementManager.default.initialLoading { (finish) in
            DispatchQueue.main.async {
                after(finish)
            }
        }
    }
    
    /// 请求前执行
    func beforeLoading() {
        measurementRefreshContainer.isHidden = false
        measurementRefreshContainer.removeShadow()
        measurementRefreshContainer.fillColor = .clear
        measurementRefresh.setTitle("载入数据", for: .normal)
        measurementRefresh.isEnabled = false
        activityIndicator.startAnimating()
    }
    func beforeRefresh() {
        OrbitAlertController.show(with: "载入数据", on: self)
    }
    
    /// 请求后执行
    func afterLoading(finish: Bool) {
        OrbitAlertController.dismiss()
        activityIndicator.stopAnimating()
        if latestMeasurements.isEmpty {
            measurementRefreshContainer.isHidden = false
            measurementRefreshContainer.addShadow()
            measurementRefreshContainer.fillColor = .white
            measurementRefresh.setTitle("载入错误，再试一次", for: .normal)
            measurementRefresh.isEnabled = true
        } else {
            measurementRefreshContainer.isHidden = true
            measurementCollectionView.reloadData()
        }

        /// 绘制曲线
        updateLineChartView()
    }
    
    /// 绘制全部曲线
    func updateLineChartView() {
        let data = MeasurementManager.default.dataSource.passiveCharts()
        
        lineChart.reloadView()

        if data.isEmpty {
            chartTitleLabel.text = " -- "
            chartPromptLabel.text = "无数据"
            chartPromptLabel.isHidden = false
        } else {
            chartTitleLabel.text = "综合"
            chartPromptLabel.text = nil
            chartPromptLabel.isHidden = true
            
            let lineChartView = lineChart.chart!
            
            config(lineChartView, config: data[0].config)
            
            data.forEach { (item) in
                lineChartView.addLine(item.columns.map { $0.value })
            }
        }
    }
    
    /// 绘制第`index`条曲线
    /// - parameter index: 指定曲线的数据索引。
    func updateLineChartView(index: Int) {
        guard let data = MeasurementManager.default.dataSource.passiveCharts(index: index) else {
            chartTitleLabel.text = " -- "
            chartPromptLabel.text = "无数据"
            chartPromptLabel.isHidden = false
            return
        }
        chartTitleLabel.text = data.mtype.textDescription
        chartPromptLabel.isHidden = true

        lineChart.reloadView()

        let labels = data.columns.map { $0.prompt }
        let lines = data.columns.map { $0.value }
        
        let lineChartView = lineChart.chart!
        
        config(lineChartView, config: data.config)
        
        lineChartView.x.labels.values = labels
        lineChartView.addLine(lines)
    }
    
    /// 配置参数
    func config(_ lineChartView: LineChart, config: PassiveChartData.Config) {
        lineChartView.animation.enabled = config.isAnimatable
        lineChartView.area = config.isArea
        lineChartView.x.labels.visible = config.isXLabelsVisible
        lineChartView.y.labels.visible = config.isYLabelsVisible
        lineChartView.x.grid.count = config.xGridCount
        lineChartView.y.grid.count = config.yGridCount
        lineChartView.colors = config.colors
        lineChartView.x.axis.inset = config.xAxisInset
        lineChartView.y.axis.inset = config.yAxisInset
    }
    
    /// 执行某项任务结束后，刷新数据源。
    func update(_ collectionView: UICollectionView, indexPaths:[IndexPath], orbit: OrbitAlertController?, after: DispatchTime = .now() + 1.0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            orbit?.update(prompt: "完成")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            orbit?.dismiss(animated: true, completion: nil)
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5, execute: {
            collectionView.performBatchUpdates({
                collectionView.reloadItems(at: indexPaths)
            }, completion: nil)
        })
    }
    
    
    // MARK: - SettingViewControllerDelegate
    
    /* 该界面可能更改设置，于是实现设置更改的代理人，可以接受在该页面更改设置时的通知.
     * 如果想得到在任何界面设置修改的通知，需要在通知中心注册
     */
    func setting(controller: SettingViewController, didChangeValueOf keyPath: String, to newValue: Any) {
        if keyPath == VGDefaultValue.KeyPath.isHiddenBackgroundImage, let isHidden = newValue as? Bool {
            updateViewFromSettings(isHidden: isHidden)
        }
        if keyPath == SettingViewControllerDidTapCheckRecordListKey {
            isShowingViewController = true
            performSegue(withIdentifier: "RecordList", sender: nil)
        }
    }
    
    func updateViewFromSettings(isHidden: Bool = VGDefaultValue.isHiddenBackgroundImage) {
        backgroundImageView.isHidden = isHidden
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard collectionView == accessoryCollectionView else { return }
        
        let i = indexPath.item
        
        var data = AccessoryManager.default.accessoryDatas[i]
        
        /// 编辑
        if collectionView == accessoryCollectionView, isEditing {
            performSegue(withIdentifier: "Accessory", sender: ["editing":true, "indexPath": indexPath, "data":data])
            return
        }
        
        /// 操作
        guard data.type.isSingleActionTypes else { return }
        
        ///
        
        let orbit = OrbitAlertController.show(with: "正在执行...", on: self)
        
        if data.state == .opened {
            data.state = .closed
        } else {
            data.state = .opened
        }
        
        ///
        
        AccessoryManager.default.accessoryDatas.replaceSubrange((i..<i+1), with: [data])
        
        ///
        
        update(accessoryCollectionView, indexPaths: [indexPath], orbit: orbit)
    }
    
    
    // MARK: - AccessoryCellDelegate
    
    ///  点击了三联操作的某个按钮
    func cell(_ cell: AccessoryCell, isTapped action: AccessoryAction) {
        
        guard let indexPath = accessoryCollectionView.indexPath(for: cell)else {
            return
        }
        
        let i = indexPath.item
        
        var data = AccessoryManager.default.accessoryDatas[i]
        
        ///
        
        guard !data.type.isSingleActionTypes else { return }
        
        ///
        
        let orbit = OrbitAlertController.show(with: "正在执行...", on: self)
        
        ///
        
        switch action {
        case .close: data.state = .closed
        case .stop: data.state = .stopped
        case .open,.timing(_): data.state = .opened
        }
        
        AccessoryManager.default.accessoryDatas.replaceSubrange((i..<i+1), with: [data])
        
        ///
        
        update(accessoryCollectionView, indexPaths: [indexPath], orbit: orbit)
    }
    
    
    
    // MARK: - AccessoryOperationDelegate
    
    func accessoryViewController(_ controller: AccessoryViewController, attemptToAdd data: AccessoryData) {
        guard AccessoryManager.default.insertAtFront(data) else {
            warning(duration: 2.0, message: "无法添加<\(data.name)>, 同名设备已存在")
            return
        }
        
        accessoryCollectionView.performBatchUpdates({
            self.accessoryCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
        }, completion: nil)
    }
    
    func accessoryViewController(_ controller: AccessoryViewController, attemptToEdit data: AccessoryData, at indexPath: IndexPath?) {
        guard let i = indexPath?.item else { return }
        
        guard AccessoryManager.default.replace(data, at: i) else {
            warning(duration: 2.0, message: "无法编辑<\(data.name)>, 同名设备已存在")
            return
        }
        
        accessoryCollectionView.performBatchUpdates({
            self.accessoryCollectionView.reloadItems(at: [indexPath!])
        }, completion: nil)
    }
    
    func accessoryViewController(_ controller: AccessoryViewController, attemptToDelete data: AccessoryData, at indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        
        guard AccessoryManager.default.remove(data) else {
            warning(duration: 2.0, message: "无法移除<\(data.name)>, 设备不存在")
            return
        }
        
        accessoryCollectionView.performBatchUpdates({
            self.accessoryCollectionView.deleteItems(at: [indexPath])
        }, completion: nil)
        
    }
    
    
    // MARK: - ListenViewControllerDelegate
    
    func listen(_ vc: ListenViewController, didRecognizedSpeech result: String) {
        vc.dismiss(animated: true) { 
            self.didRecognizedSpeech(result: result)
        }
    }
    
    // MARK: - UIScrollView Delegate
    
    /// 重新绘制曲线
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let mc = measurementCollectionView, scrollView == mc else { return }
        let point = CGPoint( x: mc.contentOffset.x + mc.frame.width * 0.5, y: mc.frame.height * 0.5)
        let cells = measurementCollectionView.visibleCells.filter { $0.frame.contains(point) }.first
        guard
            let cell = cells,
            let index = measurementCollectionView.indexPath(for: cell) else {
                return
        }
        updateLineChartView(index: index.item)
    }
    
    /// 整页滚动
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        guard self.scrollView == scrollView else { return }
        
        if velocity.y > 0.4 {
            targetContentOffset.pointee.y = accessoryContainer.frame.origin.y
        }
        if velocity.y < -0.4 {
            targetContentOffset.pointee.y = 0
        }
    }
}


extension MainViewController: SettingViewControllerDelegate, UICollectionViewDelegate, AccessoryCellDelegate, AccessoryOperationDelegate, ListenViewControllerDelegate { }

