public class AATPaymentCallbackController {
	private string quoteId{
        get{
           return ApexPages.currentPage().getParameters().get('ref'); 
        }set;
    }
    public AATPaymentCallbackController() {}   
    
    public PageReference init() {
        //SAT-1947: Commenting below method
        //string shadowQuoteDetails = VonDBServices.GetShadowQuoteWithDetail(quoteId);     
        //string shadowQuoteDetailsWithPaymentId = shadowQuoteDetails.mid(0, shadowQuoteDetails.length()-1);
        if(ApexPages.currentPage().getParameters().get('refId')!='' && ApexPages.currentPage().getParameters().get('refId')!=null){
            string refId = ApexPages.currentPage().getParameters().get('refId');
        	//SAT-1947 : Adding below line
        	string shadowQuoteDetails = Q2CUtilities.getShadowQuoteJSON('PREAUTH',quoteId);
            HttpResponse res = new HttpResponse();
       		HttpResponse res1 = new HttpResponse();
            /***** temporary fix to Call IL for Default Payment Mehtod ******/           
            Q2CShadowQuote__c sq = Q2CDBServices.GetShadowQuote(quoteId);
	        //SAT-502 : Log SFDC IL Calls : START
	        Map<String,Id> objectIds = new Map<String,Id>();
	        objectIds.put('ShadowQuote',quoteId);
	        PageReference page2Naviagte = null;
            //res1= Q2CUtilities.CallIntegrationLayer('CREATEDEFAULTPAYMENTMETHOD','{"accountId":"'+sq.ZuoraAccountID__c+'","pmtMethodId":"'+refId+'"}');
            OutboundAPI oapi = new OutboundAPI();
	        oapi.objectIds = objectIds;
            oapi.createLog = false;
            oapi.ilp = new OutboundAPI.ILParameters('CREATEDEFAULTPAYMENTMETHOD','{"accountId":"'+sq.ZuoraAccountID__c+'","pmtMethodId":"'+refId+'"}');
            res1 = oapi.callILAPI();
            if(res1.getStatusCode()==200){
                //SAT-1947: PREAUTH change
            	//string shadowQuoteDetailsWithPaymentId = '{"shadowQuote":'+shadowQuoteDetails+',"paymentMethodId":"'+refId+'"}';
                string shadowQuoteDetailsWithPaymentId = '{'+
        						(ILAuthorization__c.getAll().get('PREAUTH').Send_Order_Info__c ? '"orderInfo":' : '"shadowQuote":')
        						+ shadowQuoteDetails + ',"paymentMethodId":"' + refId + '"}';

	            oapi = new OutboundAPI();
	        	oapi.objectIds = objectIds;
	            oapi.createLog = false;
	            oapi.ilp = new OutboundAPI.ILParameters('PREAUTH',shadowQuoteDetailsWithPaymentId);
	            res = oapi.callILAPI();
                //res = Q2CUtilities.CallIntegrationLayer('PREAUTH',shadowQuoteDetailsWithPaymentId);
                if(res.getStatusCode()==200){
                    updateShadowQuote();
                    page2Naviagte = new PageReference('/apex/AATOrderComplete?ref='+quoteId);
                    page2Naviagte.setRedirect(true);
                }else{
                    updateShadowQuote();
                    page2Naviagte = new PageReference('/apex/AATPaymentPage?ct=Visa&ref='+quoteId+'&err='+res.getStatus());
                    page2Naviagte.setRedirect(true);
                }
            }else {
            	updateShadowQuote();
                page2Naviagte = new PageReference('/apex/AATPaymentPage?ct=Visa&ref='+quoteId+'&err='+res1.getStatus());
                page2Naviagte.setRedirect(true);
            }
            VonLogUtility.flush();
            return page2Naviagte;
	        //SAT-502 : Log SFDC IL Calls : END
        }else{
            PageReference page2Naviagte = new PageReference('/apex/AATPaymentPage?ct=Visa&ref='+quoteId+'&err=CardError');
            page2Naviagte.setRedirect(true);
            return page2Naviagte; 
        }
    } 
    // Created by Manas on 06/08/2015
    public void updateShadowQuote()
    {
        Q2CShadowQuote__c sq2update = new Q2CShadowQuote__c(id=quoteId);
        sq2update.ZuoraPaymentID__c = ApexPages.currentPage().getParameters().get('refId');        
        update sq2update;
    }    
}