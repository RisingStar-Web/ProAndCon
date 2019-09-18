//
//  FinalViewController.swift
//  ProAndCon
//
//  Created by Роман Кабиров on 13.12.2017.
//  Copyright © 2017 Logical Mind. All rights reserved.
//

import UIKit

class FinalViewController: UIViewController, FinalViewArgumentDelegate {

    @IBOutlet weak var labelQuestion: UILabel!
    @IBOutlet weak var labelProsCount: UILabel!
    @IBOutlet weak var labelConsCount: UILabel!
    @IBOutlet weak var labelAnswer: UILabel!
    @IBOutlet weak var imageViewAnswer: UIImageView!
    @IBOutlet weak var tableContentView: UIView!
    
    @IBOutlet weak var tablePros: UITableView!
    @IBOutlet weak var tableCons: UITableView!
    
    var question: Question?
    
    var vLine: UIView?
    
    var prosDataSource: CustomDataSource?
    var consDataSource: CustomDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

        prosDataSource = CustomDataSource()
        consDataSource = CustomDataSource()
        
        prosDataSource?.viewController = self
        consDataSource?.viewController = self
        
        
        consDataSource?.isPros = false
        consDataSource?.question = question
        prosDataSource?.question = question
        
        prosDataSource?.delegate = self
        consDataSource?.delegate = self

        tablePros.delegate = prosDataSource
        tableCons.delegate = consDataSource

        tablePros.dataSource = prosDataSource
        tableCons.dataSource = consDataSource

        tableCons.backgroundColor = .clear
        tablePros.backgroundColor = .clear
        
        labelQuestion.text = question?.questionText

        prosDataSource?.data = (question?.pros)!
        consDataSource?.data = (question?.cons)!
        
        calcResult()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prosDataSource?.data = (question?.pros)!
        consDataSource?.data = (question?.cons)!
        tableCons.reloadData()
        tablePros.reloadData()
        calcResult()
    }
    
    
    func calcResult() {
        var prosCount = 0
        var consCount = 0
        for i in (question?.pros)! { prosCount += i.weight! }
        for i in (question?.cons)! { consCount += i.weight! }
        labelProsCount.text = String(prosCount)
        labelConsCount.text = String(consCount)
        
        if prosCount > consCount {
            labelAnswer.text = "Answer: YES".localized
            imageViewAnswer.image = UIImage(named: "like")
            question?.result = .yes
        }
        else
            if prosCount < consCount {
                labelAnswer.text = "Answer: NO".localized
                imageViewAnswer.image = UIImage(named: "dislike")
                question?.result = .no
            }
            else {
                labelAnswer.text = "Answer: EQUAL".localized
                imageViewAnswer.isHidden = true
                question?.result = .unknown
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    func initView() {
        vLine?.removeFromSuperview()
        vLine = UIView(frame: CGRect(x: (UIScreen.main.bounds.width / 2) - 1, y: 0, width: 1, height: tableContentView.frame.height))
        
        vLine?.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
        tableContentView.addSubview(vLine!)
    }
    
    override func viewDidLayoutSubviews() {
        initView()
    }
    
    @IBAction func buttonPlusTap(_ sender: Any) {
        let c = storyboard?.instantiateViewController(withIdentifier: "ArgumentViewController") as? ArgumentViewController
        c?.question = self.question
        c?.editMode = true
        present(c!, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class CustomDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    var isPros = true
    var data = [Argument]()
    var question: Question?
    var delegate: FinalViewArgumentDelegate?
    var viewController: UIViewController!
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit".localized, handler: ({_,_ in
            var removeFromProsIndex: Int = -1
            var removeFromConsIndex: Int = -1
            var editArgument: Argument?
            
            if self.isPros {
                removeFromProsIndex = indexPath.row
                editArgument = self.question?.pros[indexPath.row]
            } else {
                removeFromConsIndex = indexPath.row
                editArgument = self.question?.cons[indexPath.row]
            }

            let c = self.viewController.storyboard?.instantiateViewController(withIdentifier: "ArgumentViewController") as! ArgumentViewController
            c.question = self.question
            c.editMode = true
            c.removeFromProsIndex = removeFromProsIndex
            c.removeFromConsIndex = removeFromConsIndex
            c.editArgument = editArgument
            self.viewController.present(c, animated: true, completion: nil)
        }))

        let remove = UITableViewRowAction(style: .destructive, title: "Delete".localized, handler: ({_,_ in
            if self.isPros {
                self.question?.pros.remove(at: indexPath.row)
            } else {
                self.question?.cons.remove(at: indexPath.row)
            }
            self.data.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            Data.save()
            self.delegate?.calcResult()
        }))
        
        return [remove, edit]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell") as? CellTableViewCell else { return UITableViewCell() }
        
        let name = (data[indexPath.row].name)!
        // let weight = (data[indexPath.row].weight)!
        // let text = "\(name) (\(weight))"
        
        cell.setText(name)
        
        return cell
    }
}

protocol FinalViewArgumentDelegate {
    func calcResult()
}
