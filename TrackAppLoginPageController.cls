public class TrackAppLoginPageController {
    
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}
    
    //USER SESSION ID
    public String sessionID{get;set;}
    
    //
    public String login_errorMessage{get;set;}
    public String login_successMessage{get;set;}
    
    public string getLocalStorage{get;set;}
    public string uniqueIDSession{get;set;}
    public Boolean NotApproved{get; set;}
    public string email{get;set;}
    public string password{get;set;}
    public Boolean LoginApproved{get;set;}
    
    //reset password section
    public transient String resetPassword_email{get;set;}
    public transient String resetPassword_otp{get;set;}
    public transient String resetPassword_newPassword{get;set;}
    
        
    
    public TrackAppLoginPageController()
    {
        
    }
    public PageReference LoginApproval()
    {
        try
        {
            system.debug(password);
            system.debug(email);
            NotApproved=false;
            List<Contact> contList=[select Id,Name,Email,Password__c,Title from Contact where Email=:email and Password__c=:password limit 1 ];  
            system.debug(contList);
            if(contList!=null && contList.size() > 0)
            {
                system.debug(contList);
                Session__c logedContactSession= new Session__c();
                logedContactSession.Contact__c=contList[0].Id;
                logedContactSession.Name=contList[0].Name;
                uniqueIDSession= SessionUniqueIDGenertor.UniqueIDSession();
                system.debug(uniqueIDSession);
                logedContactSession.Unique_ID__c=uniqueIDSession;
                logedContactSession.Login_Date_Time__c=System.now();
                logedContactSession.Active__c=true;
                insert  logedContactSession;  
                system.debug(logedContactSession);
                system.debug(logedContactSession.Contact__r.Title);  
                
            } 
            else
            {
                NotApproved=True;
            }
            
        }  
        catch (Exception e)
        {
            List<String> orgSetting=new List<String>();
            orgSetting.add('hasan.ahmed@logicmount.com');
            //orgSetting.add('exception@logicmount.com');
            //orgSetting.add('hasanfastnu@gmail.com');
            //orgSetting.add('laraibfatima450@gmail.com');
            Email_Logger.LogError('Error in TrackAppLoginPageController LoginApproval', e.getMessage() + '/r/n'  + e.getStackTraceString(), orgSetting);
        }
        return null;
    }
    @RemoteAction
    public static PageReference reDirectPage(string getLocalStorage)
    {
        try{
            system.debug('refdirect');
            system.debug(getLocalStorage);
            //system.debug(uniqueIDSession);
            Session__c newSessionCreated=[Select id,Title__c,Unique_ID__c from Session__c where Unique_ID__c=:getLocalStorage];
            system.debug('manager'); 
            
            if(newSessionCreated.Title__c=='Human Resources' || newSessionCreated.Title__c=='Managers' || newSessionCreated.Title__c=='Interviewers')
            {
                PageReference pageRef = new PageReference ('trackapplogin/TrackAppHrMainPage');
                system.debug('Hr');
                pageRef.setRedirect(false);
                return pageRef;   
            }
            else
            {
                PageReference pageRef = new PageReference ('trackapplogin/Unauthorized');
                system.debug('Hr');
                pageRef.setRedirect(false);
                return pageRef;  
            }
         
        }
        catch (Exception e)
        {
            List<String> orgSetting=new List<String>();
            orgSetting.add('exception@logicmount.com');
            orgSetting.add('hasanfastnu@gmail.com');
            orgSetting.add('laraibfatima450@gmail.com');
            Email_Logger.LogError('Error in TrackAppLoginPageController LoginApproval', e.getMessage() + '/r/n'  + e.getStackTraceString(), orgSetting);
            //login_errorMessage = e.getMessage(); 
        }
        return null; 
    }
    
    //RESET SCHEDULE AND SUCCESS MESSAGE
    public void schedule_resetMessages()
    {
        login_errorMessage ='';
        login_successMessage= '';
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
                    login_successMessage = 'Logged-Out Successfully!'; 
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
            login_errorMessage = e.getMessage(); 
        }
    }
    
     // logout
    public void login_checkSessionId()
    {
        try
        {           
            schedule_resetMessages();
            
            if( sessionId != null && sessionId != '')
            {
                List<Session__c> allSessions = [select id from Session__c where Unique_ID__c = :sessionId  ];
                if( allSessions != null && allSessions.size() > 0)
                {
                    login_successMessage = 'Session Exists';
                }
            }
            
        }
        catch(Exception e)
        {
            login_errorMessage = e.getMessage(); 
        }
    }
    
    // send otp
    public void resetPassword_sendOTP()
    {
        try
        {           
            schedule_resetMessages();
            if( resetPassword_email != null && resetPassword_email != '')
            {
                List<Contact> cont = [select id,email from Contact where email = :resetPassword_email limit 1];
                if( cont != null && cont.size() > 0 )
                {
                    Integer r1 = Integer.valueof((Math.random() * 9));
                    Integer r2 = Integer.valueof((Math.random() * 9));
                    Integer r3 = Integer.valueof((Math.random() * 9));
                    Integer r4 = Integer.valueof((Math.random() * 9));
                    String s = String.valueOf(r1)+String.valueOf(r2)+String.valueOf(r3)+String.valueOf(r4);
                    List<Track_App_OTP__c> oldOtps = [select id,AppUser__c,OTP_Code__c from Track_App_OTP__c where AppUser__c = :cont[0].Id ];
                    if( oldOtps != null && oldOtps.size() > 0)
                    {
                        delete oldOtps;
                    }
                    
                    Track_App_OTP__c newOtp= new Track_App_OTP__c( OTP_Code__c = Integer.valueOf(s)
                                                                  , AppUser__c = cont[0].Id
                                                                 );
                    insert newOtp;
                    if( newOtp == null || newOtp.id == null)
                    {
                        throw new OtherException('OTP could not be generated');
                    }else
                    {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        string emailBody = 'This is your 4 Digit OTP: '+ newOtp.OTP_Code__c;
                        mail.setHTMLBody(emailBody);
                        List<string> toAdds = new List<string>();
                        toAdds.add(cont[0].email);
                        mail.setToAddresses(toAdds);
                        mail.setSubject('Reset Email OTP Code');
                        List<Messaging.SingleEmailMessage> lstMail = new List<Messaging.SingleEmailMessage>();
                        lstMail.add(mail);
                        Messaging.sendEmail(lstMail);
                        login_successMessage= 'OTP Sent';
                    }
                    
                }
                else
                {
                    throw new OtherException('Invalid Email');
                }
            }else
            {
                throw new OtherException('Empty Email');
            }
        }
        catch(Exception e)
        {
            login_errorMessage = e.getMessage(); 
        }
    }
    
    //reset password 
    public void resetPassword_resetPassword()
    {
        try
        {           
            schedule_resetMessages();
            if( resetPassword_email == null || resetPassword_email == '' || resetPassword_otp == null || resetPassword_otp == '' || resetPassword_newPassword == null || resetPassword_newPassword == '' )
            {
                throw new OtherException('Email/Password/OTP is empty');
            }else
            {
                List<Contact> cont = [select id,email from Contact where email = :resetPassword_email limit 1];
                if( cont != null && cont.size() > 0)
                {
                    if( resetPassword_otp.length() == 4 && Integer.valueOf(resetPassword_otp) != null)
                    {
                        
                        List<Track_App_OTP__c> otp = [select id,AppUser__c,OTP_Code__c from Track_App_OTP__c where AppUser__c = :cont[0].id AND OTP_Code__c = :Integer.valueOf(resetPassword_otp) order by createdDate desc limit 1]; 
                        if( otp != null && otp.size() > 0)
                        {
							cont[0].password__c = resetPassword_newPassword;
                            update cont[0];
                            delete otp;
                            login_successMessage = 'Password Changed Successfully';
                        }else 
                        {
                            throw new OtherException('Invalid OTP');
                        }
                    }else
                    {
                        throw new OtherException('Invalid OTP');
                    }
                }else
                {
                    throw new OtherException('Invalid Email');
                }
                
                
            }
        }
        catch(Exception e)
        {
            login_errorMessage = e.getMessage(); 
        }
    }
}