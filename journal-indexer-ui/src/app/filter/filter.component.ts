import {Component, OnInit} from '@angular/core';
import {select, Store} from "@ngrx/store";
import {JournalService} from "../journal/journal.service";
import {AppState} from "../app-state";
import {Journal} from "../models/journal";
import {
  AbstractControl,
  FormArray,
  FormBuilder,
  FormGroup,
  ValidationErrors,
  ValidatorFn,
  Validators
} from "@angular/forms";
import {Filter} from "../models/filter";
import {FilterProperties} from "../models/filter-properties";
import {ShowServices} from "../show-journal/show-services.service";

@Component({
  selector: 'app-filter',
  templateUrl: './filter.component.html',
  styleUrls: ['./filter.component.css']
})
export class FilterComponent implements OnInit{

  journals: Journal[] = []
  filterForm: FormGroup = new FormGroup({});

  dbList: string[] = [ ]

  globalList: string[] = [ ]

  journalTypeList= ['SET', 'KILL', 'ZKILL', 'RemoteSET', 'RemoteKILL', 'RemoteZKILL', 'MirrorSET', 'MirrorKILL']

  selectedJournal?: Journal;

  showFilter = true

  //subscripts: any;

  filter: Filter = {
    File: {
      Value: ''
    },
    DatabaseName: {
      Value: ''
    },
    Type: {
      Value: ''
    },
    ProcessID: {
      Value: ''
    },
    GlobalName: {
      Value: ''
    },
    Address: {
      Start: '0',
      End: '',
      Operator: 'between'
    },
    TimeStamp: {
      Start: '',
      End: '',
      Operator: 'between'
    },
    SubscriptsSize: {
      Start: '',
      End: '',
      Operator: 'between'
    },
    OldValue: {
      Value: '',
      Position: 1
    },
    NewValue: {
      Value: '',
      Position: 1
    },
    Subscripts: [
      {
        Operator: '=',
        Start: '',
        End: '',
        Value: '',
        Logical: ''
      }
    ]
  }

  control?: FormArray;

