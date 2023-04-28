global class TrackAppInterviewCalenderController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}
    
    //USER SESSION ID
    public static String sessionID{get;set;}
    public static Contact userData{get; set;}
    private static boolean isAuthorized{get;set;}
    public static List<String> roles{get;set;}
    // Messages Modals
    public static string schedule_errorMessage {get;set;}
    public static string schedule_successMessage {get;set;}
    
    public static void initialize(){
        //isAuthorized
        isAuthorized = false;
        
        //roles defaults
        roles = new List<String>(3);
        roles[0]='Human Resources';
        roles[1]= 'Managers';
        roles[2]= 'Interviewers';
    }
    
    global static void reload(){
        system.debug('In reload function');
    }
    
    @RemoteAction
    global static List<Candidate__c> getCandidates(String session){
        List<String> candidatesNames= new List<String>();
        List<Candidate__c> candidates = new List<Candidate__c>();
        try {
            sessionID = session;
            initialize();
            //reset messages
            schedule_CalendarResetMessages();
            
            //Authorization
            authorizeBySessionId();
            if( isAuthorized == true){
                candidates = [select Id, Name from Candidate__c where status__c != 'Hired'];
                if (candidates.size() > 0)
                    return candidates;
                else
                    return null;
            } else {
                return null;
            }
            
        } catch(Exception e) {
            system.debug('An exception has occurred' + e.getMessage());
            schedule_errorMessage = e.getMessage();
            return null;
        }
    }
    
    global class tempQA{
        String InterviewID;
        String Question;
        String Answer;
    }
    
    @RemoteAction
    global static void saveQAs(List<List<String>> QAs){
        
        boolean flag = true;
        List<Interview__c> inter = new List<Interview__c>();
        List<Interview_Questions_Answers__c> allQAs = new List<Interview_Questions_Answers__c>();
        try {
            if (QAs.size() > 0){
                for (List<String> singleEvent : QAs) {
                    system.debug('List    ' + singleEvent);
                    if (flag && singleEvent[3] != 'noId') { 
                        inter = [select Id from Interview__c where Id=:singleEvent[3] LIMIT 1];
                        flag = false;
                    }
                    Interview_Questions_Answers__c newOrUpdatedQA = new Interview_Questions_Answers__c();
                    newOrUpdatedQA.Interview__c = inter[0].Id;
                    newOrUpdatedQA.Question__c = singleEvent[1];
                    newOrUpdatedQA.Answer__c = singleEvent[2];  
                    if (singleEvent[0] != 'noId')
                        newOrUpdatedQA.Id = singleEvent[0];
                    allQAs.add(newOrUpdatedQA);
                }
                if (allQAs.size() > 0) {
                    system.debug('All QAs are ' + allQAs);
                    upsert allQAs;
                } 
            }
            
        } catch(Exception e) {
            system.debug('An exception has occurred' + e.getMessage());
        }
    }    
    
    @RemoteAction
    global static List<Interview_Questions_Answers__c> getQAs(String interviewName){
        List<String> candidatesNames= new List<String>();
        List<Interview_Questions_Answers__c> QAs = new List<Interview_Questions_Answers__c>();
        try {
            QAs = [select Id, Question__c, Answer__c from Interview_Questions_Answers__c where Interview__r.name =: interviewName];
            if (QAs.size() > 0)
                return QAs;
            else
                return null;
        } catch(Exception e) {
            system.debug('An exception has occurred' + e.getMessage());
            return null;
        }
    }
    
    @RemoteAction
    global static List<String> getPickFields(Integer flag, String session){
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult;
        List<Schema.PicklistEntry> ple;
        try {
            sessionID = session;
            initialize();
            //reset messages
            schedule_CalendarResetMessages();
            
            //Authorization
            authorizeBySessionId();
            if( isAuthorized == true) {
                if (flag != null && flag > 0 && flag < 5)
                {
                    if (flag == 1){
                        fieldResult = Interview__c.Duration__c.getDescribe();
                        ple = fieldResult.getPicklistValues();
                    } else if (flag == 2){
                        fieldResult = Interview__c.Medium__c.getDescribe();
                        ple = fieldResult.getPicklistValues();
                    } else if (flag == 3){
                        fieldResult = Interview__c.Status_Progress__c.getDescribe();
                        ple = fieldResult.getPicklistValues();
                    } else if (flag == 4){
                        fieldResult = Interview__c.Type__c.getDescribe();
                        ple = fieldResult.getPicklistValues();
                    }
                    if (ple.size() > 0) {
                        for( Schema.PicklistEntry pickListVal : ple){
                            pickListValuesList.add(pickListVal.getLabel());
                        }     
                        system.debug(pickListValuesList);
                    }
                    if (pickListValuesList.size() > 0)
                        return pickListValuesList;
                    else
                        return null;
                }
                else {
                    return null;
                }
            } else {
                return null;
            }
        } catch(Exception e) {
            system.debug('An exception has occurred' + e.getMessage());
            schedule_errorMessage = e.getMessage();
            return null;
        }
    }
    
    @RemoteAction
    global static List<Contact> getInterviewers(String session){
        List<Contact> interviewers = new List<Contact>();
        try {
            sessionID = session;
            initialize();
            //reset messages
            schedule_CalendarResetMessages();
            
            //Authorization
            authorizeBySessionId();
            if( isAuthorized == true){
                interviewers = [select Id, Name from Contact where user_type__c = 'Interviewers'];
                if (interviewers.size() > 0)
                    return interviewers;
                else
                    return null;   
            } else {
                return null;
            }
        } catch(Exception e) {
            system.debug('An exception has occurred' + e.getMessage());
            schedule_errorMessage = e.getMessage();
            return null;
        }
    }
    
    @RemoteAction
    global static Interview__c getUpdateEvent(String objectId, String session) {
        //String userId = UserInfo.getUserId() ;
        try {
            sessionID = session;
            initialize();
            //reset messages
            schedule_CalendarResetMessages();
            
            //Authorization
            authorizeBySessionId();
            if( isAuthorized == true){
                if (objectId != null && objectId != '')
                {
                    List<Interview__c> userCalendar = [SELECT Id, Name, Duration__c, Interview_Timing__c, Candidate__r.Name, 
                                                       Candidate__r.Id, Interviewer__r.Id, Interviewer__r.Name, Medium__c, 
                                                       Status_Progress__c, Type__c 
                                                       FROM Interview__c 
                                                       where Id =: objectId];
                    system.debug(userCalendar + ' Interviewer:  ' + userCalendar[0].interviewer__r.Name);
                    if(userCalendar.size() > 0)
                        return userCalendar[0];
                    else
                        return null;
                }
                else {
                    return null;
                }
            }
            else {
                return null; 
            }
        } catch(Exception e) {
            system.debug('An exception has occurred' + e.getMessage());
            schedule_errorMessage = e.getMessage();
            return null;
        }
    }
    
    @RemoteAction 
    global static List<String> getUserType(String session, Integer flag) {
        try {
            sessionID = session;
            initialize();
            authorizeBySessionId();
            List<String> currentUser = new List<String>();
            if (flag == 1) {
                currentUser.add(String.valueOf(userData.User_type__c));
                return currentUser;
            } else if (flag == 2) {
                for(String role : roles) {
                    currentUser.add(role);
                }
                return currentUser;
            } else {
                return null;
            }
        } catch (Exception e) {
            system.debug('inside getUserType() exception condition' + e.getMessage());
            schedule_errorMessage = e.getMessage();
            return null;
        }
        
    }
    
    @RemoteAction
    global static List<Interview__c> setSessionID(String session) {
        sessionID = session;
        List<Interview__c> a  = getEvents();
        system.debug('Hello in set session id function ' + a);
        return a;
    }
    
    @RemoteAction
    global static List<Interview__c> getEvents() {
        //String userId = UserInfo.getUserId() ; 
        try {
            initialize();
            authorizeBySessionId();
            // Getting all Interview Data
            system.debug('isAuthorized' + isAuthorized + 'in get events function ' + userData);          
            if( isAuthorized == true && ( userData.User_type__c == roles[0] || userData.User_type__c == roles[1] ) )
            {
                //system.debug('inside if condition');
                List<Interview__c> userCalendar = [SELECT Id, Name, Duration__c, Interview_Timing__c, Status_Progress__c, Candidate__r.Name,
                                                   Type__c, Medium__c FROM Interview__c WHERE Candidate__r.Status__c != 'Hired' ORDER BY Interview_Timing__c ASC];
                system.debug('usercalendar'+userCalendar);
                if(userCalendar.size() > 0) 
                    return userCalendar;
                else
                    return null;
            } else if (isAuthorized == true && userData.User_type__c == roles[2]) {
                //system.debug('inside if condition');
                List<Interview__c> userCalendar = [SELECT Id, Name, Duration__c, Interview_Timing__c, Status_Progress__c, Candidate__r.Name,
                                                   Type__c, Medium__c FROM Interview__c where Interviewer__r.Id =: userData.Id ORDER BY Interview_Timing__c ASC];
                system.debug(userCalendar);
                if(userCalendar.size() > 0) 
                    return userCalendar;
                else
                    return null;
            } else {
                //system.debug('inside else condition');
                throw new OtherException('Un-Authorized Role');
            }
        } catch(Exception e) {
            system.debug('inside exception condition' + e.getMessage());
            schedule_errorMessage = e.getMessage();
            return null;
        }
    }
    
    @RemoteAction
    global static List<Interview__c> createOrUpdateEvents(String calendarEvent, String candidate, List<String> interviewer, String session) {
        //Geting Calendar_Event__c object from received Json String
        try {
            sessionID = session;
            initialize();
            //reset messages
            schedule_CalendarResetMessages();
            
            //Authorization
            authorizeBySessionId();
            
            System.debug('Update/Create Executed ' + isAuthorized + ' userData ' + userData);
            if( isAuthorized == true && ( userData.User_type__c == roles[0] || userData.User_type__c == roles[1] ) )
            {
                if (interviewer[0] != null && interviewer[0] != '' && candidate != null && candidate != '')
                {
                    List<Contact> interviewerObj = [select ID, Name from Contact where Id=:interviewer[0] LIMIT 1];
                    system.debug('interviewerObj '+interviewerObj );
                    List<Candidate__c> candidateObj = [select ID, Name from Candidate__c where Id=:candidate LIMIT 1];
                    system.debug('candidateObj'+candidateObj);
                    Interview__c eventObject = ((Interview__c) JSON.deserialize(calendarEvent, Interview__c.class));
                    system.debug('eventObject'+eventObject);
                    if (candidateObj.size() > 0 && interviewerObj.size() > 0) {
                        eventObject.Candidate__c = candidateObj[0].Id;
                        eventObject.Interviewer__c = interviewerObj[0].Id;
                        //you need to put proper regex to validate recordId
                        Boolean isOldRecord = eventObject.Id != null;
                        if (eventObject.Interview_Timing__c != null) {
                            Datetime now = System.now();
                            Datetime interviewTiming = Datetime.valueOf(eventObject.Interview_Timing__c);
                            if (now < interviewTiming || (eventObject.Status_Progress__c == 'Completed' || eventObject.Status_Progress__c == 'Cancelled')) {
                                upsert eventObject;
                                
                                
                                
                                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                                EmailTemplate emailTemp = [Select id, Subject, Body From EmailTemplate Where DeveloperName = 'Schedule_Interview'];
                                Interview__c inte = [Select Id, candidate__r.email__c from Interview__c where Id =: eventObject.Id Limit 1];
                                contact con=new contact();
                                if(Test.isRunningTest())
                                {
                                    con=[select id from contact limit 1];
                                }
                                else
                                {
                                  con = [select id from contact where Id = '0030r00000oVloeAAC' limit 1];  
                                }
                                List<String> emails = new List<String>();
                                emails.add(inte.candidate__r.email__c); 
                                
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                mail.setTemplateId(emailTemp.Id);
                                mail.setTargetObjectId(con.Id);
                                mail.setToAddresses(emails);
                                mail.setSaveAsActivity(false); 
                                mail.setWhatId(inte.Id);
                                mail.setTreatTargetObjectAsRecipient(false);
                                emailList.add(mail);
                                
                                if(!emailList.isEmpty()){
                                    Messaging.sendEmail(emailList);
                                    system.debug('Email sent');
                                }    
                                
                                
                                
                            }
                        }
                    }
                    return setSessionID(session);
                }
                else {
                    return setSessionID(session);
                }
            }
            /*else if ( isAuthorized == true && userData.User_type__c == roles[2]){
Contact interviewerObj = [select ID, Name from Contact where Id=:interviewer[0] LIMIT 1];
Candidate__c candidateObj = [select ID, Name from Candidate__c where Id=:candidate LIMIT 1];
Interview__c eventObject = ((Interview__c) JSON.deserialize(calendarEvent, Interview__c.class));
eventObject.Candidate__c = candidateObj.Id;
eventObject.Interviewer__c = interviewerObj.Id;
//you need to put proper regex to validate recordId
Boolean isOldRecord = eventObject.Id != null;
if (eventObject.Interview_Timing__c != null) {
Datetime now = System.now();
Datetime interviewTiming = Datetime.valueOf(eventObject.Interview_Timing__c);
if (eventObject.Id != null)
update eventObject;
}
return setSessionID(session);
}*/
            else {
                return null;
            }
        } catch(Exception e) {
            system.debug('An exception has occurred' + e.getMessage());
            schedule_errorMessage = e.getMessage();
            return setSessionID(session);
        }
    }
    @RemoteAction
    global static List<Interview__c> deleteEvent(String Idd, String session){
        try {
            sessionID = session;
            initialize();
            //reset messages
            schedule_CalendarResetMessages();
            
            //Authorization
            authorizeBySessionId();
            
            System.debug('Delete Executed ' + isAuthorized + ' userData ' + userData);
            if( isAuthorized == true && ( userData.User_type__c == roles[0] || userData.User_type__c == roles[1] ) )
            {
                if (Idd != null && Idd != '') {
                    List <Interview__c> interviewsToBeDeleted = [select Id from Interview__c where Id =: Idd];
                    delete interviewsToBeDeleted;
                    return setSessionID(session);
                } else {
                    return setSessionID(session);
                }
            }
            else
            {
                throw new OtherException('Only HR and Manager has the authority to delete interviews');
            }
        } catch(Exception e) {
            system.debug('An exception has occurred' + e.getMessage());
            schedule_ErrorMessage= e.getMessage();
            return setSessionID(session);
        }
    }
    
    // authorize by Session Id
    public static void authorizeBySessionId()
    {
        try
        {
            isAuthorized = false;
            userData = new Contact();
            System.debug('test: ' + sessionID);
            if( sessionID != null && sessionID != '')
            {
                System.debug('sessionID: ' + sessionID);
                List<Session__c> userSession = new List<Session__C>();
                userSession =[select id,Title__c, Contact__r.id from Session__c where Unique_ID__c = :sessionID];
                System.debug('userSession: ' + userSession);
                if ( userSession != null && userSession.size() > 0 )
                {
                    userData = [select id, name,email,phone,User_type__c,Profile_Pic_Url__c from Contact where id = :userSession[0].contact__r.id];
                    system.debug('User data :  ' + userData);
                    isAuthorized= true; 
                }
                else
                {
                    isAuthorized = false; 
                    throw new OtherException('Authorization Failed! Invalid Session Id');
                }
            }else {
                //
                System.debug('Empty Session Id');
                
                isAuthorized = false; 
                throw new OtherException('Authorization failed! Empty Token');
            }  
            sessionId= null;
        }
        catch(Exception e)
        {
            System.debug('Exception Auth: '+ sessionID + ' ' + userData );
            
            sessionID = null;
            userData= null;
            isAuthorized = false; 
            schedule_errorMessage = e.getMessage(); 
            throw new OtherException(e.getMessage());
        }
    }
    
    //RESET SCHEDULE AND SUCCESS MESSAGE
    public static void schedule_calendarResetMessages()
    {
        schedule_errorMessage ='';
        schedule_successMessage= '';
    }
}