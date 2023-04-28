@isTest(SeeAllData = false) 
public class TrackAppLoginPageControllerTest {
    static list<Contact> contactList=new list<Contact>();
    static account acc;
    public static Session__c sess;
    @testSetup
    static void setup()
    {
        acc=new Account();
        acc.Name='Testing Account';
        insert acc;
        
        ///contact list
        contact con1=new Contact();
        con1.LastName='Testing Contact 1';
        con1.AccountId=acc.Id;
        con1.User_type__c='Human Resources';
        con1.Position__c='Software Developer';
        con1.Email='testing@gmail.com';
        con1.Password__c='testing';
        contactList.add(con1);
        contact con2=new Contact();
        con2.LastName='Testing Contact 2';
        con2.AccountId=acc.Id;
        con2.Position__c='Software Developer';
        con2.User_type__c='Interviewers';
        contactList.add(con2);
        insert contactList;
        //session
        sess= new Session__c();
        sess.Name='Testing Session';
        sess.Contact__c=con1.Id;
        sess.Unique_ID__c='session';
        insert sess;
    }
    @isTest static void Case1() 
    {
        TrackAppLoginPageController objClass=new TrackAppLoginPageController();
        Test.startTest();
        objClass.email='testing@gmail.com';
        objClass.password='testing';
        objClass.LoginApproval();
        Test.stopTest();
    }
    @isTest static void Case2() 
    {
        Test.startTest();
        TrackAppLoginPageController.reDirectPage('session');
        Test.stopTest();
    }
    @isTest static void Case3() 
    {
        Test.startTest();
        TrackAppLoginPageController.reDirectPage('session-wrong');
        Test.stopTest();
    }
    @isTest static void Case4() 
    {
        TrackAppLoginPageController objClass=new TrackAppLoginPageController();
        
        Test.startTest();
        objClass.sessionID='session';
        objClass.logout();
        Test.stopTest();
    }
    @isTest static void Case5() 
    {
        TrackAppLoginPageController objClass=new TrackAppLoginPageController();
        Test.startTest();
        objClass.sessionID='sessio';
        objClass.logout();
        Test.stopTest();
    }
    @isTest static void Case6() 
    {
        TrackAppLoginPageController objClass=new TrackAppLoginPageController();
        Test.startTest();
        objClass.sessionID='session';
        objClass.login_checkSessionId();
        Test.stopTest();
    }
      @isTest static void Case7() 
    {
        TrackAppLoginPageController objClass=new TrackAppLoginPageController();
        Test.startTest();
        objClass.sessionID='session';
        objClass.resetPassword_email='testing@gmail.com';
        objClass.resetPassword_newPassword='resetpassword';
        objClass.resetPassword_sendOTP();
        Test.stopTest();
    }
      @isTest static void Case8() 
    {
        TrackAppLoginPageController objClass=new TrackAppLoginPageController();
        Test.startTest();
        objClass.sessionID='session';
        objClass.resetPassword_email='';
        objClass.resetPassword_newPassword='resetpassword';
        objClass.resetPassword_sendOTP();
        Test.stopTest();
    }
          @isTest static void Case9() 
    {
        TrackAppLoginPageController objClass=new TrackAppLoginPageController();
        Test.startTest();
        objClass.sessionID='session';
        objClass.resetPassword_email='testing@gmail.com';
        objClass.resetPassword_newPassword='resetpassword';
        objClass.resetPassword_otp='1234';
        objClass.resetPassword_resetPassword();
        Test.stopTest();
    }
}