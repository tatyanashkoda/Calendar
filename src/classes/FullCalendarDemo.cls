global with sharing class FullCalendarDemo {

    public String todaysDate { get; set; }

    global FullCalendarDemo() {
        todaysDate = System.now().format('yyyy-MM-dd');
    }

    @RemoteAction
    global static List<GetEvent> getEvents() {
        List<GetEvent> getEvents = new List<GetEvent>();
        TimeZone timeZone = UserInfo.getTimeZone();
        List<Event> events = [SELECT Id, Subject,StartDateTime, EndDateTime, WhoId From Event];
        List<Contact> contacts = [SELECT Id, Name From Contact];

        for (Event objEvent : events) {
            GetEvent getEvent = new GetEvent();
            for (Contact contact : contacts) {
                if (contact.Id == objEvent.WhoId) {
                    getEvent.title = contact.Name;
                }
            }
            getEvent.Id = objEvent.Id;
            if (objEvent.StartDateTime != null) {
                getEvent.StartDateTime = objEvent.StartDateTime.getTime() + timeZone.getOffset(objEvent.StartDateTime);
            }

            if (objEvent.EndDateTime != null) {
                getEvent.EndDateTime = objEvent.EndDateTime.getTime() + timeZone.getOffset(objEvent.EndDateTime);
            }
            getEvents.add(getEvent);
        }
        return getEvents;
    }


    @RemoteAction
    global static List<GetEvent> createOrUpdateEvents(String calendarEvent) {
        //Geting Calendar_Event__c object from received Json String
        Custom_Event__c eventObject = ((Custom_Event__c) JSON.deserialize(calendarEvent, Custom_Event__c.class));
        System.debug('fdgdg ' + eventObject);
//        //you need to put proper regex to validate recordId
//        Boolean isOldRecord = eventObject.Id != null;
//        upsert eventObject;
//        //If its new record, create User Calendar record as well
//        if (!isOldRecord) {
//            User_Calendar__c userCalendar = new User_Calendar__c(Event__c = eventObject.Id, User__c = UserInfo.getUserId());
            Custom_Event__c objEvent = new Custom_Event__c(
                    Start_Time__c = eventObject.Start_Time__c,
                    End_Time__c = eventObject.End_Time__c,
                    Subject__c = eventObject.Name,
                    Status__c = Constants.WAITING_FOR_APPROVAL_STATUS
            );
            System.debug('1111' + objEvent);
            insert objEvent;


        return getEvents();
    }

    global class GetEvent {
        public String Id;
        public String Title;
        public String FirstName;
        public String LastName;
        public Long StartDateTime;
        public Long EndDateTime;
        public String Subject;
    }
}

