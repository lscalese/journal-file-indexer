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
}
