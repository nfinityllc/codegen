package [=PackageName].application.Authorization.User;

import [=CommonModulePackage].Search.SearchCriteria;
import [=CommonModulePackage].Search.SearchFields;
import [=PackageName].application.Authorization.User.Dto.CreateUserInput;
import [=PackageName].application.Authorization.User.Dto.FindUserByIdOutput;
import [=PackageName].application.Authorization.User.Dto.UpdateUserInput;
import [=PackageName].domain.model.PermissionEntity;
<#if Flowable!false>
import [=PackageName].application.Flowable.ActIdUserMapper;
import [=PackageName].application.Flowable.FlowableIdentityService;
import [=PackageName].domain.Flowable.Users.ActIdUserEntity;
</#if>
import [=PackageName].domain.Authorization.Permission.PermissionManager;
import [=PackageName].application.Authorization.Permission.PermissionAppService;
import [=PackageName].domain.model.RoleEntity;
import [=PackageName].domain.Authorization.Role.RoleManager;
import [=PackageName].domain.Authorization.User.UserManager;
import [=PackageName].domain.model.UserEntity;
import [=PackageName].domain.model.QUserEntity;
import [=CommonModulePackage].logging.LoggingHelper;
import com.querydsl.core.BooleanBuilder;
import com.querydsl.core.types.Predicate;

import org.assertj.core.api.Assertions;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.slf4j.Logger;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@RunWith(SpringJUnit4ClassRunner.class)
public class UserAppServiceTest {

	@InjectMocks
	UserAppService userAppService;

	@Mock
	UserManager userManager;

	@Mock
	PermissionManager permissionManager;
	
	@Mock
	private PermissionAppService  permissionsAppService;

	@Mock
	RoleManager roleManager;

	@Mock
	UserMapper userMapper;

	@Mock
	private Logger loggerMock;

	@Mock
	private LoggingHelper logHelper;
    <#if Flowable!false>
   
	@Mock
	private ActIdUserMapper actIdUserMapper;
	
	@Mock
	private FlowableIdentityService idmIdentityService;
    
    </#if>
	private static long ID=15;

	@Before
	public void setUp() throws Exception {
		MockitoAnnotations.initMocks(userAppService);
		when(logHelper.getLogger()).thenReturn(loggerMock);
		doNothing().when(loggerMock).error(anyString());

	}

	@After
	public void tearDown() throws Exception {
	}


	@Test 
	public void findUserById_IdIsNotNullAndIdDoesNotExist_ReturnNull() {

		Mockito.when(userManager.FindById(anyLong())).thenReturn(null);	
		Assertions.assertThat(userAppService.FindById(ID)).isEqualTo(null);	

	}

	@Test
	public void findUserById_IdIsNotNullAndUserExists_ReturnAUser() {

		UserEntity user = mock(UserEntity.class);

		Mockito.when(userManager.FindById(anyLong())).thenReturn(user);
		Assertions.assertThat(userAppService.FindById(ID)).isEqualTo(userMapper.UserEntityToCreateUserOutput(user));
	}

	@Test 
	public void findUserByName_NameIsNotNullAndUserDoesNotExist_ReturnNull() {

		Mockito.when(userManager.FindByUserName(anyString())).thenReturn(null);	
		Assertions.assertThat(userAppService.FindByUserName("User1")).isEqualTo(null);	

	}

	@Test
	public void findUserByName_NameIsNotNullAndUserExists_ReturnAUser() {

		UserEntity user = mock(UserEntity.class);

		Mockito.when(userManager.FindByUserName(anyString())).thenReturn(user);
		Assertions.assertThat(userAppService.FindByUserName("User1")).isEqualTo(userMapper.UserEntityToCreateUserOutput(user));
	}

