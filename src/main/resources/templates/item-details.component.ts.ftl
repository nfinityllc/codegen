import { Component, OnInit } from '@angular/core';
import { ActivatedRoute,Router} from "@angular/router";
import { FormBuilder, FormGroup, Validators} from '@angular/forms';
import { first } from 'rxjs/operators';
import { MatDialogRef, MatDialog } from '@angular/material/dialog';

import { [=ClassName]Service } from './[=ModuleName].service';
import { [=IEntity] } from './[=IEntityFile]';
import { BaseDetailsComponent, Globals, PickerDialogService, ErrorService } from 'projects/fast-code-core/src/public_api';

<#if Relationship?has_content>
<#list Relationship as relationKey, relationValue>
<#if relationValue.relation == "ManyToOne" || (relationValue.relation == "OneToOne" && relationValue.isParent == false)>
import { [=relationValue.eName]Service } from '../[=relationValue.eModuleName]/[=relationValue.eModuleName].service';
</#if>
</#list>
</#if>
<#if AuthenticationType != "none" && ClassName == AuthenticationTable>
import { RoleService} from '../role/role.service';
</#if>

<#if AuthenticationType !="none" >
import { GlobalPermissionService } from '../core/global-permission.service';
</#if>

@Component({
  selector: 'app-[=ModuleName]-details',
  templateUrl: './[=ModuleName]-details.component.html',
  styleUrls: ['./[=ModuleName]-details.component.scss']
})
export class [=ClassName]DetailsComponent extends BaseDetailsComponent<[=IEntity]> implements OnInit {
	title:string='[=ClassName]';
	parentUrl:string='[=ApiPath?lower_case]';
	//roles: IRole[];  
	constructor(
		public formBuilder: FormBuilder,
		public router: Router,
		public route: ActivatedRoute,
		public dialog: MatDialog,
		public global: Globals,
		public dataService: [=ClassName]Service,
		public pickerDialogService: PickerDialogService,
		public errorService: ErrorService,
		<#if Relationship?has_content>
		<#list Relationship as relationKey, relationValue>
		<#if relationValue.relation == "ManyToOne" || (relationValue.relation == "OneToOne" && relationValue.isParent == false)>
		public [=relationValue.eName?uncap_first]Service: [=relationValue.eName]Service,
		</#if>
		</#list>
		</#if>
		<#if AuthenticationType != "none" && ClassName == AuthenticationTable>
		public roleService: RoleService,
		</#if>
		<#if AuthenticationType !="none" >
		public globalPermissionService: GlobalPermissionService,
		</#if>
	) {
		super(formBuilder, router, route, dialog, global, pickerDialogService, dataService, errorService);
  }

	ngOnInit() {
		this.entityName = '[=ClassName]';
		this.setAssociations();
		super.ngOnInit();
		this.setForm();
    this.getItem();
  }
  
