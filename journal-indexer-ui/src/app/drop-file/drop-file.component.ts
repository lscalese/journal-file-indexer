import {Component, OnInit} from '@angular/core';
import {FormBuilder, FormGroup, Validators} from "@angular/forms";
import {JournalFileService} from "../journal/journal-file.service";
import {catchError, map, throwError} from "rxjs";
import {HttpEventType} from "@angular/common/http";
import {Router} from "@angular/router";
import {TempStoreService} from "../journal/temp-store.service";
import {IndexStarted} from "../models/index-started";

@Component({
  selector: 'app-drop-file',
  templateUrl: './drop-file.component.html',
  styleUrls: ['./drop-file.component.css']
})
export class DropFileComponent implements OnInit{

  file?: File;

  journalForm: FormGroup = new FormGroup({});
  progress: number = -1;

  constructor(private formBuilder: FormBuilder,
              private journalFileService: JournalFileService,
              private router: Router,
              private tempStore: TempStoreService) {
  }
  ngOnInit() {
    this.journalForm =this.formBuilder.group({
      name:['', Validators.required]
    })
  }


  onSelect(event: { addedFiles: any; }) {
    console.log(event);
    this.file = event.addedFiles[0]
    if (this.file) {
      let separator = (this.file.name.includes('/')) ? '/' : '\\';
      this.journalForm.get('name')?.setValue(this.file.name.split(separator).pop())
    }
  }

  onRemove(event: File) {
    console.log(event);
    this.file = undefined;
    this.journalForm.get('name')?.setValue('')
  }

  onSubmit() {
    console.log(this.file)
    if (this.file) {
      console.log(this.file)
      let name = this.journalForm.get('name')?.value
      this.journalFileService.upload(this.file, name )
          .pipe(
              map((event: any) => {
                if (event.type == HttpEventType.UploadProgress) {
                  this.progress = Math.round((100 / event.total) * event.loaded);
                  console.log(this.progress)
                } else if (event.type == HttpEventType.Response) {
                  this.progress = 100;
                  console.log(event)
                  this.tempStore.setLastToken(event.body.Token)
                  this.router.navigate(['last-action', event.body.Token])
                }
              }),
              catchError((err: any) => {
                this.progress = -1;
                alert(err.message);
                return throwError(err.message);
              })
          ).subscribe(indexStarted => {})
    }
  }
}
