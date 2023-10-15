import {Injectable} from "@angular/core";
import { Actions, createEffect, ofType} from "@ngrx/effects";
import * as journalAction from "./journal.actions";
import { JournalProgressionService} from "./journal-progression.service";
import {map, mergeMap, catchError, of} from "rxjs";

@Injectable()
export class JournalEffects {

  updateProgression$ = createEffect(() => this.actions$.pipe(
    ofType(journalAction.UpdateProgression),
    mergeMap((action) => of(action)
      .pipe(
        map(progression => journalAction.UpdateProgressionSuccess(progression)),
        catchError((error) => of(journalAction.UpdateProgressionFailure({error})))
      )
    )
  ));

  /*deleteIndexedJournal = createEffect(() => this.actions$.pipe(
      ofType(journalAction.DeleteIndexedJournal),
      mergeMap((action) =>)
  ))*/
  constructor(private actions$: Actions) {
  }
}
