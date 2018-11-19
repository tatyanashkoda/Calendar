trigger CustomEventTrigger on Custom_Event__c (after insert, after update) {
    new CustomEventTriggerHandler().run();
}