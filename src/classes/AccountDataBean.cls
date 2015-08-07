global class AccountDataBean{

    //Method for Different Data Types related to Lead.
    
    //SIF Bean Data
    global class AccountBean{
        webservice string FirstName;
        webservice string LastName;
    }
    
    global class AccountBeanResponse{
        webservice String Message;
        webservice String AccountId;
    }
    global class AccountConfigBean {
        //webservice List<SIFQuestionBean> SIFQuestionBean;
        webservice List<SIFCriteriaBean> SIFCriteriaBean;
        webservice List<SIFPicklistBean> SIFPicklistBean;
    }
    global class AccountConfigResponse {
        webservice String Type;
        webservice List<SIFQuestionBeanResponse> SIFQuestionBeanResponse;
        webservice List<SIFCriteriaBeanResponse> SIFCriteriaBeanResponse;
        webservice List<SIFPicklistBeanResponse> SIFPicklistBeanResponse;
    }
    
    global class SIFQuestionBeanResponse {
        webservice String QuestionID;
        webservice String SIFVersionID;
        webservice String Message ; 
    }
    global class SIFCriteriaBeanResponse{
        webservice string SIFID;
        webservice string SIFVersionID;
        webservice string Message;
    }
    
    global class SIFPicklistBeanResponse{
        webservice string QuestionID;
        webservice string PicklistValue;
        webservice string Message;
    }
    
    global class SIFPicklistBean{   
        webservice string QuestionID; 
        webservice List<SIFPicklistLOVBean> SIFPicklistLOVBean;
    }
    
    global class SIFCriteriaBean{
        webservice string AreaOfStudyCode;
        webservice string AreaOfStudyValue;
        webservice string Program;
        webservice string SIFID;
        webservice string SIFIDName;
        webservice string SIFVersionID;
        webservice string SIFVersionIDName;
    }
    
    global class SIFPicklistLOVBean{
        webservice string PicklistValue;
        webservice string PicklistId;
        webservice string ParentPicklistId;
        webservice Boolean Inactive;
        webservice string PicklistCode;
        webservice string PicklistOrder;
        
    }
}