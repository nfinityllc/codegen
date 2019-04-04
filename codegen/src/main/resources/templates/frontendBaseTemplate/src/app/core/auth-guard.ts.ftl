import { Injectable } from '@angular/core';
import { Router, CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot } from '@angular/router';
import {AuthenticationService} from './authentication.service'
@Injectable()
export class AuthGuard implements CanActivate {
  
  constructor( private router: Router, private authSrv:AuthenticationService ) {}

  canActivate( route: ActivatedRouteSnapshot, state: RouterStateSnapshot ) {

  	if ( localStorage.getItem( 'token' ) ) {
  		// Logged in so return true
  		return true;
  	}
this.authSrv.postLogin({"userName": "employee2","password": "secret" }).subscribe(log=> {
    let l = log;
    return true;
  },error => {
    return false;
   });
  	
  //	this.router.navigate( ['/login'], { queryParams: { returnUrl: state.url } } );
  	return false;
  }

}