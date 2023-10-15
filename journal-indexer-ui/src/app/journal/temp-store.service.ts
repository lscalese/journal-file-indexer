import { Injectable } from '@angular/core';
import { Journal } from "../models/journal";

@Injectable({
  providedIn: 'root'
})
export class TempStoreService {

  static journal: Journal | boolean = false;

  static lastToken: string = '';
  constructor() { }

  setJournal(journal: Journal): void {
    TempStoreService.journal = journal
  }

  getJournal(): Journal | boolean {
    return TempStoreService.journal
  }

  resetJournal(): void {
    TempStoreService.journal = false;
  }

  setLastToken(token: string): void{
    TempStoreService.lastToken = token;
  }

  getLastToken(): string {
    return TempStoreService.lastToken;
  }
}
