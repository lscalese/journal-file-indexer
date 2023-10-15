import { Injectable } from '@angular/core';
import { Observable, of, throwError} from "rxjs";
import { IndexerProgression } from "../models/indexer-progression";

@Injectable({
  providedIn: 'root'
})
export class JournalProgressionService {

  constructor() { }

  refresh(progression: IndexerProgression): Observable<IndexerProgression> {
    return of(progression)
  }
}
