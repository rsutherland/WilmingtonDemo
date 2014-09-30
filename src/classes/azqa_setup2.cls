public with sharing class azqa_setup2 {
	public Question_Answer__c theRecord{get;set;}
	public Question_Answer__c theKey{get;set;}
	public string keyId {get;set;}
	public string key{get;set;}
	public string solkey{get;set;}
	public string newKey {get;set;}
	public boolean renderLST {get;set;}
	
	public azqa_setup2(){
	
	}
	public pagereference newKey(){
		recordtype r = [select id from recordtype where name = 'solution key'];
		Question_Answer__c n = new Question_Answer__c();
		n.Text__c = newKey;
		n.Parent_Solution__c = theRecord.id;
		n.recordtypeid = r.id; 
		insert n;
		keyId = n.id;
		selectkey();
		renderLST = true;
		return null;
	}
	
	public pagereference deleteKey(){
		delete theKey;
		List<SelectOption> options = getKeys();
		if (options.size() > 0){
			keyId = options[0].getValue();
			selectKey();
			renderLST = true;
		}else{
			renderLST = false;
			keyId=null;
			theKey=null;
			solkey=null;
		}
		return null;
	}
	
	public azqa_setup2(ApexPages.StandardController con){
		renderLST = false;
		theRecord = (Question_Answer__c) con.getRecord();
		List<SelectOption> options = getKeys();
		if (options.size() > 0){
			renderLST = true;
			keyId = options[0].getValue();
			selectKey();
		}
	}
	
	public list<Question_Answer__c> getQuestions(){
		return [Select Q.Id,Q.Name,Q.Session_Name__c, Q.RecordType.Name, Q.Text__c, ( Select Id,Name, Answer_Code__c, Text__c from Questions_Answers__r order by Answer_Code__c) from Question_Answer__c Q WHERE Q.RecordType.Name = 'question' AND session_name__c = : theRecord.Session_Name__c ORDER BY  name];	
	}
	
	public List<SelectOption> getKeys() {
		list<Question_Answer__c> lst = [Select Q.Id, q.name, Q.Text__c, Solution_Key_2__c from Question_Answer__c Q WHERE Q.RecordType.Name = 'solution key' AND parent_solution__c = : theRecord.id order by name];
		List<SelectOption> options = new List<SelectOption>();
		for (Question_Answer__c q : lst){
			options.add(new SelectOption(q.id,q.name + ' - ' + q.Text__c));
		}

        return options;
    }
	
	
	public pagereference selectKey(){
		theKey = [Select Q.Id, Q.Text__c, Solution_Key_2__c from Question_Answer__c Q WHERE id = : keyId];
		solkey = thekey.Solution_Key_2__c;
		return null;	
	}
	
	public pagereference updateKey(){
		system.debug('\n\n UPDATE KEY ' + key);
		thekey.Solution_Key_2__c = key;
		update theKey;
		return null;
	}
}