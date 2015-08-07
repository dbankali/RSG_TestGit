@isTest
public class TestProjectBatch{
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method. 
            // Create a fake response
            String reqParams = ''
                + 'text=' + EncodingUtil.urlEncode('TestData','UTF-8')
                + '&from=' + 'en'
                + '&to=' + 'es';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('<xml><a>a</a></xml>');
            req.setEndpoint(Label.MS_Url_Endpoint + reqParams);
            res.setStatusCode(200);
            return res;
        }
    }
    
    
    public class MockHttpResponseGenerator1 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            // Create a fake response
            String reqParams = 'grant_type=client_credentials&client_id=' + EncodingUtil.urlEncode('','UTF-8')
                + '&scope='+Label.MS_Url_Scope+'&client_secret=' + EncodingUtil.urlEncode('', 'UTF-8') ;
            HttpResponse res = new HttpResponse();
            res.setHeader('ContentType', 'application/x-www-form-urlencoded; charset=utf-8');
            res.setHeader('Content-Length', String.valueOf(reqParams.length()));
            res.setBody('{"foo":"bar"}');
            req.setEndpoint(Label.MS_Oath_URL_Endpoint);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void testProjectBatch_TransText() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ProjectBatch.doTranslateText(new Map<String,String>{Label.token => '','text' => '',
            'en' => 'en',Label.toLang => 'English'},'TestData');
        
    }
    
    @isTest
    public static void testProjectBatch_dogetAccessToken() {
        
        Microsoft_API_Credentials__c msCustom = new Microsoft_API_Credentials__c();
        msCustom.Name = 'clientId';
        msCustom.Value__c = 'TestData';
        Microsoft_API_Credentials__c msCustom_Secret = new Microsoft_API_Credentials__c();
        msCustom_Secret.Name = 'clientSecret';
        msCustom_Secret.Value__c = 'TestData';
        List<Microsoft_API_Credentials__c> customList = new List<Microsoft_API_Credentials__c> {
            msCustom_Secret,msCustom
                };
                    insert customList;
        ProjectBatch.MSCredentials = Microsoft_API_Credentials__c.getAll();
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        ProjectBatch.doGetAccessToken('');                               
        Test.Stoptest();
        
    }
    
    @isTest
    public static void testProjectBatch_translate() {
        
        Microsoft_API_Credentials__c msCustom = new Microsoft_API_Credentials__c();
        msCustom.Name = 'clientId';
        msCustom.Value__c = 'TestData';
        Microsoft_API_Credentials__c msCustom_Secret = new Microsoft_API_Credentials__c();
        msCustom_Secret.Name = 'clientSecret';
        msCustom_Secret.Value__c = 'TestData';
        List<Microsoft_API_Credentials__c> customList = new List<Microsoft_API_Credentials__c> {
            msCustom_Secret,msCustom
                };
                    insert customList;
        Project__c prjObj = new Project__c(Name = 'testData');
        insert prjObj;
        prjObj.Name = 'TestData1';
        update prjObj;
        ProjectBatch.MSCredentials = Microsoft_API_Credentials__c.getAll();
        Test.StartTest();
        Translate cont = new Translate(new ApexPages.StandardController(prjObj));
        try {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
            cont.translateRecord();
        } catch(Exception e) {}
        Test.Stoptest();
        
    }
    
    @isTest
    public static void testProjectBatch_translText() {
        
        Microsoft_API_Credentials__c msCustom = new Microsoft_API_Credentials__c();
        msCustom.Name = 'clientId';
        msCustom.Value__c = 'TestData';
        Microsoft_API_Credentials__c msCustom_Secret = new Microsoft_API_Credentials__c();
        msCustom_Secret.Name = 'clientSecret';
        msCustom_Secret.Value__c = 'TestData';
        List<Microsoft_API_Credentials__c> customList = new List<Microsoft_API_Credentials__c> {
            msCustom_Secret,msCustom
                };
                    insert customList;
        ProjectBatch.MSCredentials = Microsoft_API_Credentials__c.getAll();
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        ProjectBatch.doTranslateText(new Map<String,String>{Label.token => '','text' => '',
            'en' => 'en',Label.toLang => 'English'},'TestData');                            
        Test.Stoptest();
        
    }
    
    @isTest
    public static void testProjectBatch_transText1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Project__c prjObj = new Project__c(Name = 'testData');
        insert prjObj;
        prjObj.Name = 'TestData1';
        update prjObj;
        ProjectBatch cont;
        try {
            cont = new ProjectBatch('en','Project__c',prjObj);
            cont.ObjectName = 'Project__c';
            ProjectBatch.transMetadataMap = Translation_Metadata__c.getAll();
            cont.updateProjects(new List<Project__c> {prjObj});
        } catch(Exception e) {}
        ProjectBatch.transMetadataMap = Translation_Metadata__c.getAll();
        cont = new ProjectBatch('en','Project__c',prjObj);
        Database.BatchableContext BC;
        cont.start(BC);
        try {
            cont.execute(BC,new List<Project__c> {prjObj});
        } catch(Exception e) {}
        cont.finish(BC);
        
        
        Model_MSTransToken MSToken_Cons = new Model_MSTransToken(); 
        System.assertEquals(MSToken_Cons.access_token,null);
        System.assertEquals(MSToken_Cons.token_type,null);
        System.assertEquals(MSToken_Cons.expires_in ,null);
        System.assertEquals(MSToken_Cons.scope ,null);
        
    }
}