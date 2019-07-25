import { Component, OnInit } from '@angular/core';
import { MatDialogRef, MatDialog } from '@angular/material/dialog';

import { GenericApiService } from '../core/generic-api.service';
import { IBase } from './ibase';
import { ActivatedRoute, Router } from "@angular/router";
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { first } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { Globals } from '../../globals';
import { IAssociationEntry } from '../core/iassociationentry';
import { IAssociation } from '../core/iassociation';

import { ISearchField, operatorType } from '../../common/components/list-filters/ISearchCriteria';
import { PickerDialogService, IFCDialogConfig } from '../../common/components/picker/picker-dialog.service';
@Component({

  template: ''

})
export class BaseDetailsComponent<E extends IBase> implements OnInit {

  associations: IAssociationEntry[];
  toMany: IAssociationEntry[];
  toOne: IAssociationEntry[];

  dialogRef: MatDialogRef<any>;
  pickerDialogRef: MatDialogRef<any>;

  title: string = 'Title';
  item: E | undefined;
  parentUrl: string;
  idParam: string;
  itemForm: FormGroup;
  errorMessage = '';
  loading = false;
  submitted = false;

  isMediumDeviceOrLess: boolean;
  mediumDeviceOrLessDialogSize: string = "100%";
  largerDeviceDialogWidthSize: string = "65%";
  largerDeviceDialogHeightSize: string = "75%";

  /*constructor(private route: ActivatedRoute, private userService: UserService) { 
     this.route.params.subscribe( params => this.user$ = params.id );
  }*/
  constructor(
    public formBuilder: FormBuilder,
    public router: Router,
    public route: ActivatedRoute,
    public dialog: MatDialog,
    public global: Globals,
		public pickerDialogService: PickerDialogService,
    public dataService: GenericApiService<E>
    
    ) {
  }

  ngOnInit() {
    this.idParam = this.route.snapshot.paramMap.get('id');
    this.manageScreenResizing();
  }

  manageScreenResizing() {
    this.global.isMediumDeviceOrLess$.subscribe(value => {
      this.isMediumDeviceOrLess = value;
      if (this.dialogRef)
        this.dialogRef.updateSize(value ? this.mediumDeviceOrLessDialogSize : this.largerDeviceDialogWidthSize,
          value ? this.mediumDeviceOrLessDialogSize : this.largerDeviceDialogHeightSize);
    });
  }

  getItem(id: number): Observable<E> {
    return this.dataService.getById(id);
  }

  onSubmit() {
    this.submitted = true;

    // stop here if form is invalid
    if (this.itemForm.invalid) {
      return;
    }

    this.loading = true;
    this.dataService.update(this.itemForm.value, this.item.id)
      .pipe(first())
      .subscribe(
        data => {
          // this.alertService.success('Registration successful', true);
          this.loading = false;
         // this.router.navigate([this.parentUrl]);
         this.router.navigate([this.parentUrl],{ relativeTo: this.route.parent });
          //  this.dialogRef.close(data);
        },
        error => {

          this.loading = false;
        });
  }

  onBack(): void {
  //  this.router.navigate([this.parentUrl]);
    this.router.navigate([this.parentUrl],{ relativeTo: this.route.parent });
  }

  selectAssociation(association) {
		let parentField: string = association.descriptiveField.replace(association.table, '');
		parentField = parentField.charAt(0).toLowerCase() + parentField.slice(1);

		let dialogConfig: IFCDialogConfig = <IFCDialogConfig>{
			Title: association.table,
			IsSingleSelection: true,
			DisplayField: parentField
		};

		this.pickerDialogRef = this.pickerDialogService.open(dialogConfig);

		this.initializePickerPageInfo();
		association.service.getAll(this.searchValuePicker, this.currentPickerPage * this.pickerPageSize, this.pickerPageSize).subscribe(items => {
			this.isLoadingPickerResults = false;
			this.pickerDialogRef.componentInstance.items = items;
			this.updatePickerPageInfo(items);
		},
			error => this.errorMessage = <any>error
		);

		this.pickerDialogRef.componentInstance.onScroll.subscribe(data => {
			this.onPickerScroll();
		})

		this.pickerDialogRef.componentInstance.onSearch.subscribe(data => {
			this.onPickerSearch(data);
		})

		this.pickerDialogRef.afterClosed().subscribe(associatedItem => {
			if (associatedItem) {
				this.itemForm.get(association.column.key).setValue(associatedItem.id);
				this.itemForm.get(association.descriptiveField).setValue(associatedItem[parentField]);
			}
		});
  }
  
  isLoadingPickerResults = true;

	currentPickerPage: number;
	pickerPageSize: number;
	lastProcessedOffsetPicker: number;
	hasMoreRecordsPicker: boolean;

	searchValuePicker: ISearchField[] = [];
	pickerItemsObservable: Observable<any>;

	initializePickerPageInfo() {
		this.hasMoreRecordsPicker = true;
		this.pickerPageSize = 20;
		this.lastProcessedOffsetPicker = -1;
		this.currentPickerPage = 0;
	}

	//manage pages for virtual scrolling
	updatePickerPageInfo(data) {
		if (data.length > 0) {
			this.currentPickerPage++;
			this.lastProcessedOffsetPicker += data.length;
		}
		else {
			this.hasMoreRecordsPicker = false;
		}
	}

	onPickerScroll() {
		if (!this.isLoadingPickerResults && this.hasMoreRecordsPicker && this.lastProcessedOffsetPicker < this.pickerDialogRef.componentInstance.items.length) {
			this.isLoadingPickerResults = true;
			let selectedAssociation: IAssociationEntry = this.toOne.find(association => association.table === this.pickerDialogRef.componentInstance.title);

			selectedAssociation.service.getAll(this.searchValuePicker, this.currentPickerPage * this.pickerPageSize, this.pickerPageSize).subscribe(items => {
				this.isLoadingPickerResults = false;
				this.pickerDialogRef.componentInstance.items = this.pickerDialogRef.componentInstance.items.concat(items);
				this.updatePickerPageInfo(items);
			},
				error => this.errorMessage = <any>error
			);

		}
	}

	onPickerSearch(searchValue: string) {
		if (searchValue) {
			let searchField: ISearchField = {
				fieldName: this.pickerDialogRef.componentInstance.displayField,
				operator: operatorType.Contains,
				searchValue: searchValue
			}
			this.searchValuePicker = [searchField];
		}

		this.initializePickerPageInfo();

		let selectedAssociation: IAssociationEntry = this.toOne.find(association => association.table === this.pickerDialogRef.componentInstance.title);

		selectedAssociation.service.getAll(this.searchValuePicker, this.currentPickerPage * this.pickerPageSize, this.pickerPageSize).subscribe(items => {
			this.isLoadingPickerResults = false;
			this.pickerDialogRef.componentInstance.items = items;
			this.updatePickerPageInfo(items);
		},
			error => this.errorMessage = <any>error
		);
	}

  getQueryParams(association) {
    let queryParam: any = {};
    queryParam[association.column.key] = this.item.id;
    return queryParam;
  }

}