@isTest(SeeAllData = false) 
public class TrackAppHrMainPageControllerTest
{
    public static Session__c sess;
    static account acc;
    static list<Contact> contactList=new list<Contact>();
    @testSetup
    static void setup() {
        acc=new Account();
        acc.Name='Testing Account';
        insert acc;
        
        ///contact list
        contact con1=new Contact();
        con1.LastName='Testing Contact 1';
        con1.AccountId=acc.Id;
        con1.User_type__c='Human Resources';
        con1.Position__c='Software Developer';
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
        
        //content version
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; 
        cVersion.PathOnClient = 'Temp.PDF';
        cVersion.Origin = 'H';
        cVersion.Title = 'Temp CV File';
        cVersion.VersionData = Blob.valueOf('Temp text');
        Insert cVersion;
        //vontent document link
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;
        cDocLink.LinkedEntityId = con1.Id;
        cDocLink.ShareType = 'I';
        cDocLink.Visibility = 'AllUsers';
        Insert cDocLink;
    }
    
    //
    @isTest static void Case1() {
        Session__c sesObj=[select id from Session__c limit 1];
        Contact conObj=[select id,LastName,User_type__c,Position__c,AccountId,Phone from contact limit 1];
        TrackAppHrMainPageController objClass=new TrackAppHrMainPageController();
        
        Test.startTest();
        objClass.userData=conObj;
        objClass.sessionID='session';
        objClass.getEditProfileData();
        
        Test.stopTest();
    }
    @isTest static void Case2() {
        Session__c sesObj=[select id from Session__c limit 1];
        Contact conObj=[select id,LastName,User_type__c,Position__c,AccountId,Phone from contact limit 1];
        TrackAppHrMainPageController objClass=new TrackAppHrMainPageController();
        Test.startTest();
        objClass.userData=conObj;
        objClass.getEditProfileData();
        
        Test.stopTest();
    }
    @isTest static void Case3() {
        Session__c sesObj=[select id from Session__c limit 1];
        Contact conObj=[select id,LastName,User_type__c,Position__c,AccountId,Phone from contact limit 1];
        TrackAppHrMainPageController objClass=new TrackAppHrMainPageController();
        Test.startTest();
        objClass.userData=conObj;
        objClass.sessionID='session';
        objClass.logout();
        Test.stopTest();
    }
    @isTest static void Case4() 
    {
        TrackAppHrMainPageController objClass=new TrackAppHrMainPageController();
        Test.startTest();
        objClass.sessionID='null';
        objClass.logout();
        Test.stopTest();
    }
    @isTest static void Case5() 
    {
        Session__c sesObj=[select id from Session__c limit 1];
        
        ContentVersion cvObj=[select id,ContentLocation,PathOnClient,Origin,Title,VersionData from ContentVersion limit 1];
        Contact conObj=[select id,LastName,User_type__c,Position__c,AccountId,Phone from contact limit 1];
        WrapperCandidateCV wrapper = new WrapperCandidateCV();
        wrapper.cvDetails = cvObj;
        wrapper.cvDetails.Title = 'Sample CV';
        wrapper.cvData = 'VGhpcyBpcyBhIHNhbXBsZSBjdmVyc2lvbiBzdHJpbmc=';
        
        WrapperCandidateCV.WrapperCVToJs cvToJs = new WrapperCandidateCV.WrapperCVToJs();
        cvToJs.title = wrapper.cvDetails.Title;
        cvToJs.b64VersionData = wrapper.cvData;
        cvToJs.FileType = 'pdf';
        TrackAppHrMainPageController objClass=new TrackAppHrMainPageController();
        Test.startTest();
        system.debug('--------------'+String.valueOf(conObj));
        objClass.toSaveProfileData=JSON.serialize(conObj);
        objClass.toSaveProfilePic='{"cvDetails":{"title":"LM_TAPortal_ProfilePic","PathOnClient":"LM_TAPortal_ProfilePic.png"},"cvData":"data:image/png;base64,tK17MYnEpT9RcL6XCpq0rXpBSQUR1Qij65VbIRBWLEO4ObRMbAyTnpJXKitmuRYAAAAASUVORK5CYII="}';
        // objClass.toSaveProfilePic=JSON.serialize(cvToJs);
        system.debug('qqqqqqqqqqqq'+  objClass.toSaveProfilePic);
        objClass.sessionID='session';
        objClass.saveProfileData();
        
        Test.stopTest();
    }
    
}