import {AfterViewInit, Component, ElementRef, OnInit, ViewChild} from '@angular/core';
import {Filter} from "../../models/filter";
import {ShowServices} from "../show-services.service";
import {
  AbstractControl,
  AsyncValidatorFn,
  FormBuilder,
  FormGroup,
  ValidationErrors,
  ValidatorFn,
  Validators
} from "@angular/forms";
import {RestoreRecords} from "../../models/restore-records";
import {JournalService} from "../../journal/journal.service";
import {filterPropertiesValidator} from "../filter/filter.component";
import {catchError, map, switchMap, throwError, timer} from "rxjs";
import {ValidGlobal} from "../../models/valid-global";
import {RestoreResponse} from "../../models/restore-response";
import {IrisError} from "../../models/iris-error";
import {HttpErrorResponse} from "@angular/common/http";

@Component({
  selector: 'app-restore-global',
  templateUrl: './restore-global.component.html',
  styleUrls: ['./restore-global.component.css']
})
export class RestoreGlobalComponent implements OnInit, AfterViewInit{

  @ViewChild('closeModalButton') closeModalButton!: ElementRef;

  filter?: Filter

  restoreForm: FormGroup = new FormGroup({});

  hideForm: boolean = false;

  state: string = '';

  restoreResponse?: RestoreResponse;

  restoreErrorResponse?: IrisError;
  constructor(private showService: ShowServices,
              private fb: FormBuilder,
              private journalService: JournalService) {
  }

  ngOnInit() {
    this.showService.filter$.subscribe(filter => this.filter = filter)

    this.restoreForm = this.fb.group({
      RestoreValue: ['oldvalue', [Validators.required, filterPropertiesValidator()] ],
      RedirectTo: ['', [Validators.required], [globalNameValidator(this.journalService)]]
    })

  }

  ngAfterViewInit() {
    // console.log(this.modalRestore.nativeElement.innerHTML);
  }

  onSubmit() {
    let a = this.restoreForm.value()
  }

  restore() {

    if (this.restoreForm.invalid) {
      console.log('restoreForm is invalid', this.restoreForm)
      return
    }

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

    this.state = 'loading'
    this.hideForm = true;

    this.restoreResponse = undefined;
    this.restoreErrorResponse = undefined

    // this.journalService.restore(request).pipe(catchError(this.handleError)).subscribe({
    this.journalService.restore(request).subscribe({
      next: (restoreResponse) => {
        console.log('restore response', restoreResponse)
        this.state = 'done'
        this.restoreResponse = restoreResponse
      },
      error: (error:HttpErrorResponse) => {
        console.log('restore response error', error)
        this.state = 'error'
        this.restoreErrorResponse = error.error
      }
    })

    return
  }
  // export() {
  //
  //   if ((this.restoreForm.invalid) || (this.filter === undefined)) {
  //     return
  //   }
  //
  //   let formValue = this.restoreForm.value
  //   let request: RestoreRecords = {
  //     Filter: this.filter,
  //     RestoreValue: formValue.RestoreValue,
  //     RedirectTo: formValue.RedirectTo
  //   }
  //
  //   this.state = 'loading'
  //   this.hideForm = true;
  //
  //   this.restoreResponse = undefined;
  //   this.restoreErrorResponse = undefined
  //
  //   // this.journalService.restore(request).pipe(catchError(this.handleError)).subscribe({
  //   this.journalService.export(request).subscribe({
  //     next: (response) => {
  //       console.log('restore response', response)
  //       this.state = 'done'
  //       let dataType = response.type;
  //       let binaryData = [];
  //       binaryData.push(response);
  //       let downloadLink = document.createElement('a');
  //       downloadLink.href = window.URL.createObjectURL(new Blob(binaryData, {type: dataType}));
  //       if (this.filter)
  //         downloadLink.setAttribute('download', 'tralala.xml');
  //       document.body.appendChild(downloadLink);
  //       downloadLink.click()
  //
  //     },
  //     error: (error:HttpErrorResponse) => {
  //       console.log('restore response error', error)
  //       this.state = 'error'
  //       this.restoreErrorResponse = error.error
  //     }
  //   })
  //
  //   return
  //
  // }

  // log(o: any) {
  //   console.log(o)
  // }

  reset() {
    this.restoreResponse = undefined
    this.restoreErrorResponse = undefined
    this.state = ''
    this.hideForm = false
  }
}

export function globalNameValidator(
  journalService: JournalService,
): AsyncValidatorFn {
  return (control: AbstractControl) => {
    return timer(500).pipe(
        switchMap(() => {
          return journalService.globalExists(control.value)
            .pipe(map((result: ValidGlobal) => !result.IsValidName||result.Exists ? {
              validName: !result.IsValidName,
              exists: result.Exists
            } : null))
        })
    );
  };
}
