public with sharing class DeleteEventByLinkController {
    public Id id { get; set; }

    public Custom_Event__c getCustomEvents() {
        id = ApexPages.currentPage().getParameters().get('id');
        List<Custom_Event__c> customEvents = [SELECT Start_Time__c, End_Time__c, Id, Subject__c FROM Custom_Event__c WHERE Id =: id];
            return customEvents.get(0);
    }

    public void deleteEvent(){
        Custom_Event__c customEvent = [SELECT Start_Time__c, End_Time__c, Id, Subject__c, Contact__c FROM Custom_Event__c WHERE Id =: id];
        Event event = [SELECT Id FROM Event WHERE StartDateTime =: customEvent.Start_Time__c AND EndDateTime =: customEvent.End_Time__c AND WhoId =: customEvent.Contact__c];
        System.Debug(customEvent);
        System.debug(event);
        Delete customEvent;
        Delete event;
    }
}