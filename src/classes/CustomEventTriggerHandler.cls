public with sharing class CustomEventTriggerHandler extends TriggerHandler{

    public override void afterUpdate(){
        System.Debug('11111');
        createEvent();
    }
    public override void afterInsert(){
        System.Debug('546546');
        sendEmail();
    }

    public static Messaging.SingleEmailMessage generateEmailMessage(Id templateId, Id targetId, Id whatId) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(templateId);
        mail.setTargetObjectId(targetId);
        mail.setSaveAsActivity(false);
        mail.setWhatId(whatId);
        return mail;
    }

    public static List<Contact> sendEmail() {

        List<Contact> contacts = [SELECT Id, Name, Email From Contact Where Name=:'Manager'];

        EmailTemplate et=[Select id from EmailTemplate where name=:'Meeting is approved by the leader'];

        List<Custom_Event__c> customEvents = trigger.new;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();


        for (Custom_Event__c cEvent: customEvents){
            mails.add(generateEmailMessage(et.Id,cEvent.Contact__c, cEvent.Id));
        }

        Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(mails);
        return contacts;
    }

    private void createEvent(){
        List<Custom_Event__c> customeEvent = trigger.new;
        System.debug(customeEvent);
        if(customeEvent.get(0).Status__c == Constants.STATUS_APPROVED){
            Event event = new Event(
                    Subject = Constants.SUBJECT_EVENT,
                    StartDateTime = customeEvent.get(0).Start_Time__c,
                    EndDateTime = customeEvent.get(0).End_Time__c,
                    WhatId = Constants.MANAGER_ID,
                    WhoId = customeEvent.get(0).Contact__c

            );
            insert event;
        }
    }

}