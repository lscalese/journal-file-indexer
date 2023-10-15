import { Component } from '@angular/core';

import {TempStoreService} from "../../journal/temp-store.service";
import {LoginService} from "../../login/login.service";
import {Journal} from "../../models/journal";
import {select, Store} from "@ngrx/store";
import {AppState} from "../../app-state";
import {JournalService} from "../../journal/journal.service";

@Component({
  selector: 'app-nav-bar',
  templateUrl: './nav-bar.component.html',
  styleUrls: ['./nav-bar.component.css']
})
export class NavBarComponent {

  indexedJournals: Journal[] = []
  constructor(private tempStorage: TempStoreService,
              private loginService: LoginService,
              private store:Store<AppState>,
              private journalService: JournalService) {
    //this.journalService.updateIndexedJournals();
    this.store.pipe(select('indexedJournal')).subscribe(indexedJournals => {
      this.indexedJournals = indexedJournals;
    })
  }

  getLastToken(): string {
    return this.tempStorage.getLastToken()
  }

  disconnect() {
      this.loginService.disconnect()
  }
}
