import { Injectable } from '@angular/core';
import { Journal} from "../models/journal";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";
import { environment } from "../../environments/environment";
import { Stats } from "../models/stats";
import {IndexerProgression} from "../models/indexer-progression";
import {
  UpdateProgression,
  AddIndexedJournal,
  ClearIndexedJournal,
  DeleteIndexedJournal
} from "../journals/journal.actions";
import {AppState} from "../app-state";
import {Store} from "@ngrx/store";
import {Filter} from "../models/filter";
import {SearchRecordParams} from "../models/search-record-params";
import { Record} from "../models/record";
import {RestoreRecords} from "../models/restore-records";
import {ValidGlobal} from "../models/valid-global";
import {RestoreResponse} from "../models/restore-response";


@Injectable({
  providedIn: 'root'
})
export class JournalService {

  private journals: Journal[] = [];

  private apiUrl = environment.apiUrl;

  private webApp = environment.webApp

  constructor(private http: HttpClient,
              private store: Store<AppState>) {
  }

  updateIndexedJournals() {
    this.store.dispatch(ClearIndexedJournal())

    this.http.get<Journal[]>(this.apiUrl + "/jrnindexer/api/indexedjournals").subscribe(
      indexedJournals => {
        indexedJournals.forEach(journal => {
          this.store.dispatch(AddIndexedJournal(journal))
        });
      }
    )
  }
  progression(token: string) {
    this.http.get<IndexerProgression>(this.apiUrl + this.webApp + "/file/progression/" + token)
      .subscribe(
        progression => {
          console.log(progression)
          this.store.dispatch(UpdateProgression(progression))
        })
  }

  getStats(id: number): Observable<Stats> {
    return this.http.get<Stats>(this.apiUrl + "/jrnindexer/api/stats/" + id)
  }

  delete(id: string): void {
    this.http.delete(this.apiUrl + this.webApp + '/file/' + id).subscribe(
        ()=> { this.store.dispatch(DeleteIndexedJournal({ID:id}))}
    )
  }

  getGlobals(id: string | number, selectedDB: string) {
    return this.http.get<string[]>(this.apiUrl + this.webApp + '/globals/' + id + '?databasename=' + encodeURIComponent(selectedDB))
  }

  getDatabases(id: string | number) {
    return this.http.get<string[]>(this.apiUrl + this.webApp + '/databases/' + id)
  }

  getRecords(filter: Filter, params: SearchRecordParams): Observable<Record []>{
    const queryParams = new URLSearchParams(JSON.parse(JSON.stringify(params))).toString()
    return this.http.post<Record[]>(this.apiUrl + this.webApp + '/records/'+filter.File?.Value + '?' + queryParams, filter)
  }

  restore(requestBody: RestoreRecords): Observable<RestoreResponse> {
    return this.http.post<RestoreResponse>(this.apiUrl + this.webApp + '/restore', requestBody)
  }

  export(requestBody: RestoreRecords): Observable<any> {
    return this.http.post(this.apiUrl + this.webApp + '/export', requestBody)
  }

  globalExists(globalName: string): Observable<ValidGlobal> {
    return this.http.get<ValidGlobal>(this.apiUrl + this.webApp + '/isvalidglobal?globalName=' + encodeURIComponent(globalName))
  }
}
