package com.nfinity.codegen;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.assertj.core.api.Assertions;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
public class CommonModuleTemplateGeneratorTest {

	@Rule
    public TemporaryFolder folder= new TemporaryFolder(new File(System.getProperty("user.dir").toString()));

	@InjectMocks
	@Spy
	CommonModuleTemplateGenerator cmdGenerator;
	
	@Mock
	CommonModuleTemplateGenerator mockedCmdGenerator;
	
	@Mock
	CodeGeneratorUtils mockedUtils;
	
	static final String BACKEND_TEMPLATE_FOLDER = "/templates/backendTemplates/commonModuleTemplates/CommonModule";
	File destPath;
	String testValue = "abc";
	String packageName = "com.nfinity.demo";
	String entityName = "entity1";
	String moduleName = "entity-1";
	
	@Before
	public void setUp() throws Exception {
		MockitoAnnotations.initMocks(cmdGenerator);
		destPath = folder.newFolder("tempFolder");
	
	}

	@After
	public void tearDown() throws Exception {

	}
	
	@Test
	public void generateCommonModuleClasses_ParametersAreValid_ReturnNothing()
	{
		Map<String, Object> root = new HashMap<>();
		root.put("PackageName", packageName.concat(".CommonModule"));
		
		Map<String,Object> templates = new HashMap<>();
		
		Mockito.doReturn(templates).when(cmdGenerator).getTemplates(anyString());
		Mockito.doNothing().when(mockedUtils).generateFiles(any(HashMap.class), any(HashMap.class), anyString(), anyString());
		
		cmdGenerator.generateCommonModuleClasses(destPath.getAbsolutePath(), packageName);
		Mockito.verify(mockedUtils,Mockito.times(1)).generateFiles(any(HashMap.class),any(HashMap.class),anyString(),anyString());
			
		
	}
	
	@Test
	public void getTemplates_PathIsValid_ReturnMap()
	{
        List<String> filesList = new ArrayList<String>();
        filesList.add("/SearchUtils.java.ftl");
        filesList.add("/SearchFields.java.ftl");

        Mockito.doReturn(filesList).when(mockedUtils).readFilesFromDirectory(anyString());
        Mockito.doReturn(filesList).when(mockedUtils).replaceFileNames(any(List.class),anyString());
        
        
		Map<String, Object> templates = new HashMap<>();
		templates.put("/SearchUtils.java.ftl", "/SearchUtils.java");
		templates.put("/SearchFields.java.ftl", "/SearchFields.java");
		Assert.assertEquals(cmdGenerator.getTemplates("/templates/testTemplates").keySet(), templates.keySet());

	}
	
}
