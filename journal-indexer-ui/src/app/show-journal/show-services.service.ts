import { Injectable } from '@angular/core';
import {Filter} from "../models/filter";
import {BehaviorSubject, Subject} from "rxjs";
import {JournalService} from "../journal/journal.service";
import {SearchRecordParams} from "../models/search-record-params";
import {TableInfo} from "../models/table-info";
import {Journal} from "../models/journal";

@Injectable({
  providedIn: 'root'
})
export class ShowServices {

  constructor(private journalService: JournalService) { }

  // private filter = new Subject<Filter>();

  private filter = new BehaviorSubject<Filter>({});

  filter$ = this.filter.asObservable()

  private tableInfo = new Subject<TableInfo>()

  tableInfo$ = this.tableInfo.asObservable()

  private selectedJournal = new Subject<Journal>()

  selectedJournal$ = this.selectedJournal.asObservable()
  updateFilter(filter: Filter) {
    console.log(filter)
    this.filter.next(filter)
  }

  searchData(filter: Filter) {
    let searchParam:SearchRecordParams = {direction: 1, limitRecord: 50, startId: 0}
    let fromTableInfo: TableInfo = { firstID: 0, lastID: 0, records: [], recordPerPage: searchParam.limitRecord, page: 0, filter: filter, endOfData: false, state: 'loading', showRestoreButton: true }
    this.tableInfo.next(fromTableInfo)
    this.commonGetRecords(fromTableInfo, searchParam)
  }

  nextRecords(fromTableInfo: TableInfo) {
    if (fromTableInfo.endOfData) return
    let searchParam:SearchRecordParams = {direction: 1, limitRecord: fromTableInfo.recordPerPage, startId: fromTableInfo.lastID}
    fromTableInfo.state = 'loading'
    this.commonGetRecords(fromTableInfo, searchParam)
  }

  previousRecords(fromTableInfo: TableInfo) {
    if (fromTableInfo.page === 1) return
    let searchParam:SearchRecordParams = {direction: -1, limitRecord: fromTableInfo.recordPerPage, startId: fromTableInfo.firstID}
    fromTableInfo.state = 'loading'
    this.commonGetRecords(fromTableInfo, searchParam)
  }

  private commonGetRecords(fromTableInfo: TableInfo, searchParam:SearchRecordParams) {

    this.journalService.getRecords(fromTableInfo.filter, searchParam).subscribe(records => {
      let firstId = -1, lastId = -1

      if (records.length === 0) {
        fromTableInfo.endOfData = true
        return
      }

      if (records.length > 0) {
        firstId = records[0].id
        lastId = records[records.length-1].id
      }

      let tableInfo: TableInfo = {
        firstID: firstId,
        lastID: lastId,
        records: records,
        recordPerPage: fromTableInfo.recordPerPage,
        page: fromTableInfo.page + searchParam.direction,
        filter: fromTableInfo.filter,
        endOfData: ((records.length === 0) || (records.length !== searchParam.limitRecord)),
        state: 'ready'
      }
      this.tableInfo.next(tableInfo)
    })
  }

  setSelectedJournal(selectedJournal: Journal) {
    this.selectedJournal.next(selectedJournal)
  }

}
