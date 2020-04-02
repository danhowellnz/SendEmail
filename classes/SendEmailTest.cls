@IsTest
// (THIS SHOULD NOT BE GLOBAL...)
global class SendEmailTest {
    
    @TestSetup
    static void makeData(){

        //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dml_non_mix_sobjects_test_methods.htm
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs (thisUser) {

            // Create an email template
            EmailTemplate template = new EmailTemplate(
                IsActive = true,
                Name = 'name',
                DeveloperName = 'unique_name_testclasstest',
                TemplateType = 'text',
                FolderId = UserInfo.getUserId()
            );
            insert template;
            
            // Create test data
            Account acc = new Account(
                Name='Test Name',
                Phone = '1234',
                FAX = '123',
                Billingstreet = 'test'
            );
            insert acc;      
    
            Contact con = new Contact(
                FirstName='Test Name',
                LastName = 'test',
                AccountId = acc.Id,
                MobilePhone = '1234',
                email='fake@test.com'
            );
            insert con;
            
            ContentVersion cv = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.txt',
                VersionData = Blob.valueOf('Test Content Data')
            );
            insert cv;
            
            ContentVersion cv2 = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.txt',
                VersionData = Blob.valueOf('Test Content Data')
            );
            insert cv2;
            
            Attachment a = new Attachment(
                Name = 'Test.txt',
                Body = Blob.valueOf('Test Content Data'),
                ParentId = acc.Id
            );
            insert a;

        }
    }
    
    @IsTest
    static void testSendEmailSuccess1() {

        // Get the data
        Account theAccount = [SELECT Id FROM Account LIMIT 1];
        Contact theContact = [SELECT Id FROM Contact LIMIT 1];
        List<ContentVersion> theContentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 2];
        Attachment theAttachment = [SELECT Id FROM Attachment LIMIT 1];

        // Check the amount of tasks we have before our test
        Integer taskCount = [SELECT COUNT() FROM Task];
    
        // Create a single email to send
        SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
        request.EmailTemplateName = 'unique_name_testclasstest';
        request.Subject = 'test';
		request.plainTextBody = 'body';
		request.HtmlBody = 'body';
        request.RelatedToId = theAccount.id;
        request.ContactOrLeadID = theContact.id;
        request.TreatTargetObjectAsRecipient = false;
        request.ToAddresses = 'test@test.com';
		request.bccAddresses = 'test@test.com';
        request.ccAddresses = 'test@test.com';
        request.UseSignature = false;
        request.ContentDocumentId  = theContentVersions[0].ContentDocumentId;
        request.ContentVersionId  = theContentVersions[1].Id;
        request.AttachmentIds = new List<Id>{ theAttachment.Id };
        request.apexErrorEmail = 'test@test.com';
        
        Test.startTest();

        SendEmail.SendEmail( new List<SendEmail.InvokeSendEmail>{ request } );
        Integer invocations = Limits.getEmailInvocations();

        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Task] - taskCount, 'We expect a task not to be raised');
        System.assertEquals(1, invocations, 'We expect an email to be sent');
    }
    
    @IsTest
    static void testSendEmailSuccess2() {

        // Get the data
        Account theAccount = [SELECT Id FROM Account LIMIT 1];
        Contact theContact = [SELECT Id FROM Contact LIMIT 1];
        List<ContentVersion> theContentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 2];
        Attachment theAttachment = [SELECT Id FROM Attachment LIMIT 1];

        // Check the amount of tasks we have before our test
        Integer taskCount = [SELECT COUNT() FROM Task];
    
        // Create a single email to send
        SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
        request.Subject = 'test';
		request.plainTextBody = 'body';
		request.HtmlBody = 'body';
        request.RelatedToId = theAccount.id;
        request.ContactOrLeadID = theContact.id;
        request.TreatTargetObjectAsRecipient = false;
        request.ToAddresses = 'test@test.com';
		request.bccAddresses = 'test@test.com';
        request.ccAddresses = 'test@test.com';
        request.UseSignature = false;
        request.ContentDocumentId  = theContentVersions[0].ContentDocumentId;
        request.ContentVersionId  = theContentVersions[1].Id;
        request.AttachmentIds = new List<Id>{ theAttachment.Id };
        request.apexErrorEmail = 'test@test.com';
        
        Test.startTest();

        SendEmail.SendEmail( new List<SendEmail.InvokeSendEmail>{ request } );
        Integer invocations = Limits.getEmailInvocations();

        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Task] - taskCount, 'We expect a task not to be raised');
        System.assertEquals(1, invocations, 'We expect an email to be sent');
    }
    
    @IsTest
    static void testSendEmailSuccess3() {

        // Get the data
        Account theAccount = [SELECT Id FROM Account LIMIT 1];
        Contact theContact = [SELECT Id FROM Contact LIMIT 1];
        List<ContentVersion> theContentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 2];
        Attachment theAttachment = [SELECT Id FROM Attachment LIMIT 1];

        // Check the amount of tasks we have before our test
        Integer taskCount = [SELECT COUNT() FROM Task];
    
        // Create a single email to send
        SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
        request.Subject = 'test';
		request.HtmlBody = 'body';
        request.RelatedToId = theAccount.id;
        request.ToAddresses = 'test@test.com';
        
        Test.startTest();

        SendEmail.SendEmail( new List<SendEmail.InvokeSendEmail>{ request } );
        Integer invocations = Limits.getEmailInvocations();

        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Task] - taskCount, 'We expect a task not to be raised');
        System.assertEquals(1, invocations, 'We expect an email to be sent');
    }
    
    @IsTest
    static void testSendEmailSuccess4() {

        // Get the data
        Account theAccount = [SELECT Id FROM Account LIMIT 1];
        Contact theContact = [SELECT Id FROM Contact LIMIT 1];
        List<ContentVersion> theContentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 2];
        Attachment theAttachment = [SELECT Id FROM Attachment LIMIT 1];

        // Check the amount of tasks we have before our test
        Integer taskCount = [SELECT COUNT() FROM Task];
    
        // Create a single email to send
        SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
        request.Subject = 'test';
		request.plainTextBody = 'body';
		request.HtmlBody = 'body';
        request.RelatedToId = theAccount.id;
        request.ContactOrLeadID = theContact.id;
        request.TreatTargetObjectAsRecipient = true;
        request.ToAddresses = 'test@test.com';
		request.bccAddresses = 'test@test.com';
        request.ccAddresses = 'test@test.com';
        request.UseSignature = false;
        request.ContentDocumentId  = theContentVersions[0].ContentDocumentId;
        request.ContentVersionId  = theContentVersions[1].Id;
        request.AttachmentIds = new List<Id>{ theAttachment.Id };
        request.apexErrorEmail = 'test@test.com';
        
        Test.startTest();

        SendEmail.SendEmail( new List<SendEmail.InvokeSendEmail>{ request } );
        Integer invocations = Limits.getEmailInvocations();

        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM Task] - taskCount, 'We expect a task not to be raised');
        System.assertEquals(1, invocations, 'We expect an email to be sent');
    }
    
    @IsTest
    static void testSendEmailError1() {

        // Get the data
        Account theAccount = [SELECT Id FROM Account LIMIT 1];
        Contact theContact = [SELECT Id, Email FROM Contact LIMIT 1];
        theContact.Email = null;
        update theContact;

        // Check the amount of tasks we have before our test
        Integer taskCount = [SELECT COUNT() FROM Task];

        List<ContentVersion> theContentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 2];
        Attachment theAttachment = [SELECT Id FROM Attachment LIMIT 1];
    
        // Create a single email to send
        SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
        request.EmailTemplateName = 'unique_name_testclasstest';
        request.Subject = 'test';
		request.plainTextBody = 'body';
		request.HtmlBody = 'body';
        request.RelatedToId = theAccount.id;
        request.ContactOrLeadID = theContact.id;
        request.TreatTargetObjectAsRecipient = true;
        request.UseSignature = false;
        request.ContentDocumentId  = theContentVersions[0].ContentDocumentId;
        request.ContentVersionId  = theContentVersions[1].Id;
        request.AttachmentIds = new List<Id>{ theAttachment.Id };
        request.apexErrorEmail = 'test@test.com';
        
        Test.startTest();

        SendEmail.SendEmail( new List<SendEmail.InvokeSendEmail>{ request } );
        Integer invocations = Limits.getEmailInvocations();

        Test.stopTest();

        System.debug([SELECT Subject, ActivityDate, Description, WhatId, WhoId FROM Task]);

        // Should fail at [No Contact or Lead email address could be found with the Id] because email is blank
        
        System.assertEquals(1, [SELECT COUNT() FROM Task] - taskCount, 'We expect a task to be raised');
        System.assertEquals(1, invocations, 'We expect an email to be sent');
    }
    
    @IsTest
    static void testSendEmailError2() {

        // Get the data
        Account theAccount = [SELECT Id FROM Account LIMIT 1];
        Contact theContact = [SELECT Id FROM Contact LIMIT 1];
        List<ContentVersion> theContentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 2];
        Attachment theAttachment = [SELECT Id FROM Attachment LIMIT 1];

        // Check the amount of tasks we have before our test
        Integer taskCount = [SELECT COUNT() FROM Task];
    
        // Create a single email to send
        SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
        request.EmailTemplateName = 'unique_name_testclasstest';
        request.Subject = 'test';
		request.plainTextBody = 'body';
		request.HtmlBody = 'body';
        request.RelatedToId = theAccount.id;
        request.ContactOrLeadID = theContact.id;
        request.TreatTargetObjectAsRecipient = false;
        request.ToAddresses = 'test@test.com';
		request.bccAddresses = 'test@test.com';
        request.ccAddresses = 'test@test.com';
        request.UseSignature = false;
        request.ContentDocumentId  = theContentVersions[0].ContentDocumentId;
        request.ContentVersionId  = theContentVersions[1].Id;
        request.AttachmentIds = new List<Id>{ theAttachment.Id };
        request.apexErrorEmail = 'test@test.com';
        
        Test.startTest();

        SendEmail.SendEmail( new List<SendEmail.InvokeSendEmail>{ request }, true );
        Integer invocations = Limits.getEmailInvocations();

        Test.stopTest();

        System.debug([SELECT Subject, ActivityDate, Description, WhatId, WhoId FROM Task]);

        // Should fail to send email and have two tasks, one for original email, second for failure
        
        System.assertEquals(2, [SELECT COUNT() FROM Task] - taskCount, 'We expect a task not to be raised');
        System.assertEquals(2, invocations, 'We expect an email to be sent');
    }
    
    @IsTest
    static void testSendEmailError3() {

        // Get the data
        Account theAccount = [SELECT Id FROM Account LIMIT 1];
        Contact theContact = [SELECT Id, Email FROM Contact LIMIT 1];
        theContact.Email = null;
        update theContact;

        // Check the amount of tasks we have before our test
        Integer taskCount = [SELECT COUNT() FROM Task];

        List<ContentVersion> theContentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 2];
        Attachment theAttachment = [SELECT Id FROM Attachment LIMIT 1];
    
        // Create a single email to send
        SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
        request.EmailTemplateName = 'unique_name_testclasstestError';
        request.Subject = 'test';
		request.plainTextBody = 'body';
		request.HtmlBody = 'body';
        request.RelatedToId = theAccount.id;
        request.ContactOrLeadID = theContact.id;
        request.TreatTargetObjectAsRecipient = true;
        request.UseSignature = false;
        request.ContentDocumentId  = theContentVersions[0].ContentDocumentId;
        request.ContentVersionId  = theContentVersions[1].Id;
        request.AttachmentIds = new List<Id>{ theAttachment.Id };
        request.apexErrorEmail = 'test@test.com';
        
        Test.startTest();

        SendEmail.SendEmail( new List<SendEmail.InvokeSendEmail>{ request } );
        Integer invocations = Limits.getEmailInvocations();

        Test.stopTest();

        System.debug([SELECT Subject, ActivityDate, Description, WhatId, WhoId FROM Task]);

        // Should fail at [No Email Template Id could be found with the name]
        
        System.assertEquals(1, [SELECT COUNT() FROM Task] - taskCount, 'We expect a task to be raised');
        System.assertEquals(1, invocations, 'We expect an email to be sent');
    }
    
    @IsTest
    static void testSendEmailError4() {

        // Get the data
        Account theAccount = [SELECT Id FROM Account LIMIT 1];
        Contact theContact = [SELECT Id, Email FROM Contact LIMIT 1];

        // Check the amount of tasks we have before our test
        Integer taskCount = [SELECT COUNT() FROM Task];

        List<ContentVersion> theContentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 2];
        Attachment theAttachment = [SELECT Id FROM Attachment LIMIT 1];
    
        // Create a single email to send
        SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
        request.EmailTemplateName = 'unique_name_testclasstest';
        request.Subject = 'test';
		request.plainTextBody = 'body';
		request.HtmlBody = 'body';
        request.RelatedToId = theAccount.id;
        request.ContactOrLeadID = theAccount.id;
        request.TreatTargetObjectAsRecipient = true;
        request.UseSignature = false;
        request.ContentDocumentId  = theContentVersions[0].ContentDocumentId;
        request.ContentVersionId  = theContentVersions[1].Id;
        request.AttachmentIds = new List<Id>{ theAttachment.Id };
        request.apexErrorEmail = 'test@test.com';
        
        Test.startTest();

        SendEmail.SendEmail( new List<SendEmail.InvokeSendEmail>{ request } );
        Integer invocations = Limits.getEmailInvocations();

        Test.stopTest();

        System.debug([SELECT Subject, ActivityDate, Description, WhatId, WhoId FROM Task]);

        // Should fail at [No Contact or Lead could be found with the Id]
        
        System.assertEquals(0, [SELECT COUNT() FROM Task] - taskCount, 'We expect a task not to be raised becuase that should fail too');
        System.assertEquals(1, invocations, 'We expect an email to be sent');
    }
    
    @IsTest
    static void testSendEmailError5() {

        // Get the data
        Account theAccount = [SELECT Id FROM Account LIMIT 1];
        Contact theContact = [SELECT Id, Email FROM Contact LIMIT 1];

        // Check the amount of tasks we have before our test
        Integer taskCount = [SELECT COUNT() FROM Task];
    
        // Create a single email to send
        SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
        request.EmailTemplateName = 'unique_name_testclasstest';
        request.Subject = 'test';
		request.plainTextBody = 'body';
		request.HtmlBody = 'body';
        request.RelatedToId = theAccount.id;
        request.ContactOrLeadID = theContact.id;
        request.TreatTargetObjectAsRecipient = true;
        request.UseSignature = false;
        request.ContentDocumentId  = theContact.id;
        request.apexErrorEmail = 'test@test.com';
        
        Test.startTest();

        SendEmail.SendEmail( new List<SendEmail.InvokeSendEmail>{ request } );
        Integer invocations = Limits.getEmailInvocations();

        Test.stopTest();

        System.debug([SELECT Subject, ActivityDate, Description, WhatId, WhoId FROM Task]);

        // Should fail at [No Content Version could be found with the ContentDocumentId]
        
        System.assertEquals(1, [SELECT COUNT() FROM Task] - taskCount, 'We expect a task to be raised');
        System.assertEquals(1, invocations, 'We expect an email to be sent');
    }
    
    @IsTest
    static void testSendEmailError6() {

        // Get the data
        Account theAccount = [SELECT Id FROM Account LIMIT 1];
        Contact theContact = [SELECT Id, Email FROM Contact LIMIT 1];

        // Check the amount of tasks we have before our test
        Integer taskCount = [SELECT COUNT() FROM Task];
    
        // Create a single email to send
        SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
        request.EmailTemplateName = 'unique_name_testclasstest';
        request.Subject = 'test';
		request.plainTextBody = 'body';
		request.HtmlBody = 'body';
        request.RelatedToId = theAccount.id;
        request.ContactOrLeadID = theContact.id;
        request.TreatTargetObjectAsRecipient = true;
        request.UseSignature = false;
        request.ContentVersionId  = theContact.Id;
        request.apexErrorEmail = 'test@test.com';
        
        Test.startTest();

        SendEmail.SendEmail( new List<SendEmail.InvokeSendEmail>{ request } );
        Integer invocations = Limits.getEmailInvocations();

        Test.stopTest();

        System.debug([SELECT Subject, ActivityDate, Description, WhatId, WhoId FROM Task]);

        // Should fail at [No Content Version could be found with the Id]
        
        System.assertEquals(1, [SELECT COUNT() FROM Task] - taskCount, 'We expect a task to be raised');
        System.assertEquals(1, invocations, 'We expect an email to be sent');
    }
    
    @IsTest
    static void testSendEmailError7() {

        // Get the data
        Account theAccount = [SELECT Id FROM Account LIMIT 1];
        Contact theContact = [SELECT Id, Email FROM Contact LIMIT 1];

        // Check the amount of tasks we have before our test
        Integer taskCount = [SELECT COUNT() FROM Task];

        List<ContentVersion> theContentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 2];
        Attachment theAttachment = [SELECT Id FROM Attachment LIMIT 1];
    
        // Create a single email to send
        SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
        request.EmailTemplateName = 'unique_name_testclasstest';
        request.Subject = 'test';
		request.plainTextBody = 'body';
		request.HtmlBody = 'body';
        request.RelatedToId = theAccount.id;
        request.ContactOrLeadID = theContact.id;
        request.TreatTargetObjectAsRecipient = true;
        request.UseSignature = false;
        request.AttachmentIds = new List<Id>{ theContact.Id };
        request.apexErrorEmail = 'test@test.com';
        
        Test.startTest();

        SendEmail.SendEmail( new List<SendEmail.InvokeSendEmail>{ request } );
        Integer invocations = Limits.getEmailInvocations();

        Test.stopTest();

        System.debug([SELECT Subject, ActivityDate, Description, WhatId, WhoId FROM Task]);

        // Should fail at [No Attachment could be found with the Id]
        
        System.assertEquals(1, [SELECT COUNT() FROM Task] - taskCount, 'We expect a task to be raised');
        System.assertEquals(1, invocations, 'We expect an email to be sent');
    }

}