	@Test
	public void createUser_UserIsNotNullAndUserDoesNotExist_StoreAUser() {

		UserEntity userEntity = mock(UserEntity.class);
		CreateUserInput user=mock(CreateUserInput.class);
		RoleEntity foundRole = mock(RoleEntity.class);
		
		
		Mockito.when(roleManager.FindById(anyLong())).thenReturn(foundRole);
		Mockito.when(userManager.Create(any(UserEntity.class))).thenReturn(userEntity);
		<#if Flowable!false>
		ActIdUserEntity actIdUser = mock (ActIdUserEntity.class);
		Mockito.when(actIdUserMapper.createUsersEntityToActIdUserEntity(any(UserEntity.class))).thenReturn(actIdUser);
		doNothing().when(idmIdentityService).createUser(any(UserEntity.class),any(ActIdUserEntity.class));
		</#if>
		Mockito.when(userMapper.CreateUserInputToUserEntity(any(CreateUserInput.class))).thenReturn(userEntity);
		
		Assertions.assertThat(userAppService.Create(user)).isEqualTo(userMapper.UserEntityToCreateUserOutput(userEntity));
	}
	
	@Test
	public void createUser_UserIsNotNullAndUserDoesNotExistAndRoleIdIsNullAndRoleIdIsMandatory_ReturnNull() {

		CreateUserInput user = mock(CreateUserInput.class);
		
		Mockito.when(user.getRoleId()).thenReturn(null);
		Assertions.assertThat(userAppService.Create(user)).isEqualTo(null);
	}
	
	@Test
	public void createUser_UserIsNotNullAndUserDoesNotExistAndRoleIdIsNotNullAndRoleIdIsMandatoryAndRoleDoesNotExistIsNull_ReturnNull() {

		CreateUserInput user = mock(CreateUserInput.class);
		
		Mockito.when(roleManager.FindById(anyLong())).thenReturn(null);
		Assertions.assertThat(userAppService.Create(user)).isEqualTo(null);
	}

	@Test
	public void deleteUser_UserIsNotNullAndUserExists_UserRemoved() {

		UserEntity user=mock(UserEntity.class);

        <#if Flowable!false>
		Mockito.when(userManager.FindById(anyLong())).thenReturn(user);
		doNothing().when(idmIdentityService).deleteUser(any(String.class));
	    </#if>
		userAppService.Delete(ID);
		verify(userManager).Delete(user);
	}
	
		@Test
	public void updateUser_UserIsNotNullAndUserDoesNotExistAndChildIsNullAndChildIsMandatory_ReturnNull() {

		UpdateUserInput user = mock(UpdateUserInput.class);
		
		Mockito.when(user.getRoleId()).thenReturn(null);
		Assertions.assertThat(userAppService.Update(ID,user)).isEqualTo(null);
	}
	
	@Test
	public void updateUser_UserIsNotNullAndUserDoesNotExistAndChildIsNotNullAndChildIsMandatoryAndFindByIdIsNull_ReturnNull() {

		UpdateUserInput user = mock(UpdateUserInput.class);
		
		Mockito.when(roleManager.FindById(anyLong())).thenReturn(null);
		Assertions.assertThat(userAppService.Update(ID,user)).isEqualTo(null);
	}

	@Test
	public void updateUser_UserIdIsNotNullAndUserExistsAndRoleIdIsNotNull_ReturnUpdatedUser() {

		UserEntity userEntity = mock(UserEntity.class);
		UpdateUserInput user=mock(UpdateUserInput.class);
		RoleEntity foundRole = mock(RoleEntity.class);
		<#if Flowable!false>
		ActIdUserEntity actIdUser = mock (ActIdUserEntity.class); 
		Mockito.when(userManager.FindById(anyLong())).thenReturn(userEntity);
		Mockito.when(actIdUserMapper.createUsersEntityToActIdUserEntity(any(UserEntity.class))).thenReturn(actIdUser);
		doNothing().when(idmIdentityService).updateUser(any(UserEntity.class),any(ActIdUserEntity.class),anyString());
        </#if>
        
		Mockito.when(roleManager.FindById(anyLong())).thenReturn(foundRole);
		
		Mockito.when(userMapper.UpdateUserInputToUserEntity(any(UpdateUserInput.class))).thenReturn(userEntity);
		Mockito.when(userManager.Update(any(UserEntity.class))).thenReturn(userEntity);
		Assertions.assertThat(userAppService.Update(ID,user)).isEqualTo(userMapper.UserEntityToUpdateUserOutput(userEntity));

	}

