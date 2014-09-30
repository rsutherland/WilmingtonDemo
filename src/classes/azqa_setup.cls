public with sharing class azqa_setup{
	public Question_Answer__c theRecord{get;set;}
	public string key{get;set;}
	public azqa_setup(){
	
	}
	
	public azqa_setup(ApexPages.StandardController con){
		theRecord = (Question_Answer__c) con.getRecord();
	}
	
	public list<Question_Answer__c> getQuestions(){
		return [Select Q.Id,Q.Name,Q.Session_Name__c, Q.RecordType.Name, Q.Text__c, ( Select Id,Name, Answer_Code__c, Text__c from Questions_Answers__r order by Answer_Code__c) from Question_Answer__c Q WHERE Q.RecordType.Name = 'question' AND session_name__c = : theRecord.parent_solution__r.Session_Name__c ORDER BY  name];	
	}
	
	public pagereference updateKey(){
		system.debug('\n\n UPDATE KEY ' + key);
		therecord.Solution_Key_2__c = key;
		update theRecord;
		return null;
	}
	
}