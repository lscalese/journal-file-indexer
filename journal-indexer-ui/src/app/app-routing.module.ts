import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import {JournalListComponent} from "./journal-list/journal-list.component";
import {JournalFormComponent} from "./journal-form/journal-form.component";
import {JournalStatsComponent} from "./journal-stats/journal-stats.component";
import {RecordComponent} from "./journal/record/record.component";
import {JournalProgressionComponent} from "./journal-progression/journal-progression.component";
import {LoginComponent} from "./login/login/login.component";
import {HomeComponent} from "./home/home.component";
import {AuthGuard} from "./login/login/auth.guard";
import {DropFileComponent} from "./drop-file/drop-file.component";

const routes: Routes = [
  { path:"", redirectTo:"home", pathMatch:"full" },
  { path:"home", component: HomeComponent, canActivate: [AuthGuard] },
  { path:"login", component: LoginComponent},
  { path:"list", component: JournalListComponent, canActivate: [AuthGuard]  },
  { path:"new", component: JournalFormComponent, canActivate: [AuthGuard]  },
  { path:"upload", component: DropFileComponent, canActivate: [AuthGuard]  },
  { path:"stats/:id", component: JournalStatsComponent, canActivate: [AuthGuard] },
  { path:"record/:journal/:address", component: RecordComponent, canActivate: [AuthGuard] },
  { path:"last-action/:token", component: JournalProgressionComponent, canActivate: [AuthGuard] }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