	@Test
	public void Find_ListIsEmpty_ReturnList() throws Exception
	{
		List<UserEntity> list = new ArrayList<>();
		Page<UserEntity> foundPage = new PageImpl(list);
		Pageable pageable =mock(Pageable.class);

		List<FindUserByIdOutput> output = new ArrayList<>();
		SearchCriteria search= new SearchCriteria();
		search.setType(1);
		search.setValue("xyz");
		search.setOperator("equals");


		Mockito.when(userManager.FindAll(any(Predicate.class),any(Pageable.class))).thenReturn(foundPage);
		Assertions.assertThat(userAppService.Find(search,pageable)).isEqualTo(output);

	}

	@Test
	public void Find_ListIsNotEmpty_ReturnList() throws Exception
	{
		List<UserEntity> list = new ArrayList<>();
		UserEntity user=mock(UserEntity.class);
		list.add(user);
		Page<UserEntity> foundPage = new PageImpl(list);
		Pageable pageable =mock(Pageable.class);
		SearchCriteria search= new SearchCriteria();
		search.setType(1);
		search.setValue("xyz");
		search.setOperator("equals");

		List<FindUserByIdOutput> output = new ArrayList<>();
		output.add(userMapper.UserEntityToFindUserByIdOutput(user));
		Mockito.when(userManager.FindAll(any(Predicate.class),any(Pageable.class))).thenReturn(foundPage);
		Assertions.assertThat(userAppService.Find(search,pageable)).isEqualTo(output);

	}

	//Roles
	@Test
	public void GetRole_IfUserIdAndRoleIdIsNotNullAndUserExists_ReturnRole() {
		UserEntity user = mock(UserEntity.class);
		RoleEntity role = mock(RoleEntity.class);

		Mockito.when(userManager.FindById(anyLong())).thenReturn(user);
		Mockito.when(userManager.GetRole(anyLong())).thenReturn(role);
		Assertions.assertThat(userAppService.GetRole(ID)).isEqualTo(userMapper.RoleEntityToGetRoleOutput(role, user));
	}

	@Test 
	public void GetRole_IfUserIdAndRoleIdIsNotNullAndUserDoesNotExist_ReturnNull() {

		Mockito.when(userManager.FindById(anyLong())).thenReturn(null);
		Assertions.assertThat(userAppService.GetRole(ID)).isEqualTo(null);
	}

	@Test
	public void  searchAllProperties_SearchIsNotNull_ReturnBooleanBuilder()
	{
		String search= "xyz";
		String operator= "equals";
		QUserEntity user = QUserEntity.userEntity;
		BooleanBuilder builder = new BooleanBuilder();
		builder.or(user.authenticationSource.eq(search));
		builder.or(user.emailAddress.eq(search));
		builder.or(user.emailConfirmationCode.eq(search));
		builder.or(user.firstName.eq(search));
		builder.or(user.isPhoneNumberConfirmed.eq(search));
		builder.or(user.lastName.eq(search));
		builder.or(user.password.eq(search));
		builder.or(user.passwordResetCode.eq(search));
		builder.or(user.phoneNumber.eq(search));
		builder.or(user.userName.eq(search));
		
		Assertions.assertThat(userAppService.searchAllProperties(user,search,operator)).isEqualTo(builder);
	}

	@Test
	public void searchSpecificProperty_PropertyExists_ReturnBooleanBuilder() throws Exception
	{
		String operator= "equals";
		List<String> list = new ArrayList<>();
		list.add("firstName");
		list.add("userName");
		
		QUserEntity user = QUserEntity.userEntity;
		BooleanBuilder builder = new BooleanBuilder();
		builder.or(user.firstName.eq("xyz"));
		builder.or(user.userName.eq("xyz"));

		Assertions.assertThat(userAppService.searchSpecificProperty(user,list,"xyz",operator)).isEqualTo(builder);

	}
	
