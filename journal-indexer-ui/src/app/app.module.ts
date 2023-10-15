import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { HomeModule} from "./home/home.module";
import { JournalModule } from "./journal/journal.module";
import {HTTP_INTERCEPTORS, HttpClientModule} from "@angular/common/http";
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { PrettyBytesPipe } from './pretty-bytes.pipe';
import { StoreModule} from "@ngrx/store";
import {IndexedJournalReducer, IndexerProgressionReducer} from "./journals/journal.reducer";
import { AppState } from "./app-state";
import {EffectsModule} from "@ngrx/effects";
import {JournalEffects} from "./journals/journal.effects";
import { StoreDevtoolsModule} from "@ngrx/store-devtools";
import { LoginComponent } from './login/login/login.component';
import {FormsModule, ReactiveFormsModule} from "@angular/forms";
import {AuthInterceptor} from "./login/auth.interceptor";
import {ErrorInterceptor} from "./login/error.interceptor";
import {NgxDropzoneModule} from "ngx-dropzone";

@NgModule({
  declarations: [
    AppComponent,
    PrettyBytesPipe,
    LoginComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HomeModule,
    HttpClientModule,
    BrowserAnimationsModule,
    StoreModule.forRoot<AppState>({progression: IndexerProgressionReducer, indexedJournal: IndexedJournalReducer}),
    EffectsModule.forRoot([JournalEffects]),
    StoreDevtoolsModule.instrument(),
    FormsModule,
    ReactiveFormsModule,
    NgxDropzoneModule
  ],
  providers: [{provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true},
    { provide: HTTP_INTERCEPTORS, useClass: ErrorInterceptor, multi: true },],
  exports: [
    PrettyBytesPipe
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
