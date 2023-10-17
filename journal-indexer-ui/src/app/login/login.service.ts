import { Injectable } from '@angular/core';
import {environment} from "../../environments/environment";
import {HttpClient, HttpHeaders} from "@angular/common/http";
import {Router} from "@angular/router";
import {StorageService} from "./login/storage.service";

export interface JsonWebToken {
    access_token: string,
    refresh_token: string,
    sub: string,
    iat: string,
    exp: string
}

@Injectable({
  providedIn: 'root'
})
export class LoginService {

  private readonly loginEndPoint = environment.webApp + '/login'

  private readonly logoutEndPoint = environment.webApp + '/logout'

    constructor(private http: HttpClient,
              private router: Router,
              private storageService: StorageService) { }
  login(username: string, password: string) {
    this.storageService.clean()
    this.http.post<JsonWebToken>( this.loginEndPoint, {"user": username, "password": password })
        .subscribe({
            next: jwt => {
                //console.log(jwt)
                this.storageService.save(jwt.access_token)
                this.router.navigate(['home'])
            },
            error: err => {
                console.log('http error handling ', err)
            }
        })
  }

  disconnect() {
      return this.http.post(this.logoutEndPoint, { }).subscribe(()=> {
          this.storageService.clean()
          this.router.navigate(['login'])
      });
  }
}
