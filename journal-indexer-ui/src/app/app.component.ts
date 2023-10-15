import {ChangeDetectorRef, Component, OnDestroy, OnInit} from '@angular/core';

import {webSocket, WebSocketSubject} from 'rxjs/webSocket';
import {environment} from "../environments/environment";
import {IndexerProgression} from "./models/indexer-progression";
import {WebsocketService} from "./websocket.service";
import {UpdateProgression} from "./journals/journal.actions";
import {Store} from "@ngrx/store";
import {AppState} from "./app-state";
import {LoginService} from "./login/login.service";
import {HttpHeaders} from "@angular/common/http";
import {ActivatedRoute, NavigationEnd, Router} from "@angular/router";
import {Subject} from "rxjs";
import {ChangeDetection} from "@angular/cli/lib/config/workspace-schema";


@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit, OnDestroy{
  title = 'journal-indexer-ui';

  showNavBar: boolean = true;
  constructor(private websocketService: WebsocketService,
              private store: Store<AppState>,
              private router: Router,
              private cd: ChangeDetectorRef) {
    this.router.events.subscribe(val => {
      if (val instanceof NavigationEnd) {
          this.showNavBar = (val.url != '/login')
          this.cd.detectChanges()
      }
    });

  }

  ngOnInit() {
    const socket$ = this.websocketService.connect();

    socket$.subscribe(
      (message: IndexerProgression) => {
        console.log('Message reçu : ', message);
        if (message.MessageType == 'INDEXER') {
          this.store.dispatch(UpdateProgression(message))
        }
      },
      (error: any) => {
        console.error('Error WebSocket : ', error);
      },
      () => {
        console.log('Connexion WebSocket closed.');
      }
    );
  }
  ngOnDestroy() {
    this.websocketService.close();
  }

}
