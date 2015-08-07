global with sharing class searchTwitterController{
    
    global List<String> lstTweets {get;set;}
    
    global void twittersearch(){
        String oauthURL = 'https://api.twitter.com/oauth2/token';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(oauthURL);
        req.setMethod('POST');
        
        String consumerKey = '31zH4rN5RtYoqqgFW0GudLL1l';  
        String consumerSecret = 'UTpcLTTLF1shjkwCfzL1nTxjJ3Rmp5zgouOhGgkxbuyiVyaPg9';  
            
        Blob headerValue = Blob.valueOf(consumerKey + ':' + consumerSecret);  
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/x-www-form-urlencoded;charset=UTF-8');  
        req.setBody('grant_type=client_credentials');
        
        system.debug('----req-1-'+req);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('----------------------------'+res.getBody());
        
        String jsonStr = res.getbody();  
        JSONParser parser = JSON.createParser(jsonStr);  
            
        // extract access token from JSON response  
        string accessToken;  
        while (parser.nextToken() != null) {  
             if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {  
                  // Get the value.  
                  parser.nextToken();  
                  accessToken = parser.getText();  
             }  
        }  
        
        HttpRequest req1 = new HttpRequest();  
          req1.setMethod('GET');  
          req1.setEndpoint('https://api.twitter.com/1.1/search/tweets.json?q=deloitte');  
         
          String authorizationHeader1 = 'Bearer ' + accessToken;  
          req1.setHeader('Authorization', authorizationHeader1);  
         system.debug('----req-2---'+req1);
          Http http1 = new Http();  
          HTTPResponse searchResponse = http.send(req1);  
          system.debug('## body1 : ' + searchResponse.getBody()); 
          
          JSONParser parser2 = JSON.createParser(searchResponse.getBody());
            lstTweets = new List<String>();
            while (parser2.nextToken() != null) {
                if ((parser2.getCurrentToken() == JSONToken.FIELD_NAME) && (parser2.getText() == 'text')) {
                    // Get the value.
                    parser2.nextToken(); 
                    // Compute the grand total price for all invoices.
                    lstTweets.add(parser2.getText());
                    
                }
                }
                //system.debug('---lstTweets---'+lstTweets);
    }
}