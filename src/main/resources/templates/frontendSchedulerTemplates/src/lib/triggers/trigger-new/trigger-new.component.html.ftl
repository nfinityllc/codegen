<div>
  <mat-toolbar class="action-tool-bar" color="primary">
    <button name="cancel" mat-flat-button (click)="onCancel()">
      {{'SCHEDULER-GENERAL.ACTIONS.CANCEL' | translate}} </button>
    <span class="middle">{{'TRIGGERS.TITLE' | translate}}</span>

    <button mat-flat-button name="save" (click)="jobNgForm.ngSubmit.emit()" [disabled]="!triggerForm.valid || loading">
      {{'SCHEDULER-GENERAL.ACTIONS.SAVE' | translate}} </button>

  </mat-toolbar>
  <mat-card>
    <h2>New Trigger</h2>
    <form [formGroup]="triggerForm" #jobNgForm="ngForm" (ngSubmit)="onSubmit()" class="trigger-form">
      <div class="full-width">
        <div class="button-row">
          <mat-radio-group name="type" *ngFor="let type of triggerTypes" formControlName="triggerType" class="trigger-type">
            <mat-radio-button [value]="type">{{type}}</mat-radio-button>
          </mat-radio-group>
        </div>
        <div class="button-row">
          <button mat-raised-button color="accent" title="select-job" (click)="selectJob()">Select job</button>
        </div>
        <mat-form-field [ngClass]="{'medium-device-width': isMediumDeviceOrLess, 'large-device-width' : !isMediumDeviceOrLess}">
          <input formControlName="jobName" matInput placeholder="{{'TRIGGERS.FIELDS.JOB-NAME' | translate}}">
          <mat-error *ngIf="!triggerForm.get('jobName').valid && triggerForm.get('jobName').touched">{{'SCHEDULER-GENERAL.ERRORS.REQUIRED' | translate}}</mat-error>
        </mat-form-field>

        <mat-form-field [ngClass]="{'medium-device-width': isMediumDeviceOrLess, 'large-device-width' : !isMediumDeviceOrLess}">
          <input formControlName="jobGroup" matInput placeholder="{{'TRIGGERS.FIELDS.JOB-GROUP' | translate}}">
          <mat-error *ngIf="!triggerForm.get('jobGroup').valid && triggerForm.get('jobGroup').touched">{{'SCHEDULER-GENERAL.ERRORS.REQUIRED' | translate}}</mat-error>
        </mat-form-field>

        <mat-form-field [ngClass]="{'medium-device-width': isMediumDeviceOrLess, 'large-device-width' : !isMediumDeviceOrLess}">
          <input formControlName="triggerName" matInput placeholder="{{'TRIGGERS.FIELDS.NAME' | translate}}">
          <mat-error *ngIf="!triggerForm.get('triggerName').valid && triggerForm.get('triggerName').touched">{{'SCHEDULER-GENERAL.ERRORS.REQUIRED' | translate}}</mat-error>
        </mat-form-field>

        <mat-form-field [ngClass]="{'medium-device-width': isMediumDeviceOrLess, 'large-device-width' : !isMediumDeviceOrLess}">
          <input placeholder="{{'TRIGGERS.FIELDS.GROUP' | translate}}" formControlName="triggerGroup" matInput [matAutocomplete]="auto">
          <mat-autocomplete #auto="matAutocomplete">
            <mat-option *ngFor="let group of filteredOptions | async" [value]="group">
              {{group}}
            </mat-option>
          </mat-autocomplete>
          <mat-error *ngIf="!triggerForm.get('triggerGroup').valid && triggerForm.get('triggerGroup').touched">{{'SCHEDULER-GENERAL.ERRORS.REQUIRED' | translate}}</mat-error>
        </mat-form-field>

        <mat-form-field [ngClass]="{'medium-device-width': isMediumDeviceOrLess, 'large-device-width' : !isMediumDeviceOrLess}">
          <input matInput [matDatepicker]="startDatePicker" formControlName="startDate" placeholder="{{'TRIGGERS.FIELDS.START-DATE' | translate}}">
          <mat-datepicker-toggle matSuffix [for]="startDatePicker"></mat-datepicker-toggle>
          <mat-datepicker #startDatePicker></mat-datepicker>
          <mat-error *ngIf="!triggerForm.get('startDate').valid && triggerForm.get('startDate').touched"></mat-error>
        </mat-form-field>

        <mat-form-field [ngClass]="{'medium-device-width': isMediumDeviceOrLess, 'large-device-width' : !isMediumDeviceOrLess}">
          <input matInput [ngxTimepicker]="startTimePicker" formControlName="startTime" placeholder="{{'TRIGGERS.FIELDS.START-TIME' | translate}}">
          <ngx-material-timepicker #startTimePicker></ngx-material-timepicker>
          <mat-error *ngIf="!triggerForm.get('startTime').valid && triggerForm.get('startTime').touched">{{'SCHEDULER-GENERAL.ERRORS.INVALID-FORMAT' | translate}}</mat-error>
        </mat-form-field>

        <mat-form-field [ngClass]="{'medium-device-width': isMediumDeviceOrLess, 'large-device-width' : !isMediumDeviceOrLess}">
          <input matInput [matDatepicker]="endDatePicker" formControlName="endDate" placeholder="{{'TRIGGERS.FIELDS.END-DATE' | translate}}">
          <mat-datepicker-toggle matSuffix [for]="endDatePicker"></mat-datepicker-toggle>
          <mat-datepicker #endDatePicker></mat-datepicker>
          <mat-error *ngIf="!triggerForm.get('endDate').valid && triggerForm.get('endDate').touched"></mat-error>
        </mat-form-field>

        <mat-form-field [ngClass]="{'medium-device-width': isMediumDeviceOrLess, 'large-device-width' : !isMediumDeviceOrLess}">
          <input matInput [ngxTimepicker]="endTimePicker" formControlName="endTime" placeholder="{{'TRIGGERS.FIELDS.END-TIME' | translate}}">
          <ngx-material-timepicker #endTimePicker></ngx-material-timepicker>
          <mat-error *ngIf="!triggerForm.get('endTime').valid && triggerForm.get('endTime').touched">{{'SCHEDULER-GENERAL.ERRORS.INVALID-FORMAT' | translate}}</mat-error>
        </mat-form-field>

        <mat-form-field [ngClass]="{'medium-device-width': isMediumDeviceOrLess, 'large-device-width' : !isMediumDeviceOrLess}"
          [hidden]="triggerForm.get('triggerType').value !== triggerTypes[1]">
          <input formControlName="cronExpression" matInput placeholder="{{'TRIGGERS.FIELDS.CRON-EXPRESSION' | translate}}">
          <mat-error *ngIf="!triggerForm.get('cronExpression').valid && triggerForm.get('cronExpression').touched">{{'SCHEDULER-GENERAL.ERRORS.REQUIRED' | translate}}</mat-error>
        </mat-form-field>

        <mat-form-field [ngClass]="{'medium-device-width': isMediumDeviceOrLess, 'large-device-width' : !isMediumDeviceOrLess}"
          [hidden]="triggerForm.get('triggerType').value === triggerTypes[1]">
          <input type="number" formControlName="repeatInterval" matInput placeholder="{{'TRIGGERS.FIELDS.REPEAT-INTERVEL' | translate}}">
          <mat-error *ngIf="!triggerForm.get('repeatInterval').valid && triggerForm.get('repeatInterval').touched">{{'SCHEDULER-GENERAL.ERRORS.REQUIRED' | translate}}</mat-error>
        </mat-form-field>

        <span [ngClass]="{'medium-device-width': isMediumDeviceOrLess, 'large-device-width' : !isMediumDeviceOrLess}"
          [hidden]="triggerForm.get('triggerType').value === triggerTypes[1] ">
          <mat-checkbox formControlName="repeatIndefinite">{{'TRIGGERS.FIELDS.REPEAT-INDEFINITELY' | translate}}</mat-checkbox>
        </span>

        <mat-form-field [ngClass]="{'medium-device-width': isMediumDeviceOrLess, 'large-device-width' : !isMediumDeviceOrLess}"
          [hidden]="triggerForm.get('triggerType').value === triggerTypes[1] || (triggerForm.get('repeatIndefinite').value)">
          <input type="number" formControlName="repeatCount" matInput placeholder="{{'TRIGGERS.FIELDS.REPEAT-COUNT' | translate}}">
          <mat-error *ngIf="!triggerForm.get('repeatCount').valid && triggerForm.get('repeatCount').touched">{{'SCHEDULER-GENERAL.ERRORS.REQUIRED' | translate}}</mat-error>
        </mat-form-field>

        <mat-form-field [ngClass]="{'medium-device-width': isMediumDeviceOrLess, 'large-device-width' : !isMediumDeviceOrLess}">
          <textarea formControlName="description" matInput placeholder="{{'TRIGGERS.FIELDS.DESCRIPTION' | translate}}"></textarea>
          <mat-error *ngIf="!triggerForm.get('description').valid && triggerForm.get('description').touched">{{'SCHEDULER-GENERAL.ERRORS.LENGTH-EXCEDDING' | translate : {length : 80} }}</mat-error>
        </mat-form-field>

        <div class="full-width">
          <label style="margin-bottom: 10px">{{'TRIGGERS.FIELDS.JOB-MAP-DATA' | translate}}
            <mat-icon (click)="addJobData()">add_circle</mat-icon>
          </label>
          <table mat-table [dataSource]="dataSource" class="mat-elevation-z8">

            <!-- Key Column -->
            <ng-container matColumnDef="position">
              <th mat-header-cell *matHeaderCellDef> {{'JOB-DATA.KEY' | translate}} </th>
              <td mat-cell *matCellDef="let element">
                <input matInput [(ngModel)]="element.dataKey" [ngModelOptions]="{standalone: true}">
              </td>
            </ng-container>

            <!-- Value Column -->
            <ng-container matColumnDef="name">
              <th mat-header-cell *matHeaderCellDef> {{'JOB-DATA.VALUE' | translate}} </th>
              <td mat-cell *matCellDef="let element">
                <input matInput [(ngModel)]="element.dataValue" [ngModelOptions]="{standalone: true}">
              </td>
            </ng-container>

            <!-- Actions -->
            <ng-container matColumnDef="actions">
              <th mat-header-cell *matHeaderCellDef> {{'SCHEDULER-GENERAL.ACTIONS.ACTIONS' | translate}} </th>
              <td mat-cell *matCellDef="let element; let i = index;">
                <mat-icon (click)="removeJobData(i)">remove_circle</mat-icon>
              </td>
            </ng-container>

            <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
            <tr mat-row *matRowDef="let row; columns: displayedColumns;"></tr>
          </table>
        </div>
      </div>
    </form>
  </mat-card>
</div>