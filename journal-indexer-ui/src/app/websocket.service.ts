import { Injectable } from '@angular/core';
import { webSocket, WebSocketSubject } from 'rxjs/webSocket';

@Injectable({
  providedIn: 'root',
})
export class WebsocketService {
  private socket$: WebSocketSubject<any>;

  /*
  * // set ws protocol when using http and wss when using https
    const protocol = window.location.protocol.replace('http', 'ws');
// get location host
const host = window.location.host;
// websocket instantiation
const ws = new WebSocket(`${protocol}//${host}/stream/connect`);
  * */
  constructor() {

    const protocol = window.location.protocol.replace('http', 'ws');
    const host = window.location.host;
    console.log(`${protocol}//${host}/stream/connect`)
    this.socket$ = webSocket(`${protocol}//${host}/jrnindexer/ws/dc.journalindexer.WebSocket.cls`);

    ///ws://localhost:49187/jrnindexer/ws/dc.journalindexer.WebSocket.cls
    //this.socket$ = webSocket('/jrnindexer/ws/dc.journalindexer.WebSocket.cls');
    //this.socket$ = webSocket('ws://localhost:49187/jrnindexer/ws/dc.journalindexer.WebSocket.cls');

  }

  connect() {
    return this.socket$;
  }

  sendMessage(message: any) {
    this.socket$.next(message);
  }

  close() {
    this.socket$.complete();
  }
}
