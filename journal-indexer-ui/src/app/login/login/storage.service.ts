import { Injectable } from '@angular/core';

const USER_KEY = 'auth-user';

@Injectable({
    providedIn: 'root'
})
export class StorageService {
    constructor() {}

    clean(): void {
        window.sessionStorage.removeItem(USER_KEY);
    }

    save(userToken: string): void {
        window.sessionStorage.setItem(USER_KEY, userToken);
    }

    public isLoggedIn(): boolean {
        const user = window.sessionStorage.getItem(USER_KEY);
        return !!user;
    }

    public getToken(): string {
        const user = window.sessionStorage.getItem(USER_KEY);
        if (user) {
            return user;
        }
        else {
            return "";
        }
    }
}
