import {Component, OnInit} from '@angular/core';
import {Filter} from "../../models/filter";
import {ShowServices} from "../show-services.service";
import {FormBuilder, FormGroup, Validators} from "@angular/forms";
import {RestoreRecords} from "../../models/restore-records";
import {JournalService} from "../../journal/journal.service";

@Component({
  selector: 'app-restore-global',
  templateUrl: './restore-global.component.html',
  styleUrls: ['./restore-global.component.css']
})
export class RestoreGlobalComponent implements OnInit{

  filter?: Filter

  restoreForm: FormGroup = new FormGroup({});

  constructor(private showService: ShowServices,
              private fb: FormBuilder,
              private journalService: JournalService) {
  }

  ngOnInit() {
    this.showService.filter$.subscribe(filter => this.filter = filter)

    this.restoreForm = this.fb.group({
      RestoreValue: ['oldvalue', Validators.required ],
      RedirectTo: ['', Validators.required]
    })

  }

  onSubmit() {
    let a = this.restoreForm.value()
  }

  restore() {

    if (this.filter === undefined) {
      console.log('filter is undefined')
      return
    }

    let formValue = this.restoreForm.value

    let request: RestoreRecords = {
      Filter: this.filter,
      RestoreValue: formValue.RestoreValue,
      RedirectTo: formValue.RedirectTo
    }

    console.log(request)

    this.journalService.restore(request)
    return
  }

  export() {

  }
}
