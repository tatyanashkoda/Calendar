public with sharing class CustomEventTriggerHandler extends TriggerHandler{

    public override void afterUpdate(){
        chechStatus();
    }

    public override void afterInsert(){
        List<Custom_Event__c> customEvents = trigger.new;
        for (Custom_Event__c cEvent: customEvents) {
            sendEmail(Constants.EMAIL_TEMPLATE_WAITING, cEvent.Attached_to__c, cEvent.Id);
        }
    }

    public override void afterDelete(){
       // deleteEvant();
    }

    public static Messaging.SingleEmailMessage generateEmailMessage(Id templateId, Id targetId, Id whatId) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(templateId);
        mail.setTargetObjectId(targetId);
        mail.setSaveAsActivity(false);
        mail.setWhatId(whatId);
        return mail;
    }

    public static List<Messaging.SingleEmailMessage> sendEmail( String emailTemplateName, Id idSendEmail, Id eventId) {
        EmailTemplate emailTemplate=Database.query('Select id from EmailTemplate where name=: emailTemplateName');
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

            mails.add(generateEmailMessage(emailTemplate.Id,idSendEmail,eventId ));

        return mails;
    }

    private void deleteEvant(){
        Id id = ApexPages.currentPage().getParameters().get('id');
        Custom_Event__c customEvent = [SELECT Start_Time__c, End_Time__c, Id, Subject__c, Attached_to__c FROM Custom_Event__c WHERE Id =: id];
        sendEmail(Constants.EMAIL_TEMPLATE_APPROVED, customEvent.Attached_to__c, customEvent.Id);
    }

    private void chechStatus(){
        List<Messaging.SingleEmailMessage> mails;
        List<Custom_Event__c> customEvents = trigger.new;
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();

        if(customEvents.get(0).Status__c == Constants.STATUS_APPROVED){
            for (Custom_Event__c cEvent: customEvents) {
                mails = sendEmail(Constants.EMAIL_TEMPLATE_APPROVED, cEvent.Attached_to__c, cEvent.Id);
            }
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(mails);

            Event event = new Event(
                    Subject = Constants.SUBJECT_EVENT,
                    StartDateTime = customEvents.get(0).Start_Time__c,
                    EndDateTime = customEvents.get(0).End_Time__c,
                    WhatId = Constants.ACCOUNT_MANAGER_ID,
                    WhoId = customEvents.get(0).Contact__c,
                    Description = customEvents.get(0).Subject__c
            );
            insert event;
        }

        if(customEvents.get(0).Status__c == Constants.STATUS_DENIED){
            for (Custom_Event__c cEvent: customEvents) {
                mails = sendEmail(Constants.EMAIL_TEMPLATE_DISAPPROVED, cEvent.Attached_to__c, cEvent.Id);
            }
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(mails);
        }
    }

}