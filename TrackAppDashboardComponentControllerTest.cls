@isTest(SeeAllData = false) 
public class TrackAppDashboardComponentControllerTest {
    public static Session__c sess;
    static account acc;
    static list<Contact> contactList=new list<Contact>();
        static list<Candidate__c> candidateList=new list<Candidate__c>();
        static Interview__c person1;
        static list<Interview__c> interViewesList=new list<Interview__c>();
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
        
        Session__c sess2= new Session__c();
        sess2.Name='Testing Session';
        sess2.Contact__c=con2.Id;
        sess2.Unique_ID__c='session2';
        insert sess2;
        
        //candidate list
        Candidate__c cand1=new Candidate__c();
        cand1.Name='Testing Candidate Name 2';
        cand1.Email__c='Testing1@gmail.com';
        cand1.Phone__c='009870178019';
        cand1.Status__c='Hired';
        cand1.Degree_Title__c='Bs.Computer Science';
        candidateList.add(cand1);
        Candidate__c cand2=new Candidate__c();
        cand2.Name='Testing Candidate Name 2';
        cand2.Email__c='Testing2@gmail.com';
        cand2.Phone__c='009870178019';
        cand2.Status__c='In Evaluation';
        cand2.Degree_Title__c='Bs.Computer Englisj';
        candidateList.add(cand2);
        insert candidateList;
        
        //interview list
        person1=new Interview__c();
        // person1.Name='Testing Interview';
        person1.Candidate__c=cand2.Id;
        person1.Interviewer__c=con1.Id;
        person1.Duration__c='15';
        person1.Status_Progress__c='Scheduled';
        DateTime now = System.now();
        
        person1.Interview_Timing__c=now.addDays(1);
        person1.Type__c='Interview 1';
        interViewesList.add(person1);
        
        Interview__c person2=new Interview__c();
        // person2.Name='Testing Interview';
        person2.Candidate__c=cand2.Id;
        person2.Interviewer__c=con1.Id;
        person2.Duration__c='15';
        person2.Status_Progress__c='Scheduled';
        //D/at now = System.now();
        
        person2.Interview_Timing__c=now.addDays(1);
        person2.Type__c='Interview 1';
        interViewesList.add(person2);
        insert interViewesList;
        
        //interview question
        Interview_Questions_Answers__c qa=new Interview_Questions_Answers__c ();
        qa.Question__c='What is your hobby?';
        qa.Answer__c='Playing Video Games.';
        qa.Interview__c=person1.id;
        insert qa;
        
        //content version
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; 
        cVersion.PathOnClient = 'Temp.PDF';
        cVersion.Origin = 'H';
        cVersion.Title = 'Temp CV File';
        cVersion.VersionData = Blob.valueOf('Temp text');
        Insert cVersion;
        
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;

        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;
        cDocLink.LinkedEntityId = con1.Id;
        cDocLink.ShareType = 'I';
        cDocLink.Visibility = 'AllUsers';
        Insert cDocLink;
    }
    @isTest static void Case1() {
        Session__c sesObj=[select id from Session__c limit 1];
        Contact conObj=[select id,LastName,User_type__c,Position__c,AccountId,Phone from contact limit 1];
        TrackAppDashboardComponentController objClass=new TrackAppDashboardComponentController();
        Test.startTest();
        objClass.userData=conObj;
        objClass.sessionID='session';
        objClass.loadDashboardData();
        Test.stopTest();
    }
     @isTest static void Case2() {
        Session__c sesObj=[select id from Session__c limit 1];
        Contact conObj=[select id,LastName,User_type__c,Position__c,AccountId,Phone from contact limit 1];
         system.debug('wwwwwwwwwwwwww'+conObj);
        TrackAppDashboardComponentController objClass=new TrackAppDashboardComponentController();
        Test.startTest();
        objClass.userData=conObj;
        objClass.sessionID='session';
        objClass.loadDashboardData();
        Test.stopTest();
    }
     @isTest static void Case3() {
        Session__c sesObj=[select id from Session__c limit 1];
        Contact conObj=[select id,LastName,User_type__c,Position__c,AccountId,Phone from contact where User_Type__c=:'Interviewers' limit 1];
         system.debug('wwwwwwwwwwwwww'+conObj);
        TrackAppDashboardComponentController objClass=new TrackAppDashboardComponentController();
        Test.startTest();
        objClass.userData=conObj;
        objClass.sessionID='session2';
        objClass.loadDashboardData();
        Test.stopTest();
    }
    @isTest static void Case4() {
        TrackAppDashboardComponentController objClass=new TrackAppDashboardComponentController();
        Test.startTest();
        objClass.loadDashboardData();
        Test.stopTest();
    }
}