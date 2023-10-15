import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { JournalListComponent } from '../journal-list/journal-list.component';
import { JournalFormComponent } from '../journal-form/journal-form.component';
import { FormsModule, ReactiveFormsModule} from "@angular/forms";
import { HomeModule} from "../home/home.module";
import { JournalStatsComponent } from '../journal-stats/journal-stats.component';
import { RouterModule } from "@angular/router";
import {AppModule} from "../app.module";
import { RecordComponent } from './record/record.component';
import { JournalProgressionComponent } from '../journal-progression/journal-progression.component';
import { DropFileComponent } from '../drop-file/drop-file.component';
import {NgxDropzoneModule} from "ngx-dropzone";

@NgModule({
  declarations: [
    JournalListComponent,
    JournalFormComponent,
    JournalStatsComponent,
    RecordComponent,
    JournalProgressionComponent,
    DropFileComponent
  ],
    imports: [
        CommonModule,
        FormsModule,
        ReactiveFormsModule,
        HomeModule,
        RouterModule,
        AppModule,
        NgxDropzoneModule
    ]
})
export class JournalModule { }