  setForm(){
    this.itemForm = this.formBuilder.group({
      <#list Fields as key,value>
      <#-- to exclude the password field in case of user provided "User" table -->
      <#assign isPasswordField = false>
      <#if AuthenticationType != "none" && ClassName == AuthenticationTable>  
        <#if AuthenticationFields?? && AuthenticationFields.Password.fieldName == value.fieldName>
      <#assign isPasswordField = true>
      </#if>
      </#if>
      <#if isPasswordField == false>
        <#if value.fieldType?lower_case == "boolean">
      <#if value.isNullable == false>
      [=value.fieldName]: [false, Validators.required],
      <#else>
      [=value.fieldName]: [false],
      </#if>
      <#elseif !value.isAutogenerated && (value.fieldType?lower_case == "date" || value.fieldType?lower_case == "string" || value.fieldType?lower_case == "long" ||  value.fieldType?lower_case == "integer" ||  value.fieldType?lower_case == "short" ||  value.fieldType?lower_case == "double")>
      <#if value.isNullable == false>          
      [=value.fieldName]: ['', Validators.required],
      <#else>
      [=value.fieldName]: [''],
      </#if>
      <#elseif value.isAutogenerated>
      [=value.fieldName]: [{value: '', disabled: true}, Validators.required],
          </#if>
            </#if>
      </#list>
      <#if Relationship?has_content>
      <#list Relationship as relationKey, relationValue>
      <#if relationValue.relation == "ManyToOne" || (relationValue.relation == "OneToOne" && relationValue.isParent == false)>
      <#list relationValue.joinDetails as joinDetails>
            <#if joinDetails.joinEntityName == relationValue.eName>
            <#if joinDetails.joinColumn??>
            <#if !Fields[joinDetails.joinColumn]?? && !(DescriptiveField[relationValue.eName]?? && (joinDetails.joinColumn == relationValue.eName?uncap_first + DescriptiveField[relationValue.eName].fieldName?cap_first ))>
      <#if joinDetails.isJoinColumnOptional==false>          
      [=joinDetails.joinColumn]: ['', Validators.required],
      <#else>
      [=joinDetails.joinColumn]: [''],
      </#if>
            </#if>
            </#if>
            </#if>
            </#list>
            <#if DescriptiveField[relationValue.eName]?? && DescriptiveField[relationValue.eName].description??>
      [=DescriptiveField[relationValue.eName].description?uncap_first] : [{ value: '', disabled: true }],
      </#if>
            </#if>
      </#list>
      </#if>
      <#if AuthenticationType != "none" && ClassName == AuthenticationTable>
      roleId: [''],
      roleDescriptiveField : [{ value: '', disabled: true }],
      </#if>
      
    });
      
  }
  
  
	setAssociations(){
  	
		this.associations = [
		<#if Relationship?has_content> 
		<#list Relationship as relationKey, relationValue>
			{
				column: [
				    <#list relationValue.joinDetails as joinDetails>
                    <#if joinDetails.joinEntityName == relationValue.eName>
                    <#if joinDetails.joinColumn??>
					{
						key: '[=joinDetails.joinColumn]',
						value: undefined,
						referencedkey: '[=joinDetails.referenceColumn]'
					},
					</#if>
                    </#if>
                    </#list>  
				],
				<#if relationValue.relation == "OneToMany">
				isParent: true,
				<#elseif relationValue.relation == "ManyToOne">
				isParent: false,
				<#elseif relationValue.relation == "OneToOne">
				<#if relationValue.isParent!false>
				isParent: true,
				<#else>
				isParent: false,
				</#if>
				</#if>
				table: '[=relationValue.eName?uncap_first]',
				type: '[=relationValue.relation]',
				<#if relationValue.relation == "ManyToOne" || (relationValue.relation == "OneToOne" && relationValue.isParent == false)>
				service: this.[=relationValue.eName?uncap_first]Service,
				<#if DescriptiveField[relationValue.eName]?? && DescriptiveField[relationValue.eName].description??>
				descriptiveField: '[=DescriptiveField[relationValue.eName].description?uncap_first]',
			    referencedDescriptiveField: '[=DescriptiveField[relationValue.eName].fieldName]',
			    </#if>
			    <#elseif relationValue.relation == "OneToOne" && relationValue.isParent == true>
			    associatedPrimaryKeys: [<#list relationValue.fDetails as value><#if value.isPrimaryKey == true> '[=value.fieldName]', </#if></#list>]
                </#if>
			},
		</#list>
		</#if>
		<#if AuthenticationType != "none" && ClassName == AuthenticationTable>
			{
				column: [
				    <#list PrimaryKeys as key,value>
					{
						key: '[=AuthenticationTable?uncap_first + key?cap_first]',
						value: undefined,
						referencedkey: '[=key?uncap_first]'
					},
					</#list>
				],
				isParent: true,
				table: '[=AuthenticationTable?lower_case]permission',
				type: 'OneToMany',
			},
			{
				column: [
					{
						key: 'roleId',
						value: undefined,
						referencedkey: 'id'
					},
				],
				isParent: false,
				table: 'role',
				type: 'ManyToOne',
				service: this.roleService,
				descriptiveField: 'roleDescriptiveField',
				referencedDescriptiveField: 'name',
			},
		</#if>
		];
		
		this.childAssociations = this.associations.filter(association => {
			return (association.isParent);
		});

		this.parentAssociations = this.associations.filter(association => {
			return (!association.isParent);
		});
	}
}
