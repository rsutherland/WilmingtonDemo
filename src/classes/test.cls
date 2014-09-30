public with sharing class test{
	
	public String tabname {get;Set;}
	
	public test(){tabname=EncodingUtil.urlEncode(ApexPages.currentpage().getparameters().get('c'), 'UTF-8');
		String x = string.escapesinglequotes(ApexPages.currentpage().getparameters().get('c'));
}

}