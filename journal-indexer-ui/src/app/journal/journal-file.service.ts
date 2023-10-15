import { Injectable } from '@angular/core';
import {environment} from "../../environments/environment";
import {HttpClient, HttpEvent, HttpEventType} from "@angular/common/http";
import {Store} from "@ngrx/store";
import {AppState} from "../app-state";
import {catchError, map, Observable, of, throwError} from "rxjs";
import {IndexStarted} from "../models/index-started";
import {IndexerProgression} from "../models/indexer-progression";
import {UpdateProgression} from "../journals/journal.actions";

@Injectable({
  providedIn: 'root'
})
export class JournalFileService {

  private apiUrl = environment.apiUrl

  private webApp = environment.webApp

  progress: number = 0;

  constructor(private http: HttpClient,
              private store: Store<AppState>) {

  }
  index(path: string, userDefinedName: string): Observable<IndexStarted> {
    return this.http.post<IndexStarted>(this.apiUrl + this.webApp + "/file", {
      "path": path,
      "userDefinedName": userDefinedName,
      "runTuneTable": false});
  }

  progression(token: string) {
    this.http.get<IndexerProgression>(this.apiUrl + this.webApp + "/file/progression/" + token)
      .subscribe(
      progression => {
        console.log(progression)
        this.store.dispatch(UpdateProgression(progression))
      })
  }

  files(): Observable<[]> {
    return this.http.get<[]>(this.apiUrl+"/jrnindexer/api/serverjrnfile");
  }



  upload(file:File, userDefinedName: string): Observable<HttpEvent<IndexStarted>> {

    const formData = new FormData();
    formData.append("journalfile", file);

    ///formData.set("userDefinedName", userDefinedName); /// does not work to check ...

    console.log("before post")
      return this.http.post<IndexStarted>(this.webApp + "/upload?userDefinedName="+encodeURIComponent(userDefinedName), formData, {
          reportProgress: true,
          observe: "events"
        })
  }

}
