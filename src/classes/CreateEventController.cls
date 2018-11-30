public without sharing class CreateEventController {
    public Custom_Event__c event { get; set; }
    public Contact objContact { get; set; }

    public CreateEventController() {
        event = new Custom_Event__c();
        objContact = new Contact();
    }

    public Contact createContact() {
        List<Contact> contacts = [SELECT Id,FirstName,LastName FROM Contact WHERE Email = :objContact.Email AND LastName = :objContact.LastName];
        if (contacts.isEmpty()) {
            Contact newContact = new Contact(
                    FirstName = objContact.FirstName,
                    LastName = objContact.LastName,
                    Email = objContact.Email,
                    OwnerId = Constants.ID_GuestUser
            );

            insert newContact;
            return newContact;
        } else {
            return contacts.get(0);
        }
    }

    public PageReference save() {
        createContact();
        Boolean checkOnFreeTime = false;

        List<Free_Time__c>freeTimes = [SELECT Start_Time__c, End_Time__c From Free_Time__c];
        Date dateEvent = date.newInstance(event.Start_Time__c.year(), event.Start_Time__c.month(), event.Start_Time__c.day());

        for (Free_Time__c ft :freeTimes) {
            Date dateFreeTime = date.newInstance(ft.Start_Time__c.year(), ft.Start_Time__c.month(), ft.Start_Time__c.day());
            if (dateEvent == dateFreeTime) {
                if (event.Start_Time__c >= ft.Start_Time__c && event.Start_Time__c <= ft.End_Time__c && event.End_Time__c <= ft.End_Time__c) {
                    checkOnFreeTime = true;
                }
            }
        }

        if (checkOnFreeTime == true) {
            try {
                Custom_Event__c objEvent = new Custom_Event__c(
                        Start_Time__c = event.Start_Time__c,
                        End_Time__c = event.End_Time__c,
                        Subject__c = event.Subject__c,
                        Status__c = Constants.WAITING_FOR_APPROVAL_STATUS,
                        Contact__c = createContact().Id,
                        Attached_to__c = Constants.CONTACT_MANAGER_ID
                );
                insert objEvent;

                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Success! Event sent for review.');
                ApexPages.addMessage(msg);

                event = new Custom_Event__c(
                        Start_Time__c = null,
                        End_Time__c = null,
                        Subject__c = null
                );
                objContact = new Contact(
                        FirstName = null,
                        LastName = null,
                        Email = null
                );
                return null;


            } catch (Exception ex) {
                ApexPages.addMessages(ex);
                return null;
            }
        } else {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No meetings are held at this time.');
            ApexPages.addMessage(msg);
            return null;
        }


    }
}