  constructor(private journalService:JournalService,
              private store: Store<AppState>,
              private formBuilder: FormBuilder,
              private showService: ShowServices) {
  }
  ngOnInit(): void {
    this.journalService.updateIndexedJournals();
    this.store.pipe(select('indexedJournal')).subscribe(indexedJournals => {
      this.journals = indexedJournals;
    })

    let filterPropertiesTemplate: FilterProperties = {
      Start: '', End: '', Operator: '', Value: '', Position: 1, Logical: ''
    }

    const tsRegex= /[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$/
    const numberOrEmptyRegExp = /^[0-9]\d*$/

    this.filterForm = this.formBuilder.group({
      File: this.formBuilder.group({Operator: ['='], Value:['', Validators.required]}),
      DatabaseName: this.formBuilder.group({Operator: ['='], Value:['']}),
      GlobalName: this.formBuilder.group({Operator: ['='], Value:['']}),
      ProcessID: this.formBuilder.group({Operator: ['='], Value:['', Validators.pattern(numberOrEmptyRegExp)]}),
      Type: this.formBuilder.group({Operator: ['='], Value:['']}),
      TimeStamp: this.formBuilder.group({
        Operator: ['between'],
        Start: ['', Validators.pattern(tsRegex)],
        End: ['', Validators.pattern(tsRegex)]},{
        validators: [filterPropertiesValidator()]}),
      Address: this.formBuilder.group({
        Operator: ['between'],
        Start: ['', Validators.pattern(numberOrEmptyRegExp)],
        End: ['', Validators.pattern(numberOrEmptyRegExp)]},{
        validators: [filterPropertiesValidator()]}),
      NewValue: this.formBuilder.group({
        Operator: ['='],
        Start: [''],
        End: [''],
        Position: [1, Validators.pattern(numberOrEmptyRegExp)]},{
        validators: [filterPropertiesValidator()]}),
      OldValue: this.formBuilder.group({
        Operator: ['='],
        Start: [''],
        End: [''],
        Position: [1, Validators.pattern(numberOrEmptyRegExp)]},{
        validators: [filterPropertiesValidator()]}),
      SubscriptsSize: this.formBuilder.group({
        Operator: ['between'],
        Start: ['', Validators.pattern(numberOrEmptyRegExp)],
        End: ['', Validators.pattern(numberOrEmptyRegExp)]},{
        validators: [filterPropertiesValidator()]}),
      Subscripts: this.formBuilder.array([])
    })
    this.control = <FormArray>this.filterForm.controls['Subscripts']
    this.patch()
  }

  patch() {
    // this.control = <FormArray>this.filterForm.get('subscripts');
    this.filter.Subscripts?.forEach(x => {
      // this.control.push(this.patchValues2(x))
      if (x.Position === undefined) x.Position = 1
      if (x.Operator === undefined) x.Operator = '='
      if (x.Start === undefined) x.Start = ''
      if (x.End === undefined) x.End = ''
      if (x.Logical === undefined) x.Logical = ''
      if (this.control !==undefined) {
        this.control.push(this.patchValues(x.Position, x.Operator, x.Start, x.End, x.Logical))
      }
    });
    console.log(this.control)
  }

  // assign the values
  patchValues(position: number, operator:string, start: string, end: string, logical: string) {
    return this.formBuilder.group({
      Position: ['', Validators.pattern(/^[0-9]\d*$/)],
      Operator: [operator, Validators.required],
      Start: [start],
      End: [end],
      Logical: [logical]
    }, {
      validators: filterPropertiesValidator()
    })
  }
  onSubmit() {
    const filter: Filter = new Filter()

    filter.File = { Value: this.filterForm.get('journalID')?.value}

    if (this.filterForm.get('db')?.value !== '') {
      filter.DatabaseName = { Value: this.filterForm.get('db')?.value }
    }

    if (this.filterForm.get('global')?.value !== '') {
      filter.GlobalName = { Value: this.filterForm.get('global')?.value }
    }

    if (this.filterForm.get('pid')?.value !== '') {
      filter.ProcessID = { Value: this.filterForm.get('pid')?.value }
    }

    if (this.filterForm.get('newValue')?.value !== '') {
      filter.NewValue = {
        Value: this.filterForm.get('newValue')?.value,
        Start: this.filterForm.get('newValue')?.value,
        Position: this.filterForm.get('newValuePosition')?.value,
        End: this.filterForm.get('newValueEnd')?.value,
        Operator: this.filterForm.get('newValueOperator')?.value
      }
    }

    if (this.filterForm.get('oldValue')?.value !== '') {
      filter.OldValue = {
        Value: this.filterForm.get('oldValue')?.value,
        Start: this.filterForm.get('oldValue')?.value,
        Position: this.filterForm.get('oldValuePosition')?.value,
        End: this.filterForm.get('oldValueEnd')?.value,
        Operator: this.filterForm.get('oldValueOperator')?.value
      }
    }

    if (this.filterForm.get('type')?.value !== '') {
      filter.Type = { Value: this.filterForm.get('type')?.value }
    }

    if (this.filterForm.get('nSubscript')?.value !== '') {
      filter.SubscriptsSize = {
        Value: this.filterForm.get('nSubscript')?.value,
        Operator: this.filterForm.get('nSubscriptOperator')?.value,
        End: this.filterForm.get('nSubscriptEnd')?.value,
      }
      filter.SubscriptsSize.Start = filter.SubscriptsSize.Value
    }

    if (this.filterForm.get('tsStart')?.value !== '') {
      filter.TimeStamp = {
        Start: this.filterForm.get('tsStart')?.value,
        End: this.filterForm.get('tsEnd')?.value,
        Operator: 'between'
      }
      filter.TimeStamp.Value = filter.TimeStamp.Start
    }

    if (this.filterForm.get('addrStart')?.value !== '') {
      filter.Address = {
        Start: this.filterForm.get('addrStart')?.value,
        End: this.filterForm.get('addrEnd')?.value,
        Operator: 'between'
      }
      filter.Address.Value = filter.Address.Start
    }

    filter.Subscripts = []

    let subscriptsArray: FilterProperties[] = this.control?.value

    subscriptsArray.forEach(element => {
      if (element.Start !== '') {
        filter.Subscripts?.push({
          Logical: element.Logical,
          Position: element.Position,
          Start: element.Start,
          Value: element.Start,
          Operator: element.Operator
        })
      }
    })
    console.log(filter)

  }

  onSelectJournal() {
    let id = this.filterForm.controls['File'].value['Value']

    if (id == '0') return

    this.selectedJournal = this.journals.find( (element: Journal) => element.ID == id )

    if (this.selectedJournal === undefined) return;

    this.filterForm.controls['TimeStamp'].patchValue({Start: this.selectedJournal.FirstRecordTS, End: this.selectedJournal.LastRecordTS})
    this.filterForm.controls['Address'].patchValue({Start: this.selectedJournal.FirstRecord, End: this.selectedJournal.LastRecord})

    console.log('select',this.selectedJournal)

    this.journalService.getGlobals(id).subscribe(globals => {
      this.globalList = globals
    })

    this.journalService.getDatabases(id).subscribe(databases => {
      this.dbList = databases
    })

    return

  }

  log(o:any) {
    console.log(o)
  }
  trackByFn(index:number, item:any) {
    return index;
  }

  addSubscriptFilter() {
    if (this.control === undefined) return

    this.control.push(this.patchValues(1, '=', '', '', 'AND'))

    return
  }

  deleteSubscriptFilter(i: number) {
    if (this.control === undefined) return

    this.control.removeAt(i)

    return
  }

  resetFilter() {

    this.filter = {
      File: {
        Value: ''
      },
      DatabaseName: {
        Value: ''
      },
      Type: {
        Value: ''
      },
      ProcessID: {
        Value: ''
      },
      GlobalName: {
        Value: ''
      },
      Address: {
        Start: '',
        End: '',
        Operator: 'between'
      },
      TimeStamp: {
        Start: '',
        End: '',
        Operator: 'between'
      },
      SubscriptsSize: {
        Start: '',
        End: '',
        Operator: 'between'
      },
      OldValue: {
        Value: '',
        Position: 1
      },
      NewValue: {
        Value: '',
        Position: 1
      }
    }
    return
  }

}

export function filterPropertiesValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    let filterProperties: FilterProperties = control.value
    let valid = true;
    let between: boolean = true;

    if (filterProperties.Operator === 'between') {
      valid = ((filterProperties.Start === '') && (filterProperties.End === ''))
        || ((filterProperties.Start !== '') && (filterProperties.End !== ''));

      if (valid) {
        if (!isNaN(Number(filterProperties.Start)) && !isNaN(Number(filterProperties.End))) {
          valid = !(Number(filterProperties.Start) > Number(filterProperties.End))
        } else {
          const order = [filterProperties.Start, filterProperties.End].sort()
          valid = (order[0] == filterProperties.Start)
        }
      }
      between = !valid
    }
    if (!valid) {
      control.setErrors({between: true})
    }
    // console.log('check validity', valid, between)
    return !valid ? { between: between} : null;
  }
}
