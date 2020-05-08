//
//  TrendingTabViewController.swift
//  NewsApp
//
//  Created by Microos on 2020/5/2.
//  Copyright © 2020 Yiliang Xie. All rights reserved.
//

import UIKit
import Charts

class TrendingTabViewController: UIViewController {


    //MARK: props
    private var dataPoints = [ChartDataEntry]()

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var chartView: LineChartView!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchTrendsDataAndUpdateChart(q: "Coronavirus")
        self.searchTextField.delegate = self
        self.setupTextFieldKeyboardDismissGesture()

    }

    func fetchTrendsDataAndUpdateChart(q: String) {
        resetChartData()
        TrendingAPI.requestTrendingData(q: q) { (res) in
            switch res {
            case .success(let arr):
                for (i, v) in arr.enumerated() {
                    self.dataPoints.append(ChartDataEntry(x: Double(i), y: v))
                }
                self.updateChart(q: q)
            case .failure(let err):
                self.errorToast("\(err)")
            }
        }
    }

    func updateChart(q: String) {
        if dataPoints.isEmpty {
            self.chartView.data = nil
            self.warningToast("No Search Results Found for \"\(q)\"")
            return
        }
        let lines = LineChartData()

        let line = LineChartDataSet(entries: self.dataPoints, label: "Trending Chart for \(q)")
        line.colors = [#colorLiteral(red: 0, green: 0.4679048657, blue: 0.911139071, alpha: 1)]
        line.circleColors = [#colorLiteral(red: 0, green: 0.4679048657, blue: 0.911139071, alpha: 1)]
        line.circleHoleRadius = 0
        line.circleRadius = 4.5
        lines.addDataSet(line)

        self.chartView.data = lines

    }
    func resetChartData() {
        self.dataPoints = [ChartDataEntry]()
    }
}

//MARK: input textfield
extension TrendingTabViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text, text.count > 0 {
            fetchTrendsDataAndUpdateChart(q: text)
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }

    func setupTextFieldKeyboardDismissGesture() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:))))
        self.chartView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:))))
    }

    @objc func dismissKeyboard(_ sender: Any?) {
        self.searchTextField.endEditing(true)
    }
}
