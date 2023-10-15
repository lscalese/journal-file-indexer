import {Component, OnInit} from '@angular/core';
import { JournalService } from "../journal/journal.service";
import {Stats} from "../models/stats";
import {ActivatedRoute} from "@angular/router";
import {StatsData} from "../models/stats-data";

@Component({
  selector: 'app-journal-stats',
  templateUrl: './journal-stats.component.html',
  styleUrls: ['./journal-stats.component.css']
})
export class JournalStatsComponent implements OnInit {

  stats?: Stats;

  selectedStatsData?: StatsData;

  constructor(private journalService:JournalService,
              private activatedRoute: ActivatedRoute) {


  }

  ngOnInit(): void {
    let id = this.activatedRoute.snapshot.paramMap.get('id')
    if (id) {
      this.journalService.getStats(parseInt(<string>id)).subscribe(stats => { this.stats = stats })
      this.activatedRoute.params.subscribe(routeParams => {
        this.journalService.getStats(parseInt(routeParams['id'])).subscribe(stats => { this.stats = stats })
      })

    }

  }

  getOtherCount(statsData: StatsData): number {
    return statsData.Count - ( statsData.Details.SET + statsData.Details.KILL + statsData.Details.ZKILL )
  }
}
