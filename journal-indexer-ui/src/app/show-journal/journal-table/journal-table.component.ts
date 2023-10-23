import {Component, OnInit} from '@angular/core';
import { Record} from "../../models/record";
import {ShowServices} from "../show-services.service";
import {TableInfo} from "../../models/table-info";
import {Journal} from "../../models/journal";

@Component({
  selector: 'app-journal-table',
  templateUrl: './journal-table.component.html',
  styleUrls: ['./journal-table.component.css']
})
export class JournalTableComponent implements OnInit{

  tableInfo: TableInfo = {
    firstID: 0,
    lastID: 0,
    records: [],
    recordPerPage: 250,
    page: 0,
    filter: {},
    endOfData: true,
    state: '',
    showRestoreButton: true,
    showExportButton: true
  }

  /// used for modal details dialog
  currentRecordIndex = 0;

  private static FAKE_RECORD: Record = {
    address: 0,
    databaseName: "",
    existsNewValue: false,
    existsOldValue: false,
    file: 0,
    formattedNewValue: "",
    formattedOldValue: "",
    globalNode: "",
    id: 0,
    inTransaction: false,
    nextAddress: 0,
    position: 0,
    prevAddress: 0,
    processID: 0,
    timestamp: "",
    type: ""

  }

  private static INITIAL_JRN: Journal = {
    FirstRecord: 0,
    FirstRecordTS: "",
    ID: "",
    LastRecord: 0,
    LastRecordTS: "",
    Name: "",
    UserDefinedName: ""
  }

  selectedJournal: Journal = JournalTableComponent.INITIAL_JRN

  currentRecord: Record = JournalTableComponent.FAKE_RECORD

  constructor(private showService: ShowServices) {
  }
  ngOnInit() {
    this.showService.tableInfo$.subscribe(tableInfo => {
      this.tableInfo = tableInfo
      this.currentRecordIndex = 0
      this.currentRecord = JournalTableComponent.FAKE_RECORD
    })
    this.showService.selectedJournal$.subscribe(journal => this.selectedJournal = journal)
  }

  next() {
    this.showService.nextRecords(this.tableInfo)
  }

  previous() {
    this.showService.previousRecords(this.tableInfo)
  }

  setRecordDetails(index: number) {
    this.currentRecord = this.tableInfo.records[index]
    this.currentRecordIndex = index
  }

  previousDetail() {
    if (this.currentRecordIndex === 0) return

    this.currentRecordIndex = this.currentRecordIndex - 1
    this.currentRecord = this.tableInfo.records[this.currentRecordIndex]
  }

  nextDetail() {
    if ((this.currentRecordIndex + 1) > this.tableInfo.records.length) return

    this.currentRecordIndex = this.currentRecordIndex + 1
    this.currentRecord = this.tableInfo.records[this.currentRecordIndex]

  }

  protected readonly navigator = navigator;
}
