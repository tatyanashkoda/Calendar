trigger CustomEventTrigger on Custom_Event__c (after insert, after update, after  delete) {
    new CustomEventTriggerHandler().run();
}