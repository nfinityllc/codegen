package com.nfinity.entitycodegen;

public class FieldDetails {

	String fieldName;
	String fieldType;
	boolean isAutogenerated;
	boolean isNullable=true;
	boolean isPrimaryKey;
	int length;
	String description;
	
	
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public String getFieldName() {
		return fieldName;
	}
	public void setFieldName(String fieldName) {
		this.fieldName = fieldName;
	}
	public String getFieldType() {
		return fieldType;
	}
	public void setFieldType(String fieldType) {
		this.fieldType = fieldType;
	}
	
	public boolean getIsAutogenerated() {
		return isAutogenerated;
	}
	public void setIsAutogenerated(boolean isAutogenerated) {
		this.isAutogenerated = isAutogenerated;
	}
	public boolean getIsNullable() {
		return isNullable;
	}
	public void setIsNullable(boolean isNullable) {
		this.isNullable = isNullable;
	}
	public boolean getIsPrimaryKey() {
		return isPrimaryKey;
	}
	public void setIsPrimaryKey(boolean isPrimaryKey) {
		this.isPrimaryKey = isPrimaryKey;
	}
	public int getLength() {
		return length;
	}
	public void setLength(int length) {
		this.length = length;
	}
}
