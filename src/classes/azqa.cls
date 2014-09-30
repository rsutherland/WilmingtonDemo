public with sharing class azqa{
	public String sid {get;Set;}
	public String nextQid {get;Set;}
	public String answerId {get;Set;}
	public String questionId {get;Set;}
	public String sessionHistory{get;Set;}
	public String sessionHistory2{get;Set;}
	public String sessionHistory3{get;Set;}
	public list<Question_Answer__c> answers{get;Set;}
	public string currentQuestion {get;Set;}
	public Boolean solutionFound{get;Set;}
	public Question_Answer__c sol{get;Set;}
	 public azqa(){
	 	sid=ApexPages.currentpage().getparameters().get('id');
		currentquestion = theCurrentQuestion();
		Answers = theAnswers();
		 sessionHistory = '';
		  sessionHistory2 = '';
		 solutionFound = false;
		 sol=new Question_Answer__c();
	 }

	 public List<Question_Answer__c> getSessions(){
		 return [Select Q.Id, Next_Question__c, q.name,Q.Text__c from Question_Answer__c Q WHERE q.answer_supplied__c = null and Q.RecordType.Name = 'session' ORDER  by name];
	 }
	 
	 public string theCurrentQuestion(){
		 if(sid!=null){
			 System.debug('\n\nnextQid1 ' + nextQid);
			 System.debug('\n\nsid1 ' + sid);
			 if (nextQid == null || nextQid == sid){
				 Question_Answer__c s = [Select Q.Id, Next_Question__c, q.name,Q.Text__c from Question_Answer__c Q WHERE  Q.RecordType.Name = 'session' and Q.Id = : sid];
				 nextQid = s.Next_Question__c;
			 }else{
					 
			 }
			 System.debug('\n\nsid2 ' + sid);
			 System.debug('\n\nnextQid2 ' + nextQid);
			 Question_Answer__c q = [Select Q.Name, Q.Id, Q.Session_Name__c, Q.Text__c from Question_Answer__c Q WHERE Q.Id = : nextQid];
			 return q.Text__c;
		 }else{
			 return '';
		 }
	 }
	 public list<Question_Answer__c> theAnswers(){
		 if(sid!=null){
			  if (nextQid == null || nextQid == sid){
				 Question_Answer__c s = [Select Q.Id, Next_Question__c, q.name,Q.Text__c from Question_Answer__c Q WHERE  Q.RecordType.Name = 'session' and Q.Id = : sid];
				 nextQid = s.Next_Question__c;
			 }
			 System.debug('\n\nnextQid3 ' + nextQid);
			 return [Select Q.Name, Q.Id,Q.Parent_Question__r.Name, Q.Next_Question__c , Q.Text__c from Question_Answer__c Q WHERE Q.Parent_Question__c  = : nextQid];
		 }else{
			 return null; 
		 }
	 }
	 private String calculateSolution(){
		Map<String, Map<String, Map<String, String>>> answermap = new Map<String, Map<String, Map<String, String>>>();
		List<Question_Answer__c > sol = [Select Q.id, q.parent_solution__c, Q.Solution_Key_2__c from Question_Answer__c Q WHERE Q.RecordType.name = 'solution key' and q.parent_solution__r.session_name__c = : sid];
		for (Question_Answer__c q : sol){
			answermap.put(q.id, new map<String, Map<String, String>>());
			String temp = q.solution_key_2__c;
			List<String> questionAndAnswer = temp.split(',',0);
			for (String s : questionAndAnswer){
				if (answermap.get(q.id).containskey(s.split('=')[0])){
					answermap.get(q.id).get(s.split('=')[0]).put(s.split('=')[1],(s.split('=')[1]));
				}else{
					answermap.get(q.id).put(s.split('=')[0],new Map<String,String>());
					answermap.get(q.id).get(s.split('=')[0]).put(s.split('=')[1],(s.split('=')[1]));
				}
			}
		}
		List<String> answersGiven = sessionHistory3.split(',',0);
		List <String> solutionIdList = new List<String>();
		for (Question_Answer__c q : sol){
			//system.debug('\nstarting sol: ' + q.name);
			boolean useThisSolution = true;
			Map<String, Map<String, String>> qAnda = answermap.get(q.id);
			system.debug('\nqAnda.size() : ' + qAnda.size());
			for (String ag : answersGiven){
				system.debug('\nanswer given : ' + ag);
				if(qAnda.containskey(ag.split('=',0)[0])){
					system.debug('\nFound Question: ' + ag.split('=',0)[0]);
					if(!qAnda.get(ag.split('=',0)[0]).containskey(ag.split('=',0)[1])){
						useThisSolution = false;
						system.debug('\nuse=false: ' + ag.split('=',0)[1]);
					}
				}
			}
			if(useThisSolution){
				solutionIdList.add (q.parent_solution__c);	
			}
		}
		List <Question_Answer__c> solutionsFound = [Select Q.Id, Q.Solution_Text__c, Q.Text__c from Question_Answer__c Q where id in : solutionIdList];
		String txt = '';
		for (Question_Answer__c solution : solutionsFound){
			txt = txt + Solution.Solution_Text__c + ' ' ;
		}
		if (txt==''){
			txt = 'We were unable to find the correct advice for the combination of Answers provided, please contact your administrator.';
		}
		return txt;
	 }
	 public pagereference gotoNext(){
		 System.debug('\n\nnextQid4 ' + nextQid);
		 sessionHistory = sessionHistory + answerId + ',';
		 sessionHistory2 = sessionHistory2 + answerId + ',' ;
		 sessionHistory3 = sessionHistory3 + questionId + '=' + answerId + ',' ;
		 if (nextQid == null || nextQid == ''){
			 System.debug('\n\nsolution');
			 solutionFound=true;
			 currentquestion = 'Solution Found';
			 Answers = null;
			 List <Question_Answer__c> solutions = [Select Q.Name, Q.Id, Q.solution_text__c , Q.Text__c from Question_Answer__c Q WHERE Solution_Key__c = : sessionhistory]; //Q.id  = 'a022000000UXRpk'];
			 //if (solutions.size() > 0 ){
				 //sol=solutions[0];
				 sol = new Question_Answer__c();
				 sol.solution_text__c = calculateSolution();
				 sol.text__c = sol.solution_text__c;
				 
				 createpost();
			 //}else{
			//	 sol = new Question_Answer__c();
			//	 sol.solution_text__c = '<br/><br/><br/><br/>We were unable to find the correct advice for the combination of Answers provided, please contact your administrator.<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>';
			//	 sol.text__c = 'We were unable to find the correct advice for the combination of Answers provided, please contact your administrator.';
			//	 createpost();
			// }
		 }else{
			currentquestion = theCurrentQuestion();
		 	Answers = theAnswers();
		 }
		 return null;
	 }
	 
	 public void createpost(){
		FeedItem f = new FeedItem ();
		string s = sessionHistory ;
		s = s.replace(',','\',\'');
		 s=  '\'' + s;
		 s=s+'\'';
		 String q = 'Select Q.Parent_Question__c, Q.Parent_Question__r.Text__c, q.id, Q.Text__c from Question_Answer__c Q where Name in (' + s + ')';
		List <Question_Answer__c> qa = Database.query (q);
		//List <Question_Answer__c> qa = [Select Q.Parent_Question__r.Text__c, Q.Text__c from Question_Answer__c Q where Name in ( :s )];
		 String b = '';
		 List<Question_Answer__c> answersSupplied = new List<Question_Answer__c>();
		for (Question_Answer__c qaitem : qa){
			b = b + qaitem.Parent_Question__r.Text__c + ': ' + qaitem.text__c + '\n';
			Question_Answer__c ans = new Question_Answer__c();
			ans.answer_supplied__c = qaitem.parent_question__c;
			ans.text__c = qaitem.text__c;
			ans.session_name__c = sid;
			ans.RecordTypeId = '0122000000031RT';
			answersSupplied.add(ans);
		}
		insert answersSupplied;
		f.body = b;
		f.parentid = sid;//UserInfo.getUserId ();
		insert f;
		FeedComment fc = new FeedComment ();
		fc.feeditemid = f.id;
		fc.commentbody = sol.text__c;
		insert fc;
	 }
	 public pagereference startSession(){
		 return new apexpages.PageReference ('/apex/azqa_qa?id=' + sid);
	 }
	 
}