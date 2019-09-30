package [=PackageName];

import [=PackageName].domain.model.*;
import [=PackageName].domain.Authorization.Permission.IPermissionManager;
import [=PackageName].domain.Authorization.Rolepermission.IRolepermissionManager;
import [=PackageName].domain.Authorization.Role.IRoleManager;
import [=PackageName].CommonModule.logging.LoggingHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.Environment;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
<#if Flowable!false>
import [=PackageName].application.Flowable.ActIdUserMapper;
import [=PackageName].application.Flowable.FlowableIdentityService;
import [=PackageName].domain.Flowable.Users.ActIdUserEntity;
</#if>

@Component
@Profile("bootstrap")
public class AppStartupRunner implements ApplicationRunner {
<#if Flowable!false>
    @Autowired
    private FlowableIdentityService idmIdentityService;

    @Autowired
    private ActIdUserMapper actIdUserMapper;
</#if>
    @Autowired
    private IPermissionManager permissionManager;

    @Autowired
    private IRoleManager rolesManager;
    
	@Autowired
    private IRolepermissionManager rolepermissionManager;
    
    @Autowired
    private LoggingHelper loggingHelper;

    @Autowired
    private PasswordEncoder pEncoder;

    @Autowired
    private Environment env;
    
    
    @Override
    public void run(ApplicationArguments args) {

<#if Flowable!false>
        idmIdentityService.deleteAllUsersGroupsPrivileges();
</#if>
        System.out.println("*****************Creating Default Users/Roles/Permissions *************************");

        // Create permissions for default entities

        loggingHelper.getLogger().info("Creating the data in the database");

        // Create roles

        RoleEntity role = new RoleEntity();
        role.setName("ROLE_Admin");
        role = rolesManager.Create(role);
        <#if Flowable!false>
        idmIdentityService.createGroup("ROLE_Admin");
        </#if>
        
		List<String> entityList = new ArrayList<String>();
        entityList.add("role");
        entityList.add("permission");
        entityList.add("rolepermission");
        
        <#if !authenticationTable??>
		entityList.add("user");
		entityList.add("userpermission");
		<#else>
		entityList.add("[=authenticationTable?lower_case]permission");
        </#if>

        <#list entitiesMap as entityKey, entityMap>
		entityList.add("[=entityKey?lower_case]");
		</#list>
		
		for(String entity: entityList) {
        	addEntityPermissions(entity, role.getId());
        }
        <#if Flowable!false>
		addFlowablePrivileges(role.getId());
        </#if>
        loggingHelper.getLogger().info("Completed creating the data in the database");

    }
    <#if Flowable!false>
    
    private void addFlowablePrivileges(long roleId) {
    	PermissionEntity pe5 = new PermissionEntity("access-idm","");
        PermissionEntity pe6 = new PermissionEntity("access-admin","");
        PermissionEntity pe7 = new PermissionEntity("access-modeler","");
        PermissionEntity pe8 = new PermissionEntity("access-task","");
        PermissionEntity pe9 = new PermissionEntity("access-rest-api","");
        
        pe5 = permissionManager.Create(pe5);
        pe6 = permissionManager.Create(pe6);
        pe7 = permissionManager.Create(pe7);
        pe8 = permissionManager.Create(pe8);
        pe9 = permissionManager.Create(pe9);
        
        RolepermissionEntity pe5RP = new RolepermissionEntity(pe5.getId(), roleId);
        RolepermissionEntity pe6RP = new RolepermissionEntity(pe5.getId(), roleId);
        RolepermissionEntity pe7RP = new RolepermissionEntity(pe5.getId(), roleId);
        RolepermissionEntity pe8RP = new RolepermissionEntity(pe5.getId(), roleId);
        RolepermissionEntity pe9RP = new RolepermissionEntity(pe5.getId(), roleId);
        
        rolepermissionManager.Create(pe5RP);
        rolepermissionManager.Create(pe6RP);
        rolepermissionManager.Create(pe7RP);
        rolepermissionManager.Create(pe8RP);
        rolepermissionManager.Create(pe9RP);

        idmIdentityService.createPrivilege("access-idm");
        idmIdentityService.createPrivilege("access-admin");
        idmIdentityService.createPrivilege("access-modeler");
        idmIdentityService.createPrivilege("access-task");
        idmIdentityService.createPrivilege("access-rest-api");

        idmIdentityService.addGroupPrivilegeMapping("ROLE_Admin", pe5.getName());
        idmIdentityService.addGroupPrivilegeMapping("ROLE_Admin", pe6.getName());
        idmIdentityService.addGroupPrivilegeMapping("ROLE_Admin", pe7.getName());
        idmIdentityService.addGroupPrivilegeMapping("ROLE_Admin", pe8.getName());
        idmIdentityService.addGroupPrivilegeMapping("ROLE_Admin", pe9.getName());
        
    }
    </#if>
    
    private void addEntityPermissions(String entity, long roleId) {
		PermissionEntity pe1 = new PermissionEntity(entity.toUpperCase() + "ENTITY_CREATE", "create " + entity);
        PermissionEntity pe2 = new PermissionEntity(entity.toUpperCase() + "ENTITY_READ", "read " + entity);
        PermissionEntity pe3 = new PermissionEntity(entity.toUpperCase() + "ENTITY_DELETE", "delete " + entity);
        PermissionEntity pe4 = new PermissionEntity(entity.toUpperCase() + "ENTITY_UPDATE", "update " + entity);

        pe1 = permissionManager.Create(pe1);
        pe2 = permissionManager.Create(pe2);
        pe3 = permissionManager.Create(pe3);
        pe4 = permissionManager.Create(pe4);
        
        RolepermissionEntity pe1RP = new RolepermissionEntity(pe1.getId(), roleId);
        RolepermissionEntity pe2RP = new RolepermissionEntity(pe2.getId(), roleId);
        RolepermissionEntity pe3RP = new RolepermissionEntity(pe3.getId(), roleId);
        RolepermissionEntity pe4RP = new RolepermissionEntity(pe4.getId(), roleId);
        
        rolepermissionManager.Create(pe1RP);
        rolepermissionManager.Create(pe2RP);
        rolepermissionManager.Create(pe3RP);
        rolepermissionManager.Create(pe4RP);
    }
}
