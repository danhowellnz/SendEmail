@istest
Global class SendEmailTest {
    
    @isTest
    static void SendEmailTest() {
        //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dml_non_mix_sobjects_test_methods.htm
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
        //CREATE EMAIL TEMPLATE
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'name';
        validEmailTemplate.DeveloperName = 'unique_name_testclasstest';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
		insert validEmailTemplate;        
        
        
        

 		//CREATE TEST DATA
        Account acc= new Account(
          Name='Test Name',
          Phone = '1234',
          FAX = '123',
          Billingstreet = 'test'
        );
        insert acc;      
 
        Contact con= new Contact(
            FirstName='Test Name',
            LastName = 'test',
            AccountId = acc.Id,
            MobilePhone = '1234'
        );
        insert con; 
        
        

    
        //CREATE SINGLE EMAIL
        SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
        //request.RelatedToId = acc.id;
        //request.ContactorLeadID = con.id;
        request.ToAddresses ='test@test.com';
		request.Subject = 'subject';
		request.plainTextBody = 'body';
        request.EmailTemplateName ='unique_name_testclasstest';
        request.OrgWideEmailAddress = 'test@test.com';

        List<SendEmail.InvokeSendEmail> requests = new List<SendEmail.InvokeSendEmail>{ request };
            
        Test.startTest();    
        SendEmail.Sendemail( requests );
        Test.stopTest();  
        
        }
    }

}