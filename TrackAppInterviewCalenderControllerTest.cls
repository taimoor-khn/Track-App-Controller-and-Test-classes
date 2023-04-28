@isTest(SeeAllData = false) 
public class TrackAppInterviewCalenderControllerTest {
    static List<List<String>> qas = new List<List<String>>
    {
        new List<String>{'Question 1', 'Answer 1','Wrong', 'Wrong'},
            new List<String>{'Question 2', 'Answer 2','Question 22', 'Answer 22'},
                new List<String>{'Question 3', 'Answer 3','Question 33', 'Answer 33'},
                    new List<String>{'Question ', 'Answer 3','Question 33', 'Answer 33'}
        
    };
        static account acc;
    static Candidate__c cand;
    //static Contact con;
    static Session__c sess;
    static Interview__c person1;
    
    static list<  Session__c> sessionList=new list<  Session__c>();
    static list<Candidate__c> candidateList=new list<Candidate__c>();
    static list<Interview__c> interViewesList=new list<Interview__c>();
    static list<Contact> contactList=new list<Contact>();
    static List<String> Interviewer = new List<String>{'Interviewer 1', 'Interviewer 2'};
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
        }
    
    //Delete Event case
    @isTest static void Case2() {
        Interview__c obj=[select Id, candidate__c from Interview__c limit 1];
        Test.startTest();
        TrackAppInterviewCalenderController.deleteEvent(obj.Id,'session');
        Test.stopTest();
    }
    @isTest static void Case3() {
        
        Test.startTest();
        TrackAppInterviewCalenderController.deleteEvent('1',null);
        Test.stopTest();
    }
    //
    @isTest static void Case4() {
        String conname=[select ID, Name from Contact limit 1].Id;
        list<string> conlist=new list<string>();
        conlist.add(conname);
        Interview__c obj=[select Id, candidate__c,Interview_Timing__c from Interview__c limit 1];
        system.debug('interview timg'+obj);
        String candidateName=[select Id, Name from Candidate__c limit 1].Id;
        Test.startTest();
        TrackAppInterviewCalenderController.createOrUpdateEvents(JSON.serialize(obj),candidateName,conlist,'session');
        Test.stopTest();
    }
    @isTest static void case5()
    {
        TrackAppInterviewCalenderController.getUserType('session',1);
    }
    @isTest static void case6()
    {
        TrackAppInterviewCalenderController.getUserType('session',2);
    } 
    @isTest static void case7()
    {
        TrackAppInterviewCalenderController.getUserType('sessio',2);
    }
    @isTest static void case8()
    {
        Interview__c obj=[SELECT Id, Name, Duration__c, Interview_Timing__c, Candidate__r.Name, 
                          Candidate__r.Id, Interviewer__r.Id, Interviewer__r.Name, Medium__c, 
                          Status_Progress__c, Type__c FROM Interview__c limit 1];
        TrackAppInterviewCalenderController.getUpdateEvent(obj.id,'session');
    }
    @isTest static void case9()
    {
        TrackAppInterviewCalenderController.getUpdateEvent('1','session');
    }
    @isTest static void case10()
    {
        TrackAppInterviewCalenderController.getInterviewers('session');
    }
    @isTest static void case11()
    {
        TrackAppInterviewCalenderController.getPickFields(1,'session');
    }
    @isTest static void case12()
    {
        TrackAppInterviewCalenderController.getPickFields(1,null);
    }
    @isTest static void case13()
    {
        TrackAppInterviewCalenderController.getQAs('I-0722');
    }
    @isTest static void case14()
    {
        TrackAppInterviewCalenderController.getQAs(null);
    }
    @isTest static void case15()
    {
        TrackAppInterviewCalenderController.saveQAs(qas);
    }
    @isTest static void case16()
    {
        TrackAppInterviewCalenderController.getCandidates('sessionid'); 
    }
    @isTest static void case17()
    {
        TrackAppInterviewCalenderController.reload();
        TrackAppInterviewCalenderController.getInterviewers(null);
    }
    
}