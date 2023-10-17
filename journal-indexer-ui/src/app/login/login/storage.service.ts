import { Injectable } from '@angular/core';

const USER_KEY = 'auth-user';

@Injectable({
    providedIn: 'root'
})
export class StorageService {
    constructor() {}

    clean(): void {
        // @ts-ignore
        window.sessionStorage.removeItem(USER_KEY);
    }

    save(userToken: string): void {
        // @ts-ignore
        window.sessionStorage.setItem(USER_KEY, userToken);
    }

    public isLoggedIn(): boolean {
        // @ts-ignore
        const user = window.sessionStorage.getItem(USER_KEY);
        return !!user;
    }

    public getToken(): string {
        // @ts-ignore
        const user = window.sessionStorage.getItem(USER_KEY);
        if (user) {
            return user;
        }
        else {
            return "";
        }
    }
}
