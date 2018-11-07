global with sharing class ResponsiveCalendarCtrl{

    public string todaysdate{get;set;}

    global ResponsiveCalendarCtrl(){
        todaysdate = system.now().format('yyyy-MM-dd');
    }

    @RemoteAction
    global static list<calendarWrapper> getCalendarItems(){
        list<calendarWrapper> lstcalendar = new list<calendarWrapper>();
        TimeZone timeZone = UserInfo.getTimeZone();


        List<Event> events = [SELECT  Id, Subject,StartDateTime, EndDateTime  From Event];
        System.Debug(events);

        for(Event objEvent:events){
            System.Debug(objEvent);
            calendarWrapper calendarWrapper = new calendarWrapper();

            calendarWrapper.title = objEvent.Subject;
            calendarWrapper.Id = objEvent.Id;
            if(objEvent.StartDateTime != null){
                calendarWrapper.startTime = objEvent.StartDateTime.getTime() + timeZone.getOffset(objEvent.StartDateTime);
            }

            if(objEvent.EndDateTime != null){
                calendarWrapper.endTime = objEvent.EndDateTime.getTime() + timeZone.getOffset(objEvent.EndDateTime);

            }
            lstcalendar.add(calendarWrapper);
        }
        System.Debug(lstcalendar);
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