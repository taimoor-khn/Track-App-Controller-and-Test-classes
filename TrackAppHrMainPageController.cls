public class TrackAppHrMainPageController {
    
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}
    
    //USER SESSION ID
    public Transient String sessionID{get;set;}
    public Contact userData{get; set;}
    private boolean isAuthorized{get;set;}
    public List<String> roles{get;set;}
    //savepoint
    private Savepoint sp {get;set;}
    //
    public String trackApp_errorMessage{get;set;}
    public String trackApp_successMessage{get;set;}
    
    //edit profile
    public Transient Contact editProfileData{get;set;}
    public Transient String toSaveProfileData{get;set;}
    public Transient String toSaveProfilePic{get;set;}
    
    //RESET SCHEDULE AND SUCCESS MESSAGE
    public void schedule_resetMessages()
    {
        trackApp_errorMessage ='';
        trackApp_successMessage= '';
    }
    
    // logout
    public void logout()
    {
        try
        {           
            schedule_resetMessages();
            
            if( sessionId != null && sessionId != '')
            {
                List<Session__c> allSessions = [select id from Session__c where Unique_ID__c = :sessionId  ];
                if( allSessions != null && allSessions.size() > 0)
                {
                    delete allSessions;
                    trackApp_successMessage = 'Logged-Out Successfully!'; 
                }else
                {
                    throw new OtherException('User Not Logged In!');
                }
            }
            else
            {
                throw new OtherException('Invalid User/SessionId!');
            }
            
        }
        catch(Exception e)
        {
            trackApp_errorMessage = e.getMessage(); 
        }
    }
    
    //get Edit Profile Data
    public void getEditProfileData()
    {
        try
        {
            authorizeBySessionId();
            editProfileData = new Contact();
            editProfileData.Id = userData.id;
            editProfileData.FirstName = userData.FirstName;
            editProfileData.LastName = userData.LastName;
            editProfileData.Phone= userData.Phone;
        }
        catch(Exception e)
        {
            trackApp_errorMessage = e.getMessage();
        }
    }
    
    //saveProfileData
    public void saveProfileData()
    {
        try
        {
            //sp= Database.setSavepoint();
            authorizeBySessionId();
            system.debug('oooooooooooooooooo'+toSaveProfileData);
            Contact c = (Contact) JSON.deserialize(toSaveProfileData, Contact.class);
            if( c != null)
            {
                Contact toUpdateCont = new Contact();
                toUpdateCont.id = userData.Id;
                toUpdateCont.FirstName = c.FirstName;
                toUpdateCont.LastName = c.LastName;
                toUpdateCont.Phone = c.Phone;
                Update toUpdateCont;
                
                if( toSaveProfilePic != null && toSaveProfilePic != '')
                {
                    WrapperCandidateCV cvWrapper = new WrapperCandidateCV();
                    cvWrapper = (WrapperCandidateCV) JSON.deserialize(toSaveProfilePic, WrapperCandidateCV.class);
                    if( cvWrapper.cvData != null && cvWrapper.cvData != '' && cvWrapper.cvDetails != null )
                    {
                        ContentVersion cv = cvWrapper.cvDetails;
                        String base64 = cvWrapper.cvData.substring(cvWrapper.cvData.indexOf(',')+1);
                        cv.VersionData= EncodingUtil.base64Decode(base64);
                        
                        List<ContentDocumentLink> cdLinkList= [select id, contentDocumentId from ContentDocumentLink where linkedEntityId = :userData.Id];
                        if( cdLinkList != null && cdLinkList.size() > 0 )
                        {
                            Set<Id> cdLinkIds = new Set<Id>();
                            for(ContentDocumentLink cdLink : cdLinkList )
                            {
                                cdLinkIds.add(cdLink.contentDocumentId);
                            }
                            List<ContentVersion> cvList = [ select id,title,versionData,FileType,ContentDocumentId from ContentVersion where ContentDocumentId in :cdLinkIds and title like '%LM_TAPortal_ProfilePic%' and (FileType = 'JPG' OR FileType = 'PNG') order by createdDate desc];
                            if( cvList != null && cvList.size() > 0 )
                            {
                                Set<Id> cvIds= new Set<Id>();
                                for(ContentVersion contVer: cvList )
                                {
                                    cvIds.add(contVer.ContentDocumentId);
                                }
                                if(cvIds.size() > 0)
                                {
                                    List<ContentDocument> cdList = [select id from ContentDocument where id in :cvIds];
                                    Delete cdList;
                                }
                            }
                        }
                        
                        insert cv;
                        ContentVersion cv2 = [select id,ContentSize, contentDocumentId from ContentVersion where id = :cv.id];
                        //Create new link with current candidate
                        ContentDocumentLink cdLink1 = new ContentDocumentLink();
                        cdLink1.ContentDocumentId= cv2.ContentDocumentId;
                        cdLink1.LinkedEntityId = userData.Id;
                        cdLink1.Visibility= 'AllUsers';
                        insert cdLink1;
                    }
                }
                
                editProfileData = new Contact();
                editProfileData.Id = toUpdateCont.id;
                editProfileData.FirstName = toUpdateCont.FirstName;
                editProfileData.LastName = toUpdateCont.LastName;
                editProfileData.Phone= toUpdateCont.Phone;
                
                trackApp_successMessage = 'Profile Updates Successfully';
            }
            
        }
        catch(Exception e)
        {
            //Database.rollback(sp);
            trackApp_errorMessage = e.getMessage();
        }
    }
    
    // authorize by Session Id
    public void authorizeBySessionId()
    {
        try
        {
            isAuthorized = false;
            userData = new Contact();
            if( sessionID != null && sessionID != '')
            {
                System.debug('sessionID: ' + sessionID);
                List<Session__c> userSession = new List<Session__C>();
                userSession =[select id,Title__c, Contact__r.id from Session__c where Unique_ID__c = :sessionID];
                System.debug('userSession: ' + userSession);
                if ( userSession != null && userSession.size() > 0 )
                {
                    userData = [select id, FirstName,LastName, name,email,phone,User_type__c,Profile_Pic_Url__c from Contact where id = :userSession[0].contact__r.id];
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
            trackApp_errorMessage = e.getMessage(); 
            throw new OtherException(e.getMessage());
        }
    }
    
}