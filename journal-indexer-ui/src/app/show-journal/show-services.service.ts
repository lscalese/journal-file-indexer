import { Injectable } from '@angular/core';
import {Filter} from "../models/filter";
import {Subject} from "rxjs";

@Injectable({
  providedIn: 'root'
})
export class ShowServices {

  constructor() { }

  private filter = new Subject<Filter>();

  filter$ = this.filter.asObservable()

  updateFiler(filter: Filter) {
    this.filter.next(filter)
    console.log('filter updated', filter)
  }

}
