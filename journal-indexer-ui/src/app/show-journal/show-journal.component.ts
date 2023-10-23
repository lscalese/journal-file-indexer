import {Component, OnInit} from '@angular/core';
import {ShowServices} from "./show-services.service";
import {Filter} from "../models/filter";

@Component({
  selector: 'app-show-journal',
  templateUrl: './show-journal.component.html',
  styleUrls: ['./show-journal.component.css']
})
export class ShowJournalComponent implements OnInit {

  constructor(private showService: ShowServices) {
  }
  ngOnInit(){
    this.showService.filter$.subscribe(filter => {
      this.showService.searchData(filter)
    })
  }

}
