/*
This class is used to Translate all the Text values in the Project Object 
and Store in Separate Record Types. Currently it supports English , Chinese , Japanese , Spanish. 
*/
public class ProjectBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    
    public String token;
    public Set<String> fieldsList;
    public String langCode;
    public String languageName;
    public String ObjectName;
    public static Map<String,Microsoft_API_Credentials__c> MSCredentials {set;get;}
    public static Map<String,Translation_Metadata__c> transMetadataMap {set;get;}
    public Sobject sObj {set;get;}
    public Map<String,String> langCodesMap = new Map<String,String>();
    public Map<String,String> languageMap = new Map<String,String>();
    
    public ProjectBatch(String langCode, String ObjectName, SObject sObj){
        for(Language_Translation_Setting__c langCod : Language_Translation_Setting__c.getAll().Values()) {
        langCodesMap.put(langCod.Language_Code__c, langCod.Name);
        languageMap.put(langCod.Name, langCod.Language_Code__c);
        }
        languageName = langCode;
        langCode = languageMap.get(langCode);
        this.langCode = langCode;
        this.ObjectName = ObjectName;
        this.sObj = sObj;
        fieldsList = new Set<String>();
        String nsPrefix = ProjectBatch.class.getName().substringBefore('ProjectBatch');
        MSCredentials = Microsoft_API_Credentials__c.getAll();
        Schema.DescribeSObjectResult prjResult;
        //if(nsPrefix != null) {
        //    prjResult = Schema.getGlobalDescribe().get(nsPrefix.subStringBefore('.') + '__'+ObjectName).getDescribe(); 
        //} else {
            prjResult = Schema.getGlobalDescribe().get(ObjectName).getDescribe();
       // }
        for(String fieldName : prjResult.fields.getMap().keySet()) {
            if(fieldName.contains('__c')) {
                fieldsList.add(fieldName);
            }
            fieldsList.add('Name');
        }   
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String queryStr = '';
        for(String fieldObj : fieldsList) {
            queryStr = queryStr + fieldObj + ',';
        }
        String query='SELECT '+queryStr+'Id from '+ObjectName+' where Id = \''+sObj.get('Id')+'\'';
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<sObject> prjLst = (List<sObject>)scope;
        translateProject(prjLst);
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    
    public void translateProject(List<sObject> prjLst) {
        token = ProjectBatch.doGetAccessToken('');
        updateProjects(prjLst);
    }
    
    public void updateProjects( List<Sobject> prjLst) {
        List<Sobject> trPrjList = new List<Sobject>();
        List<Language_Translation__c> langTrList = new List<Language_Translation__c>();    
        Map<String,Sobject> langPrjMap = new Map<String,Sobject>();
        for(Sobject str : prjLst) {
            Schema.SobjectType obType = (sObj.Id).getSObjectType();
            Sobject trPrj = sObj.clone(false,false,false,false);
            for(String fieldName : fieldsList) {
                trPrj.put(fieldName,
                          ProjectBatch.doTranslateText(new Map<String,String>{Label.token => token,'text' => '',
                              Label.fromLang => 'en',Label.toLang => langCode},str.get(fieldName)+''));
            }
            langPrjMap.put(str.Id+langCode , trPrj);
            trPrjList.add(trPrj);
        }
        
        database.insert(trPrjList,false);
        for(Sobject prj : prjLst) {
            Sobject trPrj = (Sobject)langPrjMap.get(prj.Id+langCode);
            Language_Translation__c langTrnsObj = new Language_Translation__c(Project1__c = prj.Id , 
                                                                              Language__c = languageName, Project__c = trPrj.Id);
            langTrList.add(langTrnsObj);
        }
        
        database.insert(langTrList,false);
        
    }
    
    public static String doGetAccessToken(String param){
        
        try{
            HttpRequest req = new HttpRequest();
            MSCredentials = Microsoft_API_Credentials__c.getAll();
            String clientId = MSCredentials.get('clientId').Value__c; 
            String clientSecret = MSCredentials.get('clientSecret').Value__c; 
            
            String reqParams = 'grant_type=client_credentials&client_id=' + EncodingUtil.urlEncode(clientId,'UTF-8')
                + '&scope='+Label.MS_Url_Scope+'&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8') ;
            req.setEndpoint(Label.MS_Oath_URL_Endpoint);
            req.setMethod('POST');
            req.setHeader('ContentType', 'application/x-www-form-urlencoded; charset=utf-8');
            req.setHeader('Content-Length', String.valueOf(reqParams.length()));
            req.setBody(reqParams);
            req.setTimeout(60000);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            Model_MSTransToken result = new Model_MSTransToken();
            if(res.getStatusCode() == 200){
                result = (Model_MSTransToken)JSON.deserialize(res.getBody(), Model_MSTransToken.class);
            } else {
                throw new TranslatorException(Label.Exception_Message);
            }
            
            return result.access_token;
        }catch(Exception ex){
            throw ex;
        }
    }
    
    public class TranslatorException extends Exception {}
    public static String doTranslateText(Map<String, String> params,String TRandom){
        try{
            String token = params.get('token');
            String fromLang = params.containsKey(Label.fromLang) ? params.get(Label.fromLang) : 'en';
            String toLang = params.containsKey(Label.toLang) ? params.get(Label.toLang) : 'es';
            String text = params.containsKey('text') ? params.get('text') : ''; 
            
            HttpRequest req = new HttpRequest();
            
            token = token.replaceAll('&amp;', '&');
            String reqParams = ''
                + 'text=' + EncodingUtil.urlEncode(TRandom,'UTF-8')
                + '&from=' + fromlang
                + '&to=' + tolang;
            req.setEndpoint(Label.MS_Url_Endpoint + reqParams);
            req.setHeader('ContentType', 'text/plain');
            req.setHeader('Authorization', 'Bearer+' + token);
            req.setMethod('GET');
            req.setTimeout(60000);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            if(res.getStatusCode() != 200)
                throw new TranslatorException(Label.Exception_Message + res.getBody());
            
            XmlStreamReader xsr = new XmlStreamReader(res.getBody());
            String rtnText;
            while(xsr.hasNext()){
                if(xsr.getEventType() == XmlTag.END_ELEMENT){
                    break;
                } else if(xsr.getEventType() == XmlTag.CHARACTERS){
                    rtnText = xsr.getText();
                }
                xsr.next();
            }
            return rtnText;
        }catch(Exception ex){
            return null;
        }
    }
    
}