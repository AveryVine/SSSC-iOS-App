//
//  TermsViewController.swift
//  SSSCTemp
//
//  Created by Avery Vine on 2018-09-27.
//  Copyright © 2018 Avery Vine. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GradesViewControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    private var addTermButton: UIBarButtonItem!
    private var editTermsButton: UIBarButtonItem!
    private var doneEditingTermsButton: UIBarButtonItem!
    
    private var terms = [Term]()
    private var creatingTerm = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTermButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTermPressed))
        editTermsButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTermPressed))
        doneEditingTermsButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editTermPressed))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadTerms()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if creatingTerm {
            creatingTerm = false
            loadTerms()
        } else {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        toggleOffTableViewEditMode()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return terms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TermTableViewCell", for: indexPath) as? TermTableViewCell  else {
            fatalError("The dequeued cell is not an instance of TermTableViewCell.")
        }
        cell.termName.text = terms[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let term = terms[indexPath.row]
            if Database.instance.deleteTerm(id: term.id) {
                self.terms.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    @objc func addTermPressed() {
        performSegue(withIdentifier: "createTerm", sender: nil)
    }
    
    @objc func editTermPressed() {
        toggleEditMode()
    }
    
    func toggleOffTableViewEditMode() {
        if tableView.isEditing {
            toggleEditMode()
        }
    }
    
    private func toggleEditMode() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing {
            getNavigationItem()?.setLeftBarButton(doneEditingTermsButton, animated: true)
        } else {
            getNavigationItem()?.setLeftBarButton(editTermsButton, animated: true)
        }
    }
    
    private func loadTerms() {
        terms.removeAll()
        terms = Database.instance.getTerms()
        self.tableView.reloadData()
    }
    
    func toggleTableViewButtonsInNavigationBar(show: Bool) {
        if show {
            if tableView.isEditing {
                getNavigationItem()?.setLeftBarButton(doneEditingTermsButton, animated: false)
            } else {
                getNavigationItem()?.setLeftBarButton(editTermsButton, animated: false)
            }
            getNavigationItem()?.setRightBarButton(addTermButton, animated: false)
        } else {
            getNavigationItem()?.setLeftBarButton(nil, animated: true)
            getNavigationItem()?.setRightBarButton(nil, animated: true)
        }
        //TODO: fix bug where Edit button appears after switching segments in GradesViewController
    }
    
    private func getNavigationItem() -> UINavigationItem? {
        return navigationController?.navigationBar.topItem
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "termDetail" {
            let controller = segue.destination as! CoursesViewController
            let indexPath = tableView.indexPathForSelectedRow!
            controller.term = terms[indexPath.row]
        } else if segue.identifier == "createTerm" {
            creatingTerm = true
        }
    }
    
}
