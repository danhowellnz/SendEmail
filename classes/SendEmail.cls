global without sharing class SendEmail {
	//hangover from a darker time
	global static List<String> apexErrors = new List<String>();

	// Defines the input parameters of this Flow Element in the Canvas Designer
	global class InvokeSendEmail {
		// Required
		@InvocableVariable(label='Related To ID' description='' required=false)
		global Id RelatedToId;

		@InvocableVariable(label='Contact/Lead ID' description='Required if you use an email template' required=false)
		global Id ContactOrLeadID;

		@InvocableVariable(
			label='Body - Template Id'
			description='Contact/Lead ID required if you use this'
			required=false
		)
		global Id EmailTemplateId;

		@InvocableVariable(label='Case ID' description='Case ID if you want to have threaded emails' required=false)
		global Id caseId;
		@InvocableVariable(
			label='Body - Template Unique Name'
			description='API Name -- Contact/Lead ID required if you use this'
			required=false
		)
		global String EmailTemplateName;

		// Optional
		@InvocableVariable(label='To - To Addresses' description='' required=false)
		global String ToAddresses;

		@InvocableVariable(label='Body - Use Signature' description='' required=false)
		global Boolean UseSignature;

		@InvocableVariable(label='To - bcc Email Addresses' description='' required=false)
		global String bccAddresses;

		@InvocableVariable(label='To - cc Email Addresses' description='' required=false)
		global String ccAddresses;

		@InvocableVariable(label='To - email Opt Out Policy' description='' required=false)
		global String emailOptOutPolicy;

		@InvocableVariable(label='Subject' description='' required=false)
		global String subject;

		@InvocableVariable(label='Body - Plain Text ' description='' required=false)
		global String plainTextBody;

		@InvocableVariable(label='Body - Html' description='' required=false)
		global String HtmlBody;

		@InvocableVariable(label='From - Org Wide Email Address' description='' required=false)
		global String OrgWideEmailAddress;

		@InvocableVariable(label='TreatTargetObjectAsRecipient' description='' required=false)
		global Boolean TreatTargetObjectAsRecipient;

		@InvocableVariable(label='(Deprecated) TreatBodiesAsTemplate' description='' required=false)
		global Boolean TreatBodiesAsTemplate;

		@InvocableVariable(
			label='Attachment - ContentDocument - Comma Seperated Ids'
			description='List of Content Document Ids'
			required=false
		)
		global String ContentDocumentId;

		@InvocableVariable(
			label='Attachment - ContentVersion - Comma Seperated Ids'
			description='List of Content Version Ids'
			required=false
		)
		global String ContentVersionId;

		@InvocableVariable(
			label='Attachment - String Collection of Ids'
			description='List of Attachment Ids'
			required=false
		)
		global List<Id> AttachmentIds;

		@InvocableVariable(label='Setting - Save As Activity' description='' required=false)
		global Boolean SaveAsActivity;

		@InvocableVariable(
			label='Setting - Apex Error Email'
			description='Send an email to the specified address containing all errors'
			required=false
		)
		global String apexErrorEmail;
	}

	@InvocableMethod(label='Send Email')
	global static void SendEmail(List<InvokeSendEmail> requests) {
		SendEmail(requests, false);
	}

	global static void SendEmail(List<InvokeSendEmail> requests, Boolean forceSendEmailError) {
		// Initialise a new list to capture task details
		List<Task> tasks = new List<Task>();

		// List of emails to send / create
		Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();

		// Set of email template names to query
		Set<String> emailTemplateNames = new Set<String>();

		// Set of Org Wide Email addresses to query
		Set<String> orgWideEmailAddresses = new Set<String>();

		// Set of Contact or Lead Ids to query
		Set<String> contactOrLeadIds = new Set<String>();

		set<id> allIds = new Set<id>();
		// Set of Content Document Ids to query
		Set<ID> contentDocumentIds = new Set<ID>();

		// Set of Content Version Ids to query
		Set<ID> contentVersionIds = new Set<ID>();

		// Set of Attachment Ids to query
		Set<id> attachmentIds = new Set<id>();

		// Initiate a variable to get the apex error email
		String apexErrorEmail = requests[0].apexErrorEmail;

		// For each email
		for (InvokeSendEmail request : requests) {
			// Get the template name if we have one
			if (String.isNotBlank(request.EmailTemplateName)) {
				emailTemplateNames.add(request.EmailTemplateName);
			}
			// Get the Org Wide Email Address if we have one
			if (String.isNotBlank(request.orgWideEmailAddress)) {
				orgWideEmailAddresses.add(request.orgWideEmailAddress);
			}
			// Get the Contact or Lead Id if we have one
			if (String.isNotBlank(request.ContactOrLeadID)) {
				contactOrLeadIds.add(request.ContactOrLeadID);
			}
			// Get the Content Document Ids
			if (String.isNotBlank(request.ContentDocumentId)) {
				List<string> docIds = request.ContentDocumentId.split(',');
				for (string docid : docIds) {
					allids.add(id.valueOf(docid));
				}
			}
			// Get the Content Version Ids
			if (String.isNotBlank(request.ContentVersionId)) {
				List<string> docIds = request.ContentVersionId.split(',');
				for (string docid : docIds) {
					allids.add(id.valueOf(docid));
				}
			}
			// Get the Attachment Ids
			if (request.AttachmentIds != null && !request.AttachmentIds.isEmpty()) {
				allids.addAll(request.AttachmentIds);
			}
		}
		//because who knows what was actually passed in, lets ask salesforce.
		for (id currentId : allIds) {
			switch on currentId.getSObjectType().getDescribe().getName() {
				when 'Attachment' {
					attachmentIds.add(currentId);
				}
				when 'ContentVersion' {
					contentVersionIds.add(currentId);
				}
				when 'ContentDocument' {
					contentDocumentIds.add(currentId);
				}
				when else {
					apexErrors.add(
						'Didn\'t expect attachment of type ' +
						currentId.getSObjectType().getDescribe().getName() +
						'. Please reach out to have this added if required.'
					);
				}
			}
		}

		// Map of Email Template Id's by it's Name
		Map<String, String> emailTemplateIdsByName = new Map<String, String>();

		// If we have templates to query
		if (!emailTemplateNames.isEmpty()) {
			System.debug('SendEmail emailTemplateNames: ' + emailTemplateNames);

			// For each template we find
			for (EmailTemplate template : [
				SELECT Id, Name, DeveloperName
				FROM EmailTemplate
				WHERE DeveloperName IN :emailTemplateNames OR Name IN :emailTemplateNames
			]) {
				// Add a mapping to it's name
				emailTemplateIdsByName.put(template.Name, template.Id);
				// Add a mapping to it's developer name
				emailTemplateIdsByName.put(template.DeveloperName, template.Id);
			}

			System.debug('SendEmail emailTemplateIdsByName: ' + emailTemplateIdsByName);
		}

		// Map of Org Wide Email Address Id's by it's Address
		Map<String, String> orgWideEmailAddressIdsByAddress = new Map<String, String>();

		// If we have org wide emails to query
		if (!orgWideEmailAddresses.isEmpty()) {
			System.debug('SendEmail orgWideEmailAddresses: ' + orgWideEmailAddresses);

			// For each org wide email address we find
			for (OrgWideEmailAddress orgWideEmail : [
				SELECT Id, Address
				FROM OrgWideEmailAddress
				WHERE Address IN :orgWideEmailAddresses
			]) {
				// Add a mapping to it's address
				orgWideEmailAddressIdsByAddress.put(orgWideEmail.Address, orgWideEmail.Id);
			}

			System.debug('SendEmail orgWideEmailAddressIdsByAddress: ' + orgWideEmailAddressIdsByAddress);
		}

		// Map of Contact or Lead Email's by it's Id
		Map<String, String> contactOrLeadEmailsById = new Map<String, String>();

		// If we have Contact or Lead Ids to query
		if (!contactOrLeadIds.isEmpty()) {
			System.debug('SendEmail contactOrLeadIds: ' + contactOrLeadIds);

			// For each Contact we find
			for (Contact theContact : [SELECT Id, Email FROM Contact WHERE Id IN :contactOrLeadIds]) {
				// Add a mapping to it's email
				contactOrLeadEmailsById.put(theContact.Id, theContact.Email);
			}

			// For each Lead we find
			for (Lead theLead : [SELECT Id, Email FROM Lead WHERE Id IN :contactOrLeadIds]) {
				// Add a mapping to it's email
				contactOrLeadEmailsById.put(theLead.Id, theLead.Email);
			}

			System.debug('SendEmail contactOrLeadEmailsById: ' + contactOrLeadEmailsById);
		}

		// Map of Content Version by it's Id, ContentDocumentId or AttachmentId
		Map<ID, ContentVersion> contentVersionsById = new Map<ID, ContentVersion>();

		// If we have Content Documents or Content Versions to query
		if (!contentDocumentIds.isEmpty() || !contentVersionIds.isEmpty()) {
			System.debug('SendEmail contentDocumentIds: ' + contentDocumentIds);
			System.debug('SendEmail contentVersionIds: ' + contentVersionIds);

			// For each file we find
			for (ContentVersion file : [
				SELECT Id, PathOnClient, VersionData, ContentDocumentId
				FROM ContentVersion
				WHERE Id IN :contentVersionIds OR (ContentDocumentId IN :contentDocumentIds AND IsLatest = TRUE)
			]) {
				// Add a mapping to it's Id
				contentVersionsById.put(file.Id, file);
				// Add a mapping to it's ContentDocumentId
				contentVersionsById.put(file.ContentDocumentId, file);
			}

			System.debug('SendEmail contentVersionsById: ' + contentVersionsById);
		}

		// If we have Attachments to query
		if (!attachmentIds.isEmpty()) {
			System.debug('SendEmail attachmentIds: ' + attachmentIds);

			// For each file we find
			for (Attachment file : [SELECT Id, Name, Body FROM Attachment WHERE Id IN :attachmentIds]) {
				// Add a mapping to it's Id
				contentVersionsById.put(file.Id, new ContentVersion(PathOnClient = file.Name, VersionData = file.Body));
			}

			System.debug('SendEmail contentVersionsById: ' + contentVersionsById);
		}

		// For each email
		for (InvokeSendEmail request : requests) {
			try {
				System.debug('SendEmail InvokeSendEmail request: ' + request);

				// Initialise the email
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

				// If we have a Template Name
				if (String.isNotBlank(request.EmailTemplateName)) {
					// If we have a template with this Name or DeveloperName
					if (
						emailTemplateIdsByName.containsKey(request.EmailTemplateName) &&
						String.isNotBlank(emailTemplateIdsByName.get(request.EmailTemplateName))
					) {
						request.EmailTemplateId = emailTemplateIdsByName.get(request.EmailTemplateName);
						System.debug('SendEmail request.EmailTemplateId: ' + request.EmailTemplateId);
					} else {
						// Create error nothing found
						System.debug(
							'SendEmail No Email Template Id could be found with the name: ' + request.EmailTemplateName
						);
						throw new SendEmailException(
							'No Email Template Id could be found with the name: ' + request.EmailTemplateName
						);
					}
				}

				// Set the template Id or set the Subject and Body
				if (String.isNotBlank(request.EmailTemplateId)) {
					mail.setTemplateId(request.EmailTemplateId);
				} else {
					if (String.isNotBlank(request.subject))
						mail.setSubject(request.subject);
					if (String.isNotBlank(request.plainTextBody))
						mail.setplainTextBody(request.plainTextBody);
					if (String.isNotBlank(request.HtmlBody))
						mail.setHtmlBody(request.HtmlBody);
				}

				// Split the email addresses in to String Arrays
				String[] ToAddressesSplit = String.isBlank(request.ToAddresses) || !request.ToAddresses.contains('@')
					? new List<String>{}
					: request.ToAddresses.split(',');
				String[] ccAddressesSplit = String.isBlank(request.ccAddresses) || !request.ccAddresses.contains('@')
					? new List<String>{}
					: request.ccAddresses.split(',');
				String[] bccAddressesSplit = String.isBlank(request.bccAddresses) || !request.bccAddresses.contains('@')
					? new List<String>{}
					: request.bccAddresses.split(',');

				System.debug('SendEmail ToAddressesSplit: ' + ToAddressesSplit);
				System.debug('SendEmail ccAddressesSplit: ' + ccAddressesSplit);
				System.debug('SendEmail bccAddressesSplit: ' + bccAddressesSplit);

				// Set the related Id
				//remove if lead or contact
				if (String.isNotBlank(request.RelatedToId)) {
					if (
						string.valueof(request.RelatedToId).startsWithIgnoreCase('00Q') ||
						string.valueof(request.RelatedToId).startsWithIgnoreCase('003')
					) {
						request.RelatedToId = null;
					}
				}
				if (String.isNotBlank(request.RelatedToId))
					mail.setWhatId(request.RelatedToId);

				// Set the contact, lead or email addresses to send to
				if (String.isNotBlank(request.ContactOrLeadID)) {
					// Make sure we have a valid Contact or Lead
					if (!contactOrLeadEmailsById.containsKey(request.ContactOrLeadID)) {
						// Create error nothing found
						System.debug(
							'SendEmail No Contact or Lead could be found with the Id: ' + request.ContactOrLeadID
						);
						throw new SendEmailException(
							'No Contact or Lead could be found with the Id: ' + request.ContactOrLeadID
						);
					} else {
						if (String.isBlank(contactOrLeadEmailsById.get(request.ContactOrLeadID))) {
							//create error becaase we wanted to set the target object as recipient but there isn't an email for them.
							if (request.TreatTargetObjectAsRecipient == true) {
								System.debug(
									'SendEmail No Contact or Lead email address could be found with the Id: ' +
									request.ContactOrLeadID
								);
								throw new SendEmailException(
									'No Contact or Lead email address could be found with the Id: ' +
									request.ContactOrLeadID
								);
							}
							mail.setTreatTargetObjectasRecipient(false);
						} else {
							mail.setTreatTargetObjectasRecipient(
								request.TreatTargetObjectAsRecipient != null
									? request.TreatTargetObjectAsRecipient
									: true
							);
							mail.setTargetObjectId(request.ContactOrLeadID);
						}
					}
				}
				if (!ToAddressesSplit.isEmpty()) {
					mail.setToAddresses(ToAddressesSplit);
				} else if (String.isBlank(request.ContactOrLeadID) || request.TreatTargetObjectAsRecipient != true) {
					// Create error no email
					System.debug('SendEmail No to email address could be found');
					throw new SendEmailException('No to email address could be found');
				}

				// If we have CC or BCC add those
				if (!ccAddressesSplit.isEmpty())
					mail.setCcAddresses(ccAddressesSplit);
				if (!bccAddressesSplit.isEmpty())
					mail.setBccAddresses(bccAddressesSplit);

				// Optional Parameters
				if (request.UseSignature != null)
					mail.setUseSignature(request.UseSignature);
				if (String.isNotBlank(request.emailOptOutPolicy))
					mail.setOptOutPolicy(request.emailOptOutPolicy);

				// Save as activty  must be false if sending to users
				if (
					request.SaveAsActivity != false //&& String.isNotBlank(request.ContactOrLeadID) //&& !String.valueOf(request.ContactOrLeadID).startsWithIgnoreCase('005')
				) {
					mail.SaveAsActivity = true;
				}

				// If we have a Org Wide Email Address
				if (String.isNotBlank(request.OrgWideEmailAddress)) {
					// If we have a Org Wide Email Address with this Address
					if (orgWideEmailAddressIdsByAddress.containsKey(request.OrgWideEmailAddress)) {
						mail.setOrgWideEmailAddressId(orgWideEmailAddressIdsByAddress.get(request.OrgWideEmailAddress));
						System.debug(
							'SendEmail OrgWideEmailAddressId: ' +
							orgWideEmailAddressIdsByAddress.get(request.OrgWideEmailAddress)
						);
					} else {
						// Create error nothing found
						System.debug(
							'SendEmail No Org Wide Email Address Id could be found with the address: ' +
							request.OrgWideEmailAddress
						);
						throw new SendEmailException(
							'No Org Wide Email Address Id could be found with the address: ' +
							request.OrgWideEmailAddress
						);
					}
				}

				// If we have any file attachments
				if (
					String.isNotBlank(request.ContentDocumentId) ||
					String.isNotBlank(request.ContentVersionId) ||
					(request.AttachmentIds != null && !request.AttachmentIds.isEmpty())
				) {
					// Init a list for file attacments
					Messaging.EmailFileAttachment[] fileAttachments = new List<Messaging.EmailFileAttachment>{};

					if (String.isNotBlank(request.ContentDocumentId)) {
						// For each Content Document Id
						for (String contentDocumentId : request.ContentDocumentId.split(',')) {
							System.debug('SendEmail contentDocumentId: ' + contentDocumentId);
							// If we have a File with this Id
							if (contentVersionsById.containsKey(id.valueOf(contentDocumentId))) {
								// Get the file
								ContentVersion file = contentVersionsById.get(id.valueOf(contentDocumentId));
								// Create a file attachment
								Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
								// Set the file name
								fileAttachment.setFileName(file.PathOnClient.replaceAll('[^a-zA-Z0-9.]', ''));
								// Set the file blob
								fileAttachment.setBody(file.VersionData);
								// Add the file to the list
								fileAttachments.add(fileAttachment);
								System.debug('SendEmail ContentVersion: ' + file);
							} else {
								// Create error nothing found
								string err =
									'SendEmail No Content Version could be found with the ContentDocumentId: ' +
									contentDocumentId;
								System.debug(err);
								throw new SendEmailException(err);
							}
						}
					}

					if (String.isNotBlank(request.ContentVersionId)) {
						// For each Content Version Id
						for (String contentVersionId : request.ContentVersionId.split(',')) {
							System.debug('SendEmail contentVersionId: ' + contentVersionId);
							// If we have a File with this Id
							if (contentVersionsById.containsKey(id.valueOf(contentVersionId))) {
								// Get the file
								ContentVersion file = contentVersionsById.get(id.valueOf(contentVersionId));
								// Create a file attachment
								Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
								// Set the file name
								fileAttachment.setFileName(file.PathOnClient.replaceAll('[^a-zA-Z0-9.]', ''));
								// Set the file blob
								fileAttachment.setBody(file.VersionData);
								// Add the file to the list
								fileAttachments.add(fileAttachment);
								System.debug('SendEmail ContentVersion: ' + file);
							} else {
								// Create error nothing found
								string err =
									'SendEmail No Content Version could be found with the Id: ' + contentVersionId;
								System.debug(err);
								throw new SendEmailException(err);
							}
						}
					}

					if (request.AttachmentIds != null) {
						// For each Attachment Id
						for (String attachmentId : request.AttachmentIds) {
							System.debug('SendEmail attachmentId: ' + attachmentId);
							// If we have a File with this Id
							if (contentVersionsById.containsKey(attachmentId)) {
								// Get the file
								ContentVersion file = contentVersionsById.get(attachmentId);
								// Create a file attachment
								Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
								// Set the file name
								fileAttachment.setFileName(file.PathOnClient.replaceAll('[^a-zA-Z0-9.]', ''));
								// Set the file blob
								fileAttachment.setBody(file.VersionData);
								// Add the file to the list
								fileAttachments.add(fileAttachment);
								System.debug('SendEmail ContentVersion (From Attachment): ' + file);
							} else {
								// Create error nothing found
								String err = 'SendEmail No Attachment could be found with the Id: ' + attachmentId;
								System.debug(err);
								throw new SendEmailException(err);
							}
						}
					}

					// If we have any files to attach
					if (!fileAttachments.isEmpty()) {
						mail.setFileAttachments(fileAttachments);
					}
				}

				// if case threading is desired
				if (request.caseId != null) {
					System.debug('SendEmail threading with caseid: ' + request.caseId);

					//Get the threading message identifier
					String messageId = Cases.generateThreadingMessageId(request.caseId);
					//Insert the message identifier into the References header
					mail.setReferences(messageId);
				}

				// Add the email to the list of emails to be sent
				mails.add(mail);
			} catch (Exception ex) {
				// Add an error for the apex email
				apexErrors.add(
					String.format(
						'*** FAILED TO CONSTRUCT EMAIL MESSAGE ***\n{4}\n\nRequest: {0}\n\nException Type: {1}\nException Message: {2}\nStack Trace String: {3}',
						new List<String>{
							JSON.serialize(request),
							ex.getTypeName(),
							ex.getMessage(),
							ex.getStackTraceString(),
							'Current User Id: ' + UserInfo.getUserId()
						}
					)
				);

				// Create a task for the user to action
				tasks.add(
					createTask(
						'Failed to send email',
						String.format(
							'Exception Type: {0}\nException Message: {1}\nStack Trace String: {2}',
							new List<String>{ ex.getTypeName(), ex.getMessage(), ex.getStackTraceString() }
						),
						request.RelatedToId,
						request.ContactOrLeadID
					)
				);

				System.debug('SendEmail Exception Message: ' + ex.getMessage());
				System.debug('SendEmail Exception StackTraceString: ' + ex.getStackTraceString());
			}
		}

		try {
			// If we have emails to send
			if (!mails.isEmpty()) {
				if (forceSendEmailError) {
					mails.add(new Messaging.SingleEmailMessage());
				}

				// Send the emails and capture the results
				Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false);

				// For each email sent
				Integer mailIndex = 0;
				for (Messaging.SendEmailResult result : results) {
					// If this is not a successful email
					if (!result.isSuccess()) {
						// Create a task for the user to action
						tasks.add(
							createTask(
								'Failed to send email',
								String.format(
									'Errors: \n{0}\n\nEmail Body: {1}',
									new List<String>{
										getSendEmailErrors(result.getErrors()),
										mails[mailIndex].plainTextBody
									}
								),
								mails[mailIndex].WhatId,
								mails[mailIndex].TargetObjectId
							)
						);

						// Add an error for the apex email
						apexErrors.add(
							String.format(
								'*** FAILED TO SEND EMAIL ***\n\n{0}\n\nErrors: \n{1}\n\n',
								new List<String>{
									'Current User Id: ' + UserInfo.getUserId(),
									getSendEmailErrors(result.getErrors())
								}
							)
						);
					}
					mailIndex++;
				}
			}
		} catch (Exception ex) {
			// Add an error for the apex email
			apexErrors.add(
				String.format(
					'*** FAILED TO SEND EMAILS ***\n\nException Type: {0}\nException Message: {1}\nStack Trace String: {2}\n\n',
					new List<String>{ ex.getTypeName(), ex.getMessage(), ex.getStackTraceString() }
				)
			);

			System.debug('SendEmail Exception Message: ' + ex.getMessage());
			System.debug('SendEmail Exception StackTraceString: ' + ex.getStackTraceString());
		}

		try {
			// If we have tasks
			if (!tasks.isEmpty())
				insert tasks;
		} catch (DMLException ex) {
			// Add an error for the apex email
			apexErrors.add(
				String.format(
					'*** FAILED TO CREATE TASKS ***\n\nException Type: {0}\nException Message: {1}\nStack Trace String: {2}\n\n',
					new List<String>{ ex.getTypeName(), ex.getMessage(), ex.getStackTraceString() }
				)
			);

			System.debug('SendEmail DMLException Message: ' + ex.getMessage());
			System.debug('SendEmail DMLException StackTraceString: ' + ex.getStackTraceString());
		}

		try {
			// If we have an apex error email to send to
			if (String.isNotBlank(apexErrorEmail) && !apexErrors.isEmpty()) {
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setToAddresses(new List<String>{ apexErrorEmail });
				mail.setSubject('Send Email Errors');
				mail.setPlainTextBody(String.join(apexErrors, ''));
				Messaging.SendEmailResult[] results = Messaging.sendEmail(
					new List<Messaging.SingleEmailMessage>{ mail }
				);
				if (!results[0].success) {
					System.debug('Failed to send apex error email: ' + getSendEmailErrors(results[0].getErrors()));
				}
			}
		} catch (Exception ex) {
			System.debug('SendEmail Exception Message: ' + ex.getMessage());
			System.debug('SendEmail Exception StackTraceString: ' + ex.getStackTraceString());
		}
	}

	private static String getSendEmailErrors(Messaging.SendEmailError[] errors) {
		String errorString = '';
		for (Messaging.SendEmailError error : errors) {
			errorString += String.format(
				'{0}Error Fields: {1}\nError Message: {2}\nStatus Code: {3}\nTarget Object Id: {4}',
				new List<String>{
					String.isNotBlank(errorString) ? '\n\n' : '',
					String.join(error.getFields(), ', '),
					error.getMessage(),
					String.valueOf(error.getStatusCode()),
					error.getTargetObjectId()
				}
			);
		}
		return errorString;
	}

	private static Task createTask(String subject, String description, Id whatId, Id whoId) {
		return new Task(
			Subject = subject,
			ActivityDate = System.today(),
			Description = String.isNotBlank(description) ? description.left(30000) : null,
			WhatId = whatId,
			WhoId = whoId
		);
	}

	// Custom Exception Class
	public class SendEmailException extends Exception {
	}
}
