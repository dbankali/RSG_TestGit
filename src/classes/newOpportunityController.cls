public class newOpportunityController 
{
    public list<objectClass> standardObjList{get;set;}
    public list<objectClass> customObjList{get;set;}
    public set<string> objectSet{get;set;}
    public String val {get;set;}
    public String val2 {get;set;}
    Map<String, List<String>> mapObjectNameDataTypeKeyWithFields;
    public List<WrapperFields> listWrap { get; set; }
    public List<String> sObjectFieldsList {get; set;}
    
 public newOpportunityController()
 {
        customObjList  = new list<objectClass> ();
       standardObjList = new list<objectClass> ();
       objectSet= new set<string>();
       val = '';
       val2 = '';
       mapObjectNameDataTypeKeyWithFields = new Map<String, List<String>>();
       listWrap = new List<WrapperFields>();
       sObjectFieldsList = new List<String>();

 }
 
    public List<selectOption> getobjectList()
    {
        List<selectOption> options2 = new List<selectOption>(); 
        //Loop through sObject list
         for(Schema.SObjectType sobj : Schema.getGlobalDescribe().Values()) 
         {

             //Get described of object
             Schema.DescribeSObjectResult f = sobj.getDescribe();
             system.debug('----val2---'+val2);
             if(val2 == '') 
                 val2 = 'Standard Object';
                 
             else if(val2 == 'Custom Object' && f.isCustom())
             {
                 options2 = new List<selectOption>();
                options2.add(new SelectOption(f.getName(),f.getLabel()));
             }
             else if(val2 == 'Standard Object')
             {
                options2.add(new SelectOption(f.getName(),f.getLabel())); 
             }
             else
             {
                options2 = new List<selectOption>(); 
                options2.add(new SelectOption('Currently No Custom Objects in the org','Currently No Custom Objects in the org')); 
             }
            
        }
        
        system.debug('------options2------'+options2);
        return options2;
    }
    
    public void getFieldType() 
    {
        List<String> fieldNameStringList = new List<String>();
        mapObjectNameDataTypeKeyWithFields = new Map<String, List<String>>();
        listWrap = new List<WrapperFields>(); 
        system.debug('------in here----');
        for(Schema.Sobjectfield sObjectFields : Schema.getGlobalDescribe().get(val2).getDescribe().fields.getMap().values()) 
        {
            
            Schema.Describefieldresult fieldDescribedResult = sObjectFields.getDescribe();
            system.debug('----------------1-------'+fieldDescribedResult.getName() );
            //if(mapObjectNameDataTypeKeyWithFields.containsKey(String.valueOf(fieldDescribedResult.getType())) == false) 
            //{
                fieldNameStringList.add(fieldDescribedResult.getName() + '-' + fieldDescribedResult.getLabel() + '-' + String.valueOf(fieldDescribedResult.getLength()) + '-' + String.valueOf(fieldDescribedResult.isAccessible()) + '-' + String.valueOf(fieldDescribedResult.isUpdateable()));
            //} 
            //else 
            //{
                //fieldNameStringList = mapObjectNameDataTypeKeyWithFields.get(String.valueOf(fieldDescribedResult.getType()));
                //fieldNameStringList.add(fieldDescribedResult.getName() + '-' + fieldDescribedResult.getLabel() + '-' + String.valueOf(fieldDescribedResult.getLength()) + '-' + String.valueOf(fieldDescribedResult.isAccessible()) + '-' + String.valueOf(fieldDescribedResult.isUpdateable()));
            //} 

            mapObjectNameDataTypeKeyWithFields.put(String.valueOf(fieldDescribedResult.getLabel()), fieldNameStringList); 
        }
        system.debug('----val2--2nd ----'+val2);
        //sObjectFieldsList.addAll(mapObjectNameDataTypeKeyWithFields.get(val2));
        //system.debug('----sObjectFieldsList ----'+sObjectFieldsList); 
        Integer i=1;

        if(fieldNameStringList != null) 
        {
            for(String str : fieldNameStringList) 
            {
                listWrap.add(new WrapperFields( i++ , str.split('-')[0] , str.split('-')[1] , str.split('-')[2] , str.split('-')[3] , str.split('-')[4])); 
            }
        } 
        else 
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Fields Are Not Available For This Data Type')); 
        }
        system.debug('------listWrap------'+listWrap);
    }
    
   public PageReference step1() {
   return Page.opptyStep1;
   }

   public PageReference step2() {
   system.debug('------val------'+val);
   return Page.opptyStep2;
   }

   public PageReference step3() {
    return Page.opptyStep3;
   }
   
   public List<selectOption> getaccts() 
   {
        List<selectOption> options = new List<selectOption>(); 
        options.add(new selectOption('Standard Object', 'Standard Object')); 
        options.add(new selectOption('Custom Object', 'Custom Object')); 
        return options;
    }
    
    //This is a wrapper class. 
   public class objectClass
   {
        public string label{get;set;}
        public string apiName{get;set;}
        public string keyPrefix{get;set;}
        public boolean isCustomSet{get;set;}
        public list<Schema.ChildRelationship> childObjects;
        public list<string> childObjectArray{get;set;}
        public list<schema.RecordTypeInfo> recordTypes;
        public list<string> recordTypeArray{get;set;}
        public objectClass(string lab, string api, string prefix, list<Schema.ChildRelationship> childObj, boolean isCustomSetting, list<schema.RecordTypeInfo> recordTypeList){
            this.label = lab;
            this.apiName = api;
            this.KeyPrefix = prefix;
            this.isCustomSet = isCustomSetting;
            this.childObjectArray = new list<string>();
            this.recordTypeArray = new list<string>();
            if(childObj!=null){
                for(schema.childRelationShip ch : childObj){
                    this.childObjectArray.add(ch.getChildSObject().getDescribe().getLabel()+' ('+ch.getChildSObject().getDescribe().getName()+')');
                }
            }
            if(recordTypeList!= null){
                for(schema.RecordTypeInfo rt: recordTypeList){
                    this.recordTypeArray.add(rt.getName());
                }
            }
        }
    }

     //Wrapper Class to hold different type of values
 public class WrapperFields {

 //Variable 
 public Integer srNm { get; set; }
 public String nameOfField {get ; set ; }
 public String labelOfField {get ; set ; }
 public String lengthOfField {get ; set ; }
 public string updatable { get; set; }
 public string accessable { get; set; } 

 //Calling Constructor
 public WrapperFields(Integer srNm , String nameOfField , String labelOfField , String lengthOfField , string updatable , string accessable) {

 this.srNm = srNm;
 this.nameOfField = nameOfField;
 this.labelOfField = labelOfField;
 this.lengthOfField = lengthOfField;
 this.updatable = updatable;
 this.accessable = accessable;
 }
 }

}