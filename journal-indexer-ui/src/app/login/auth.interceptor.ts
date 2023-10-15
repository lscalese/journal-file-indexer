import { Injectable } from '@angular/core';
import { StorageService} from "./login/storage.service";
import { HttpHandler, HttpInterceptor, HttpRequest } from '@angular/common/http';

@Injectable()
export class AuthInterceptor implements HttpInterceptor {

    constructor(private storageService: StorageService) {}

    intercept(req: HttpRequest<any>, next: HttpHandler) {
        // Get the auth token from the service.
        const authToken = this.storageService.getToken();

        // Clone the request and replace the original headers with
        // cloned headers, updated with the authorization.
        if (authToken !== ''){
            req = req.clone({
                headers: req.headers.set('Authorization', 'Bearer ' + authToken)
            });
        }
        // send cloned request with header to the next handler.
        return next.handle(req);
    }
}
