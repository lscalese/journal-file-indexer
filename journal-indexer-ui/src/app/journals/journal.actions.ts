import { createAction, props } from "@ngrx/store";
import { IndexerProgression } from "../models/indexer-progression";
import {Journal} from "../models/journal";

export const UpdateProgression = createAction('[Journal] Update Progression', props<IndexerProgression>());
export const UpdateProgressionSuccess = createAction('[Journal] Update Progression successfully', props<IndexerProgression>());
export const UpdateProgressionFailure = createAction('[Journal] Update Progression failure', props<{ error: any }>());

export const AddIndexedJournal = createAction('[Journal] Add indexed journal', props<Journal>());
export const DeleteIndexedJournal = createAction('[Journal] Delete indexed journal', props<{ ID: string }>());
export const ClearIndexedJournal = createAction('[Journal] Clear indexed journal');

/*export const UpdateLoggedIn = createAction('[Login] Update login state', props<loginState>());*/
