public with sharing class Translate {
    public Language_Translation__c langObj {set;get;}
    public Project__c proj {set;get;}
    public String nsPrefix {set;get;}
    
    public Translate(ApexPages.StandardController controller) {
        langObj = new Language_Translation__c();
        nsPrefix = ProjectBatch.class.getName().substringBefore('ProjectBatch');
        proj = (Project__c)controller.getRecord();
    }
    
    public Pagereference translateRecord() {
        Database.executeBatch(new ProjectBatch(langObj.Language__c,proj.getSobjectType().getDescribe().getName(),proj),10);
        Pagereference pr = new Pagereference('/'+proj.Id);
        pr.setRedirect(true);
        return pr;
    }
    
}