import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HomeComponent } from './home.component';
import { RouterModule } from "@angular/router";
import { NavBarComponent } from './nav-bar/nav-bar.component';


@NgModule({
    declarations: [
        HomeComponent,
        NavBarComponent
    ],
    exports: [
        HomeComponent,
        NavBarComponent
    ],
  imports: [
    CommonModule,
    RouterModule
  ]
})
export class HomeModule { }
