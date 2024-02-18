//
//  ReportChartTableViewCell.swift
//  20231119_MoneyNote
//
//  Created by Yen Lin on 2023/12/4.
//

import UIKit
import Charts

class ReportChartTableViewCell: UITableViewCell, ChartViewDelegate {
    
    var pieChartView = PieChartView()
    
    var records = [CategoryType:Double]() {
        didSet {
            updateChartData()
        }
    }
    
    var chartDataEntry = [PieChartDataEntry]()
    
    var chartColors: [NSUIColor] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "\(ReportChartTableViewCell.self)")
        
        pieChartView.delegate = self
        
        for record in records {
            chartDataEntry.append(PieChartDataEntry(value: record.value, label: record.key.categoryName))
            print("***", record.value, record.key.categoryName)
        }
        
        setupUI()
        setupChartColor()
        showChartData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(pieChartView)
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pieChartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            pieChartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pieChartView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            pieChartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupChartColor() {
        // 為每個類別生成一個獨特的顏色
        for _ in 0..<chartDataEntry.count {
            let red = Double.random(in: 0...1)
            let green = Double.random(in: 0...1)
            let blue = Double.random(in: 0...1)
            let color = NSUIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
            chartColors.append(color)
        }
    }
    
    private func updateChartData() {
        chartDataEntry.removeAll()
        for record in records {
            chartDataEntry.append(PieChartDataEntry(value: record.value, label: record.key.categoryName))
        }
        showChartData()
    }
    
    private func showChartData() {
        
        let dataSet = PieChartDataSet(entries: chartDataEntry, label: "")
        dataSet.colors = ChartColorTemplates.colorful()
//        dataSet.colors = chartColors
        
        let pieChartData = PieChartData(dataSet: dataSet)
        pieChartView.data = pieChartData
        pieChartView.legend.enabled = false
        
        pieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }

}
