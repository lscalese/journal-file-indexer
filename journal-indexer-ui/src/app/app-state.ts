import {IndexerProgression} from "./models/indexer-progression";
import {Journal} from "./models/journal";

export interface loginState {
  isLoggedIn: boolean
}
export interface AppState {

  readonly progression: IndexerProgression

  readonly indexedJournal: Journal []

 /* readonly loggedIn: loginState*/
}
