trigger EventTrigger on Event__c (after update) {
    new CustomEventTriggerHandler().run();
}