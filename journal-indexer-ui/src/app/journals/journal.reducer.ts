import { createReducer, on} from "@ngrx/store";
import {
    UpdateProgression,
    UpdateProgressionSuccess,
    UpdateProgressionFailure, AddIndexedJournal, ClearIndexedJournal, DeleteIndexedJournal,
} from "./journal.actions";
import { IndexerProgression } from "../models/indexer-progression";
import {Journal} from "../models/journal";
import {loginState} from "../app-state";

export const initialState: IndexerProgression = {};

export const initialJournalList: Journal[] = [];

export const initialLoginState: loginState = {isLoggedIn: false};

export const IndexerProgressionReducer = createReducer(
  initialState,
  on(UpdateProgression,(state) => { return state }),
  on(UpdateProgressionSuccess,(state, IndexerProgression) => state = IndexerProgression),
  on(UpdateProgressionFailure, (state, {error}) => {
    console.log('this is UpdateProgressionFailure')
    console.log(error);
    return state
  })
);

export const IndexedJournalReducer = createReducer(
  initialJournalList,
  on(AddIndexedJournal, (state, indexedJournal) => {
    console.log('add indexed journal')
    return [...state,indexedJournal]
  }),
  on(ClearIndexedJournal, (state) => {
    return []
  }),
  on(DeleteIndexedJournal, (state, toDelete:{ID: string}) => {
    return state.filter(value => {return value.ID !== toDelete.ID})
  })
)
/*
export const LoginReducer = createReducer(
  initialLoginState,
  on(UpdateLoggedIn, (state, loginState ) => {
      return loginState
  })
)
*/
