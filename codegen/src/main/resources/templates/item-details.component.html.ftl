<div *ngIf="item">
	<mat-toolbar class="action-tool-bar" color="primary">
		<button mat-flat-button (click)="onBack()">
	    Cancel </button>
		<span class="middle">{{title}}</span>
	
		<button mat-flat-button (click)="itemNgForm.ngSubmit.emit()">
	    Save </button>
	</mat-toolbar>
	<mat-card>
		<mat-card-content>
			<form [formGroup]="itemForm" #itemNgForm="ngForm" (ngSubmit)="onSubmit()" class="item-form">
			<#list Fields as key,value>
			<#if value.fieldName?lower_case == "id">    
			<#elseif value.fieldType?lower_case == "boolean">    
				<mat-checkbox formControlName="[=value.fieldName]">[=value.fieldName]</mat-checkbox>            
			<#elseif value.fieldType == "Date">
				<mat-form-field>
					<input formControlName="[=value.fieldName]" matInput [matDatepicker]="[=value.fieldName]Picker" placeholder="Enter [=value.fieldName]">
					<mat-datepicker-toggle matSuffix [for]="[=value.fieldName]Picker"></mat-datepicker-toggle>
					<mat-datepicker #[=value.fieldName]Picker></mat-datepicker>
					<#if value.isNullable == false>
					<mat-error *ngIf="!itemForm.get('[=value.fieldName]').valid && itemForm.get('[=value.fieldName]').touched">[=value.fieldName] is required</mat-error>
					</#if>
				</mat-form-field>
			<#elseif value.fieldType?lower_case == "string">
				<mat-form-field>
					<input formControlName="[=value.fieldName]" matInput placeholder="Enter [=value.fieldName]">
					<#if value.isNullable == false>
					<mat-error *ngIf="!itemForm.get('[=value.fieldName]').valid && itemForm.get('[=value.fieldName]').touched">[=value.fieldName] is required</mat-error>
				    </#if>
				</mat-form-field>
			<#elseif value.fieldType?lower_case == "long" ||  value.fieldType?lower_case == "int">
				<mat-form-field>
					<input type="number" formControlName="[=value.fieldName]" matInput placeholder="Enter [=value.fieldName]">
					<#if value.isNullable == false>
					<mat-error *ngIf="!itemForm.get('[=value.fieldName]').valid && itemForm.get('[=value.fieldName]').touched">[=value.fieldName] is required</mat-error>
				    </#if>
				</mat-form-field>
			</#if>
			</#list>
			
				<mat-form-field *ngFor="let association of toOne">
					<input matInput disabled placeholder="{{association.table}}" value="{{item[association.descriptiveField]}}">
				</mat-form-field>
				
				<div *ngFor="let association of toMany">
					<a [routerLink]="['/' + association.table]" [queryParams]="getQueryParams(association)" class="btn btn-link">{{association.table}}</a>
				</div>
			</form>
		</mat-card-content>
	</mat-card>
</div>