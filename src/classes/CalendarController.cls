global with sharing class CalendarController {

    public String todaysDate { get; set; }

    global CalendarController() {
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
            if (objEvent.Subject != null) {
                getEvent.Subject = objEvent.Subject;
            }
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

    public static Contact createOrGetContact(String contactFirstName, String contactLastName, String contactEmail) {
        Id_Different_Users__c IdGuestUser = Id_Different_Users__c.getValues('Id Guest User');
        List<Contact> contacts = [SELECT Id,FirstName,LastName FROM Contact WHERE Email = :contactEmail AND LastName = :contactLastName];
        if (contacts.isEmpty()) {
            Contact newContact = new Contact(
                    FirstName = contactFirstName,
                    LastName = contactLastName,
                    Email = contactEmail,
                    OwnerId = IdGuestUser.Id__c
            );
            System.debug('Contact1-->'+newContact);
            insert newContact;
            return newContact;
        } else {
            System.debug('Contact2-->'+contacts.get(0));
            return contacts.get(0);
        }
    }


    @RemoteAction
    global static List<GetEvent> createOrUpdateEvents(String calendarEvent) {
        Id_Different_Users__c IdContactManager = Id_Different_Users__c.getValues('Contact Manager Id');
        Custom_Event__c eventObject = ((Custom_Event__c) JSON.deserialize(calendarEvent, Custom_Event__c.class));
        System.debug('eventObject-->'+eventObject);
//        Boolean isOldRecord = eventObject.Id != null;
//        upsert eventObject;
//        if (!isOldRecord) {
//            User_Calendar__c userCalendar = new User_Calendar__c(Event__c = eventObject.Id, User__c = UserInfo.getUserId());
        Boolean checkOnFreeTime = false;

        List<Free_Time__c>freeTimes = [
                SELECT Start_Time__c, End_Time__c
                From Free_Time__c
                WHERE Start_Time__c <= :eventObject.Start_Time__c
                AND End_Time__c >= :eventObject.Start_Time__c
                AND End_Time__c >= :eventObject.End_Time__c
        ];
        List<Free_Time__c> dsf = [SELECT Start_Time__c, End_Time__c FROM Free_Time__c];
        System.debug(dsf);
        System.debug('Free time-->' + freeTimes);

        if (!freeTimes.isEmpty()) {
            checkOnFreeTime = true;
        }
        if (checkOnFreeTime == true) {
            Custom_Event__c objEvent = new Custom_Event__c(
                    Start_Time__c = eventObject.Start_Time__c,
                    End_Time__c = eventObject.End_Time__c,
                    Subject__c = eventObject.Subject__c,
                    Status__c = Constants.WAITING_FOR_APPROVAL_STATUS,
                    Contact__c = createOrGetContact(eventObject.Contact_First_Name__c, eventObject.Contact_Last_Name__c, eventObject.Contact_Email__c).Id,
                    Attached_to__c = IdContactManager.Id__c
            );
            System.debug('objEvent-->' + objEvent);
            insert objEvent;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Success! Event sent for review.');
            ApexPages.addMessage(msg);
            return getEvents();
        }
        else {
            System.debug('sdfsdfsdf');
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No meetings are held at this time.');
            ApexPages.addMessage(msg);
            return null;
        }
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

