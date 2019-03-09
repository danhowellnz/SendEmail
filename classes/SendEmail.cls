Global without sharing  class SendEmail {
    
    // defines the input parameters of this flow element in the canvas designer
    Global class InvokeSendEmail {
        
        //Required
        @InvocableVariable(label='Related To ID' description='' required=false)
        Global  Id RelatedToId;
        @InvocableVariable(label='Contact/Lead/User ID' description='Required if you use an email template' required=false)
        Global  Id ContactorLeadID;
        @InvocableVariable(label='Email Template Id' description='Contact/Lead/User ID required if you use this' required=false)
        Global  Id EmailTemplateId;  
        @InvocableVariable(label='Email Template Unique Name' description='API Name  -- Contact/Lead/User ID required if you use this' required=false)
        Global  String EmailTemplateName;  
        
        
        //Optional
        @InvocableVariable(label='ToAddresses' description='' required=false)
        Global  String ToAddresses;
        @InvocableVariable(label='Use Signature' description='' required=false)
        Global  Boolean UseSignature;
        @InvocableVariable(label='bccAddresses' description='' required=false)
        Global  String bccAddresses;
        @InvocableVariable(label='ccAddresses' description='' required=false)
        Global  String ccAddresses;
        @InvocableVariable(label='emailOptOutPolicy' description='' required=false)
        Global  String emailOptOutPolicy;
        @InvocableVariable(label='subject' description='' required=false)
        Global  String subject;
        @InvocableVariable(label='plainTextBody' description='' required=false)
        Global  String plainTextBody;
        @InvocableVariable(label='HtmlBody' description='' required=false)
        Global  String HtmlBody;
        @InvocableVariable(label='OrgWideEmailAddress' description='' required=false)
        Global  String OrgWideEmailAddress;
        @InvocableVariable(label='setTreatTargetObjectAsRecipient' description='' required=false)

        Global  Boolean TreatBodiesAsTemplate;
        @InvocableVariable(label='Attachment - ContentDocument' description='' required=false)
        Global  String ContentDocumentId;
        @InvocableVariable(label='Attachment - ContentVersion' description='' required=false)
        Global  String ContentVersionId;
        @InvocableVariable(label='SaveAsActivity' description='' required=false)
        Global  Boolean SaveAsActivity;
        
    }    
    
	@InvocableMethod(label='Send Email' )
    Global static void Sendemail(List<InvokeSendEmail> requests){
	
      //list array
      Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage> {};
        
      //     //Loop through each record
      for ( InvokeSendEmail request : requests ) {
          
          			//Empty var
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          			system.debug('request: '+request);
          		
          			//Create arrays
          			String[] bccAddressesSplit = request.bccAddresses == null ? null : request.bccAddresses.split(',');
          			String[] ccAddressesSplit = request.ccAddresses == null ? null :request.ccAddresses.split(',');
          			String[] ToAddressesSplit = request.ToAddresses == null ? null :request.ToAddresses.split(',');			
          			
                      If( request.EmailTemplateId == null && request.EmailTemplateName !=null){
                          system.debug('SENDEMAIL___unique email template name: '+request.EmailTemplateName);
                          ID EmailTemplateId = [select id,DeveloperName from EmailTemplate where DeveloperName = :request.EmailTemplateName limit 1].Id; 
                          system.debug('SENDEMAIL___Found from unique email template id: '+EmailTemplateId);
                          request.EmailTemplateId = EmailTemplateId;
                      }
          			
          
          
                    //Core parameters
                    if(request.RelatedToId != null) 			mail.setWhatId(request.RelatedToId);
          			//Someone to send to 
          			if(request.ContactorLeadID != null)  		mail.setTargetObjectId(request.ContactorLeadID);
                    if(ToAddressessplit != null) 				mail.setToAddresses( ToAddressessplit);
          			//An email template
                    if(request.EmailTemplateId != null) 		mail.setTemplateId(request.EmailTemplateId);
          
          			//Optional Parameters
                    if(request.UseSignature != null) 			mail.setUseSignature(request.UseSignature);
          			if(request.bccAddresses != null) 			mail.setBccAddresses(bccAddressessplit);
          			if(request.ccAddresses != null) 			mail.setCcAddresses(ccAddressessplit);
                    //if(request.parentMessageIds != null)		mail.setInReplyTo(request.parentMessageIds);
                    if(request.emailOptOutPolicy != null)		mail.setOptOutPolicy(request.emailOptOutPolicy) ;   
                    if(request.subject != null) 				mail.setSubject(request.subject);
                    if(request.plainTextBody  != null) 			mail.setplainTextBody(request.plainTextBody );  
          			if(request.HtmlBody  != null) 				mail.setHtmlBody(request.HtmlBody );
          			//if(request.references  != null) 			mail.setReferences(request.references );			
          			if(request.TreatBodiesAsTemplate  != null) 	mail.setTreatBodiesAsTemplate(request.TreatBodiesAsTemplate );  
          			if(request.OrgWideEmailAddress  != null){
                        OrgWideEmailAddress[] OrgWideEmail = [select Id from OrgWideEmailAddress where Address = :request.OrgWideEmailAddress ];
                     	if(OrgWideEmail.size()>0) 				mail.setOrgWideEmailAddressId(OrgWideEmail[0].Id);                       
                    }
          			mail.SaveAsActivity = true;
          			if(request.SaveAsActivity == false || request.ContactorLeadID == null) 		mail.SaveAsActivity = false;
          
          			//Save as activty  must be false if sending to users
          			if(request.ContactorLeadID != null && String.valueOf(request.ContactorLeadID).startsWithIgnoreCase('005')){
          				mail.SaveAsActivity = false;
     				}			
          
          			//Check for files
          			if(request.ContentVersionId == null && request.ContentDocumentId != null){
                        // Find version
                        request.ContentVersionId = [select Id from ContentVersion where ContentDocumentId = :request.ContentDocumentId].ID;
                    }
          			if(request.ContentVersionId != null  && request.ContentVersionId != ''){
                        ContentVersion cv = [select Id,VersionData, PathOnClient from ContentVersion where ID = :request.ContentVersionId];
                    	// Create the email attachment
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName(cv.pathOnClient); 
                        efa.setBody(cv.versionData);
                        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                    }
          
				mails.add(mail);
      }//end loop
        
            
                    //Send the Email
                    
        			Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                    if (results[0].success) {
                        System.debug('The email was sent successfully.');
                    } else {
                        System.debug('The email failed to send: ' + results[0].errors[0].message);
                    }
        
        
    }     
}