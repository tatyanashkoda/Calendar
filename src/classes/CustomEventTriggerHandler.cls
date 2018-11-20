public with sharing class CustomEventTriggerHandler extends TriggerHandler{

    public override void afterUpdate(){
        createEvent();
    }
    public override void afterInsert(){
        List<Custom_Event__c> customEvents = trigger.new;
        for (Custom_Event__c cEvent: customEvents) {
            sendEmail(Constants.EMAIL_TEMPLATE_WAITING, cEvent.Attached_to__c, cEvent.Id);
        }
    }

    public static Messaging.SingleEmailMessage generateEmailMessage(Id templateId, Id targetId, Id whatId) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(templateId);
        mail.setTargetObjectId(targetId);
        mail.setSaveAsActivity(false);
        mail.setWhatId(whatId);
        return mail;
    }



    public static List<Contact> sendEmail( String emailTemplateName, Id idSendEmail, Id eventId) {

        List<Contact> contacts = [SELECT Id, Name, Email From Contact Where Name=:'Manager'];
        EmailTemplate emailTemplate=Database.query('Select id from EmailTemplate where name=: emailTemplateName');
        System.debug('EmAILtEMPLATE-->'+emailTemplate.Id);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

            mails.add(generateEmailMessage(emailTemplate.Id,idSendEmail,eventId ));

        Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(mails);
        return contacts;
    }


    private void createEvent(){
        List<Custom_Event__c> customeEvent = trigger.new;

        if(customeEvent.get(0).Status__c == Constants.STATUS_APPROVED){
            sendEmail(Constants.WAITING_FOR_APPROVAL_STATUS, customeEvent.Attached_to__c, customeEvent.Id);
            Event event = new Event(
                    Subject = Constants.SUBJECT_EVENT,
                    StartDateTime = customeEvent.get(0).Start_Time__c,
                    EndDateTime = customeEvent.get(0).End_Time__c,
                    WhatId = Constants.ACCOUNT_MANAGER_ID,
                    WhoId = customeEvent.get(0).Contact__c

            );
            insert event;
        }
        if(customeEvent.get(0).Status__c == Constants.STATUS_DENIED){


        }
    }

}