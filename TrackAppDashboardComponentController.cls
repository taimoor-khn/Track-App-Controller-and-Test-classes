public class TrackAppDashboardComponentController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}
    
    //USER SESSION ID
    public String sessionID{get;set;}
    public Contact userData{get; set;}
    //user profile Pic
    public Transient String userProfilePicData{get; set;}
    private boolean isAuthorized{get;set;}
    public List<String> roles{get;set;}
    // Messages Modals
    public string dashboard_errorMessage {get;set;}
    public string dashboard_successMessage {get;set;}
    //
    public List<Interview__c> todayInterviews{get;set;}
    //Percentage chart  for candidates
    public Decimal totalCandidatesNo{get;set;}
    public Decimal inEvaluationCandidatesPer{get;set;}
    public Decimal hiredCandidatesPer{get;set;}
    public Decimal rejectedCandidatesPer{get;set;}
    public Decimal inEvaluationCandidatesNo{get;set;}
    public Decimal hiredCandidatesNo{get;set;}
    public Decimal rejectedCandidatesNo{get;set;}
    //Percentage chart  for Interviews
    public Decimal totalInterviewsNo{get;set;}
    public Decimal scheduledInterviewsPer{get;set;}
    public Decimal completedInterviewsPer{get;set;}
    public Decimal cancelledInterviewsPer{get;set;}
    public Decimal scheduledInterviewsNo{get;set;}
    public Decimal completedInterviewsNo{get;set;}
    public Decimal cancelledInterviewsNo{get;set;}
    
    
    
    public TrackAppDashboardComponentController()
    {
        sessionID = null;
        userData = new Contact();
        isAuthorized = false;
        //roles defaults
        roles = new List<String>(3);
        roles[0]='Human Resources';
        roles[1]= 'Managers';
        roles[2]= 'Interviewers';
    }
    
    //RESET SCHEDULE AND SUCCESS MESSAGE
    public void dashboard_resetMessages()
    {
        dashboard_errorMessage ='';
        dashboard_successMessage= '';
    }
    
    //Dashboard data loading
    public void loadDashboardData()
    {
        try
        {
            System.debug('Dashboard called');
            dashboard_resetMessages();
            authorizeBySessionId();
            
            todayInterviews = new List<Interview__c>();
            
            //getting profile Pic
            List<ContentDocumentLink> cdLinkList= [select id, contentDocumentId from ContentDocumentLink where linkedEntityId = :userData.Id];
            if( cdLinkList != null && cdLinkList.size() > 0 )
            {
                Set<Id> cdLinkIds = new Set<Id>();
                for(ContentDocumentLink cdLink : cdLinkList )
                {
                    cdLinkIds.add(cdLink.contentDocumentId);
                }
                List<ContentVersion> cvList = [ select id,title,versionData,FileType from ContentVersion where ContentDocumentId in :cdLinkIds and title like '%LM_TAPortal_ProfilePic%' and (FileType = 'JPG' OR FileType = 'PNG') order by createdDate desc limit 1];
                if( cvList != null && cvList.size() > 0 )
                {
                    System.debug('Test'+cvList );
                    userProfilePicData= EncodingUtil.base64Encode(cvList[0].versionData);
                }
            }
            system.debug('oooooooooooooooooo'+userData.User_type__c);
            if( isAuthorized == true && (userData.User_type__c == roles[0] || userData.User_type__c == roles[1]) )
            {
                todayInterviews = [select Id, Candidate__c, Candidate__r.Name,  Candidate__r.Email__c, Candidate__r.Phone__c,Name,  Interview_Timing__c, Interview_Date__c,Interviewer__r.id, Interviewer__r.Name, Interviewer__r.Email,Interviewer__r.Phone, Interviewer__c,Medium__c,Status_Progress__c, Duration__c, Type__c, Feedback__c from Interview__c where Interview_Date__c = :Date.today() and Status_Progress__c = 'Scheduled'  order by Interview_Timing__c asc]; //where Interview_Date__c = :Date.today()  order by Interview_Timing__c desc];
                
                //Candidates
                AggregateResult totalCandidates = [select count(id) from Candidate__c];
                AggregateResult inEvaluationCandidates = [select count(id) from Candidate__c where status__c = 'In Evaluation'];
                AggregateResult hiredCandidates = [select count(id) from Candidate__c where status__c = 'Hired'];
                AggregateResult rejectedCandidates = [select count(id) from Candidate__c where status__c = 'Rejected'];
                
                totalCandidatesNo = (Decimal)totalCandidates.get('expr0');
                inEvaluationCandidatesNo = (Decimal)inEvaluationCandidates.get('expr0');
                hiredCandidatesNo = (Decimal)hiredCandidates.get('expr0');
                rejectedCandidatesNo = (Decimal)rejectedCandidates.get('expr0');
                
                inEvaluationCandidatesPer = Math.round((inEvaluationCandidatesNo/totalCandidatesNo)*100);
                hiredCandidatesPer = Math.round((hiredCandidatesNo/totalCandidatesNo)*100);
                rejectedCandidatesPer = Math.round((rejectedCandidatesNo/totalCandidatesNo)*100);
                
                //Interviews
                AggregateResult totalInterviews = [select count(id) from Interview__c];
                AggregateResult scheduledInterviews = [select count(id) from Interview__c where Status_Progress__c = 'Scheduled'];
                AggregateResult completedInterviews = [select count(id) from Interview__c where Status_Progress__c = 'Completed'];
                AggregateResult cancelledInterviews = [select count(id) from Interview__c where Status_Progress__c = 'Cancelled'];
                
                totalInterviewsNo = (Decimal)totalInterviews.get('expr0');
                scheduledInterviewsNo = (Decimal)scheduledInterviews.get('expr0');
                completedInterviewsNo = (Decimal)completedInterviews.get('expr0');
                cancelledInterviewsNo = (Decimal)cancelledInterviews.get('expr0');
                
                scheduledInterviewsPer = Math.round((scheduledInterviewsNo/totalInterviewsNo)*100);
                completedInterviewsPer = Math.round((completedInterviewsNo/totalInterviewsNo)*100);
                cancelledInterviewsPer = Math.round((cancelledInterviewsNo/totalInterviewsNo)*100);
                
            }
            else if( isAuthorized == true && (userData.User_type__c == roles[2]) )
            {
                todayInterviews = [select Id, Candidate__c, Candidate__r.Name,  Candidate__r.Email__c, Candidate__r.Phone__c,Name,  Interview_Timing__c, Interview_Date__c,Interviewer__r.id, Interviewer__r.Name, Interviewer__r.Email,Interviewer__r.Phone, Interviewer__c,Medium__c,Status_Progress__c, Duration__c, Type__c, Feedback__c from Interview__c where Interview_Date__c = :Date.today() and Status_Progress__c = 'Scheduled' and Interviewer__r.id = :userData.Id   order by Interview_Timing__c asc];
                
                List<Candidate__c> candidate_RelatedToInterviewer = [select id from Candidate__c where id in (select candidate__c from Interview__c where Interviewer__r.id = :userData.id )];//and status_progress__c = 'Scheduled')];
                List<Id> candidateIds = new List<Id>();
                if( candidate_RelatedToInterviewer != null && candidate_RelatedToInterviewer.size() > 0)
                {
                    for( Candidate__c c : candidate_RelatedToInterviewer)
                    {
                        candidateIds.add(c.id);  
                    }
                }
                
                
                //Candidates
                AggregateResult totalCandidates = [select count(id) from Candidate__c where id in:candidateIds ];
                AggregateResult inEvaluationCandidates = [select count(id) from Candidate__c where status__c = 'In Evaluation' and id in:candidateIds];
                AggregateResult hiredCandidates = [select count(id) from Candidate__c where status__c = 'Hired' and id in:candidateIds];
                AggregateResult rejectedCandidates = [select count(id) from Candidate__c where status__c = 'Rejected' and id in:candidateIds];
                
                totalCandidatesNo = (Decimal)totalCandidates.get('expr0');
                inEvaluationCandidatesNo = (Decimal)inEvaluationCandidates.get('expr0');
                hiredCandidatesNo = (Decimal)hiredCandidates.get('expr0');
                rejectedCandidatesNo = (Decimal)rejectedCandidates.get('expr0');
                
                inEvaluationCandidatesPer = Math.round((inEvaluationCandidatesNo/totalCandidatesNo)*100);
                hiredCandidatesPer = Math.round((hiredCandidatesNo/totalCandidatesNo)*100);
                rejectedCandidatesPer = Math.round((rejectedCandidatesNo/totalCandidatesNo)*100);
                
                //Interviews
                AggregateResult totalInterviews = [select count(id) from Interview__c  where interviewer__c = :userData.Id];
                AggregateResult scheduledInterviews = [select count(id) from Interview__c where Status_Progress__c = 'Scheduled' and interviewer__c = :userData.Id];
                AggregateResult completedInterviews = [select count(id) from Interview__c where Status_Progress__c = 'Completed' and interviewer__c = :userData.Id];
                AggregateResult cancelledInterviews = [select count(id) from Interview__c where Status_Progress__c = 'Cancelled' and interviewer__c = :userData.Id];
                
                totalInterviewsNo = (Decimal)totalInterviews.get('expr0');
                scheduledInterviewsNo = (Decimal)scheduledInterviews.get('expr0');
                completedInterviewsNo = (Decimal)completedInterviews.get('expr0');
                cancelledInterviewsNo = (Decimal)cancelledInterviews.get('expr0');
                
                scheduledInterviewsPer = Math.round((scheduledInterviewsNo/totalInterviewsNo)*100);
                completedInterviewsPer = Math.round((completedInterviewsNo/totalInterviewsNo)*100);
                cancelledInterviewsPer = Math.round((cancelledInterviewsNo/totalInterviewsNo)*100);
                
            }   
            
        }
        catch(Exception e)
        {
            dashboard_errorMessage = e.getMessage();
        }
    }
    
    // authorize by Session Id
    public void authorizeBySessionId()
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
                    userData = [select id, 
                                title,
                                name,
                                email,
                                phone,
                                facebook__c,
                                twitter__c,
                                linkedin__c,
                                User_type__c,
                                Profile_Pic_Url__c,
                                MailingAddress,
                                MailingCity,
                                MailingCountry
                                from Contact where id = :userSession[0].contact__r.id];
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
            dashboard_errorMessage = e.getMessage(); 
            throw new OtherException(e.getMessage());
        }
    }
}