/*canActivate: [AuthGuard] */
import {Injectable} from "@angular/core";
import {StorageService} from "./storage.service";
import {ActivatedRouteSnapshot, Router, RouterStateSnapshot, UrlTree} from "@angular/router";
import {Observable} from "rxjs";

@Injectable({
    providedIn: 'root',
})
export class AuthGuard {
    constructor(public storageService: StorageService, public router: Router) {}

    canActivate( next: ActivatedRouteSnapshot, state: RouterStateSnapshot ): Observable<boolean> | Promise<boolean> | UrlTree | boolean {
        if (!this.storageService.isLoggedIn()) {
            window.alert('Access Denied, Login is Required to Access This Page!');
            this.router.navigate(['login']);
        }
        return true;
    }
}
