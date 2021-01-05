//
//  ViewController.swift
//  AnotherDB
//
//  Created by Dennis Schaefer on 1/4/21.
//

import Cocoa
import SQLite3

internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

class ViewController: NSViewController {

    var db: OpaquePointer?
    var statement: OpaquePointer?
    var aname:String = ""
    var mycounter:Int = 0
    var dbName:String = "MyDatabase.sqlite"
    var tblName:String = "test"
    var tblDefinition:String = "(id integer primary key autoincrement, name text)"
    var tblInserts:String = "(name)"
    var tblSelects:String = "id, name"
    var createSQL:String = "create table if not exists \(tblName) \(tblDefinition)"
    var insertSQL:String = "insert into \(tblName) \(tblInserts) values (?)"
    var selectSQL:String = "select \(tblSelects) from \(tblName)"

    //==========================================================
    // Create and open the database
    //==========================================================
    func dbConnect(dbn: String) {
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(dbn)
        print(fileURL)
        // open database
        
        guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
            print("bad sqlite3_open: error opening database")
            sqlite3_close(db)
            db = nil
            return
        }
    }

    func dbTableCreate(cSQL: String) {
        //==========================================================
        // Create the table
        //==========================================================

        if sqlite3_exec(db, cSQL, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("bad sqlite3_exec: error creating table: \(errmsg)")
        } else {
            print("good sqlite3_exec:")
        }

    }
    
    func stmtPrepareInsert(iSQL: String) {
        //==========================================================
        // Prepare the SQL statement
        //==========================================================

        if sqlite3_prepare_v2(db, iSQL, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("bad sqlite3_prepare: error preparing insert: \(errmsg)")
        } else {
            print("good sqlite3_prepare")
        }
    }
    func stmtPrepareSelect(sSQL: String) {
        //==========================================================
        // Prepare the select statement
        //==========================================================

        if sqlite3_prepare_v2(db, sSQL, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("bad sqlite3_prepare: error preparing select: \(errmsg)")
        } else {
            print("good sqlite3_prepare:")
        }
    }
    
    func stmtBind(vname:String) {
        //==========================================================
        // Connect the data to be inserted to the statement
        //==========================================================

        if sqlite3_bind_text(statement, 1, aname, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("bad sqlite3_bind_text: failure binding \(vname): \(errmsg)")
            print(statement)
        } else {
            print("good sqlite3_bind_text:")
            print(statement)
        }
    }
    
    func stmtStepInsert() {
        //==========================================================
        // Execute (step) the SQL statement
        //==========================================================

        if sqlite3_step(statement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("bad sqlite3_step: failure inserting foo: \(errmsg)")
        } else {
            print("good sqlite3_step:")
        }

    }
    
    func stmtStepSelect() {
        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int64(statement, 0)
            print("id = \(id); ", terminator: "")
        
            if let cString = sqlite3_column_text(statement, 1) {
                let name = String(cString: cString)
                print("name = \(name)")
            } else {
                print("name not found")
            }
        }
    }
    
    func stmtReset() {
        //==========================================================
        // Reset the statement
        //==========================================================

        if sqlite3_reset(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("bad sqlite3_reset: error resetting prepared statement: \(errmsg)")
        } else {
            print("good sqlite3_reset:")
        }
    }
    
    func stmtFinalize() {
        //==========================================================
        // Finalize the statement to recover memory
        //==========================================================

        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("bad sqlite3_finalize: error finalizing prepared statement: \(errmsg)")
        } else {
            print("good sqlite3_finalize:")
        }
        statement = nil
        if sqlite3_close(db) != SQLITE_OK {
            print("bad sqlite3_close: error closing database")
        } else {
            print("good sqlite3_close:")
        }
        db = nil
    }
    
    //==========================================================
    // viewDidLoad
    //==========================================================
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        dbConnect(dbn: dbName)
        dbTableCreate(cSQL: createSQL)
    }
    
    //==========================================================
    // handle addrowButton
    //==========================================================
    @IBAction func addrowButton(_ sender: Any) {
        dbConnect(dbn: dbName)
        
        aname = "Dennis"
        mycounter += 1
        let counterappend:String = String(mycounter)
        aname = aname + counterappend

        stmtPrepareInsert(iSQL: insertSQL)
        
        stmtBind(vname: aname)
        
        stmtStepInsert()
        
        stmtReset()
        
        stmtFinalize()
    }

    //==========================================================
    // handle getrowsButton
    //==========================================================
    @IBAction func getrowsButton(_ sender: Any) {
        dbConnect(dbn: dbName)
        aname = "Dennis"

        stmtPrepareSelect(sSQL: selectSQL)
        
        stmtStepSelect()
        
        stmtFinalize()
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

