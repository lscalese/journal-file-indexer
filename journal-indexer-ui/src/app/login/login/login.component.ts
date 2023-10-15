import {Component, OnInit} from '@angular/core';
import {AbstractControl, FormBuilder, FormGroup, ValidationErrors, ValidatorFn, Validators} from "@angular/forms";
import {LoginService} from "../login.service";

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit{

  loginForm: FormGroup = new FormGroup({});

  constructor(private formBuilder: FormBuilder,
              private loginService: LoginService) {
  }

  ngOnInit() {
    this.loginForm =this.formBuilder.group({
      username:['', [Validators.required]],
      password:['', Validators.required]
    })
  }

  onSubmit() {
    this.loginService.login(this.loginForm.get('username')?.value, this.loginForm.get('password')?.value)
  }

}
