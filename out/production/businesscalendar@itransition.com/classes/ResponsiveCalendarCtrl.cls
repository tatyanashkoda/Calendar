global with sharing class ResponsiveCalendarCtrl{

    public string todaysdate{get;set;}

    global ResponsiveCalendarCtrl(){
        todaysdate = system.now().format('yyyy-MM-dd');
    }


    @RemoteAction
    global static list<calendarWrapper> getCalendarItems(){
        list<calendarWrapper> lstcalendar = new list<calendarWrapper>();
        TimeZone timeZone = UserInfo.getTimeZone();


        List<Event> events = [SELECT  Id, Subject,StartDateTime, EndDateTime, WhoId  From Event];
        List<Contact> contacts = new List<Contact>();

        Integer i = 0;
        System.Debug(events);

        for(Event objEvent:events){
            calendarWrapper calendarWrapper = new calendarWrapper();
//            contacts = [SELECT Id, LastName, FirstName From Contact Where Id =:events.get(i).WhoId];
            calendarWrapper.title = 'Test';
            calendarWrapper.Id = objEvent.Id;
            if(objEvent.StartDateTime != null){
                calendarWrapper.startTime = objEvent.StartDateTime.getTime() + timeZone.getOffset(objEvent.StartDateTime);
            }

            if(objEvent.EndDateTime != null){
                calendarWrapper.endTime = objEvent.EndDateTime.getTime() + timeZone.getOffset(objEvent.EndDateTime);

            }
            lstcalendar.add(calendarWrapper);
            i++;
        }
        return lstcalendar;

    }

    global class calendarWrapper{
        public string Id;
        public string title;
        public string url;
        public long startTime;
        public long endTime;
    }
}