	@Test
	public void searchKeyValuePair_PropertyExists_ReturnBooleanBuilder()
	{
		QUserEntity user = QUserEntity.userEntity;
		SearchFields searchFields = new SearchFields();
		searchFields.setOperator("equals");
		searchFields.setSearchValue("xyz");
	    Map map = new HashMap();
        map.put("firstName",searchFields);
        BooleanBuilder builder = new BooleanBuilder();
        builder.and(user.firstName.eq("xyz"));
        Map searchMap = new HashMap();
        map.put("xyz",ID);
        
        Assertions.assertThat(userAppService.searchKeyValuePair(user, map,searchMap)).isEqualTo(builder);
	}

	@Test(expected = Exception.class)
	public void checkProperties_PropertyDoesNotExist_ThrowException() throws Exception
	{
		List<String> list = new ArrayList<>();
		list.add("first");

		userAppService.checkProperties(list);
	}
	@Test
	public void checkProperties_PropertyExists_ReturnNothing() throws Exception
	{
		List<String> list = new ArrayList<>();
		list.add("firstName");

		userAppService.checkProperties(list);
	}
	
	@Test
	public void search_SearchIsNotNullAndSearchContainsCaseOne_ReturnBooleanBuilder() throws Exception
	{
		QUserEntity user = QUserEntity.userEntity;
		SearchCriteria search= new SearchCriteria();
		search.setType(1);
		search.setValue("xyz");
		search.setOperator("equals");
        BooleanBuilder builder = new BooleanBuilder();
		builder.or(user.authenticationSource.eq("xyz"));
		builder.or(user.emailAddress.eq("xyz"));
		builder.or(user.emailConfirmationCode.eq("xyz"));
		builder.or(user.firstName.eq("xyz"));
		builder.or(user.isPhoneNumberConfirmed.eq("xyz"));
		builder.or(user.lastName.eq("xyz"));
		builder.or(user.password.eq("xyz"));
		builder.or(user.passwordResetCode.eq("xyz"));
		builder.or(user.phoneNumber.eq("xyz"));
		builder.or(user.userName.eq("xyz"));
        Assertions.assertThat(userAppService.Search(search)).isEqualTo(builder);
        
	}
	
	@Test
	public void search_SearchIsNotNullAndSearchContainsCaseTwo_ReturnBooleanBuilder() throws Exception
	{
		QUserEntity user = QUserEntity.userEntity;
		List<SearchFields> fieldsList= new ArrayList<>();
		SearchFields fields=new SearchFields();
		SearchCriteria search= new SearchCriteria();
		search.setType(2);
		search.setValue("xyz");
		search.setOperator("equals");
		fields.setFieldName("firstName");
        fieldsList.add(fields);
        search.setFields(fieldsList);
    	BooleanBuilder builder = new BooleanBuilder();
		builder.or(user.firstName.eq("xyz"));

       Assertions.assertThat(userAppService.Search(search)).isEqualTo(builder);
	}
	@Test
	public void search_SearchIsNotNullAndSearchContainsCaseThree_ReturnBooleanBuilder() throws Exception
	{
		Map<String,SearchFields> map = new HashMap<>();
		QUserEntity user = QUserEntity.userEntity;
		List<SearchFields> fieldsList= new ArrayList<>();
		SearchFields fields=new SearchFields();
		SearchCriteria search= new SearchCriteria();
		search.setType(3);
		fields.setFieldName("firstName");
       fields.setOperator("equals");
		fields.setSearchValue("xyz");
       fieldsList.add(fields);
       search.setFields(fieldsList);
   	BooleanBuilder builder = new BooleanBuilder();
   	builder.or(user.firstName.eq("xyz"));
  	
       Assertions.assertThat(userAppService.Search(search)).isEqualTo(builder);
	}
	
	@Test
	public void search_StringIsNull_ReturnNull() throws Exception
	{
		 Assertions.assertThat(userAppService.Search(null)).isEqualTo(null);
	}


}