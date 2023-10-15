import { Component, OnInit } from '@angular/core';
import {AbstractControl, FormBuilder, FormGroup, ValidationErrors, ValidatorFn, Validators} from "@angular/forms";
import { JournalService} from "../journal/journal.service";
import {Journal} from "../models/journal";
import { Router } from "@angular/router";
import {IndexStarted} from "../models/index-started";
import {TempStoreService} from "../journal/temp-store.service";
import {JournalFileService} from "../journal/journal-file.service";

@Component({
  selector: 'app-journal-form',
  templateUrl: './journal-form.component.html',
  styleUrls: ['./journal-form.component.css']
})
export class JournalFormComponent implements OnInit {

  journalForm: FormGroup = new FormGroup({});

  indexStarted: IndexStarted = {Message: '', PID: '', Status: '', Token: ''};

  serverJournals: [] = [];

  constructor(
    private formBuilder: FormBuilder,
    private journalService: JournalFileService,
    private router: Router,
    private tempStore: TempStoreService) {

  }
  ngOnInit() {
    this.journalForm =this.formBuilder.group({
      path:['', Validators.required],
      name:['', Validators.required]
    })

    this.journalService.files().subscribe(serverFiles => {
      this.serverJournals = serverFiles
    })
  }

  onSubmit() {
    if (this.journalForm.valid) {
      console.log('Journal form is valid.')
      let journal: Journal = this.journalForm.value;
      let path = this.journalForm.get('path')?.value
      let name = this.journalForm.get('name')?.value
      this.journalService.index(path, name)
        .subscribe(indexStarted => {
          this.indexStarted = indexStarted
          console.log(this.indexStarted)
          this.tempStore.setLastToken(indexStarted.Token)
          this.router.navigate(['last-action', indexStarted.Token])
        })

      //this.router.navigate(['/list']);
    }
  }

  selectFile(file: string) {
    this.journalForm.get('path')?.setValue(file)
    let separator= (file.includes('/')) ? '/' : '\\';
    this.journalForm.get('name')?.setValue(file.split(separator).pop())
  }

  submit() {

  }
}
