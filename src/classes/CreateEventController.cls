public with sharing class CreateEventController {
    public Custom_Event__c event {get; set;}
    public Contact objContact{get; set;}

    public CreateEventController(){
        event = new Custom_Event__c();
        objContact = new Contact();

    }

    public Contact createContact(){
        List<Contact> contact = [SELECT Id,FirstName,LastName FROM Contact WHERE Email=:objContact.Email AND LastName =: objContact.LastName];
        if(contact.isEmpty()){
            Contact newContact = new Contact (
                    FirstName = objContact.FirstName,
                    LastName = objContact.LastName,
                    Email = objContact.Email,
                    OwnerId = Constants.ID_GuestUser
            );

            insert newContact;
            return newContact;
        }
        else {
            return contact.get(0);
        }
    }


    public void save(){
        createContact();
        try {
            Custom_Event__c event = new Custom_Event__c(
                    Start_Time__c = event.Start_Time__c,
                    End_Time__c = event.End_Time__c,
                    Subject__c = event.Subject__c,
                    Status__c = Constants.WAITING_FOR_APPROVAL_STATUS,
                    Contact__c = createContact().Id
            );
            insert event;
        }
        catch (Exception ex){
            ApexPages.addMessages(ex);
        }

    }
}