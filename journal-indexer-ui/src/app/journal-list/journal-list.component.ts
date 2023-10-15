import { Component, OnInit } from '@angular/core';
import { JournalService} from "../journal/journal.service";
import { Journal } from "../models/journal";
import { Router } from "@angular/router";
import {select, Store} from "@ngrx/store";
import {AppState} from "../app-state";
import {Observable} from "rxjs";


@Component({
  selector: 'app-journal-list',
  templateUrl: './journal-list.component.html',
  styleUrls: ['./journal-list.component.css']
})
export class JournalListComponent implements OnInit {
  journals: Journal [] = [];


  constructor(private journalService: JournalService,
              private router: Router,
              private store: Store<AppState>) {
  }
  ngOnInit(): void {
    this.journalService.updateIndexedJournals();
    this.store.pipe(select('indexedJournal')).subscribe(indexedJournals => {
      this.journals = indexedJournals;
    })
  }

  deleteJournals(id: string) {
    this.journalService.delete(id);
  }

  showStats(id: string) {
    this.router.navigate(['/stats/',id])
  }
}
